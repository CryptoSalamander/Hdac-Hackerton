import Web3 from 'web3';

let web3;

export const URL_WEB3_PROVIDER = 'http://localhost:9545';

export const web3Provider = function() {
    if (!!web3) {
        web3 = new Web3(web3.currentProvider);
    } else {
        web3 = new Web3(new Web3.providers.HttpProvider(URL_WEB3_PROVIDER));
    }

    // TODO return null when web3 provider is not given
    // if (!!!web3.givenProvider) {
    //     return null;
    // }

    return web3;
}();
