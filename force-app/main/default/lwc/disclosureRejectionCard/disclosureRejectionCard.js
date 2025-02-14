import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { getRecord } from 'lightning/uiRecordApi';
import getDisclosureInventorByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getDisclosureInventorByDisclosureId';
import getContactById from '@salesforce/apex/DisclosureRecordFetch.getContactById';

const DISCLOSURE_FIELDS = [
    'Disclosure__c.Status__c',
    'Disclosure__c.Rejected_By__c',
    'Disclosure__c.Rejection_Reason__c',
    'Disclosure__c.Disclosure_Reason__c',
    'Disclosure__c.Disclosure_Reason_Comment__c',
    'Disclosure__c.Case_Number__c'
]
export default class DisclosureRejectionCard extends NavigationMixin(LightningElement) {
    @api recordId;

    rejectionBy;
    rejectionReason;
    rejectionData = null;

    showEmailRecipientModal = false;
    fetchInventorsError = false;
    fetchInventorsErrorText = '';
    emailRecipientsList = [];
    loadingEmailRecipientList = false;

    // showCaseNumberModal = true;
    // fetchCaseNumberError = false;
    // fetchCaseNumberErrorText = '';
    // caseNumber = '';
    // loadingCaseNumber = false;
    // caseNumberValidationError = false;

    toggleEmailRecipientsModal() {
        this.showEmailRecipientModal = !this.showEmailRecipientModal;
    }

    // toggleCaseNumberModal() {
    //     this.showCaseNumberModal = !this.showCaseNumberModal;
    // }

    // handleCaseNumberChange(event) {
    //     //regex test to see if the case number contains only numbers and letters
    //     let regex = /^[a-zA-Z0-9]+$/;

    //     if (!event.target.value.length > 0 || !regex.test(event.target.value)) {
    //         this.caseNumberValidationError = true;
    //         return;
    //     }

    //     this.caseNumberValidationError = false;
    //     this.caseNumber = event.target.value;
    // }

    // handleCaseNumberSubmit() {
    //     this.loadingCaseNumber = true;
    //     this.fetchCaseNumberError = false;
    //     this.fetchCaseNumberErrorText = '';
    //     console.log(this.caseNumber);
    //     this.loadingCaseNumber = false;
    // }

    getEmailRecipientList = async () => {
        this.loadingEmailRecipientList = true;
        try {
            this.fetchInventorsError = false;
            this.fetchInventorsErrorText = '';

            const response = await getDisclosureInventorByDisclosureId({ disclosureId: this.recordId });//

            //if there are inventors, get their TLO contact info and push it to the emailRecipientsList
            if (response && response.length > 0) {
                let emailFetchArray = [];

                try {
                    //some magic for doing a bunch of async calls in parallel
                    //this generates
                    const contacts = new Set();
                    for (let i = 0; i < response.length; i++) {
                        //Assumptions are made here, All inventors should get a review and Sign Disclosure email. (If not signed, the submitter will not get Sign email)
                        //Email to the Submitter that TLO Approved and Primary Inventors that TLO Approved.
                        // Everyone who gets sent a notification - not matter which type approved or pls review and sign should be listed on this popup.
                        contacts.add(response[i].Contact__c);
                        //If not SOB the Submitter will be one of the Inventors.
                        if (response[i].Disclosure__r.SubmittedOnBehalf__c == true) {
                            contacts.add(response[i].Disclosure__r.Submitting_Contact__c);
                        }
                    }
                    contacts.forEach(key => {
                        emailFetchArray.push(getContactById({ id: key }));
                    })
                    this.emailRecipientsList = await Promise.all(emailFetchArray);


                } catch (error) {
                    console.error(`%c [INVENTORS ERROR]`, `color: red`, error);
                    this.fetchInventorsError = true;
                    this.fetchInventorsErrorText = 'Could not load the inventors for this disclosure.'
                }
            }

            //if there are no inventors, set the error flag to true
            if (response.length === 0) {
                this.fetchInventorsError = true;
                this.fetchInventorsErrorText = 'There are no inventors for this disclosure.'
            }
        } catch (error) {
            console.error(`%c [INVENTORS ERROR]`, `color: red`, error);
            this.fetchInventorsError = true;
            this.fetchInventorsErrorText = 'Could not load the inventors for this disclosure.'
        }
        this.loadingEmailRecipientList = false;
    }


    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.loadingCaseNumber = true;
            this.rejectionData = data;
            this.rejectionBy = data.fields.Rejected_By__c.value;
            this.rejectionReason = data.fields.Rejection_Reason__c.value;
            // this.caseNumber = data.fields.Case_Number__c.value ?? '';
            // this.loadingCaseNumber = false;
            this.getEmailRecipientList();
        } else if (error) {
            console.error(error)
        }
    }

    get isRejected() {
        if (!this.rejectionData) return false;

        if (this.rejectionData && this.rejectionData.fields.Status__c?.value === 'Rejected') {
            return true;
        }
        return false;
    }

    get isApproved() {
        if (!this.rejectionData) return false;

        if (this.rejectionData && this.rejectionData.fields.Status__c?.value === 'Approved') {
            return true;
        }
        return false;
    }

    // get disableCaseNumberSubmitButton() {
    //     if (this.caseNumber.length === 0 || this.caseNumberValidationError || this.loadingCaseNumber) {
    //         return true;
    //     }
    //     return false;
    // }

    // get disableCaseNumberInputField() {
    //     if (this.loadingCaseNumber) {
    //         return true;
    //     }
    //     return false;
    // }

    navigateToTloContactDetails(event) {
        event.preventDefault();
        let contact = event.target.id.split('-');
        contact = contact[0];

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contact,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
}