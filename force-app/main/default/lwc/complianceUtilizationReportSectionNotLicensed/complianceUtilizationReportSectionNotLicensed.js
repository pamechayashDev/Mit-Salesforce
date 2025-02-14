/**
 * Created by Andreas du Preez on 2024/10/30.
 * This LWC is for the Compliance Utilization Report Not Licensed Section.
 * To add and use fields from specific objects, add an @api property with the name of the object in the suitcase.
 * The parent should use the lwc:spread attribute, which will then automatically populate the @api property from the
 * suitcase object.
 *
 * Business Logic may be implemented in this component.
 */

import { api, LightningElement } from "lwc";

export default class ComplianceUtilizationReportSectionNotLicensed extends LightningElement {

    staticTrue = true;
    staticFalse = false;

    @api id;
    @api utilizationReport;
    @api readOnlyMode;
    @api allowEditMode;

    // ------ UI Properties ------
    accordionNotLicensedOpen = true;

    @api verifyValidity() {
        let fieldsValidity = [];
        this.template.querySelectorAll('c-compliance-utilization-report-field-input').forEach(field => {
            fieldsValidity.push(field.verifyValidity());
        })

        return fieldsValidity;
    }

    handleEnableEditMode() {
        this.dispatchEvent(new CustomEvent('enableeditmode'));
    }

    handleValueChange(event) {
        this.dispatchEvent(new CustomEvent('valuechange', {detail: { ...event.detail }, bubbles: true, composed: false}));
    }

    // Getters
    get isInputDisabled() {
        return !this.allowEditMode;
    }

    get sectionNotLicensedClass() {
        return `${this.accordionNotLicensedOpen ? "slds-section slds-is-open slds-p-top_medium" : "slds-section slds-p-top_medium"}`;
    }

    // Event Handlers
    handleNotLicensedSectionClick() {
        this.accordionNotLicensedOpen = !this.accordionNotLicensedOpen;
    }
}