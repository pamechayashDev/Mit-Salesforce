import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import TIME_ZONE from '@salesforce/i18n/timeZone';
const CONTACT_FIELDS = ['Account.PersonEmail', 'Account.PersonDepartment', 'Account.Institution__pc', 'Account.Name', 'Account.PersonTitle']

export default class DisplayData extends NavigationMixin(LightningElement) {
    @api index;
    @api accData;
    @api appData;
    @api relatedListsData;
    @api piData;
    @api tloData;
    @api signatureCard;
    timeZone = TIME_ZONE;

    contactId;
    contact;
    isInventor = false;
    isDepHead = false;
    isSignature = false;
    error;
    departmentAndInstitutionData = false;
    inventorSignedStatus = false;

    displayApp = false;
    displayAcc = false;
    displayRelatedLists = false;
    displayRelatedContact = false;

    get shouldDisplay() {
        return this.index <= 2;
    }

    determineCardType() {
        if (this.accData) {
            this.displayAcc = true;
        }

        if (this.appData) {
            this.displayApp = true;
        }

        if (this.relatedListsData) {
            this.contactId = this.relatedListsData.fields.Contact__c.value;

            this.isInventor = this.relatedListsData.apiName === "DisclosureInventor__c" ? true : false;
            this.inventorSignedStatus = this.isInventor ? (this.relatedListsData.fields?.Signed_Status__c?.value ?? 'Pending') !== 'Pending' : false;

            this.isDepHead = this.relatedListsData.apiName === "Department_Head__c" ? true : false;
            this.displayRelatedLists = true;
        }

        if (this.tloData) {
            this.displayRelatedContact = true;
        }

        if (this.signatureCard) {
            this.isSignature = true;
        }
    }

    @wire(getRecord, { recordId: '$contactId', fields: CONTACT_FIELDS })
    handleDisclosure({ error, data }) {
        if (data) {
            this.contact = data;
            if (this.contact.fields.Institution__pc.value && this.contact.fields.PersonDepartment.value) {
                this.departmentAndInstitutionData = true;
            }
        } else if (error) {
            console.log(error)
        }
    }

    navigateToTloContactDetails(event) {
        event.preventDefault();
        let contactId = event.target.id.split('-');
        contactId = contactId[0];

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    navigateToInventorDetails(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.relatedListsData.id,
                objectApiName: 'DisclosureInventor__c',
                actionName: 'view'
            },
        });
    }

    connectedCallback() {
        this.determineCardType();
    }
}