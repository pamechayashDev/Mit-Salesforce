/**
 * Created by Andreas du Preez on 2024/11/04.
 */

import { api, LightningElement, track } from "lwc";
import { showConfirmationDialog } from "c/utils";

const COMMERCIAL_PROD_COLUMNS_EDIT = [
    {
        type: "action", typeAttributes: {
            rowActions: [
                { label: "Edit", name: "editProduct" },
                { label: "Delete", name: "deleteProduct" }
            ]
        }
    }];
const COMMERCIAL_PROD_COLUMNS = [
    {
        label: "Commercial Product",
        fieldName: "Commercial_Name__c",
        type: "Text",
        sortable: true, hideDefaultActions: true
    },
    {
        label: "FDA Approval Type",
        fieldName: "Fda_Approval_Type__c",
        type: "Text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "Public Announced Indicator Flag",
        fieldName: "Public_Ind__c",
        type: "Text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    }];

export default class ComplianceUtilizationReportSectionNih extends LightningElement {

    @api id;
    @api utilizationReport;
    @api
    get commercialProds() {
        return this._commercialProds;
    }
    set commercialProds(value) {
        this._commercialProdsRecords = JSON.parse(JSON.stringify(value.records));
        this._commercialProds = value;
    }

    @api readOnlyMode;
    @api allowEditMode;
    @track _commercialProdsRecords = [];

    @api verifyValidity() {
        let fieldsValidity = [];
        this.template.querySelectorAll("c-compliance-utilization-report-field-input").forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        });

        return fieldsValidity;
    }

    _editProductName = "";
    _editFDAApprovalNumber = "";
    _editFDAApprovalType = "";
    _editPublicInd = "";
    _editGovernmentReviewStatus = "";
    _editLocalId = "";
    _editCreateOrUpdate = "";
    _commercialProds;
    commercialProdsColumns = [];
    showModal = false;
    accordionNIHOpen = true;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    connectedCallback() {
        this.commercialProdsColumns = [...COMMERCIAL_PROD_COLUMNS, ...(this.allowEditMode ? COMMERCIAL_PROD_COLUMNS_EDIT : [])];
    }

    // Getter
    get getProductModalButtonLabel() {
        if (this._editCreateOrUpdate === "create") {
            return "Add";
        }
        else if (this._editCreateOrUpdate === "update") {
            return "Update";
        }

        return "Add";
    }

    get getFDAApprovalTypeOptions() {
        return [{label: ' - None -', value: ''}].concat(this.commercialProds?.objectDescribe?.Fda_Approval_Type__c?.picklistValues ?? []);
    }

    get getPublicIndOptions() {
        return this.commercialProds?.objectDescribe?.Public_Ind__c?.picklistValues;
    }

    get sectionNIHClass() {
        return `${this.accordionNIHOpen ? "slds-section slds-is-open slds-p-top_medium" : "slds-section slds-p-top_medium"}`;
    }

    // Event Handlers
    handleNIHSectionClick() {
        this.accordionNIHOpen = !this.accordionNIHOpen;
    }

    handleEnableEditMode() {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
    }

    handleValueChange(event) {
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: { ...event.detail },
            bubbles: true,
            composed: false
        }));

    }

    handleAddProductCancel(event) {
        this.showModal = false;
        this.clearEditFields();
    }

    handleAddEditProduct(event) {
        if (!this.validateFields()) {
            return;
        }

        if (this._editCreateOrUpdate === "create") {

            let tempNewRecord = {
                Commercial_Name__c: this._editProductName,
                Fda_Approval_Number__c: this._editFDAApprovalNumber,
                Fda_Approval_Type__c: this._editFDAApprovalType,
                Public_Ind__c: this._editPublicInd,
                Govt_Review_Status__c: this._editGovernmentReviewStatus,
                localId: Math.random().toString(36).substring(7)
            };
            this._commercialProdsRecords.push(tempNewRecord);
        }
        else if (this._editCreateOrUpdate === "update") {
            let updatedRecord = this._commercialProdsRecords.find(record => record.localId === this._editLocalId || record.Id === this._editLocalId);
            updatedRecord.Commercial_Name__c = this._editProductName;
            updatedRecord.Fda_Approval_Number__c = this._editFDAApprovalNumber;
            updatedRecord.Fda_Approval_Type__c = this._editFDAApprovalType;
            updatedRecord.Public_Ind__c = this._editPublicInd;
            updatedRecord.Govt_Review_Status__c = this._editGovernmentReviewStatus;
        }

        this._commercialProdsRecords = [...this._commercialProdsRecords];

        // Send the updated records to the parent to update the suitcase
        this.dispatchEvent(new CustomEvent("relatedobjectchange", {
            detail: {
                recordEvent: "updateRecordList",
                records: this._commercialProdsRecords,
                path: "commercialProds"
            }, bubbles: true, composed: false
        }));

        this.clearEditFields();
        this.showModal = false;
    }

    validateFields() {
        return [...this.template.querySelectorAll(".input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }

    clearEditFields() {
        this._editProductName = "";
        this._editFDAApprovalNumber = "";
        this._editFDAApprovalType = "";
        this._editPublicInd = "";
        this._editGovernmentReviewStatus = "";
        this._editCreateOrUpdate = "";
        this._editLocalId = "";
    }

    handleAddCommercialProduct() {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
        this._editCreateOrUpdate = "create";
        this.showModal = true;
    }

    async handleRowAction(event) {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case "editProduct":
                this._editProductName = row.Commercial_Name__c;
                this._editFDAApprovalNumber = row.Fda_Approval_Number__c;
                this._editFDAApprovalType = row.Fda_Approval_Type__c;
                this._editPublicInd = row.Public_Ind__c;
                this._editGovernmentReviewStatus = row.Govt_Review_Status__c;
                this._editCreateOrUpdate = "update";
                this._editLocalId = row.Id ?? row.localId;
                this.showModal = true;
                break;
            case "deleteProduct":
                if (await showConfirmationDialog('Confirm Delete', `Are you sure you want to delete Commercial Product "${row.Commercial_Name__c}"?`, 'warning')) {
                    if (row.Id) {
                        this._commercialProdsRecords = this._commercialProdsRecords.filter(record => record.Id !== row.Id);
                        this.dispatchEvent(new CustomEvent("relatedobjectchange", {
                            detail: {
                                recordEvent: "deleteRecord",
                                deletedRecord: row,
                                path: "commercialProdsToDelete"
                            }, bubbles: true, composed: false
                        }));
                    } else {
                        this._commercialProdsRecords = this._commercialProdsRecords.filter(record => record.localId !== row.localId);
                    }

                    this._commercialProdsRecords = [...this._commercialProdsRecords];
                    this.dispatchEvent(new CustomEvent("relatedobjectchange", {
                        detail: {
                            recordEvent: "updateRecordList",
                            records: this._commercialProdsRecords,
                            path: "commercialProds"
                        }, bubbles: true, composed: false
                    }));
                }
                break;
            default:
        }
    }

    handleProductNameChange(event) {
        this._editProductName = event.target.value;
    }

    handleFDAApprovalNumberChange(event) {
        this._editFDAApprovalNumber = event.target.value;
    }

    handleFDAApprovalTypeChange(event) {
        this._editFDAApprovalType = event.target.value;
    }

    handlePublicIndChange(event) {
        this._editPublicInd = event.target.value;
    }

    handleGovernmentReviewStatusChange(event) {
        this._editGovernmentReviewStatus = event.target.value;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this._commercialProdsRecords];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this._commercialProdsRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}