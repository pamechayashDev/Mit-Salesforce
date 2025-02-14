import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getBioTangData } from 'c/utils';

import { DISCLOSURE_FIELDS } from 'c/utils';

export default class BioTangFunding extends LightningElement {
    @api recordId;

    disclosureData;
    recordData;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        // this.reset();
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.recordData = await getBioTangData(this.recordId);
        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }
    }
}