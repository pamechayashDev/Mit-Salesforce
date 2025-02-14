/**
 * Created by Andreas du Preez on 2024/04/03.
 */

import { api, LightningElement, wire } from "lwc";
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    {
        fieldApiName: 'MINIMUM_DUE_DATE__c',
        objectApiName:'Forrester_SHIR_AGREEMENT_VIEW__x'
    },
    {
        fieldApiName: 'ROYALTY_YEAR_BEGIN_DATE__c',
        objectApiName:'Forrester_SHIR_AGREEMENT_VIEW__x'
    },
];

export default class AgreementRoyaltyTermsRecordFields extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS, optionalFields: FIELDS})
    agreementRecord;

    get getMinimumDueDate() {
        return this.agreementRecord.data?.fields?.MINIMUM_DUE_DATE__c?.displayValue?.split(' ')[0] ?? '';
    }

    get getRoyaltyYearBeginDate() {
        return this.agreementRecord.data?.fields?.ROYALTY_YEAR_BEGIN_DATE__c?.displayValue?.split(' ')[0] ?? '';
    }
}