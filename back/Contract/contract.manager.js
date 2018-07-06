import solc from 'solc';
import fs from 'fs';
import path from 'path';

import {getOwnerAccountByIndex} from '../Account/account';

import {web3Provider as web3} from '../util/util';

export let instances = {};
const CONTARCT_DIR = path.resolve(__dirname, '../../../solidity');

let findContract = (pathname) => {
    const contractPath = path.resolve(CONTARCT_DIR, pathname);
    console.log(contractPath);
    if (isContract(contractPath)) {
        return fs.readFileSync(contractPath, 'utf8');
    } else {
        throw new Error(`File ${contractPath} not found`);
    }
};

let isContract = (pathname) =>  {
    return fs.existsSync(pathname);
};

export class ContractManager {
    /**
    *  @param {Object} option options for creating and deploying new contracts
    *  @param {string} option.owner a eth Account who creates new contracts
    *  @param {Number} option.gas a gas 
    *  @param {Number} option.price gas prices for each etherium 
    *  @param {string} option.filename a solidity file(.sol) path
    *  @param {string} option.name a contract name
    */
    constructor(option) {
        if (!!instances[option.name]) {
            return instances[option.name];
        }

        if (option.isDeployed) {
            loadContractInstance ();
            return;
        }

        this.owner = option.owner;
        this.gas = option.gas;
        this.price = option.price;
        this.filename = option.filename;
        this.name = option.name;

        this.abi = null;
        this.bytecode = null;
        this.address = null;
        this.contractInstance = null;
    }

    setContractOwner(owner) {
        this.owner = owner;
    }

    compileSolidity () {
        if(!!!this.name) {
            console.error('-----\tFailed to resolve a Solidity file name\t-----');
            console.error('-----\tReceived Solidity file name is empty\t-----');
            return false;
        }

        const pathContract = path.resolve(CONTARCT_DIR, `${this.filename}.sol`);
        let input = {};
        let code = fs.readFileSync(pathContract, 'utf8');
        input[`${this.filename}.sol`] = code;
        
        let compiled = solc.compile({ sources: input }, 1, this.findImports);

        compiled = !!this.name? compiled.contracts[`${this.filename}.sol:${this.name}`]: compiled.contracts;

        if (!!!compiled){
            console.error(`-----\tFailed to Compile Solidity file (PATH : ${pathContract})\t-----`);
            return false;
        }
        
        if (!!!compiled.interface || !!!compiled.bytecode) {
            console.error(`-----\tCannot find properties (interface of bytecode) from ${this.name} contract. (PATH : ${pathContract})\t-----`);
            return false;
        }

        this.abi = compiled.interface;
        this.bytecode = compiled.bytecode;
        console.log(`-----\tSuccess to Compile Contract File (NAME: ${this.name})\t-----`);
        return true;
    }

    findImports(pathname) {
        try {
            return { contents: findContract(pathname) };
        } catch(e) {
            return { error: e.message };
        }
    }

    deploy () {
        return new Promise(async (resolve, reject) => {
            if(!!!web3) {
                reject(`-----\tCannot deploy ${this.name}\t-----`);
            }

            if (!!!this.abi || !!!this.bytecode){
                console.error(`-----\tCannot find compiled Contract\t-----`);
                console.error(`-----\tNow compiling Contract File (NAME : ${this.name})\t-----`);

                if (!this.compileSolidity()) return;
            }
    
            if (typeof this.owner !== 'string' || !this.owner.startsWith('0x')) 
                this.owner = await getOwnerAccountByIndex(this.owner);
    
            const Contract = new web3.eth.Contract(JSON.parse(this.abi), this.owner);
            Contract.deploy({
                data: `0x${this.bytecode}`,
                arguments: []
            })
            .send({
                from: this.owner,
                gas: this.gas,
                gasPrice: this.price
            })
            .on('error', error => {
                console.error(`-----\tCannot deploy ${this.name}\t-----`);
                console.error(error);
                reject(error);
            })
            .then((contractInstance) => {
                console.log(`-----\t Success to deploy, contractInstance : ${contractInstance} \t-----`);
                this.address = contractInstance.options.address;
                instances[this.name] = this;
                this.contractInstance = contractInstance;
                resolve({
                    address: this.address,
                    abi: this.abi
                });
            });
        });
    }

    getContractInstance () {
        console.log(`-----\t call contract instancd \t-----`);
        console.log(`-----\t ${this.contractInstance} \t-----`);
        console.log(`-----\t ${this.contractInstance.options} \t-----`);
        console.log(`-----\t ${this.contractInstance.options.address} \t-----`);
        return this.contractInstance;
    }

    getContractMetadata () {
        if (!!this.address) {
            return {
                address: this.address,
                abi: this.abi
            };
        } else {
            console.error(`-----\tCannot found a ${this.name} contract instance\t-----`);
            return null;
        }
    }

    loadContractInstance () {
        this.name = this.name;
        this.abi = this.abi;
        this.address = this.address;
        this.contractInstance = new web3.eth.Contract(this.abi, this.address);
        instances[this.name] = this;
    }
}