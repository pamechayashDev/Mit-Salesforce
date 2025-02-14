import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

import globalStyles from '@salesforce/resourceUrl/globalStyles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

const DEP_HEAD_FIELDS = ['Department_Head__c.Contact__c'];
export default class DepartmentHeads extends NavigationMixin(LightningElement) {
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
    depHeadData;
    piData;
    error;

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: '$relatedListId',
        fields: DEP_HEAD_FIELDS,
    }) depHeadListInfo({ error, data }) {
        this.loading = true;
        if (data) {
            if (data.records.length > 0) {
                this.noResults = false;
            }
            this.depHeadData = data.records;
            this.loading = false;
            this.profileAmt = this.depHeadData.length > 3 ? '3+' : this.depHeadData.length;
            this.error = undefined;
        } else if (error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
            console.log("ERROR: ", this.error);
            this.depHeadData = undefined;
            this.noResults = true;
            this.loading = false;
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