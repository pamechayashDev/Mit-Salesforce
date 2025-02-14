/**
 * Created by Andreas du Preez on 2024/03/14.
 */

import { api, LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext, subscribe, APPLICATION_SCOPE, unsubscribe } from 'lightning/messageService';
import msgService from "@salesforce/messageChannel/crdrStatusChange__c";
import getContainerObjectId from '@salesforce/apex/ExternalObjectRepository.getContainerObjectId';
import createTaskDS from '@salesforce/apex/TaskHelper.createTask';
import updateMultipleCaseCRDRStatusDS from '@salesforce/apex/CrdrController.updateMultipleCaseCRDRStatus';
import crdrPathAssistantModal from 'c/crdrPathAssistantModal';
import CASE_CRDR_OBJECT from '@salesforce/schema/Case_CRDR__c';
import CASE_CRDR_STATUS_PICKLIST from '@salesforce/schema/Case_CRDR__c.Status__c';
import CASE_CRDR_ID_FIELD from '@salesforce/schema/Case_CRDR__c.Id';
import checkPermissions from '@salesforce/apex/CrdrController.checkPermissions';


const caseCrdrExternalObjectName = 'Forrester_SHIR_CRDR_VIEW__x';
const caseCrdrExternalObjectRecIdFieldName = 'CASE_CRDR_RECID__c';
const caseCrdrContainerObjectName = 'CASE_CRDR__c';
const caseCrdrContainerObjectRecIdFieldName = 'ExternalCaseCRDRId__c';
const thisCmpMsgServiceOrigin = 'crdrPathAssistant';

const CASE_CRDR__c_FIELDS = [
    'CASE_CRDR__c.Status__c'
];

const AVAILABLE_STATUSES = {
    AWAITING_DRAFT: 'AWAITING_DRAFT',
    DRAFT: 'DRAFT',
    IN_REVIEW: 'IN_REVIEW',
    APPROVED: 'APPROVED',
    FINALIZED: 'FINALIZED'
};
const DISABLE_STEP_ON = [AVAILABLE_STATUSES.AWAITING_DRAFT, AVAILABLE_STATUSES.APPROVED, AVAILABLE_STATUSES.FINALIZED];
const OPEN_MODAL_STEP_ON = [AVAILABLE_STATUSES.IN_REVIEW];

export default class crdrPathAssistant extends LightningElement {

