import express from 'express';
import {ContractManager} from '../../../Contract/contract.manager';

const router = express.Router();

router.get('/', (req, res) => {
    const blockin = new ContractManager({name: req.query.name});
    const contractInstance = blockin.getContractInstance();

    if (!!contractInstance) {
        return res.status(200).json({
            'methods': Object.keys(contractInstance.methods),
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

router.post('/send', (req, res) => {
    const blockin = new ContractManager({name: req.body.name});
    const param = req.body.param;
    const method = req.body.method;
    const from = req.body.from; // cookie로 변경해야함.
    const gas = req.body.gas;
    const contractInstance = blockin.getContractInstance();

    if (!!contractInstance) {
        contractInstance.methods[`${method}`](...param)
        .send({
            from: from,
            gas: gas
        })
        .then((ret) => {
            return res.status(200).json({
                ret,
                'code': 200
            });
        })
        .catch((error) => {
            console.log(error);
            return res.status(500).json({
                code: 500,
                msg: error
            });
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

router.post('/call', (req, res) => {
    const blockin = new ContractManager({name: req.body.name});
    const param = req.body.param;
    const method = req.body.method;
    const from = req.body.from;    // cookie로 변경해야함.
    const contractInstance = blockin.getContractInstance();

    if (!!contractInstance) {
        contractInstance.methods[`${method}`](...param)
        .call({
            from: from
        })
        .then((ret) => {
            return res.status(200).json({
                ret,
                'code': 200
            });
        })
        .catch((error) => {
            return res.status(500).json({
                code: 500,
                msg: error
            });
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