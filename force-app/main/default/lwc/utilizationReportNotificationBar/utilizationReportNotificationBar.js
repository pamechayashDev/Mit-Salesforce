import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import msgService from "@salesforce/messageChannel/utilizationReportNotificationRefresh__c";
import validateUtilizationReportDS from '@salesforce/apex/ComplianceUtilizationReportController.validateUtilizationReport';
import UTILIZATION_REPORT_STATUS_FIELD from '@salesforce/schema/Utilization_Report__c.Utilization_Report_Status__c';
import ERROR_MESSAGE_FIELD from '@salesforce/schema/Utilization_Report__c.Error_Messages__c';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import { refreshApex } from "@salesforce/apex";

// Constants
const STATUS_ERROR = 'Error';
const STATUS_DEFAULT = 'Utilization Questions';
const STATUS_READY_TO_SUBMIT = 'Review Questions';
const ERROR_ICON_CLASS = 'slds-icon-custom-custom66 custom-icon-error-background';
const DEFAULT_ICON_CLASS = 'custom-icon-background icon-color';
const READY_TO_SUBMIT_ICON_CLASS = 'icon-color';
const ERROR_ICON_NAME = 'standard:first_non_empty';
const DEFAULT_ICON_NAME = 'standard:timeslot';
const READY_TO_SUBMIT_ICON_NAME = 'standard:task2';
const TITLE_CLASS_ERROR = 'slds-page-header__title redColor';
const TITLE_CLASS_DEFAULT = 'slds-page-header__title defaultColor';
const TITLE_CLASS_READY_TO_SUBMIT = 'slds-page-header__title greenColor';

export default class UtilizationReportNotificationBar extends NavigationMixin(LightningElement) {
    @api recordId;
    utilizationReportStatus;
    errorMessageRaw;
    @track showModal = false;
    errorData = [];
    validationResult = {};

    // Default Texts
    titleText = STATUS_DEFAULT;
    messageText = 'Complete the utilization questions to finalize your report submission';
    buttonClass = 'slds-button slds-button_neutral';
    iconClass = DEFAULT_ICON_CLASS;
    iconName = DEFAULT_ICON_NAME;
    titleClass = TITLE_CLASS_DEFAULT;
    buttonText = STATUS_DEFAULT;

    loadedValidationResult = false;
    loadedRecord = false;
    showButton = false;
    wiredResultRecord;

    connectedCallback() {
        this.subscribeHandler();
        this.validateUtilizationReport();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    validateUtilizationReport() {
        validateUtilizationReportDS({
            recordId: this.recordId
        })
            .then((validationResult) => {
                this.validationResult = validationResult;
                this.loadedValidationResult = true;
                this.init();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Validating Utilization Report',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    init(){
        if (this.loadedValidationResult && this.loadedRecord) {
            console.log('Loading Styles per status...');
            this.updateStylesBasedOnStatus();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [UTILIZATION_REPORT_STATUS_FIELD, ERROR_MESSAGE_FIELD] })
    async wiredRecord(record) {
        this.wiredResultRecord = record;
        if (this.wiredResultRecord.data) {
            this.utilizationReportStatus = this.wiredResultRecord.data.fields.Utilization_Report_Status__c.value;
            this.errorMessageRaw = this.wiredResultRecord.data.fields.Error_Messages__c.value;
            this.loadedRecord = true;
            this.init();
        } else if (this.wiredResultRecord.error) {
            console.error('Error retrieving utilization report status:', this.wiredResultRecord.error);
        }
    }

    @wire(MessageContext)
    messageContext;

    updateStylesBasedOnStatus() {
        if (this.utilizationReportStatus === STATUS_ERROR) {
            this.showButton = true;
            this.setErrorStyles();
        } else {
            if (this.validationResult?.isValid) {
                this.setReadyToSubmitStyles();
            } else {
                console.log('Utilization Report Incomplete: ', this.validationResult.errorMessages);
                this.setDefaultStyles();
            }
        }
    }

    setErrorStyles() {
        this.titleText = 'Errors on submission';
        this.messageText = 'Please view and correct the errors on the submission before resubmitting the report';
        this.iconClass = ERROR_ICON_CLASS;
        this.iconName = ERROR_ICON_NAME;
        this.titleClass = TITLE_CLASS_ERROR;
        this.buttonText = 'View Errors';
    }

    setDefaultStyles() {
        this.titleText = STATUS_DEFAULT;
        this.messageText = 'Complete the utilization questions to finalize your report submission';
        this.iconClass = DEFAULT_ICON_CLASS;
        this.iconName = DEFAULT_ICON_NAME;
        this.titleClass = TITLE_CLASS_DEFAULT;
        this.buttonText = STATUS_DEFAULT;
    }

    setReadyToSubmitStyles() {
        this.titleText = STATUS_DEFAULT;
        this.messageText = 'All questions completed. Your report is now ready for submission';
        this.iconClass = READY_TO_SUBMIT_ICON_CLASS;
        this.iconName = READY_TO_SUBMIT_ICON_NAME;
        this.titleClass = TITLE_CLASS_READY_TO_SUBMIT;
        this.showButton = false;
    }

    handleUtilizationQuestions() {
       if (this.loadedValidationResult && this.loadedRecord) {
            this.showModal = true;
            this.parseErrorMessages();
        } else {
            console.warn('Component data not fully loaded yet. Please try again.');
        }
    }

    parseErrorMessages() {
        try {
            if (this.errorMessageRaw) { 
                // Parse the error messages only if data exists
                const parsedData = JSON.parse(this.errorMessageRaw);
                this.errorData = parsedData.errors || []; // Default to an empty array if no "errors" field exists
            } else {
                // Assign an empty array if errorMessageRaw is null or undefined
                this.errorData = [];
            }
        } catch (e) {
            console.error('Error parsing JSON:', e);
            this.errorData = []; // Ensure errorData is reset to an empty array on parse failure
        }
    }
    

    handleCloseModal() {
        this.showModal = false;
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
        if (message.utilizationReportId === this.recordId) {
            this.validateUtilizationReport();
            refreshApex(this.wiredResultRecord).then(() => this.init());
        }
    }
}