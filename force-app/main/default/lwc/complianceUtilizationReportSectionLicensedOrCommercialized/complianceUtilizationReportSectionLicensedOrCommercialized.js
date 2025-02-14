/**
 * Created by Andreas du Preez on 2024/11/06.
 */

import { api, LightningElement } from "lwc";

const LICENSEES_COLUMNS = [
    {
        label: "Licensee Name",
        fieldName: "Licensee_Name__c",
        type: "text",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "Small Business",
        fieldName: "Small_Business__c",
        type: "boolean",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "# of exclusive licenses and/or options",
        fieldName: "Exclusive_Count__c",
        type: "number",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    },
    {
        label: "# of non-exclusive licenses and/or options",
        fieldName: "Non_Exclusive_Count__c",
        type: "number",
        cellAttributes: { alignment: "left" },
        sortable: true, hideDefaultActions: true
    }
];

const LICENSEES_COLUMNS_EDIT = [
    {
        type: "action",
        typeAttributes: {
            rowActions: [
                { label: "Edit", name: "editLicensee" }
            ]
        }
    }];

export default class ComplianceUtilizationReportSectionLicensedOrCommercialized extends LightningElement {
    staticTrue = true;
    staticFalse = false;
    @api id;
    @api utilizationReport;
    @api
    get licensees() {
        return this._licensees;
    }

    set licensees(value) {
        this._licensees = value;
        this._licenseeRecords = JSON.parse(JSON.stringify(value?.records ?? []));
    }

    @api manufacturingCommProds;
    @api readOnlyMode;
    @api allowEditMode;

    // ------ Data Properties ------
    _licenseeRecords = [];
    _licensees = {};
    _tempLicenseeRecord = {};

    // ------ UI Properties ------
    accordionLicensedOrCommercialized = true;
    licenseesColumns = [];
    showLicenseeModal = false;

