/**
 * Created by Andreas du Preez on 2024/07/24.
 */

import { NavigationMixin } from 'lightning/navigation';
import { api, LightningElement, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { peopleSearch,
    determineActiveStatus,
    determineAffiiation,
    getFullName,
    getBirthdate,
    getDisplayName,
    getEmail,
    getInstitution,
    jitGetCreateContact,
    reduceErrors
} from "c/utils";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import IPIA_RECORD from "@salesforce/schema/IPIA_Record__c";
import IPIA_NAME_FIELD from "@salesforce/schema/IPIA_Record__c.Name";
import IPIA_MIT_ID_FIELD from "@salesforce/schema/IPIA_Record__c.MitId__c";
import IPIA_SIGN_DATE_TIME_FIELD from "@salesforce/schema/IPIA_Record__c.SignDatetime__c";
import IPIA_FORM_NAME_FIELD from "@salesforce/schema/IPIA_Record__c.FormName__c";
import IPIA_TYPE_ID_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__c";
import IPIA_TYPE_NAME_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__r.Name";
import IPIA_TYPE_EXEMPTION_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__r.Exemption__c";
import IPIA_TYPE_STATUS_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__r.Status__c";
import IPIA_RECORD_CREATED_BY from "@salesforce/schema/IPIA_Record__c.CreatedById";
import IPIA_RECORD_CREATED_DATE from "@salesforce/schema/IPIA_Record__c.CreatedDate";
import IPIA_RECORD_MODIFIED_BY from "@salesforce/schema/IPIA_Record__c.LastModifiedBy.Name";
import IPIA_RECORD_MODIFIED_DATE from "@salesforce/schema/IPIA_Record__c.LastModifiedDate";
import IPIA_RECORD_DOCUSIGN_TEMPLATE from "@salesforce/schema/IPIA_Record__c.DocusignTemplate__c";
import IPIA_RECORD_DOCUSIGN_ENVELOPE from "@salesforce/schema/IPIA_Record__c.DocusignEnvelopeId__c";
import IPIA_RECORD_CONTACT_RECID from "@salesforce/schema/IPIA_Record__c.Contact_Recid__c";
import getCurrentIPIARecord from "@salesforce/apex/IPIAController.getCurrentIPIARecord";
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSandboxJITEmail from '@salesforce/apex/GuestAccount.getSandboxJITEmail'
import msgService from "@salesforce/messageChannel/ipiaCurrentChange__c";
import IPIA_System_Admin_Access from '@salesforce/customPermission/IPIA_System_Admin_Access';
import IPIA_Record_MIT_ID_Editable from '@salesforce/customPermission/IPIA_Record_MIT_ID_Editable';
import IPIA_Record_Edit_Historic_Data from '@salesforce/customPermission/IPIA_Record_Edit_Historic_Data';
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe, publish } from "lightning/messageService";

const IPIA_FIELDS = [
    IPIA_NAME_FIELD,
    IPIA_MIT_ID_FIELD,
    IPIA_SIGN_DATE_TIME_FIELD,
    IPIA_FORM_NAME_FIELD,
    IPIA_TYPE_ID_FIELD,
    IPIA_TYPE_NAME_FIELD,
    IPIA_TYPE_EXEMPTION_FIELD,
    IPIA_TYPE_STATUS_FIELD,
    IPIA_RECORD_CREATED_BY,
    IPIA_RECORD_CREATED_DATE,
    IPIA_RECORD_MODIFIED_BY,
    IPIA_RECORD_MODIFIED_DATE,
    IPIA_RECORD_DOCUSIGN_TEMPLATE,
    IPIA_RECORD_DOCUSIGN_ENVELOPE,
    IPIA_RECORD_CONTACT_RECID
];

export default class IPIADetails extends NavigationMixin(LightningElement) {
    @api recordId

    record;
    loading = true
    contactName;
    accordionDetailsOpen = true;

    timezone = TIME_ZONE;
    hourSet = true;
    validationError;
    peopleSearchFields = {};
    ampm = true;
    isCurrentIPIAForMITId = false;
    userHasEditAccess = false;
    isInEditMode = false;

    // Getters
    get mitId() {
        return this.record ? getFieldValue(this.record.data, IPIA_MIT_ID_FIELD) : null;
    }

    get signDateTime() {
        return this.record ? getFieldValue(this.record.data, IPIA_SIGN_DATE_TIME_FIELD) : null;
    }

    get ipiaTypeStatus() {
        return this.record ? getFieldValue(this.record.data, IPIA_TYPE_STATUS_FIELD) : null;
    }

    get exemption() {
        return this.record ? getFieldValue(this.record.data, IPIA_TYPE_EXEMPTION_FIELD) : null;
    }

    get name() {
        return this.record ? getFieldValue(this.record.data, IPIA_NAME_FIELD) : null;
    }

    get formName() {
        return this.record ? getFieldValue(this.record.data, IPIA_FORM_NAME_FIELD) : null;
    }

    get ipiaTypeId() {
        return this.record ? getFieldValue(this.record.data, IPIA_TYPE_ID_FIELD) : null;
    }

    get ipiaTypeName() {
        return this.record ? getFieldValue(this.record.data, IPIA_TYPE_NAME_FIELD) : null;
    }

    get docusignEnvelopeId() {
        return this.record ? getFieldValue(this.record.data, IPIA_RECORD_DOCUSIGN_ENVELOPE) : null;
    }

    get docusignTemplateId() {
        return this.record ? getFieldValue(this.record.data, IPIA_RECORD_DOCUSIGN_TEMPLATE) : null;
    }

    get contactRecId() {
        return this.record ? getFieldValue(this.record.data, IPIA_RECORD_CONTACT_RECID) : null;
    }

