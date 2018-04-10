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

import fs = require('fs');
import cheerio = require('cheerio');
import { identifierName } from '@angular/compiler';

export class MDCodeExtractor {
    static extract(filepath: string) {
        const $ = cheerio.load(fs.readFileSync(filepath, 'UTF8'));

        const codeBlocks = {};

        $('code-block').each((i, el) => {

            let type = $(el).attr('type');
            let subType = $(el).attr('sub-type');
            let identifier = $(el).attr('identifier');
            let text = $(el).text().trim();

            if (!type) {
                console.warn(`code-block: ${text} \ndoes not contain a type attribute, not adding to set.`);
                return;
            } else if (!subType) {
                console.warn(`code-block: ${text} \ndoes not contain a sub-type attribute, not adding to set.`);
                return;
            }else if (!identifier) {
                console.warn(`code-block: ${text} \ndoes not contain an identifier attribute, not adding to set.`);
                return;
            }

            if (!codeBlocks.hasOwnProperty(type)) {
                codeBlocks[type] = {};
            }

            if (!codeBlocks[type].hasOwnProperty(subType)) {
                codeBlocks[type][subType] = {};
            }

            codeBlocks[type][subType][identifier] = text;
        });

        return codeBlocks;
    }
}
