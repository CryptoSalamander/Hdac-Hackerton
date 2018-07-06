import express from 'express';
import {getAccounts, createAccount, getBalance} from '../../../Account/account';

const router = express.Router();

router.get('/', (req, res) => {
    getAccounts()
    .then((accounts) => {
        res.status(200).json({
            code: 200,
            msg: 'Success to load accounts',
            accounts: accounts
        });
    });
});

router.get('/getBalance', (req, res) => {
    const account = req.query.account;

    getBalance(account)
    .then((balance) => {
        res.status(200).json({
            code: 200,
            msg: 'Success to get Balance',
            account_address: account,
            balance: balance
        });
    })
    .catch((error) => {
        res.status(400).json({
            code: 400,
            msg: error
        })
    });
});

router.post('/create', (req, res) => {
    const password = req.body.password;

    createAccount(password)
    .then((accounts) => {
        res.status(200).json({
            code: 200,
            msg: 'Success to create new Account',
            accounts: accounts
        })
    })
    .catch((error) => {
        res.status(300).json({
            code: 300,
            msg: 'Failed to create new Account',
            error: error
        });
    })
});

module.exports = router;