    @api recordId;
    currentStep;
    stepList = [];
    containerObjectId;
    externalCaseCRDRId;
    containerRcdName;
    isLoading = true;
    getCaseCRDRRecordResult;
    hasPermission = false;

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
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: CASE_CRDR_STATUS_PICKLIST })
    picklistResults({ error, data }) {
        if (data) {
            this.stepList = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.stepList = [];
            console.log('Failed to retrieve Case_CRDR__c.Status__c picklist values. Error: ', error);
        }
    }

    @wire(checkPermissions, { recordId: '$recordId' })
    async wiredCheckPermissions({ data, error }) {
        if (data) {
            this.hasPermission = data.hasPermission;
        } else if (error) {
            // Handle error
            console.error('Error checking permissions:', error);
        }
    }

    @wire(getContainerObjectId, {
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

    @wire(getRecord, { recordId: '$containerObjectId', fields: CASE_CRDR__c_FIELDS })
    handleCRDR(wireResult) {
        this.isLoading = true;
        const { data, error } = wireResult;
        this.getCaseCRDRRecordResult = wireResult;

        if (data) {
            this.currentStep = data.fields.Status__c?.value;
            this.isLoading = false;
        } else if (error) {
            console.error(error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error retrieving Status',
                    message: error,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        }
    }

    @wire(MessageContext)
    messageContext;

    // Helper functions
    async updateCaseCRDRStatus(stepValue) {
        // Create the recordInput object
        const fields = {};
        fields[CASE_CRDR_ID_FIELD.fieldApiName] = this.containerObjectId;
        fields[CASE_CRDR_STATUS_PICKLIST.fieldApiName] = stepValue;
        const recordInput = { fields };

        return updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status updated',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.publishStatusChangeMessage();
                return refreshApex(this.getCaseCRDRRecordResult);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    createTask(commentValue) {
        createTaskDS({
            whatId: this.containerObjectId,
            subject: 'Rerun Draft CRDR',
            relatedSObjectAPIName: CASE_CRDR_OBJECT.objectApiName,
            priority: 'Normal',
            status: 'Not Started',
            comment: commentValue,
            groupDeveloperName: 'Finance_Queue',
            groupType: 'Queue'
        })
            .then((taskId) => {
                console.log('Task created with Id: ', taskId);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Task record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    async updateMultipleCaseCRDRStatus(caseCrdrIds, statusValue) {
        return updateMultipleCaseCRDRStatusDS({
            caseCrdrIdList: caseCrdrIds,
            newStatus: statusValue
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Status updated',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.publishStatusChangeMessage();
                return refreshApex(this.getCaseCRDRRecordResult);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating multiple Case_CRDR__c records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    // Getter functions
    get checkPathStepDisabled() {
        return DISABLE_STEP_ON.includes(this.currentStep) || !this.containerObjectId;
    }

    get getShowStatusFooterCard() {
        return this.currentStep === AVAILABLE_STATUSES.AWAITING_DRAFT || this.currentStep === AVAILABLE_STATUSES.APPROVED;
    }

    get getStatusFooterHeading() {
        switch (this.currentStep) {
            case AVAILABLE_STATUSES.AWAITING_DRAFT:
                return 'Awaiting Draft';
            case AVAILABLE_STATUSES.APPROVED:
                return 'Awaiting Finalization';
            default:
                return '';
        }
    }

    get getStatusFooterBody() {
        switch (this.currentStep) {
            case AVAILABLE_STATUSES.AWAITING_DRAFT:
                return 'A new Draft CRDR is being generated by Finance.';
            case AVAILABLE_STATUSES.APPROVED:
                return 'The CRDR is waiting finalization from Finance. You will be notified once the final version is ready.';
            default:
                return '';
        }
    }

    // Event handlers
    async handlePathButtonClick(event) {
        if (OPEN_MODAL_STEP_ON.includes(this.currentStep)) {
            await crdrPathAssistantModal.open({
                caseCrdrRecId: this.externalCaseCRDRId,
                hasPermission : this.hasPermission
            }).then((result) => {

                if (result.success && result.approveRejectValue === 'reject') {
                    this.updateCaseCRDRStatus(AVAILABLE_STATUSES.AWAITING_DRAFT).then(() => {
                        this.createTask(result.commentValue);
                    });
                } else if (result.success && result.approveRejectValue === 'approve') {
                    let caseCrdrIds = [this.containerObjectId];
                    caseCrdrIds.push(...result.relatedCaseCRDRIds ?? []);

                    this.updateMultipleCaseCRDRStatus(caseCrdrIds, AVAILABLE_STATUSES.APPROVED);
                }
            });
        } else {
            let nextStepValue = this.stepList[this.stepList.findIndex((step) => step.value === this.currentStep) + 1].value;
            this.updateCaseCRDRStatus(nextStepValue);
        }
    }

    publishStatusChangeMessage() {
        publish(this.messageContext, msgService, {
            origin: thisCmpMsgServiceOrigin,
            statusChanged: true,
            caseCrdrId: this.recordId
        });
    }

    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    handleMessage(message){
        if (message.origin === 'crdrAuditHistory' && message.caseCrdrId === this.recordId) {
            if (this.currentStep === AVAILABLE_STATUSES.DRAFT) {
                refreshApex(this.getCaseCRDRRecordResult);
                this.publishStatusChangeMessage();
            }
        }
    }
}