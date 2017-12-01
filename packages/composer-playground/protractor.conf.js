/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


'use strict';

/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */

// Protractor conf file
let os = require('os');
let SpecReporter = require('jasmine-spec-reporter').SpecReporter;

exports.config = {
    allScriptsTimeout: 20000,
    framework: 'jasmine',
    directConnect: true,
    baseUrl: 'http://127.0.0.1:3001',
    specs: ['./e2e/specs/welcome.spec.ts',
        './e2e/specs/login-define.spec.ts'
    ],
    capabilities: {
        'browserName': 'chrome',
        'chromeOptions': {
            prefs: {
                download: {
                    'prompt_for_download': false,
                    'directory_upgrade': true,
                    'default_directory': './e2e/downloads'
                }
            }
        }
    },
    jasmineNodeOpts: {
        showColors: true,
        defaultTimeoutInterval: 60000
    },
    beforeLaunch: function() {
        require('ts-node').register({
            project: './tsconfig.json'
        });
    },
    onPrepare: function() {
        jasmine.getEnv().addReporter(new SpecReporter({
            displayStacktrace: 'all'
        }));
        browser.manage().window().setSize(1280, 1024);
    }
};
