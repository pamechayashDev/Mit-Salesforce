import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getThirdPartyCodeBySoftwareCodeId from '@salesforce/apex/DisclosureRecordFetch.getThirdPartyCodeBySoftwareCodeId';
import getOpenSourceBySoftwareCodeId from '@salesforce/apex/DisclosureRecordFetch.getOpenSourceBySoftwareCodeId';
import { getRecord } from 'lightning/uiRecordApi';
import { DISCLOSURE_FIELDS, getSoftwareCodeData, DOCUMENT_CLASSIFICATIONS } from 'c/utils';

export default class SoftwareDisclosureTab extends NavigationMixin(LightningElement) {
    @api recordId;
    disclosureData;
    recordData;

    thirdPartyList = [];
    thirdPartyFullList = [];
    loadingThirdParty = true;
    errorThirdParty = false;
    noThirdParty = false;

    openSourceData = {};
    loadingOpenSource = false;
    errorOpenSource = false;
    noOpenSource = false;
    displayOpenSource = false;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.recordData = await getSoftwareCodeData(this.recordId);

            this.getOpenSourceData();
            this.getThirdPartyList();

        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

    get documentQueryType() {
        return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE;
    }

    get openSourceValue() {
        if (!this.recordData?.Is_Open_Source_YN__c) return '';
        return this.recordData.Is_Open_Source_YN__c ?? ''
    }

    get thirdPartyCodeCount() {
        return this.thirdPartyFullList?.length ?? 0;
    }

    get yearPublished() {
        if (!this.recordData?.Years_Code_First_Published__c) return '';
        return this.recordData.Years_Code_First_Published__c ?? ''
    }
    get yearCreated() {
        if (!this.recordData?.Years_Code_First_Created__c) return '';
        return this.recordData.Years_Code_First_Created__c ?? ''
    }

    get render3rdPartyDetails() {
        if (this.recordData?.Use_Any_Third_Party_Code__c === 'No') return false;
        return true;
    }

    get renderDisclosureSubmittedComment() {
        if (!this.recordData?.Derivative__c) return false;
        return this.recordData?.Derivative__c === 'Yes, internally developed and MIT-owned' ? true : false;
    }

    get disclosureSubmittedComment() {
        if (!this.recordData?.Derivative__c) return '';
        return this.recordData.Existing_Disclosure_Comment__c ?? '';
    }

    get distributeMethodValue() {
        return this.recordData?.Is_Open_Source_YN__c === 'No' ? this.recordData?.Open_Source_Comment__c : 'N/A'
    }

    async getOpenSourceData() {
        this.loadingOpenSource = true;
        this.errorOpenSource = false;

        if (!this.recordData) return;
        try {
            let res = await getOpenSourceBySoftwareCodeId({ softwareDisclosureId: this.recordData.Id })
            if (res.length <= 0) {
                this.noOpenSource = true;
            }
            if (res.length > 0) {
                this.noOpenSource = false;
                this.openSourceData = res[0];
            }
            if(this.recordData.Is_Open_Source_YN__c !== undefined && this.recordData.Is_Open_Source_YN__c != '') {
                this.displayOpenSource = true;
            }
        }
        catch (error) {
            this.errorOpenSource = true;
            console.log(error);
        }
        this.loadingOpenSource = false;
    }

    get isLicenseOther() {
        if (this.openSourceData.Open_Source_Licensing_Type__c === 'Other') {
            return true
        }
        return false
    }

    async getThirdPartyList() {
        if (!this.recordData) return;
        this.loadingThirdParty = true;
        this.errorThirdParty = false;
        this.noThirdParty = false;

        try {
            let res = await getThirdPartyCodeBySoftwareCodeId({ softwareDisclosureId: this.recordData.Id })
            if (res.length <= 0) {
                this.noThirdParty = true;
            }
            this.thirdPartyFullList = res
            this.thirdPartyList = res?.slice(0, 2);

        } catch (error) {
            console.log(error);
            this.errorThirdParty = true;

        }
        this.loadingThirdParty = false;
    }


    get trainingDataSourceList() {
        if (!this.recordData.Source_of_Training_Data__c) return [];
        return this.recordData.Source_of_Training_Data__c.split(';') ?? [];
    }

    get aiDeveloped() {
        if (!this.recordData?.Encompass_AI_Or_Machine_Learning__c) return '';
        return this.recordData.Encompass_AI_Or_Machine_Learning__c ?? '';
    }

    get softwareTypeDetails() {
        if (!this.recordData?.Software_Type_Details__c) return '';
        return this.recordData.Software_Type_Details__c ?? '';
    }

    get isSoftwareDerivativeDetails() {
        if (!this.recordData?.Derivative__c) return '';
        return this.recordData.Derivative__c ?? '';
    }

    get algoOrPatentableDetails() {
        if (!this.recordData?.Algorithm_or_Patentable_Invention__c) return '';
        return this.recordData.Algorithm_or_Patentable_Invention__c ?? '';
    }

    get sourceOfTrainingDetails() {
        if (!this.recordData?.Source_of_Training_Details__c) return '';
        return this.recordData.Source_of_Training_Details__c ?? '';
    }

    get thirdPartyCodeUsed() {
        return this.recordData?.Use_Any_Third_Party_Code__c ?? '';
    }

    get partOfEmployment() {
        if (!this.recordData?.Part_Of_Employment_YN__c) return '';
        return this.recordData.Part_Of_Employment_YN__c ?? '';
    }

    get renderOpenSourceComment() {

        if (this.openSourceData?.Open_Source_Licensing_Type__c === 'Other' && this.recordData.Is_Open_Source_YN__c === 'Yes') {
            return true;
        }
        return false;
    }

    get openSourceLicenseType() {
        return this.recordData?.Is_Open_Source_YN__c === 'Yes' ? this.openSourceData?.Open_Source_Licensing_Type__c : 'N/A';
    }

    navigateToAllThirdParty(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordData.Id,
                objectApiName: 'Software_Disclosure__c',
                relationshipApiName: 'Third_Party_Code__r',
                actionName: 'view'
            },
        });
    }
}