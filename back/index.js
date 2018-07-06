import express from 'express';
import http from 'http';
import bodyParser from 'body-parser';

import index from './routes/api/v0.1/index';

import {ContractManager, contractInstances} from './Contract/contract.manager';

let app = express();

app.use(bodyParser.json());
// TODO: app.set(%front files%)

/**
 * allow CROS
 */
app.all('/*', (req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "*");
    next();
});

app.use('/block-in/api', index);

let server = http.createServer(app).listen(80, function () {
    console.log('server running port : ' + 80);
});
