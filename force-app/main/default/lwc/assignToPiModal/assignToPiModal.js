import { LightningElement, api, track, wire } from 'lwc'
import getChildBipsData from '@salesforce/apex/getChildBips.getChildBipsData'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import UpdateBipPiRecords from '@salesforce/apex/UpdateBipPi.UpdateBipPiRecords'
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import msgService from "@salesforce/messageChannel/bipRequestStatusChange__c";
import { MessageContext, publish } from "lightning/messageService";


export default class AssignToPiModal extends LightningElement {
    open
    value = ['Request background case review from proposal']
    @api recordId
    @track childList = []
    comment = ''
    commentMap = {}
    selectMap = {}

    isLoading = false

    @wire(MessageContext)
    messageContext;

    @api invoke() {
        this.childList = []
        console.log('invoke ', this.recordId)
        this.open = true

        getChildBipsData({ recId: this.recordId }).then((res) => {
            let childs = res.childs
            for (let i = 0; i < childs.length; i++) {
                this.childList.push({
                    label: childs[i].PI__r.Name,
                    value: childs[i].Id,
                    Id: childs[i].Id,
                    selectedActions: [],
                    comments: ''
                })
            }

            console.log('childList--', this.childList)
            console.log('res-------', res)
        })
    }
    
    get options() {
        return [
            {
                label: 'Request background case review from proposal',
                value: 'Request background case review from proposal'
            },
            {
                label: 'Report undisclosed background IP',
                value: 'Report undisclosed background IP'
            }
        ]
    }

    handleClose() {
        this.open = false
    }

    handleCheckboxChange(event) {
        const recordId = event.target.dataset.id

        const selectedActions = event.detail.value

        this.childList = this.childList.map((record) => {
            return record.Id === recordId
                ? { ...record, selectedActions }
                : record
        })
        console.log(this.childList)
    }

    handleCommentChange(event) {
        const recordId = event.target.dataset.id
        const comments = event.target.value
        this.childList = this.childList.map((record) => {
            return record.Id === recordId ? { ...record, comments } : record
        })
        console.log(this.childList)
    }

    handleContinue() {
        this.isLoading = true
        let objList = []

        for (let i = 0; i < this.childList.length; i++) {
            let obj = {}
            obj.Id = this.childList[i].Id
            let selectedActionStr = this.childList[i].selectedActions.join(';')
            obj.selectedActions = selectedActionStr
            obj.comments = this.childList[i].comments
            objList.push(obj)
        }

        UpdateBipPiRecords({
            records: objList
        }).then((res) => {
            console.log(res)
            if (res === 'success') {
                notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                this.publishStatusChangeMessage();

                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Records Updated Successfully',
                    variant: 'success',
                    mode: 'dismissable'
                })
                this.dispatchEvent(event)
                this.isLoading = false
                this.open = false
            }
        })
    }

    publishStatusChangeMessage() {
        publish(this.messageContext, msgService, {
            id: this.recordId
        });
    }
}