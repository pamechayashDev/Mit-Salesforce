import { LightningElement, api, wire, track } from "lwc";
import LightningAlert from 'lightning/alert';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { errorToList } from "c/forresterUtils";
import rejectTLOContactUpdateRequestById from "@salesforce/apex/DisclosureRecordFetch.rejectTLOContactUpdateRequestById";

export default class TloContactUpdateRequestReject extends LightningElement {


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

        await rejectTLOContactUpdateRequestById({ id: this.recordId }).then(() => {
            LightningAlert.open({
                message: 'Update request rejected',
                theme: 'success',
                label: 'Reject Update Request',
            }).then(function () {
                console.log('alert is closed');
                if (self) {
                    self.closeQuickAction()
                    self.refreshView()
                }
            });

        }).catch(error => {
            LightningAlert.open({
                message: errorToList(error),
                theme: 'error',
                label: 'Reject Update Request',
            }).then(function () {
                console.log('alert is closed');
                if (self) {
                    self.closeQuickAction()
                }
            });
        })
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$UPDATE_FIELDS' })
    async handleAction({ error, data }) {
        this.error = false
        this.loading = true
        if (data) {
            console.log(data);
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
}