import { NavigationMixin } from "lightning/navigation";
import { api, LightningElement, wire, track } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import { RefreshEvent } from 'lightning/refresh';
import msgServiceNotification from "@salesforce/messageChannel/utilizationReportNotificationRefresh__c";
import msgServiceDocument from "@salesforce/messageChannel/utilizationReportDocumentRefresh__c";
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe, publish } from "lightning/messageService";
import {
    reduceErrors
} from "c/utils";

import updateUtilizationReportStatus from '@salesforce/apex/IEdisonService.updateUtilizationReportStatus'
import submitUtilizationReport from '@salesforce/apex/IEdisonService.submitUtilizationReport'
import updateForresterDataReport from '@salesforce/apex/IEdisonService.updateForresterDataReport'
import validateUtilizationReportDS from '@salesforce/apex/ComplianceUtilizationReportController.validateUtilizationReport';

import UTILIZATION_REPORT_TITLE_FIELD from "@salesforce/schema/Utilization_Report__c.Utilization_Report_Title__c";
import UTILIZATION_REPORT_INVENTION_REPORT_NUMBER_FIELD from "@salesforce/schema/Utilization_Report__c.Invention_Report_Number__c";
import UTILIZATION_REPORT_STATUS_FIELD from "@salesforce/schema/Utilization_Report__c.Utilization_Report_Status__c";
import UTILIZATION_REPORT_CASE_NUMBER_FIELD from "@salesforce/schema/Utilization_Report__c.Case_RecId__r.CONTRACT_CASE_NUM__c";
import UTILIZATION_REPORT_CASE_STATUS_FIELD from "@salesforce/schema/Utilization_Report__c.Case_RecId__r.STATUS__c";
import UTILIZATION_REPORT_TLO_OFFICER_FIELD from "@salesforce/schema/Utilization_Report__c.Case_RecId__r.TLO_NAME__c";
import UTILIZATION_REPORT_REPORTING_YEAR_FIELD from "@salesforce/schema/Utilization_Report__c.Reporting_Year__c";
import UTILIZATION_REPORT_CASE_ID_FIELD from "@salesforce/schema/Utilization_Report__c.Case_RecId__r.Id";


import TIME_ZONE from "@salesforce/i18n/timeZone";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const UTILIZATION_REPORT_FIELDS = [
    UTILIZATION_REPORT_TITLE_FIELD,
    UTILIZATION_REPORT_STATUS_FIELD,
    UTILIZATION_REPORT_INVENTION_REPORT_NUMBER_FIELD,
    UTILIZATION_REPORT_CASE_NUMBER_FIELD,
    UTILIZATION_REPORT_CASE_STATUS_FIELD,
    UTILIZATION_REPORT_REPORTING_YEAR_FIELD,
    UTILIZATION_REPORT_TLO_OFFICER_FIELD,
    UTILIZATION_REPORT_CASE_ID_FIELD
];

export default class UtilizationReportHighlightsPanel extends NavigationMixin(LightningElement) {
    @api recordId;

    record;
    loading = true;
    timezone = TIME_ZONE;
    includeStatus = 'Include for Utilization';
    
    reportIsValid = false;
    loadedRecord = false;
    loadedValidationResult= false;
    validationResult = {};

    @track type='success';
    @track message;
    @track showToastBar = false;
    autoCloseTime = 3000;
    variant;

    connectedCallback() {
        this.subscribeHandler();
        this.validateUtilizationReport();
        this.updateForresterData();
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
                this.dispatchEvent(new RefreshEvent());
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

    updateForresterData() {
        updateForresterDataReport({
            id: this.recordId
        })
            .then((result) => {
                if (result.includes('Success')) {
                    this.dispatchEvent(new RefreshEvent());
                } else {
                    this.dispatchEvent(new RefreshEvent());
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Updating Forrester data',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    init() {
        if (this.loadedValidationResult && this.loadedRecord) {
            if (this.validationResult?.isValid) {
                console.log('Report is valid');
                this.reportIsValid = true;
            } else  {
                console.log('Report is invalid');
                console.log('Utilization Report Incomplete: ', this.validationResult?.errorMessages);
                this.reportIsValid = false;
            }
        }
    }

    // Getters
    get utilizationReportTitle() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_TITLE_FIELD) : null;
    }

    get utilizationReportStatus() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_STATUS_FIELD) : null;
    }

    get inventionRportNumber() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_INVENTION_REPORT_NUMBER_FIELD) : null;
    }

    get caseNumber() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_CASE_NUMBER_FIELD) : null;
    }

    get caseStatus() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_CASE_STATUS_FIELD) : null;
    }

    get tloOfficer() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_TLO_OFFICER_FIELD) : null;
    }

    get reportingYear() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_REPORTING_YEAR_FIELD) : null;
    }

    get caseId() {
        return this.record ? getFieldValue(this.record.data, UTILIZATION_REPORT_CASE_ID_FIELD) : null;
    }

    // Wire Methods
    @wire(getRecord, { recordId: "$recordId", fields: UTILIZATION_REPORT_FIELDS })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            this.loading = false;
            this.loadedRecord = true;
            this.init();
        }
        if (record.error) {
            this.error = true;
        }
    }

    @wire(IsConsoleNavigation)
    isConsoleNavigation;

    @wire(MessageContext)
    messageContext;

    navToCase() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.caseId,
                actionName: "view"
            }
        });
    }

    async onIncludeForReporting() {
        try {
            this.loading = true;
            const result = await updateUtilizationReportStatus({ id: this.recordId, status:this.includeStatus });

            if (result.includes('Success')) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: `${this.utilizationReportTitle} included for reporting.`,
                        variant: 'success'
                    })
                );
            } else {
                throw new Error(result);
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: reduceErrors(error).join(' '),
                    variant: 'error'
                })
            );
        }

        await this.dispatchEvent(new RefreshEvent());
    }

    async onSubmitForUtilization() {
        try {
            this.loading = true;
            const result = await submitUtilizationReport({ id: this.recordId });

            if (result.includes('Success')) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Report Submitted for Utilization',
                        message: `You will be notified once the submitted report is completed, or if there are any errors with the submission.`,
                        variant: 'success'
                    })
                );

                publish(this.messageContext, msgServiceDocument, {
                    utilizationReportId: this.recordId
                });
            } else {
                throw new Error(result);
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errors on Submission',
                    message: 'There are errors on submission. Please review.',
                    variant: 'error'
                })
            );
        }

        await this.dispatchEvent(new RefreshEvent());
    }

    // Event handlers
    subscribeHandler() {
        this.messageSubscriptionNotification = subscribe(this.messageContext, msgServiceNotification, (message) => {this.handleMessageNotificationRefresh(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscriptionNotification);
        this.messageSubscriptionNotification = null;
    }

    handleMessageNotificationRefresh(message){
        if (message.utilizationReportId === this.recordId) {
            this.validateUtilizationReport();
        }
    }
}