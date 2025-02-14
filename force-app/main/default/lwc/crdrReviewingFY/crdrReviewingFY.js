/**
 * Created by Andreas du Preez on 2024/04/30.
 */

import { api, LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ['Forrester_SHIR_AGREEMENT_VIEW__x.REVIEWING_FY__c'];

export default class CrdrReviewingFy extends LightningElement {

    @api recordId;
    reviewingFY = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    async handleGetRecord({ error, data }) {
        if (error) {
            console.error(error);
        } else if (data) {
            this.reviewingFY = data.fields.REVIEWING_FY__c?.value;
        }
    }
}