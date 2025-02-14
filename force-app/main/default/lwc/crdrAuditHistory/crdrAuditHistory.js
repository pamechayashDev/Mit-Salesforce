import { api, LightningElement, wire } from "lwc";
import msgService from "@salesforce/messageChannel/crdrStatusChange__c";
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe } from "lightning/messageService";
import getContainerObjectIdDS from '@salesforce/apex/ExternalObjectRepository.getContainerObjectId';
import getCaseCRDRAuditEventsDS from '@salesforce/apex/CrdrController.getCaseCRDRAuditEvents';
import { refreshApex } from "@salesforce/apex";
import TIME_ZONE from '@salesforce/i18n/timeZone';

const caseCrdrExternalObjectName = 'Forrester_SHIR_CRDR_VIEW__x';
const caseCrdrExternalObjectRecIdFieldName = 'CASE_CRDR_RECID__c';
const caseCrdrContainerObjectName = 'CASE_CRDR__c';
const caseCrdrContainerObjectRecIdFieldName = 'ExternalCaseCRDRId__c';
const cmpListenForMessagesFrom = 'crdrPathAssistant';

const AVAILABLE_STATUSES = {
    AWAITING_DRAFT: 'AWAITING_DRAFT',
    DRAFT: 'DRAFT',
    IN_REVIEW: 'IN_REVIEW',
    APPROVED: 'APPROVED',
    FINALIZED: 'FINALIZED'
};

export default class crdrAuditHistory extends LightningElement {
    @api recordId;
    containerObjectId;
    externalCaseCRDRId;
    containerRcdName;
    loading = true;
    auditEvents = [];
    messageSubscription;
    crdrAuditHistoryWireResult;
    isLoading = true;
    timeZone = TIME_ZONE;

    caseCrdrExternalObjectName = caseCrdrExternalObjectName;
    caseCrdrExternalObjectRecIdFieldName = caseCrdrExternalObjectRecIdFieldName;
    caseCrdrContainerObjectName = caseCrdrContainerObjectName;
    caseCrdrContainerObjectRecIdFieldName = caseCrdrContainerObjectRecIdFieldName;

    connectedCallback() {
        this.subscribeHandler();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }
   
    // Wire functions
    @wire(getContainerObjectIdDS, {
        externalObjRecId: '$recordId',
        externalObjApiName: '$caseCrdrExternalObjectName',
        externalObjRecIdFieldName: '$caseCrdrExternalObjectRecIdFieldName',
        matchingContainerObject: '$caseCrdrContainerObjectName',
        containerObjRecIdFieldName: '$caseCrdrContainerObjectRecIdFieldName'
    })
    async handleLoadData({ data, error }) {
        if (data) {
            this.containerObjectId = data.Id;
            this.externalCaseCRDRId = data.ExternalCaseCRDRId__c;
            this.containerRcdName = data.Name;
        }
        if (error) {
            console.error(error);
            this.isLoading = false;
        }
    }

    @wire(getCaseCRDRAuditEventsDS, {
        caseCrdrId: '$containerObjectId'
    })
    getCaseCRDRAuditEvents(wireResult) {
        const { data, error } = wireResult;
        this.crdrAuditHistoryWireResult = wireResult;

        if (data) {
            let clonedData = JSON.parse(JSON.stringify(data));

            clonedData.forEach(record => {
                if (record.Message__c?.includes('{')) {

                    // Get the value inside curly braces by substring the value from Message__c
                    let placeholderValue = record.Message__c.substring(record.Message__c.indexOf('{') + 1, record.Message__c.indexOf('}'));
                    let placeholderValues = placeholderValue.split(';');
                    record.url = `/lightning/r/${placeholderValues[0]}/view`;
                    record.urlDisplayMessage = placeholderValues[1];
                    record.displayMessage = record.Message__c.replace(`{${placeholderValue}}`, '');
                }
                else {
                    record.displayMessage = record.Message__c ?? '';
                }

                record.iconName = this.getIconName(record.Status__c, record.Subject__c);
                record.Subject__c = record.Subject__c ?? record.Status__c;
            });

            this.auditEvents = clonedData;
            this.isLoading = false;
        }
        else if (error) {
            console.error('Error retrieving Case CRDR Audit History:' , error);
            this.isLoading = false;
        }
    }

    @wire(MessageContext)
    messageContext;

    // Event handlers
    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    handleMessage(message){
        if (message.origin === cmpListenForMessagesFrom && message.caseCrdrId === this.recordId && message.statusChanged === true) {
            refreshApex(this.crdrAuditHistoryWireResult);
        }
    }

    getIconName(eventType, subject) {
        switch (eventType) {
            case AVAILABLE_STATUSES.AWAITING_DRAFT:
                if (subject?.includes('Adjustment')) {
                    return 'standard:product_request_line_item';
                }
                return 'standard:task';
            case AVAILABLE_STATUSES.DRAFT:
                return 'standard:task';
            case AVAILABLE_STATUSES.IN_REVIEW:
            case AVAILABLE_STATUSES.APPROVED:
            case AVAILABLE_STATUSES.FINALIZED:
                return 'standard:approval';
            default:
                return 'standard:task';
        }
    }
}