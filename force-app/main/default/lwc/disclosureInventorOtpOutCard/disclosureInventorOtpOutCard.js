import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { getRecord } from 'lightning/uiRecordApi';

const DISCLOSURE_INVENTOR_FIELDS = [
    'DisclosureInventor__c.Signed_Status__c',
    'DisclosureInventor__c.Signed_Comment__c'
]

export default class DisclosureRejectionCard extends NavigationMixin(LightningElement) {
    @api recordId;

    rejectionReason;
    rejectionData = null;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_INVENTOR_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.loadingCaseNumber = true;
            this.rejectionData = data;
            this.rejectionReason = data.fields.Signed_Comment__c.value;
                        
        } else if (error) {
            console.error(error)
        }
    }

    get isRejected() {
        if (!this.rejectionData) return false;

        if (this.rejectionData && this.rejectionData.fields.Signed_Status__c?.value === 'Opted Out') {
            return true;
        }
        return false;
    }
}