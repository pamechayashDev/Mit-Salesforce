import { LightningElement, api, wire, track } from "lwc";
import LightningAlert from 'lightning/alert';
import LightningConfirm from 'lightning/confirm';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { errorToList } from "c/forresterUtils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import markCompleteTLOContactUpdateRequestById from "@salesforce/apex/DisclosureRecordFetch.markCompleteTLOContactUpdateRequestById";

export default class TloContactUpdateRequestComplete extends LightningElement {
    UPDATE_FIELDS = [
        'TLO_Contact_Update_Request__c.Id',
        'TLO_Contact_Update_Request__c.Update_Status__c',
        'TLO_Contact_Update_Request__c.Disclosure__c',
        'TLO_Contact_Update_Request__c.Contact__c'
    ]

    @track requestData
    loading = true
    error = false

    @api recordId;
    @api async invoke(self) {
        console.log(`Action on recordId ${this.recordId}`);
        this.loading = false

        const result = await LightningConfirm.open({
            message: 'Please confirm that you manually updated the contacts with the suggested details.',
            theme: 'success',
            label: 'Mark Complete',
            // setting theme would have no effect
        });
        if (result) {
            this.loading = true
            await markCompleteTLOContactUpdateRequestById({ id: this.recordId }).then(() => {
                // Done
                this.loading = false
                self.closeQuickAction()
                self.showSuccessToast()
                self.refreshView()
            }).catch(error => {
                this.loading = false
                console.error(error)
                LightningAlert.open({
                    // Get Trigger Validation message
                    message: errorToList(error),
                    theme: 'error',
                    label: 'Mark Complete',
                }).then(function () {
                    console.log('alert is closed');
                    self.closeQuickAction()
                });
            })
        } else {
            self.closeQuickAction()
        }


    }

    @wire(getRecord, { recordId: '$recordId', fields: '$UPDATE_FIELDS' })
    async handleAction({ error, data }) {
        this.error = false
        this.loading = true
        if (data) {
            console.debug('[UPDATE REQUEST]', data);
            this.requestData = data;
            this.invoke(this)

        } else if (error) {
            console.log(error);
            console.log(error.body.message);
            this.error = error;
            this.loading = false
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    refreshView() {
        const myMessage = () => {
            eval("$A.get('e.force:refreshView').fire();");
        }
        setTimeout(myMessage, 2000);
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Mark Complete',
            message: 'Record updated',
            variant: 'success',
        });
        this.dispatchEvent(evt);

    }
}