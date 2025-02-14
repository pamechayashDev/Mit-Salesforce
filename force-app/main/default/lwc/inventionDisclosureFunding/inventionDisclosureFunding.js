import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import { DISCLOSURE_FIELDS  } from 'c/utils';

export default class InventionDisclosureDisclosure extends LightningElement {
    @api recordId;

    disclosureData;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }
}