    @api verifyValidity() {
        let fieldsValidity = [];
        this.template.querySelectorAll("c-compliance-utilization-report-field-input").forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        });

        if (this.template.querySelector("c-compliance-utilization-report-section-commercialized")) {
            fieldsValidity.push(...this.template.querySelector("c-compliance-utilization-report-section-commercialized").verifyValidity());
        }

        return fieldsValidity;
    }

    connectedCallback() {
        this.licenseesColumns = [...LICENSEES_COLUMNS, ...(this.allowEditMode ? LICENSEES_COLUMNS_EDIT : [])]
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

    handleIsUSManufacturingValueChange(event) {
        // Update the Suitcase with the new value for is_us_manufacturing_required_1__c
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: { ...event.detail },
            bubbles: true,
            composed: false
        }));

        // Clear the value for is_us_manufacturing_required_2__c in the Suitcase
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: {
                value: null,
                fieldPath: 'utilizationReport.is_us_manufacturing_required_2__c'
            }, bubbles: false, composed: false
        }));

        // Clear the value for is_us_manufacturing_required_3__c in the Suitcase
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: {
                value: null,
                fieldPath: 'utilizationReport.is_us_manufacturing_required_3__c'
            }, bubbles: false, composed: false
        }));
    }

    // Getters:
    get isInputDisabled() {
        return !this.allowEditMode;
    }

    get sectionLicensedOrCommercialized() {
        return `${this.accordionLicensedOrCommercialized ? "slds-section slds-is-open slds-p-top_medium" : "slds-section slds-p-top_medium"}`;
    }

    get isLatestStageOfDevelopmentCommercialized() {
        return this.utilizationReport?.latest_stage_of_development__c?.value === "Commercialized";
    }

    get isIsUSManufacturingRequired1Completed() {
        return this.utilizationReport?.is_us_manufacturing_required_1__c?.value && this.utilizationReport?.is_us_manufacturing_required_1__c?.value.trim().length > 0;
    }

    get getIsUSManufacturingRequired2Label() {
        const isRequired = this.utilizationReport.is_us_manufacturing_required_1__c.value;
        if (isRequired === "Y") {
            return "In the designated reporting period, do all licenses include a requirement that any products embodying the subject invention or produced using the subject invention will be manufactured substantially in the United States (including manufacturing requirements other than 35 U.S.C. 204)?";
        } else if (isRequired === "N") {
            return "In the designated reporting period do all grants to any person of the exclusive right to use or sell the subject invention in the United States require that any products embodying the subject invention or produced using the subject invention will be manufactured substantially in the United States as required by 35 U.S.C. 204?";
        }

        return "";
    }

    get getIsUSManufacturingRequired3Label() {
        const isRequired = this.utilizationReport.is_us_manufacturing_required_1__c.value;
        if (isRequired === "Y") {
            return "In the designated reporting period, are all products embodying the subject invention or produced using the subject invention manufactured substantially in the United States (including manufacturing requirements other than 35 U.S.C. 204)?";
        } else if (isRequired === "N") {
            return "In the designated reporting period are all products embodying the subject invention or produced using the subject invention manufactured substantially in the United States for all grants to any person of the exclusive right to use or sell the subject invention in the United States as required by 35 U.S.C. 204?";
        }

        return "";
    }

    get getIsUSManufacturingRequired2PicklistOptions() {
        if (this.utilizationReport.is_us_manufacturing_required_1__c.value === "Y") {
            return this.utilizationReport.is_us_manufacturing_required_2__c?.picklistValues.filter(picklistValue => picklistValue.value !== "N/A");
        }
        return this.utilizationReport.is_us_manufacturing_required_2__c?.picklistValues;
    }

    get getIsUSManufacturingRequired3PicklistOptions() {
        if (this.utilizationReport.is_us_manufacturing_required_1__c.value === "Y") {
            return this.utilizationReport.is_us_manufacturing_required_3__c?.picklistValues.filter(picklistValue => picklistValue.value !== "N/A");
        }
        return this.utilizationReport.is_us_manufacturing_required_3__c?.picklistValues;
    }

    get getIsCommercializationPlanRequired() {
        return this.utilizationReport.latest_stage_of_development__c?.value === "Commercialized";
    }

    // Event Handlers
    handleLicensedOrCommercialized() {
        this.accordionLicensedOrCommercialized = !this.accordionLicensedOrCommercialized;
    }

    handleReplaceSuitcaseObject(event) {
        this.dispatchEvent(new CustomEvent("handlereplacesuitcaseobject", {
            detail: { ...event.detail },
            bubbles: true,
            composed: false
        }));
    }

    handleManufacturingCommProdSectionChange(event) {
        this.dispatchEvent(new CustomEvent("manufacturingcommprodopensectionchange", {
            detail: { ...event.detail }
        }));
    }

    handleLicenseesRowAction(event) {
        this.dispatchEvent(new CustomEvent("enableeditmode"));
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case "editLicensee":
                this._tempLicenseeRecord = JSON.parse(JSON.stringify(row));
                this.showLicenseeModal = true;
                break;
            default:
                break;
        }
    }

    handleLicenseeNameChange(event) {
        this._tempLicenseeRecord.Licensee_Name__c = event.detail.value;
    }

    handleLicenseeModalCancel(event) {
        this._tempLicenseeRecord = {};
        this.showLicenseeModal = false;
    }

    handleEditLicensee(event) {
        if (!this.validLicenseeName()) {
            return;
        }
        let licenseeRecord = this._licenseeRecords?.find(licensee => licensee.Id === this._tempLicenseeRecord.Id);
        licenseeRecord.Licensee_Name__c = this._tempLicenseeRecord.Licensee_Name__c;
        this._tempLicenseeRecord = {};
        this._licenseeRecords = [...this._licenseeRecords];

        // Send the updated records to the parent to update the suitcase
        this.dispatchEvent(new CustomEvent("relatedobjectchange", {
            detail: {
                recordEvent: "updateRecordList",
                records: this._licenseeRecords,
                path: "licensees"
            }, bubbles: true, composed: false
        }));

        this.showLicenseeModal = false;
    }

    validLicenseeName() {
        // Validate Licensee Name for empty value
        const input = this.template.querySelector(`[data-recordid="licenseeNameInput"]`);
        if (this._tempLicenseeRecord.Licensee_Name__c === '') {
            input.reportValidity();
            return false;
        }
        // Validate Licensee Name for duplicate values
        const duplicates = this._licenseeRecords.some(licensee => licensee.Licensee_Name__c === this._tempLicenseeRecord.Licensee_Name__c && licensee.Id !== this._tempLicenseeRecord.Id);
        if (duplicates) {
            input.setCustomValidity('Licensee Name must be unique');
            input.reportValidity();
            return false;
        }

        return true;
    }
}