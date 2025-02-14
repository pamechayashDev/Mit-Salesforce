/**
 * Created by Andreas du Preez on 2024/10/24.
 * This LWC is the controller for the Compliance Utilization Report.
 * It is responsible for controlling the data flow between the child components.
 * It uses the ComplianceUtilizationReportDataService to fetch the record, save the record and parse the record to a suitcase.
 * The suitcase is used to pass the record's data between the child components.
 *
 * Business Logic may be implemented in this component.
 *
 * To add a new field to the Compliance Utilization Report, follow these steps:
 * 1. Add the field to the object in the Salesforce org.
 * 2. Add the c-compliance-utilization-report-field-input component to the appropriate section in the HTML.
 * 3. Implement business rules to the evaluateBusinessRules method.
 */

import * as DATA_SERVICE from "c/complianceUtilizationReportDataService";
import { LightningElement, track, wire } from "lwc";
import { getObjectInfos, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors, showConfirmationDialog } from "c/utils";
import msgService from "@salesforce/messageChannel/utilizationReportNotificationRefresh__c";
import { MessageContext, publish } from "lightning/messageService";

export default class ComplianceUtilizationReportController extends LightningElement {

    // ------ Properties -------
    @api recordId;
    // This is the object that are used between all child LWC components.
    // Each field (and nested object's field) is populated with the field describe object and a value.
    @track utilizationReportSuitcase = {};
    // This is a temporary object that is used to restore the Utilization Report Suitcase if the user cancels the edit.
    tempUtilizationReportSuitcase = {};
    staticTrue = true;
    staticFalse = false;

    // ------ Data Service Properties ------
    // utilizationReportObjects are the objects' describe that are used in the component.
    // This is initially declared as undefined because both @wire methods' results are required before the record
    // can be fetched. It is then assigned in the first wire method, so that the second wire can be called sequentially.
    utilizationReportObjects = DATA_SERVICE.UTILIZATION_REPORT_OBJECTS;

    // ------ UI Properties ------
    isLoading = true;
    accordionStageOpen = true;
    accordionGeneralOpen = true;
    readOnlyMode = true;
    saveError = false;
    showSaveErrors = false;
    saveErrorMessages = '';
    manufacturingCommProdOpenSection = [];

