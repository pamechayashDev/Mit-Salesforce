/**
 * Created by Andreas du Preez on 2024/07/23.
 */

import { NavigationMixin } from "lightning/navigation";
import { api, LightningElement, wire, track } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import {
    determineActiveStatus, determineAffiiation, getBirthdate,
    getDisplayName,
    getEmail, getFullName, getInstitution,
    jitGetCreateContact,
    peopleSearch,
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
import IPIA_TYPE_STATUS_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__r.Status__c";
import IPIA_TYPE_EXEMPTION_FIELD from "@salesforce/schema/IPIA_Record__c.IPIA_Type__r.Exemption__c";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSandboxJITEmail from '@salesforce/apex/GuestAccount.getSandboxJITEmail'
import deleteIpiaRecords from '@salesforce/apex/IpiaRecordFetch.deleteIpiaRecords'

const IPIA_FIELDS = [
    IPIA_NAME_FIELD,
    IPIA_MIT_ID_FIELD,
    IPIA_SIGN_DATE_TIME_FIELD,
    IPIA_FORM_NAME_FIELD,
    IPIA_TYPE_ID_FIELD,
    IPIA_TYPE_NAME_FIELD,
    IPIA_TYPE_EXEMPTION_FIELD,
    IPIA_TYPE_STATUS_FIELD
];

export default class IPIAHeader extends NavigationMixin(LightningElement) {
    @api recordId;

    record;
    peopleSearchFields = {};
    contactName;
    hasPlpSearchResponse;
    loading = true;
    timezone = TIME_ZONE;
    ampm = true;
    userHasDeletePermission = false;
    showDeleteConfirmationModal = false;

    @track type='success';
    @track message;
    @track showToastBar = false;
    autoCloseTime = 3000;
    variant;

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

    // Wire Methods
    @wire(getRecord, { recordId: "$recordId", fields: IPIA_FIELDS })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            Promise.all([
                this.getPeopleSearchFields()
            ]).then(() => {
                this.hasPlpSearchResponse = (Object.keys(this.peopleSearchFields).length != 0);
                this.contactName = this.peopleSearchFields.name;
                this.loading = false;
            });
        }
        if (record.error) {
            this.error = true;
        }
    }

    @wire(IsConsoleNavigation)
    isConsoleNavigation;

    @wire(getObjectInfo, { objectApiName: IPIA_RECORD.objectApiName })
    ipiaRecordSchema({ error, data }) {
        if (data) {
            this.userHasDeletePermission = data?.deletable;
        }
        if (error) {
            console.error("Error loading IPIA Record Schema", error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading IPIA Record Schema",
                    message: error?.body?.message,
                    variant: "error"
                })
            );
        }
    }

    clearFields() {
        this.peopleSearchFields = {};
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

    async navToContact() {
        if (!this.hasPlpSearchResponse) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There is no contact associated with this MIT ID. Please contact your System Admin',
                    variant: 'error'
                })
            );
            
            return;
        }

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
            type: "standard__recordPage",
            attributes: {
                recordId: this.ipiaTypeId,
                actionName: "view"
            }
        });
    }

    // Event Handlers
    showDeleteConfirmation() {
        this.showDeleteConfirmationModal = true;
    }

    handleDeleteCancel() {
        this.showDeleteConfirmationModal = false;
    }

    async handleDelete() {
        try {
            const result = await deleteIpiaRecords({ recordId: this.recordId });

            if (result.includes('Success')) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: `IPIA "${this.name}" was deleted.`,
                        variant: 'success'
                    })
                );
                this.showDeleteConfirmationModal = false; // Close modal if needed
                // Optionally refresh the page or navigate elsewhere
                if (!this.isConsoleNavigation) {
                    return;
                }

                // Use setTimeout to delay the tab closing by 1 seconds (1000ms)
                const { tabId } = await getFocusedTabInfo();
                setTimeout(async () => {
                    await closeTab(tabId);
                }, 1000);
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
    }
}