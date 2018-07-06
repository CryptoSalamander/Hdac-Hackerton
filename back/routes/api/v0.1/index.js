import express from 'express';
import contract from './contract';
import account from './account';
import contractInterface from './interface';
import {web3Provider as web3} from '../../../util/util';

const router = express.Router();

router.use('/*', (req, res, next) => {
    if (!!!web3) {
        console.error(`-----\tweb3 is not provied\t-----\n-----\tPlease, check testRPC or geth status\t-----`);

        return res.status(500).json({
            code: '500',
            msg: 'web3 is not provided'
        });
    }
    next();
});

router.use('/contract', contract);
router.use('/account', account);
router.use('/interface', contractInterface);

module.exports = router;