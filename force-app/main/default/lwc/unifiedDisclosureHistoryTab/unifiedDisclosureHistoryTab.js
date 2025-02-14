import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getDisclosureAuditEventsByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getDisclosureAuditEventsByDisclosureId';
import Disclosure_DAE_noHistories from '@salesforce/label/c.Disclosure_DAE_noHistories';
import Disclosure_DAE_failedFetch from '@salesforce/label/c.Disclosure_DAE_failedFetch';

const DISCLOSURE_FIELDS = [
    'Disclosure__c.Name',
];
export default class UnifiedDisclosureHistoryTab extends LightningElement {
    @api recordId;

    CLABLE__Disclosure_DAE_noHistories = Disclosure_DAE_noHistories;
    CLABLE__Disclosure_DAE_failedFetch = Disclosure_DAE_failedFetch;

    loading = true;

    elementData = {};
    disclosureData = {};

    auditHistories = [];
    noAuditHistories = false;
    historiesLength = 0;

    disclosureType = '';
    error = false;
    fetchErrorText = '';

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        this.loading = true;
        if (data) {
            this.error = false;

            try {
                let res = await getDisclosureAuditEventsByDisclosureId({ disclosureId: data.id })
                if (res.length > 0) {
                    //cater for zero indexing
                    this.historiesLength = res.length - 1;
                    this.auditHistories = res.sort((b, a) => {
                        return new Date(b.Event_Date__c) - new Date(a.Event_Date__c);
                    });
                    this.noAuditHistories = false;
                    console.log(`%c [HISTORIES]`, `color: green`, res);
                } else {
                    this.noAuditHistories = true;
                    this.auditHistories = [];
                }

            } catch (historiesError) {
                this.error = true;
                this.fetchErrorText = Disclosure_DAE_failedFetch;
            }

            this.disclosureType = data.recordTypeInfo.name;
            this.disclosureData = data;
            this.loading = false;

        } else if (error) {
            console.log(error)
            this.loading = false;
            this.error = true;
            this.fetchErrorText = 'Failed to load data for this disclosure';
        }
    }
}