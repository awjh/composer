#!/usr/bin/env node

'use strict';

const argv = require('yargs')
    .option('p', {
        alias: 'port',
        demand: false,
        default: process.env.PORT || 8080,
        type: 'number',
        describe: 'The port to start composer on'
    })
    .option('t', {
        alias: 'test',
        demand: false,
        default: false
    })
    .argv;

const Logger = require('composer-common').Logger;
const util = require('util');

Logger.setFunctionalLogger({
    log: (level, method, msg, args) => {
        args = args || [];
        let formattedArguments = args.map((arg) => {
            if (arg === Object(arg)) {
                // It's an object, array, or function, so serialize it as JSON.
                try {
                    return JSON.stringify(arg);
                } catch (e) {
                    return arg;
                }
            } else {
                return arg;
            }
        }).join(', ');
        switch (level) {
        case 'debug':
            return console.log(util.format('%s %s %s', method, msg, formattedArguments));
        case 'warn':
            return console.warn(util.format('%s %s %s', method, msg, formattedArguments));
        case 'info':
            return console.info(util.format('%s %s %s', method, msg, formattedArguments));
        case 'verbose':
            return console.log(util.format('%s %s %s', method, msg, formattedArguments));
        case 'error':
            return console.error(util.format('%s %s %s', method, msg, formattedArguments));
        }
    }
});

const app = require('composer-playground-api')(argv.port, argv.test);
const express = require('express');
const isDocker = require('is-docker');
const opener = require('opener');
const path = require('path');

if (process.env.COMPOSER_CONFIG) {
    const config = JSON.parse(process.env.COMPOSER_CONFIG);
    app.get('/config.json', (req, res, next) => {
        res.json(config);
    });
}

const dist = path.resolve(__dirname, 'dist');
app.use(express.static(dist));
app.all('/*', (req, res, next) => {
    res.sendFile('index.html', {
        root: dist
    });
});

const LOG = Logger.getLog('Composer');

const method = 'main';
LOG.entry(method);

if (!isDocker()) {
    opener(`http://localhost:${argv.port}`);
}
