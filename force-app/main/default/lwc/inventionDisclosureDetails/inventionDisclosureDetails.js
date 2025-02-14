import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getInventionData, getUserData, longTextFieldsFromApiPicklist } from 'c/utils';

import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS } from 'c/utils';

import getDisclosureReasonPicklist from "@salesforce/apex/DisclosureRecordFetch.getDisclosureReasonPicklist";


import Common_title from '@salesforce/label/c.Common_title';
import Common_lastModifiedBy from '@salesforce/label/c.Common_lastModifiedBy';

import Disclosure_Documents_Header_TechnicalDescription from '@salesforce/label/c.Disclosure_Documents_Header_TechnicalDescription';

export default class InventionDisclosureDetails extends NavigationMixin(LightningElement) {
    CLABEL__Common_title = Common_title;
    CLABEL__Common_lastModifiedBy = Common_lastModifiedBy;
    CLABEL__TechDisc = Disclosure_Documents_Header_TechnicalDescription;

    @api recordId;

    disclosureData;
    recordData;
    userData;
    loading = true;

    disclosureReasonList;

    lastEditedUserDetails = {};

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.userId = this.disclosureData.lastModifiedById;

            this.recordData = await getInventionData(this.recordId);
            this.userData = await getUserData(this.userId);
            this.getPicklistValues();

            this.loading = false;
        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
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

    get docCardTitle() {
        return this.CLABEL__TechDisc;
    }

    get documentQueryType() {
        return DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION;
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