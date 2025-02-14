import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS, longTextFieldsFromApiPicklist, getSoftwareCodeData, getUserData } from 'c/utils';
import Common_title from '@salesforce/label/c.Common_title';
import Common_lastModifiedBy from '@salesforce/label/c.Common_lastModifiedBy';
import Disclosure_Documents_Header_TechnicalDescription from '@salesforce/label/c.Disclosure_Documents_Header_TechnicalDescription';
import getDisclosureReasonPicklist from '@salesforce/apex/DisclosureRecordFetch.getDisclosureReasonPicklist';

export default class SoftwareDetails extends NavigationMixin(LightningElement) {
  CLABEL__Common_title = Common_title;
  CLABEL__Common_lastModifiedBy = Common_lastModifiedBy;
  CLABEL__TechDisc = Disclosure_Documents_Header_TechnicalDescription;

  @api recordId;

  disclosureData;
  recordData;
  userData;

  loading = true;
  disclosureReasonList;

  @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
  async handleDisclosure({ error, data }) {
    if (data) {
      console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
      this.disclosureData = data;
      this.userId = this.disclosureData.lastModifiedById;

      this.recordData = await getSoftwareCodeData(this.recordId);
      this.userData = await getUserData(this.userId);
      await this.getPicklistValues();

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

  get hasSoftwareCategorization() {
    if (!this.recordData.Software_Categorization__c) return false;
    return this.recordData.Software_Categorization__c.length > 0 ? true : false;
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

  get shouldRenderOtherComment() {
    return this.disclosureReasonList?.includes('Other') ? true : false;
  }

  get technicalDocumentQueryType() {
    return DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION;
  }

  get softwareDocumentQueryType() {
    return DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE;
  }

  async getPicklistValues() {
    try {
      const res = await getDisclosureReasonPicklist();

      this.disclosureReasonList = longTextFieldsFromApiPicklist(res, this.disclosureData.fields.Disclosure_Reason__c?.value ?? '');

    } catch (error) {
      console.error(error);
    }
  }
}