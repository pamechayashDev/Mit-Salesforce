import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getRecord } from 'lightning/uiRecordApi'
import { refreshApex } from '@salesforce/apex';

import globalStyles from '@salesforce/resourceUrl/globalStyles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import DisclosureAddInventorModal from 'c/disclosureAddInventorModal';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import DISCLOSURE_INVENTOR_OBJECT from '@salesforce/schema/DisclosureInventor__c'

const INVENTOR_FIELDS = ['DisclosureInventor__c.Contact__c', 'DisclosureInventor__c.Signed_Status__c', 'DisclosureInventor__c.PrimaryInventor__c', 'DisclosureInventor__c.Signed_Disclosure_Date__c'];

export default class DisclosureRelatedCards extends NavigationMixin(LightningElement) {
    // Target Configs API
    @api cardIcon;
    @api cardTitle;
    @api relatedListId;

    // Disclosure Record Id
    @api recordId;

    // Custom Variables
    loading;
    noResults = true;
    profileAmt;
    relatedListsData;
    error;
    isSignature = false;
    createableInventor = false;
    isApproved = false

    determineCardType() {
        if (this.cardTitle === 'Signature' || this.cardTitle === 'Signatures') {
            this.isSignature = true;
        }
    }


    // Can Create new Inventor
    @wire(getObjectInfo, { objectApiName: DISCLOSURE_INVENTOR_OBJECT })
    disclosureInventorInfo({ data, error }) {
        if (data) {
            console.log(data.fields)
            this.createableInventor = data.fields.Contact__c?.createable === true
            console.log(`createableInventor: ${this.createableInventor}`)
        } else if (error) {
            this.error = 'Unknown error';
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Disclosure__c.Id', 'Disclosure__c.Status__c']
    })
    handleDisclosureGetRecord({ data, error }) {
        if (data) {
            this.isApproved = data.fields.Status__c.value === 'Approved' ? true : false
        }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: '$relatedListId',
        fields: INVENTOR_FIELDS,
    })
    listInfo({ error, data }) {
        this.loading = true;
        this.determineCardType();
        if (data) {
            if (data.records.length > 0) {
                this.noResults = false;
            }
            this.relatedListsData = data.records;
            this.loading = false;
            this.profileAmt = this.relatedListsData.length > 3 ? '3+' : this.relatedListsData.length;
            this.error = undefined;
        } else if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            console.log("ERROR: ", this.error);
            this.relatedListsData = undefined;
            this.noResults = true;
            this.loading = false;
        }
    }

    get isNewDisabled() {
        console.log(`canCreateInventor: ${this.createableInventor}`)
        console.log(`isApproved: ${this.isApproved}`)
        return !(this.isApproved && this.createableInventor)
    }

    async handleNewClick() {
        const result = await DisclosureAddInventorModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            recordId: this.recordId
            // content: 'Passed into content api',
        });
        console.log(result)
        if (result === 'Success') {
            // Refresh LWC data when added
            refreshApex(this.relatedListsData) // Does not work? Next line is workaround
            // eslint-disable-next-line no-restricted-globals
            location.reload()
        }
    }

    navigateToAll() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Disclosure__c',
                relationshipApiName: this.relatedListId,
                actionName: 'view'
            },
        });
    }

    connectedCallback() {
        loadStyle(this, globalStyles);
    }
}