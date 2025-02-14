/**
 * Created by Andreas du Preez on 2024/07/25.
 */

import { api, LightningElement, track, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import createIPIAType from "@salesforce/apex/IPIAController.createIPIAType";
import getCreateAccess from "@salesforce/apex/IPIAController.userHasIPIARecordCreatePermission";
import IPIA_TYPE_NAME from "@salesforce/schema/IPIA_Type__c.Name";
import IPIA_TYPE_DESCRIPTION from "@salesforce/schema/IPIA_Type__c.Description__c";
import IPIA_TYPE_EXEMPTION from "@salesforce/schema/IPIA_Type__c.Exemption__c";
import IPIA_TYPE_STATUS from "@salesforce/schema/IPIA_Type__c.Status__c";
import IPIA_TYPE_DOCUSIGN_TEMPLATE_ID from "@salesforce/schema/IPIA_Type__c.DocusignTemplate__c";
import { NavigationMixin } from "lightning/navigation";
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import { reduceErrors } from "c/utils";

const TOAST_VARIANT_SUCCESS = "success";
const TOAST_VARIANT_ERROR = "error";
const MAX_FILE_SIZE = 2500000;
const IPIA_TYPE_NAME_MAX_LENGTH = 80;
const STATUS_ACTIVE = "Active";


export default class IpiaNewType extends NavigationMixin(LightningElement) {

    @api fromLwc = false;
    @api disableExemption;
    @api exemptionValue;

    // Toast Variables
    showToastBar = false;
    toastType = TOAST_VARIANT_SUCCESS;
    toastMessage;

    // Form Fields
    formName;
    formDescription;
    docusignTemplateId;
    createdIpia;
    hasNewTypePermission = true;
    isLoading = true;
    nameMaxLength = IPIA_TYPE_NAME_MAX_LENGTH;
    statusPicklistValues = []
    @track filesData = [];

    connectedCallback() {
        getCreateAccess().then((result) => {
            this.hasNewTypePermission = result;
            this.isLoading = false;
        });
    }

    // Getters
    get getToastInnerClass() {
        return "slds-icon_container slds-icon-utility-" + this.toastType + " slds-m-right_small slds-no-flex slds-align-top";
    }

    get getToastOuterClass() {
        return "slds-notify slds-notify_toast slds-theme_" + this.toastType;
    }

    get getToastIconName() {
        return this.toastType === TOAST_VARIANT_SUCCESS ? "utility:success" : "utility:error";
    }

    get getToastHeaderLabel() {
        return this.toastType === TOAST_VARIANT_SUCCESS ? "IPIA Record Type successfully created." : "Error";
    }

    get getHeaderClass() {
        return this.hasNewTypePermission ? "slds-modal__header" : "slds-modal__header slds-notify slds-notify_alert slds-alert_warning custom-modal__header-transparent slds-p-around--medium";
    }

    get getHeaderLabel() {
        return this.hasNewTypePermission ? "New IPIA Type" : "No Permissions";
    }

    get getExemptionOptions() {
        return [
            { label: 'No', value: false },
            { label: 'Yes', value: true }
        ];
    }

    get getTemplateRequired() {
        return !this.exemptionValue;
    }

    // Wires
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: IPIA_TYPE_STATUS })
    picklistResults({ error, data }) {
        if (data) {
            this.statusPicklistValues = data.values;
        } else if (error) {
            console.error("Error loading picklist values", error);
        }
    }

    // Event Handlers
    handleFilesChange(event) {
        const files = event.target.files;
        if (files.length > 0) {
            if (this.filesData.length >= 1) {
                this.filesData = [];
            }

            const file = files[0];

            if (file.size > MAX_FILE_SIZE) {
                this.showToast(TOAST_VARIANT_ERROR, "File size exceeded. A file is larger than 2.4MB.", TOAST_VARIANT_ERROR);
                return;
            }
            const fileReader = new FileReader();
            fileReader.onloadend = (() => {
                const fileToUpload = {
                    fileName: file.name
                };
                let result = fileReader.result;
                const base64 = 'base64,';
                const i = result.indexOf(base64) + base64.length;
                fileToUpload.fileBase64 = result.substring(i);

                this.filesData.push(fileToUpload);
            });
            fileReader.readAsDataURL(file);
        }
    }

    handleExemptionChange(event) {
        this.exemptionValue = event.detail.value === 'true';
    }

    saveNewRecord() {
        if (this.validateFields()) {
            let ipiaType = {
                [IPIA_TYPE_NAME.fieldApiName]: this.template.querySelector("lightning-input[data-formfield=\"formName\"]").value,
                [IPIA_TYPE_DESCRIPTION.fieldApiName]: this.template.querySelector("lightning-input[data-formfield=\"description\"]").value,
                [IPIA_TYPE_EXEMPTION.fieldApiName]: this.exemptionValue,
                [IPIA_TYPE_STATUS.fieldApiName]: this.statusPicklistValues.find(picklist => picklist.value === STATUS_ACTIVE).value,
                [IPIA_TYPE_DOCUSIGN_TEMPLATE_ID.fieldApiName]: this.template.querySelector("lightning-input[data-formfield=\"docusignTemplateId\"]").value
            };

            // Create IPIA Type Record and ContentVersion
            createIPIAType({ ipiaType: ipiaType, fileName: this.filesData[0]?.fileName, fileBase64: this.filesData[0]?.fileBase64 }).then(result => {
                if (result != null) {
                    console.log("File uploaded successfully");
                    this.showToast(TOAST_VARIANT_SUCCESS, "IPIA Type created successfully", 2000);
                    this.createdIpia = result;
                } else {
                    console.error("Error uploading file");
                    this.showToast(TOAST_VARIANT_ERROR, "Error creating IPIA Type.", 3000);
                }
            }).catch(error => {
                let errorMessages = reduceErrors(error);
                for (let i = 0; i < errorMessages.length; i++) {
                    if (errorMessages[i].includes("name for the IPIA Type already exist")){
                        let formName = this.template.querySelector("lightning-input[data-formfield=\"formName\"]");
                        formName.setCustomValidity(errorMessages[i]);
                        formName.reportValidity();
                        errorMessages.splice(i, 1);
                    }
                    else if (errorMessages[i].includes("duplicate value found: DocusignTemplate__c duplicates value on record with id:")){
                        let formName = this.template.querySelector("lightning-input[data-formfield=\"docusignTemplateId\"]");
                        formName.setCustomValidity("The DocuSign Template ID for the IPIA Type already exist");
                        formName.reportValidity();
                        errorMessages.splice(i, 1);
                    }
                }

                if (errorMessages.length > 0) {
                    console.error("error", errorMessages);
                    this.showToast(TOAST_VARIANT_ERROR, errorMessages.join(", "), 3000);
                }
            });
        }
    }

    removeFile() {
        this.filesData = [];
    }

    // Helper Methods
    showToast(type, message, time) {
        this.toastType = type;
        this.toastMessage = message;
        this.autoCloseTime = time;
        this.showToastBar = true;
        if (type === TOAST_VARIANT_SUCCESS) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.showToastBar = false;
                this.closeModal();
            }, this.autoCloseTime);
        } else {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.showToastBar = false;
            }, this.autoCloseTime);
        }
    }

    validateFields() {
        let fieldValidity = [];
        [...this.template.querySelectorAll("lightning-input, lightning-combobox")].forEach(field => {
            field.setCustomValidity("");
        });

        [...this.template.querySelectorAll("lightning-input, lightning-combobox")].forEach(field => {
            fieldValidity.push(field.reportValidity());
        });

        // Specific validation for formDescription length
        this.formDescription = this.template.querySelector("lightning-input[data-formfield=\"description\"]").value;

        if (this.formDescription.length > 255) {
            const formDescriptionField = this.template.querySelector("lightning-input[data-formfield=\"description\"]");
            formDescriptionField.setCustomValidity("Form Description cannot exceed 255 characters.");
            formDescriptionField.reportValidity();
            fieldValidity.push(false);
        } else {
            const formDescriptionField = this.template.querySelector("lightning-input[data-formfield=\"description\"]");
            formDescriptionField.setCustomValidity("");
            formDescriptionField.reportValidity();
        }

        if (!this.statusPicklistValues.some((picklist) => picklist.value === STATUS_ACTIVE)) {
            this.showToast(TOAST_VARIANT_ERROR, "Active status is not available", 3000);
            fieldValidity.push(false);
        }

        return !fieldValidity.includes(false);

    }

    closeModal() {
        if (!this.fromLwc) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        }
        else {
            this.dispatchEvent(new CustomEvent('close', { detail: { createdIpia: this.createdIpia } }));
        }
    }

    closeToast() {
        this.showToastBar = false;
    }
}