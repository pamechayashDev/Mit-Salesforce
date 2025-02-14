/**
 * Created by Andreas du Preez on 2024/03/18.
 */

import { api, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from "lightning/modal";
import getRelatedCRDROpenTaskCountDS from "@salesforce/apex/CrdrController.getRelatedCRDROpenTaskCount";
import STATUS_FIELD from "@salesforce/schema/Case_CRDR__c.Status__c";
import RECORD_SVG_ICON from "@salesforce/resourceUrl/record_icon_svg";
import { sortBy, determineSortPrimer, SORT_BY_TYPE_ENUMS } from "c/utils";

const stepAcceptReject = "acceptReject";
const stepViewRelatedCRDRs = "viewRelatedCRDRs";
const stepConfirmOpenTaskContinue = "confirmOpenTaskContinue";
const stepConfirmationNotTheTLOOfficer = "stepConfirmationNotTheTLOOfficer";
const stepErrorOpenChecklist = "errorOpenChecklist";
const stepErrorRelatedAwaitingDraft = "errorRelatedAwaitingDraft";
const stepErrorNoApprovalPermission = "errorNoApprovalPermission";
const errorSteps = [stepErrorOpenChecklist, stepErrorRelatedAwaitingDraft, stepErrorNoApprovalPermission];
const confirmationSteps = [stepConfirmOpenTaskContinue, stepConfirmationNotTheTLOOfficer];

const approveRejectValueOptions = [
    { label: "Approved", value: "approve" },
    { label: "Send for Adjustment/Request New Draft", value: "reject" }
];
const RECORD_ICON_SVG_ID = "record_icon";
const relatedCRDRColumns = [
    {
        label: "CRDR",
        fieldName: "crdrSObjectUrl",
        type: "url",
        typeAttributes: {
            label: {
                fieldName: "ForresterCaseCrdrName"
            },
            target: "_blank"
        }, 
        sortable: true, sortFieldName: 'ForresterCaseCrdrName', sortFieldType: SORT_BY_TYPE_ENUMS.TEXT,
        hideDefaultActions: true, initialWidth: 250
    },
    {
        label: "Case",
        fieldName: "caseSObjectUrl",
        type: "url",
        typeAttributes: {
            label: {
                fieldName: "CaseContractNumber"
            },
            target: "_blank"
        }, 
        sortable: true, sortFieldName: 'CaseContractNumber', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: true
    },
    {
        label: "Agreement",
        fieldName: "agreementSObjectUrl",
        type: "url",
        typeAttributes: {
            label: {
                fieldName: "AgreementRecId"
            },
            target: "_blank"
        }, 
        sortable: true, sortFieldName: 'AgreementRecId', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: true
    },
    {
        label: "Open Tasks",
        fieldName: "OpenTaskCount",
        type: "text",
        sortable: true, sortFieldName: 'OpenTaskCount', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: true
    },
    {
        label: "Open Checklist",
        fieldName: "RelatedHasOpenChecklist",
        type: "boolean",
        sortable: true, sortFieldName: 'CaseContractNumber', sortFieldType: SORT_BY_TYPE_ENUMS.TEXT,
        hideDefaultActions: true, 
        cellAttributes: { class: 'slds-text-heading_medium' }
    },
    {
        label: "CRDR Status",
        fieldName: "status_DisplayValue",
        type: "text",
        sortable: true,
        hideDefaultActions: true
    },
    {
        label: "TLO Officer",
        fieldName: "TLOOfficer",
        type: "text",
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 150
    }
];

export default class crdrPathAssistantModal extends LightningModal {

    // Variables
    @api caseCrdrRecId;
    @api hasPermission;
    currentStep = stepAcceptReject;
    approveRejectValueOptions = approveRejectValueOptions;
    approveRejectValue;
    showCommentTextBox = false;
    commentValue;
    isLoadingRelatedCRDRs = true;
    hasRelatedCRDRs = false;
    relatedCRDRColumns = relatedCRDRColumns;
    relatedCRDRData = [];
    currentCRDR;

    sortDirection = 'asc'
    sortedBy = ''

    // Wire Functions
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: STATUS_FIELD })
    statusPicklistValues;

    // Helper Functions
    loadRelatedCRDRs() {
        this.isLoadingRelatedCRDRs = true;
        this.hasRelatedCRDRs = false;

        getRelatedCRDROpenTaskCountDS({
            caseCrdrRecId: this.caseCrdrRecId
        }).then(result => {
            if (result) {
                if (result.length > 0) {
                    let clonedData = JSON.parse(JSON.stringify(result));

                    clonedData.forEach(row => {
                        row.crdrSObjectUrl = `/lightning/r/${row.ForresterCaseCrdrId}/view`;
                        row.caseSObjectUrl = `/lightning/r/${row.CaseId}/view`;
                        row.agreementSObjectUrl = row.AgreementId ? `/lightning/r/${row.AgreementId}/view` : '';
                        row.status_DisplayValue = this.statusPicklistValues.data.values.find(picklistValue => picklistValue.value === row.Status)?.label ?? '';
                    });

                    this.relatedCRDRData = clonedData;
                    this.hasRelatedCRDRs = this.relatedCRDRData.some(row => row.ForresterCaseCrdrRecId !== this.caseCrdrRecId);
                    this.currentCRDR = this.relatedCRDRData.find(row => row.ForresterCaseCrdrRecId === this.caseCrdrRecId);

                    if (!this.hasRelatedCRDRs) {
                        this.determineCurrentStep();
                    }
                    this.isLoadingRelatedCRDRs = false;
                } else {
                    this.close({
                        success: true,
                        approveRejectValue: this.approveRejectValue,
                        relatedCaseCRDRIds: result.map(row => row.CaseCrdrId)
                    });
                }
            }
        }).catch(error => {
            console.error("Exception thrown by Dynamic Related List. ", error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading Related CRDRs",
                    message: "Please contact your administrator.",
                    variant: "error"
                })
            );
        });
    }

    determineCurrentStep() {
        if (this.approveRejectValue === "reject") {
            this.close({
                success: true,
                approveRejectValue: this.approveRejectValue,
                commentValue: this.commentValue
            });
        } else if (this.currentStep === stepAcceptReject) {
            if (!this.hasPermission) {
                this.currentStep = stepErrorNoApprovalPermission;
            } else {
                this.currentStep = stepViewRelatedCRDRs;
                this.loadRelatedCRDRs();
            }
        } else if (this.currentStep === stepViewRelatedCRDRs && this.relatedCRDRData.some(row => row.RelatedHasOpenChecklist)) {
            this.currentStep = stepErrorOpenChecklist;
        } else if (this.currentStep === stepViewRelatedCRDRs && this.relatedCRDRData.some(row => row.Status === "AWAITING_DRAFT")) {
            this.currentStep = stepErrorRelatedAwaitingDraft;
        } else if (this.currentStep === stepViewRelatedCRDRs&& this.relatedCRDRData.some(row => row.OpenTaskCount > 0)) {
            this.currentStep = stepConfirmOpenTaskContinue;
        } else if ((this.currentStep === stepViewRelatedCRDRs || this.currentStep === stepConfirmOpenTaskContinue) && this.relatedCRDRData.some(row => row.TLOOfficerEmail !== this.currentCRDR.TLOOfficerEmail)) {
            this.currentStep = stepConfirmationNotTheTLOOfficer;
        } else if (confirmationSteps.includes(this.currentStep) || (this.currentStep === stepViewRelatedCRDRs && this.relatedCRDRData.some(row => row.OpenTaskCount === 0))) {
            this.close({
                success: true,
                approveRejectValue: this.approveRejectValue,
                relatedCaseCRDRIds: this.relatedCRDRData.map(row => row.CaseCrdrId).filter(row => row && row !== this.caseCrdrRecId) // Remove the current CRDR from the list
            });
        } else if (errorSteps.includes(this.currentStep)) {
            this.close({
                success: false
            })
        }
    }

    // Getters
    get getHeaderTitle() {
        if (this.currentStep === stepAcceptReject) {
            return "In Review";
        } else if (this.currentStep === stepViewRelatedCRDRs) {
            return "CRDR's";
        } else if (this.currentStep === stepConfirmOpenTaskContinue) {
            return "Open Task(s)";
        } else if (this.currentStep === stepConfirmationNotTheTLOOfficer) {
            return "Different TLO Officer";
        } else if (this.currentStep === stepErrorOpenChecklist) {
            return "Open Checklist";
        } else if (this.currentStep === stepErrorRelatedAwaitingDraft) {
            return "Awaiting Draft";
        } else if (this.currentStep === stepErrorNoApprovalPermission) {
            return "Restricted Action";
        }

        return "";
    }

    get isApproveRejectStep() {
        return this.currentStep === stepAcceptReject;
    }

    get isRelatedCRDRStep() {
        return this.currentStep === stepViewRelatedCRDRs;
    }

    get isConfirmationStep() {
        return confirmationSteps.includes(this.currentStep);
    }

    get isErrorStep() {
        return errorSteps.includes(this.currentStep);
    }

    get isErrorNoApprovalPermission() {
        return this.currentStep === stepErrorNoApprovalPermission;
    }

    get getErrorStepMessage() {
        if (this.currentStep === stepErrorOpenChecklist) {
            return "Approval cannot proceed: An open checklist is linked to one or more related Cases, preventing the CRDR from being approved.";
        } else if (this.currentStep === stepErrorRelatedAwaitingDraft) {
            return "Approval cannot proceed: One or more related CRDR's are still in <b>Awaiting Draft</b>, preventing the CRDR from being approved.";
        } else if (this.currentStep === stepErrorNoApprovalPermission) {
            return "Your account does not have approval permissions.";
        }

        return '';
    }

    get getConfirmationStepMessage() {
        if (this.currentStep === stepConfirmOpenTaskContinue) {
            return "You still have Open Task(s) for the CRDR(s). Do you want to continue marking it as Approved?";
        }
        else if (this.currentStep === stepConfirmationNotTheTLOOfficer) {
            return "Please note: One or more related CRDRs has a different assigned officer. By proceeding, you will approve these on behalf of the other officer(s)."
        }

        return '';
    }

    get getSubmitButtonLabel() {
        if (confirmationSteps.includes(this.currentStep) || this.currentStep === stepViewRelatedCRDRs ) {
            return "Continue"
        }
        else if (errorSteps.includes(this.currentStep)) {
            return "Ok"
        }

        return "Submit";
    }

    get getShowCancelButton() {
        return !errorSteps.includes(this.currentStep);
    }

    get relatedCRDRHeaderTitle() {
        return `CRDRs (${this.relatedCRDRData.length})`;
    }

    get recordIconUrl() {
        return `${RECORD_SVG_ICON}#${RECORD_ICON_SVG_ID}`;
    }

    get getModalHeaderClasses() {
        if (confirmationSteps.includes(this.currentStep)) {
            return 'slds-notify slds-notify_alert slds-alert_warning custom-modal__header-transparent'
        } else if (errorSteps.includes(this.currentStep)) {
            return 'slds-notify slds-notify_alert slds-alert_error custom-modal__header-transparent'
        }

        return '';
    }

    // Event Handlers
    handleApproveRejectChange(event) {
        this.approveRejectValue = event.target.value;
        console.log('checkPermissions() hasPermission===> ',this.hasPermission);
        this.showCommentTextBox = this.approveRejectValue === "reject";
    }

    handleCancelButton() {
        this.close();
    }

    handleCommentTextChange(event) {
        this.commentValue = event.target.value;
    }

    handleSubmitButton() {
        if (!this.approveRejectValue) {
            return;
        }

        this.determineCurrentStep();
    }

    onHandleSort(event) {
        console.log('onHandleSort');
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.relatedCRDRData]
        const sortFieldType = this.relatedCRDRColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.relatedCRDRColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.relatedCRDRData = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }
}