/**
 * Created by Andreas du Preez on 2024/11/06.
 */

import { api, LightningElement, track } from "lwc";

export default class ComplianceUtilizationReportSectionDoe extends LightningElement {

    staticFalse = false;

    @api id;
    @api utilizationReport;
    @api readOnlyMode;
    @api allowEditMode;
    @api verifyValidity() {
        let fieldsValidity = [];
        this.template.querySelectorAll('c-compliance-utilization-report-field-input').forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        })

        return fieldsValidity;
    }

    @track _manufacturingCommProdsRecords = [];
    accordionDOEOpen = true;
    _manufacturingCommProds;
    showModal = false;

    handleEnableEditMode() {
        this.dispatchEvent(new CustomEvent('enableeditmode'));
    }

    handleValueChange(event) {
        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: { ...event.detail },
            bubbles: true,
            composed: false
        }));
    }

    // Getters
    get isInputDisabled() {
        return !this.allowEditMode;
    }

    get sectionDOEClass() {
        return `${this.accordionDOEOpen ? "slds-section slds-is-open slds-p-top_medium" : "slds-section slds-p-top_medium"}`;
    }

    // Event Handlers
    handleDOESectionClick() {
        this.accordionDOEOpen = !this.accordionDOEOpen;
    }
}