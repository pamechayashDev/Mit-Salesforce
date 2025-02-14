/**
 * Created by Andreas du Preez on 2024/08/12.
 */

import LightningModal from "lightning/modal";
import { api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createIPIARecord from "@salesforce/apex/IPIAController.createIPIARecord";
import linkIPIARecordToDoc from "@salesforce/apex/IPIAController.linkIPIARecordToDoc";
import getAllIPIATypes from "@salesforce/apex/IPIAController.getAllIPIATypes";
import getTypeCreateAccess from "@salesforce/apex/IPIAController.userHasIPIATypeCreatePermission";
import IPIA_RECORD_MIT_ID from "@salesforce/schema/IPIA_Record__c.MitId__c";
import IPIA_RECORD_FORM_NAME from "@salesforce/schema/IPIA_Record__c.FormName__c";
import IPIA_RECORD_IPIA_TYPE from "@salesforce/schema/IPIA_Record__c.IPIA_Type__c";
import IPIA_RECORD_SIGN_DATE from "@salesforce/schema/IPIA_Record__c.SignDatetime__c";
import TIME_ZONE from '@salesforce/i18n/timeZone';
import IPIA_Record_Error_Sign_Date_Today from '@salesforce/label/c.IPIA_Record_Error_Sign_Date_Today'
import { reduceErrors } from "c/utils";

const TYPE_SELECTION_STEP = "TYPE_SELECTION_STEP";
const TYPE_DETAILS_STEP = "TYPE_DETAILS_STEP";
const TOAST_VARIANT_ERROR = "error";

export default class IpiaNewRecordModal extends LightningModal  {

    @api mitId;
    @api docDetails;

    disabled = false;    
    currentStep = TYPE_SELECTION_STEP;
    exemptionValue;
    ipiaTypeOptions = [
        { label: 'IPIA', value: false },
        { label: 'Exemption', value: true }
    ];
    clickEventRegistered = false;
    getAllIPIATypesLoading = true;
    allIPIATypes;
    searchResults;
    searchResultsCached;
    selectedSearchResult;
    showNewIpiaTypeModal = false;
    ipiaTypeInputClicked = false;
    hasNewTypePersmission= false;
    timezone = TIME_ZONE;

    get getHeaderLabel() { return this.currentStep === TYPE_SELECTION_STEP ? "New Signed IPIA" : this.exemptionValue ? "Exemption" : "IPIA"; }
    get isTypeSelectionStep() { return this.currentStep === TYPE_SELECTION_STEP; }
    get isDetailsStep() { return this.currentStep === TYPE_DETAILS_STEP; }
    get getSubmitButtonLabel() { return this.currentStep === TYPE_SELECTION_STEP ? "Continue" : "Create"; }
    get selectedValue() { return this.selectedSearchResult?.label ?? null; }
    get hasDoc() { return this.docDetails != null }
    get docTitle() { return this.docDetails?.Title }

    connectedCallback() {
        getTypeCreateAccess().then((result) => {
            this.hasNewTypePersmission = result;
        });
    }

    // Since LWS prevents us from determining the target of a click event, we need to register the click event on the Template and Document.
    // The templateClickHandler has context of the current LWC, so we can determine if the target is within the LWC but cannot fire outside the LWC.
    // The documentClickHandler does not have context of the current LWC, but can fire outside the LWC.
    // By combining the two, we can determine if the IPIA Type combobox should be closed if clicked outside the input.
    renderedCallback() {
        if (this.clickEventRegistered) return;
        this.template.addEventListener('click',this.templateClickHandler,true);
        document.addEventListener('click',this.documentClickHandler);

        this.clickEventRegistered = true;
    }

    disconnectedCallback() {
        this.template.removeEventListener('click',this.templateClickHandler);
        document.removeEventListener('click',this.documentClickHandler);
    }

    handleSubmitButton() {
        this.disabled = true;

        var allFieldsValid = false;
        if (this.currentStep === TYPE_DETAILS_STEP) {
            allFieldsValid = this.validateFields();

            if (!allFieldsValid) {
                this.disabled = false;
                return;
            }
        }

        if (this.currentStep === TYPE_SELECTION_STEP) {
            let radioGroupSelection = this.template.querySelector("lightning-radio-group");
            radioGroupSelection.reportValidity()
            if (this.exemptionValue !== undefined) {
                this.currentStep = TYPE_DETAILS_STEP;

                getAllIPIATypes({exemption: this.exemptionValue}).then((result) => {
                    this.allIPIATypes = result.sort((a, b) =>
                        a.Name.localeCompare(b.Name)
                    );

                    this.searchResultsCached = this.allIPIATypes.map((element) => ({
                        label: element.Name + "  (" + element.Status__c + ")", 
                        value: element.Id
                    }));
                    this.getAllIPIATypesLoading = false;
                });
            }
            this.disabled = false;
        } else if (this.currentStep === TYPE_DETAILS_STEP && allFieldsValid) {
            let ipiaType = {
                [IPIA_RECORD_MIT_ID.fieldApiName]: this.mitId,
                [IPIA_RECORD_FORM_NAME.fieldApiName]: this.selectedSearchResult?.label,
                [IPIA_RECORD_IPIA_TYPE.fieldApiName]: this.selectedSearchResult?.value,
                [IPIA_RECORD_SIGN_DATE.fieldApiName]: this.template.querySelector("lightning-input[data-formfield=\"agreementDate\"]").value,
            };

            createIPIARecord({ ipiaRecord: ipiaType }).then(async (result) => {
                if (result != null) {
                    // link document to newly created IPIA Record
                    if (this.docDetails != null) {
                        await linkIPIARecordToDoc({ ipiaRecordId: result.Id, contentDocumentId: this.docDetails.ContentDocumentId });
                    }

                    document.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'IPIA Record created successfully',
                            variant: 'success'
                        })
                    );
                    this.close();
                }
                else {
                    document.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error creating IPIA Record',
                            variant: 'error'
                        })
                    );
                }
            }).catch((error) => {
                let errorMessages = reduceErrors(error);
                for (let i = 0; i < errorMessages.length; i++) {
                    if (errorMessages[i].includes(IPIA_Record_Error_Sign_Date_Today.replace('<TODAY>',''))) {
                        let formName = this.template.querySelector("lightning-input[data-formfield=\"agreementDate\"]");
                        formName.setCustomValidity(errorMessages[i]);
                        formName.reportValidity();
                        errorMessages.splice(i, 1);
                    }
                }

                if (errorMessages.length > 0) {
                    console.error("error", errorMessages);
                    document.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: errorMessages.join(", "),
                            variant: TOAST_VARIANT_ERROR
                        })
                    );
                }

                this.disabled = false;
            });
        }
    }

    // Event Handlers
    handleIpiaTypeChange(event) {
        this.exemptionValue = event.detail.value === 'true';
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.searchResultsCached.filter((element) =>
            element.label.toLowerCase().includes(input)
        );
        this.searchResults = result;
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;

        this.selectedSearchResult = this.searchResults.find(
            (pickListOption) => pickListOption.value === selectedValue
        );
        this.clearSearchResults();
    }

    handleOnIPIATypeCreated(event) {
        this.showNewIpiaTypeModal = false;
        if (event.detail.createdIpia?.Id) {
            let createdIpiaSearchEntry = { label: event.detail.createdIpia?.Name, value: event.detail.createdIpia?.Id }
            this.selectedSearchResult = createdIpiaSearchEntry;
            this.searchResultsCached.unshift(createdIpiaSearchEntry);
            this.allIPIATypes.unshift(createdIpiaSearchEntry);
        }
    }

    templateClickHandler = (event) => {
        this.ipiaTypeInputClicked = false;
        let container = this.template.querySelector('.custom-container');
        this.ipiaTypeInputClicked = container.contains(event.target);
    }

    documentClickHandler = () => {
        if (this.searchResults && !this.ipiaTypeInputClicked) {
            this.clearSearchResults();
        }
        this.ipiaTypeInputClicked = false;
    }

    // Helper Functions
    newIpiaType() {
        this.showNewIpiaTypeModal = true;
    }

    handleCancelButton() {
        this.close();
    }

    clearSearchResults() {
        this.searchResults = null;
        let ipiaType = this.template.querySelector("lightning-input[data-formfield=\"ipiaTypeLookup\"]");
        if (!this.selectedSearchResult) {
            ipiaType.value = "";
        }
    }

    showIPIAOptions() {
        if (!this.searchResults) {
            this.searchResults = this.searchResultsCached;
        }
    }

    validateFields() {
        let ipiaTypeLookup  = this.template.querySelector("lightning-input[data-formfield=\"ipiaTypeLookup\"]");

        let found = false;
        this.searchResultsCached.forEach((element) => {
            if (element.label === ipiaTypeLookup.value && ipiaTypeLookup.value === this.selectedSearchResult.label) {
                found = true;
            }
        });

        if (!found) {
            ipiaTypeLookup.value = "";
        }

        let fieldValidity = [];
        [...this.template.querySelectorAll("lightning-input")].forEach(field => {
            field.setCustomValidity("");
        });

        [...this.template.querySelectorAll("lightning-input")].forEach(field => {
            fieldValidity.push(field.reportValidity());
        });

        return !fieldValidity.includes(false);
    }
}