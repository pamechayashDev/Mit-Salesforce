import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS, getBioTangData, getUserData, longTextFieldsFromApiPicklist } from 'c/utils';
import Disclosure_Documents_Header_TechnicalDescription from '@salesforce/label/c.Disclosure_Documents_Header_TechnicalDescription';
import getDisclosureReasonPicklist from '@salesforce/apex/DisclosureRecordFetch.getDisclosureReasonPicklist';


export default class BioTangDetails extends NavigationMixin(LightningElement) {
    @api recordId;

    disclosureData;
    recordData;
    userData;
    loading = true;

    disclosureReasonList;

    CLABEL__TechDisc = Disclosure_Documents_Header_TechnicalDescription;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.userId = this.disclosureData.lastModifiedById;

            this.recordData = await getBioTangData(this.recordId);
            this.userData = await getUserData(this.userId);
            this.getPicklistValues();

            this.loading = false;
        } else if (error) {
            console.log(error)
            console.log(error.body.message)
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