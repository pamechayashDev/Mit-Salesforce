import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { DISCLOSURE_FIELDS } from 'c/utils';

import getTLOOfficerById from "@salesforce/apex/DisclosureRecordFetch.getTLOOfficerById";

export default class TloOfficerCard extends NavigationMixin(LightningElement) {
    @api recordId;

    tloOfficerData;
    error;
    loading;

    async getOfficerDetails() {
        this.error = false
        this.loading = true
        try {
            let res = await getTLOOfficerById({ tloId: this.disclosureData.fields.TLO_License_Officer__c.value })
            if (res) {
                this.tloOfficerData = res;
            }
        } catch (error) {
            this.error = error;
            console.log(error);

        }
        this.loading = false
    }

    get tloOfficerName() {
        return this.tloOfficerData ? this.tloOfficerData.Name : '';
    }

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        this.error = false
        this.loading = true
        if (data) {
            this.disclosureData = data;
            this.getOfficerDetails();

        } else if (error) {
            console.log(error);
            console.log(error.body.message);
            this.error = error;
            this.loading = false
        }
    }

    navigateToOfficerDetails(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.tloOfficerData.Id,
                objectApiName: 'TLO_Officer__c',
                actionName: 'view'
            },
        });
    }
}