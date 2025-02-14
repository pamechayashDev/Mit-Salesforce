import { LightningElement, api, wire, track } from "lwc";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi'

import { peopleSearch, ACCOUNT_FIELDS } from 'c/utils'

import GuestUserImage from '@salesforce/resourceUrl/GuestUserImage'
import getImageContent from '@salesforce/apex/AwsApiCall.getImageContent'
import getCurrentIPIARecord from '@salesforce/apex/IPIAController.getCurrentIPIARecord'
import msgService from "@salesforce/messageChannel/ipiaCurrentChange__c";
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe } from "lightning/messageService";

export default class PersonHeader extends LightningElement {
    @api recordId
    @api mitIdField
    @api nameField
    @api institutionField
    @api contactRecIdField

    record
    peopleSearchFields = {}
    @track currentIPIA = {};
    loading = true
    error = false

    profilePic = GuestUserImage

    resource
    // TODO: Remove before go live
    apiName

    connectedCallback() {
        this.subscribeHandler();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record
            // TODO: Remove before go live
            this.apiName = record?.data?.apiName
            Promise.all([
                this.getPeopleSearchFields(),
                this.getProfilePic(),
                this.getCurrentIPIA()
            ]).then(() => {
                this.loading = false
            })
        }
        if (record.error) {
            this.error = true
        }
    }

    get mitId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.mitIdField)
        }
        return null
    }

    get name() {
        if (this.record) {
            return getFieldValue(this.record.data, this.nameField)
        }
        return null
    }

    get institution() {
        if (this.record) {
            return getFieldValue(this.record.data, this.institutionField)
        }
        return null
    }

    get contactRecId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.contactRecIdField)
        }
        return null
    }

    clearFields() {
        this.peopleSearchFields = {}
    }

    async getProfilePic() {
        try {
            const apiName = 'accountApi'
            const res = await getImageContent({
                api: apiName,
                resource: `/user/picture?mitId=${this.mitId}&resolution=low`
            })
            let finalResult = JSON.parse(res)
            this.profilePic =
                finalResult?.hasPicture && finalResult?.url
                    ? finalResult?.url
                    : GuestUserImage
            return false
        } catch (error) {
            console.error(error)
            this.error = true
            return false
        }
    }

    async getPeopleSearchFields() {
        this.clearFields()
        if (this.mitId) {
            let { searchResults, error } = await peopleSearch(this.mitId)

            if (searchResults && searchResults.length > 0) {
                this.peopleSearchFields = searchResults[0]
            } else {
                this.noMitId()
            }
            if (error) {
                console.error(error)
                this.error = true
            }
        } else {
            this.noMitId()
        }
    }

    async getCurrentIPIA() {
        // Get the current IPIA record
        let currentIPIA = await getCurrentIPIARecord({ mitId: this.mitId })

        if (currentIPIA) {
            this.currentIPIA.SignDatetime = currentIPIA.SignDatetime__c;
            this.currentIPIA.IPIATypeNameExemption = ` ${currentIPIA.IPIA_Type__r?.Name ?? currentIPIA.FormName__c}${currentIPIA.IPIA_Type__r?.Exemption__c ? " (Exemption)" : ""}${currentIPIA.IPIA_Type__r?.Status__c && currentIPIA.IPIA_Type__r?.Status__c !== 'Active' ? ` - ${currentIPIA.IPIA_Type__r?.Status__c}` : ""}`;
        }
        else {
            this.currentIPIA = {};
        }
    }

    noMitId() {
        // No MIT Id (guest), add fields from SF
        this.peopleSearchFields = {
            institution: this.institution
        }
    }

    // Event handlers
    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    handleMessage(message){
        if (message.mitId === this.mitId) {
            this.getCurrentIPIA();
        }
    }
}