    init() {
        if (DATA_SERVICE.ComplianceUtilizationReportDataService.allDataFetched()) {
            console.log("All wire methods called. Fetching Utilization Report...");
            this.getUtilizationReport();
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DATA_SERVICE.UTILIZATION_REPORT__C.objectApiName,
        recordTypeId: "012000000000000AAA"
    })
    utilizationReportPicklistValues({ data, error }) {
        if (data) {
            DATA_SERVICE.ComplianceUtilizationReportDataService.picklistValues[DATA_SERVICE.UTILIZATION_REPORT__C.objectApiName] = data.picklistFieldValues
            this.init();
        }
        if (error) {
            console.error("Error fetching possible Picklist values => ", error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DATA_SERVICE.UTILIZATION_COMMERCIAL_PRODS__C.objectApiName,
        recordTypeId: "012000000000000AAA"
    })
    utilizationCommercialProdsPicklistValues({ data, error }) {
        if (data) {
            DATA_SERVICE.ComplianceUtilizationReportDataService.picklistValues[DATA_SERVICE.UTILIZATION_COMMERCIAL_PRODS__C.objectApiName] = data.picklistFieldValues
            this.init();
        }
        if (error) {
            console.error("Error fetching possible Picklist values => ", error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DATA_SERVICE.UTILIZATION_PRODUCT_LOCATION__C.objectApiName,
        recordTypeId: "012000000000000AAA"
    })
    utilizationProductLocationPicklistValues({ data, error }) {
        if (data) {
            DATA_SERVICE.ComplianceUtilizationReportDataService.picklistValues[DATA_SERVICE.UTILIZATION_PRODUCT_LOCATION__C.objectApiName] = data.picklistFieldValues
            this.init();
        }
        if (error) {
            console.error("Error fetching possible Picklist values => ", error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: DATA_SERVICE.UTILIZATION_MANUFACTURING_COMM_PROD__C.objectApiName,
        recordTypeId: "012000000000000AAA"
    })
    utilizationManufacturingCommProdsPicklistValues({ data, error }) {
        if (data) {
            DATA_SERVICE.ComplianceUtilizationReportDataService.picklistValues[DATA_SERVICE.UTILIZATION_MANUFACTURING_COMM_PROD__C.objectApiName] = data.picklistFieldValues
            this.init();
        }
        if (error) {
            console.error("Error fetching possible Picklist values => ", error);
        }
    }

    @wire(getObjectInfos, { objectApiNames: "$utilizationReportObjects" })
    objectInfos({ data, error }) {
        if (data) {
            DATA_SERVICE.ComplianceUtilizationReportDataService.objectDescribes = data.results.map(obj => ({ ...obj.result }));
            this.init();
        }
        if (error) {
            console.error("getObjectInfo => ", error);
        }
    }

    @wire(MessageContext)
    messageContext;

    getUtilizationReport() {
        console.log("------ Fetching Utilization Report ------");
        DATA_SERVICE.ComplianceUtilizationReportDataService.getUtilizationReport(this.recordId)
            .then(result => {
                this.utilizationReportSuitcase = DATA_SERVICE.ComplianceUtilizationReportDataService.parseRecordToSuitcase(result);
                this.utilizationReportSuitcase.manufacturingCommProds = {...this.utilizationReportSuitcase?.manufacturingCommProds, openSections: this.manufacturingCommProdOpenSection};
                this.isLoading = false;
            });
    }


    // Getters
    get sectionStageClass() {
        return `${this.accordionStageOpen ? "slds-section slds-is-open" : "slds-section"}`;
    }

    get sectionGeneralClass() {
        return `${this.accordionGeneralOpen ? "slds-section slds-is-open" : "slds-section"}`;
    }

    get isEditMode() {
        return !this.readOnlyMode;
    }

    get allowEditMode() {
        return this.utilizationReportSuitcase?.utilizationReport?.utilization_report_status__c?.value !== "In Progress";
    }

    get isInputDisabled() {
        return !this.allowEditMode;
    }

    get isStageLicensedOrCommercialized() {
        return this.isStageLicensed || this.isStageCommercialized;
    }

    get isStageNotLicensed() {
        return this.utilizationReportSuitcase?.utilizationReport?.latest_stage_of_development__c.value === "Not Licensed";
    }

    get isStageLicensed() {
        return this.utilizationReportSuitcase?.utilizationReport?.latest_stage_of_development__c.value === "Licensed";
    }

    get isStageCommercialized() {
        return this.utilizationReportSuitcase?.utilizationReport?.latest_stage_of_development__c?.value === "Commercialized";
    }

    get isAgencyNIH() {
        return this.utilizationReportSuitcase?.utilizationReport?.funding_agency__c?.value.split(";").some((value) => value.trim() === 'NIH');
    }

    get showDoeSection() {
        return (this.isStageLicensed || this.isStageCommercialized) && this.utilizationReportSuitcase?.utilizationReport?.funding_agency__c?.value.split(";").some((value) => value.trim() === 'DOE');
    }

    // Event Handlers
    handleStageSectionClick() {
        this.accordionStageOpen = !this.accordionStageOpen;
    }

    handleGeneralSectionClick() {
        this.accordionGeneralOpen = !this.accordionGeneralOpen;
    }

    handleEnableEditMode() {
        if (this.readOnlyMode === true) {
            this.tempUtilizationReportSuitcase = JSON.parse(JSON.stringify(this.utilizationReportSuitcase));
            this.evaluateBusinessRules();
            this.readOnlyMode = false;
        }
    }

    handleCancelEdit() {
        this.tempUtilizationReportSuitcase = JSON.parse(JSON.stringify(this.tempUtilizationReportSuitcase));
        this.utilizationReportSuitcase = { ...this.tempUtilizationReportSuitcase };
        this.utilizationReportSuitcase.utilizationReport.latest_stage_of_development__c = {...this.utilizationReportSuitcase.utilizationReport.latest_stage_of_development__c};
        this.readOnlyMode = true;
        console.log("Restored Suitcase: ", JSON.parse(JSON.stringify(this.utilizationReportSuitcase)));
    }

    handleValidateSave() {
        // Call verifyValidity on all fields to ensure all fields are valid before saving.
        console.log("Validating Fields...");
        let fieldsValidity = [];
        // TODO: Add common selector to all components to avoid this repetition.
        this.template.querySelectorAll("c-compliance-utilization-report-field-input").forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        });

        if (this.template.querySelector("c-compliance-utilization-report-section-licensed-or-commercialized")) {
            fieldsValidity.push(...this.template.querySelector("c-compliance-utilization-report-section-licensed-or-commercialized").verifyValidity());
        }
        if (this.template.querySelector("c-compliance-utilization-report-section-not-licensed")) {
            fieldsValidity.push(...this.template.querySelector("c-compliance-utilization-report-section-not-licensed").verifyValidity());
        }
        if (this.template.querySelector("c-compliance-utilization-report-section-n-i-h")) {
            fieldsValidity.push(...this.template.querySelector("c-compliance-utilization-report-section-n-i-h").verifyValidity());
        }
        if (this.template.querySelector("c-compliance-utilization-report-section-d-o-e")) {
            fieldsValidity.push(...this.template.querySelector("c-compliance-utilization-report-section-d-o-e").verifyValidity());
        }

        if (!fieldsValidity.includes(false)) {
            this.saveUtilizationReport(true);
        }
    }

    handleSaveDraft() {
        this.saveUtilizationReport(false);
    }

    saveUtilizationReport(doServerValidation) {
        this.isLoading = true;
        DATA_SERVICE.ComplianceUtilizationReportDataService.saveUtilizationReport(this.utilizationReportSuitcase, doServerValidation)
            .then((result) => {
                if (result.isValid) {
                    const event = new ShowToastEvent({
                        title: "Success",
                        variant: "success",
                        message: "Utilization Report Saved Successfully"
                    });
                    this.dispatchEvent(event);

                    // Get the updated Utilization Report
                    this.getUtilizationReport();
                    this.publishNotificationBarRefreshMessage();

                    // Hide and clear the Save Errors
                    this.showSaveErrors = false;
                    this.saveError = false;
                    this.saveErrorMessages = '';

                    this.readOnlyMode = true;
                }
                else {
                    this.isLoading = false;
                    this.saveError = true;
                    this.showSaveErrors = true;
                    this.saveErrorMessages = result.errorMessages.join("");
                }
            })
            .catch(error => {
                let friendlyErrorMessage = reduceErrors(error);
                const event = new ShowToastEvent({
                    title: "Error",
                    variant: "error",
                    message: friendlyErrorMessage.join(". ")
                });
                this.dispatchEvent(event);

                this.isLoading = false;
            });
    }

    handleShowSaveErrors() {
        this.showSaveErrors = true;
    }

    handleHideSaveErrors() {
        this.showSaveErrors = false;
    }

    async handleLatestStageOfDevelopmentChange(event) {
        const confirmed = await showConfirmationDialog('Confirm', 'Changing the Latest Stage of Development will clear all the fields not related to the new stage. Are you sure you want to continue?', 'warning');

        if (confirmed) {
            this.utilizationReportSuitcase = {...DATA_SERVICE.ComplianceUtilizationReportDataService.handleLatestStageOfDevelopmentChange(this.utilizationReportSuitcase, event.detail.value)};
            this.evaluateBusinessRules();
        }
        else {
            this.template.querySelector(`[data-recordid="latestStageOfDevelopmentInput"]`).value = this.utilizationReportSuitcase.utilizationReport.latest_stage_of_development__c.value;
        }
    }

    handleValueChange(event) {
        // Update the value in the suitcase and evaluate business rules.
        DATA_SERVICE.ComplianceUtilizationReportDataService.updateValueByPath(this.utilizationReportSuitcase, event.detail.fieldPath, event.detail.value);
        this.utilizationReportSuitcase = { ...this.utilizationReportSuitcase };

        console.log("Updated Suitcase: ", JSON.parse(JSON.stringify(this.utilizationReportSuitcase)));
        this.evaluateBusinessRules();
    }

    handleRelatedObjectChange(event) {
        if (event.detail.recordEvent === "updateRecordList") {
            this.utilizationReportSuitcase = { ...this.utilizationReportSuitcase };
            this.utilizationReportSuitcase[event.detail.path].records = [...event.detail.records];
            this.utilizationReportSuitcase[event.detail.path] = {...this.utilizationReportSuitcase[event.detail.path]};
            this.evaluateBusinessRules();
        }
        else if (event.detail.recordEvent === "deleteRecord") {
            if (!Object.prototype.hasOwnProperty.call(this.utilizationReportSuitcase, event.detail.path)) {
                this.utilizationReportSuitcase[event.detail.path] = [];
            }

            this.utilizationReportSuitcase[event.detail.path].push(event.detail.deletedRecord);
        }

        this.evaluateBusinessRules();
        console.log("Updated Suitcase: ", JSON.parse(JSON.stringify(this.utilizationReportSuitcase)));
    }

    handleReplaceSuitcaseObject(event) {
        if (!this.utilizationReportSuitcase[event.detail.path]) {
            this.utilizationReportSuitcase[event.detail.path] = {};
        }
        this.utilizationReportSuitcase[event.detail.path].records = event.detail.object;
        this.evaluateBusinessRules();
        console.log("Updated Suitcase: ", JSON.parse(JSON.stringify(this.utilizationReportSuitcase)));
    }

    handleManufacturingCommProdSectionChange(event) {
        this.manufacturingCommProdOpenSection = event.detail.openSections;
    }

    // Business Rules
    // Add business rules to this method to evaluate the fields' values and update the fields' properties.
    evaluateBusinessRules() {
        // Notes__c is required when the Commercialization Plan is value '3' or '6':
        this.utilizationReportSuitcase.utilizationReport.notes__c.required = this.utilizationReportSuitcase.utilizationReport?.commercialization_plan_id__c?.value === "3" ||
            this.utilizationReportSuitcase.utilizationReport?.commercialization_plan_id__c?.value === "6";
    }

    publishNotificationBarRefreshMessage() {
        publish(this.messageContext, msgService, {
            utilizationReportId: this.recordId
        });
    }
}