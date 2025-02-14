import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getDisclosureReasonPicklist from "@salesforce/apex/DisclosureRecordFetch.getDisclosureReasonPicklist";
import { getCopyrightData, getUserData } from 'c/utils';

import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS, longTextFieldsFromApiPicklist } from 'c/utils';

import Materials_Header_TechnicalDescription from '@salesforce/label/c.Materials_Header_TechnicalDescription';

export default class CopyrightDetails extends NavigationMixin(LightningElement) {
    CLABEL__TechDisc = Materials_Header_TechnicalDescription;

    @api recordId;

    disclosureData;
    recordData;
    userData;
    disclosureReasonList;

    loading = true;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.userId = this.disclosureData.lastModifiedById;

            this.recordData = await getCopyrightData(this.recordId);
            this.userData = await getUserData(this.userId);
            this.getPicklistValues();

            this.loading = false;
        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

    get docCardTitle() {
        return this.CLABEL__TechDisc;
    }

    get documentQueryType() {
        return DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION;
    }

    async getPicklistValues() {
        try {
            const result = await getDisclosureReasonPicklist();

            this.disclosureReasonList = longTextFieldsFromApiPicklist(result, this.disclosureData.fields.Disclosure_Reason__c?.value);
        } catch (error) {
            console.error(error);
        }
    }

    get shouldRenderOtherComment() {
        return this.disclosureReasonList?.includes('Other') ? true : false;
    }

    navigateToUserDetails(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.userData.Id,
                objectApiName: 'User',
                actionName: 'view'
            },
        });
    }
}