import express from 'express';
import {ContractManager} from '../../../Contract/contract.manager';
import {web3Provider as web3} from '../../../util/util';

const router = express.Router();

let option = {
    owner: 1,
    gas: 4712388,
    price: 100000000000,
    filename: 'hdac',
    name: 'hdac',
    address: '',
    abi: '',
    isDeployed: false
};

const isDeployed = false;

(async function () {
    if (!!!web3) {
        console.error(`-----\tweb3 is not provied\t-----\n-----\tPlease, check testRPC or geth status\t-----`);
        return;
    }

    const contractBlockin = new ContractManager(option);
    await contractBlockin.deploy()
    .catch((error) => {
        console.error(error);
    });
})();

router.get('/', (req, res) => {
    const blockin = new ContractManager({name: req.query.name});
    const metadata = blockin.getContractMetadata();

    if (!!metadata) {
        return res.status(200).json({
            metadata,
            'code': 200
        });
    } else {
        return res.status(404).json({
            code: 404,
            msg: `Cannot find contract instance.
            It might be not deployed yet.
            Please, request this api again few seconds later.`
        });
    }
});

module.exports = router;