    get sectionDetailsClass() {
        return `${this.accordionDetailsOpen ? 'slds-section slds-is-open' : 'slds-section'}${this.isInEditMode ? ' custom-section-border' : ''}`;
    }

    get sectionSystemInformationClass() {
        return this.accordionSystemInformationOpen ? this.isInEditMode ? 'slds-section slds-is-open custom-section-border' : 'slds-section slds-is-open' : 'slds-section'
    }

    get fieldsAreEditable() {
        // If the user has system admin access, they can edit the fields
        if (IPIA_System_Admin_Access) {
            return true;
        }

        // If the user has edit access to the record, the record is the current IPIA for the MIT ID or the user has Edit Historic Data access if it is a historic IPIA, and the record does not contain DocuSign metadata, they can edit the fields
        return this.userHasEditAccess &&
            (this.isCurrentIPIAForMITId || IPIA_Record_Edit_Historic_Data) &&
            !this.hasDocuSignMetadata;
    }

    get hasDocuSignMetadata() {
        return this.docusignEnvelopeId || this.docusignTemplateId;
    }

    get mitIdEditable() {
        return (IPIA_Record_MIT_ID_Editable || IPIA_System_Admin_Access);
    }

    connectedCallback() {
        this.subscribeHandler();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    // Wire Methods
    @wire(MessageContext)
    messageContext;

    @wire(getObjectInfo, { objectApiName: IPIA_RECORD.objectApiName })
    ipiaRecordSchema({ error, data }) {
        if (data) {
            this.userHasEditAccess = data.updateable;
        }
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message,
                    variant: 'error'
                })
            );
            console.error(error);
            this.error = true;
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: IPIA_FIELDS })
    async handleGetRecord(record) {
        this.record = record;
        if (this.record.data) {
            Promise.all([
                this.getPeopleSearchFields(),
                getCurrentIPIARecord({ mitId: this.mitId })
            ]).then((results) => {
                this.contactName = this.peopleSearchFields.name;
                this.loading = false;

                // Check if the current IPIA is the one being viewed
                this.isCurrentIPIAForMITId = results[1] && results[1].Id === this.recordId;
            });
        }
        if (record.error) {
            this.error = true;
        }
    }

    async getPeopleSearchFields() {
        this.clearFields();
        if (this.mitId) {
            let { searchResults, error } = await peopleSearch(this.mitId);

            if (searchResults && searchResults.length > 0) {
                this.peopleSearchFields = searchResults[0];
            }
            if (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.error(error);
                this.error = true;
            }
        } else {
            this.contactName = "";
        }
    }

    // Navigation
    async navToContact() {
        try {
            const detailRow = JSON.parse(JSON.stringify(this.peopleSearchFields))
            detailRow.kerbStatus = determineActiveStatus(
                detailRow.moiraStatus
            )
            detailRow.email = getEmail(
                this.peopleSearchFields.kerbStatus,
                this.peopleSearchFields.mitPreferredEmail,
                this.peopleSearchFields.mitEmail,
                this.peopleSearchFields.alumni,
                this.peopleSearchFields.alumniEmail,
                this.peopleSearchFields.nonMitEmail
            )
            detailRow.name = getDisplayName(
                this.peopleSearchFields.preferredName,
                this.peopleSearchFields.legalFirstName,
                this.peopleSearchFields.legalMiddleName,
                this.peopleSearchFields.legalLastName
            )
            detailRow.fullName = getFullName(
                this.peopleSearchFields.legalFirstName,
                this.peopleSearchFields.legalMiddleName,
                this.peopleSearchFields.legalLastName
            )
            detailRow.birthDate = getBirthdate(
                this.peopleSearchFields.dobMonth,
                this.peopleSearchFields.dobDay
            )
            detailRow.affiliation = determineAffiiation(
                this.peopleSearchFields.affiliate,
                this.peopleSearchFields.student,
                this.peopleSearchFields.staff,
                this.peopleSearchFields.alumni,
                this.peopleSearchFields.guest
            )
            detailRow.finalInstitution = getInstitution(
                detailRow.kerbStatus,
                this.peopleSearchFields.institution
            )

            const guestAccountNeeded = (detailRow.kerbStatus === 'Active' || detailRow.alumni === true) ? false : true
            if (guestAccountNeeded) {
                detailRow.email = await getSandboxJITEmail({email: this.peopleSearchFields.email})
            }
            const response = await jitGetCreateContact(
                detailRow
            )
            const tloContact = response.data;
            const error = response.error;
            if (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            } else if (tloContact) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: tloContact.Id,
                        actionName: 'view'
                    }
                })
            }
        } catch (e) {
            this.validationError = true;
            this.errorMessage = reduceErrors(e)[0];
            console.error('Navigate to Contact error', this.errorMessage);
        }
    }

    navToIPIAType() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ipiaTypeId,
                actionName: 'view'
            }
        });
    }

    // Event Handlers
    handleDetailsSectionClick() {
        this.accordionDetailsOpen = !this.accordionDetailsOpen
    }

    handleEditRecordClick() {
        this.isInEditMode = true;
    }

    handleCloseEdit() {
        this.isInEditMode = false;
        this.publishCurrentIPIAChangeMessage();
    }

    // Helper Methods
    clearFields() {
        this.peopleSearchFields = {};
    }

    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    publishCurrentIPIAChangeMessage() {
        publish(this.messageContext, msgService, {
            mitId: this.mitId
        });
    }

    handleMessage(message){
        if (message.mitId === this.mitId) {
            getCurrentIPIARecord({ mitId: this.mitId }).then((result) => {
                this.isCurrentIPIAForMITId = result && result.Id === this.recordId;
            });
        }
    }
}