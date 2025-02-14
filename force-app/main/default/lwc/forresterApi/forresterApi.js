import { LightningElement, api, track, wire } from 'lwc';
import restPost from '@salesforce/apex/AwsApiCall.restPost';
import createGuestAccounts from '@salesforce/apex/GuestAccount.createGuestAccounts';
import onBeforeApproveValidationByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.onBeforeApproveValidationByDisclosureId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Disclosure__c.Status__c';
import ID_FIELD from '@salesforce/schema/Disclosure__c.Id';
import REJECTION_REASON from '@salesforce/schema/Disclosure__c.Rejection_Reason__c';
import REJECTED_BY from '@salesforce/schema/Disclosure__c.Rejected_By__c';
import NAME_FIELD from '@salesforce/schema/User.Name'
import CASE_NUMBER_FIELD from '@salesforce/schema/Disclosure__c.Case_Number__c';
import CASE_RECID_FIELD from '@salesforce/schema/Disclosure__c.Case_RecId__c'
import STAGE_FIELD from '@salesforce/schema/Disclosure__c.Stage__c';
import { populateBioTangData } from 'c/biotang';
import { populateInventionData } from 'c/invention';
import { populateSoftwareCodeData } from 'c/softwareCode';
import { populateCopyrightData } from 'c/copyright';
import Id from '@salesforce/user/Id';
import LightningAlert from 'lightning/alert';
import { filterAWSErrorMessage } from "c/forresterUtils";
import globalStyles from '@salesforce/resourceUrl/globalStyles';
import { loadStyle } from 'lightning/platformResourceLoader';

import allowDisclosureApproveReject from '@salesforce/customPermission/Disable_Approve_Reject_Button';

const DISCLOSURE_FIELDS = [
  'Disclosure__c.Status__c',
  'Disclosure__c.Rejected_By__c',
  'Disclosure__c.Rejection_Reason__c',
  'Disclosure__c.Disclosure_Reason__c',
  'Disclosure__c.Submitted_Date__c',
  'Disclosure__c.External_ID__c',
  'Disclosure__c.CreatedById',
  'Disclosure__c.Submitting_Contact__r.Name',
  'Disclosure__c.Submitting_Contact__r.Id',
  'Disclosure__c.Case_Number__c',
  'Disclosure__c.Stage__c',
  'Disclosure__c.Name__c',
  'Disclosure__c.Description__c',
  'Disclosure__c.Funding_Details__c',
  'Disclosure__c.Submitted_Date__c',
  'Disclosure__c.SubmittedOnBehalf__c',
  'Disclosure__c.RecordType.DeveloperName'

]
export default class ForresterApi extends LightningElement {
  @api recordId;
  userId = Id;
  disclosure;
  user;
  @track showModal = false;
  statusSelected = 'Approve';
  rejectionReason = '';
  currentStage = 'Review';
  isLoading = true;
  disclosureStatus = '';

  @track pathStepClosed;

  hasDisclosureConcluded = false;

  get statusPicklist() {
    return [
      { label: 'Approve', value: 'Approve' },
      { label: 'Reject', value: 'Reject' },
    ];
  }

  handleStatusPicklistChange(event) {
    this.statusSelected = event.detail.value;
  }
  handleRejectionReason(event) {
    this.rejectionReason = event.detail.value;
  }

  toggleModal() {
    this.showModal = !this.showModal;
  }

  @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
  handleDisclosure({ error, data }) {

    if (data) {
      console.info('✅ track userid:', this.userId)
      this.disclosure = data;
      this.hasDisclosureConcluded = this.checkHasDisclosureConcluded; // Call this as a getter and not as a function
      this.disclosureStatus = data.fields.Status__c.value;

      this.pathStepClosed = this.template.querySelector('lightning-progress-step.path-closed');
      // // Update path styling depending on Disclosure Status
      if (this.disclosureStatus === 'Rejected') {
        this.addStylingWhenRejected();
      } else if (this.disclosureStatus === 'Approved') {
        this.addStylingWhenApproved();
      }

      // Enable 'Approve or Reject' button when Disclosure Status is 'Inventor submitted'
      if (this.disclosureStatus === 'Inventor Submitted') {
        this.template.querySelector('lightning-button.set-stage').disabled = false;
      }



      this.isLoading = false;
    } else if (error) {
      this.isLoading = false;
      console.error('🔴 Fetch Record Error', error)
    }
  }

  updateDisclosure(caseNumber, caseRecid, status, errorMessages ) {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = this.disclosure.id;
    fields[STATUS_FIELD.fieldApiName] = status;
    if (caseNumber !== undefined) {
      fields[CASE_NUMBER_FIELD.fieldApiName] = caseNumber;
    }

    fields[STAGE_FIELD.fieldApiName] = this.currentStage;

    if (caseRecid !== undefined) {
      fields[CASE_RECID_FIELD.fieldApiName] = caseRecid.toString();
    }
    
    const recordInput = { fields };

    const showNotification = (errorMessages === undefined || errorMessages.length === 0) ? true : false;

    updateRecord(recordInput)
      .then(() => {
        if (caseNumber !== undefined && status === 'Approved') {
          if (showNotification) {
            this.showNotification('Status Updated', 'success', 'The disclosure has successfully been approved.');
          } else {
            LightningAlert.open({
              message: errorMessages.join('\r\n'),
              theme: 'warning',
              label: 'The disclosure has been approved with errors.',
            });
          }
        }
        this.addStylingWhenApproved();
        this.toggleModal();
      })
      .catch(error => {
        console.log('🔴 [APPROVE UPDATE ERROR]', error)
        LightningAlert.open({
          message: this.errorToContentList(error),
          theme: 'error',
          label: 'The status could not be updated',
        });
        this.isLoading = false;
      })
  }
  async submitStatusChange() {
    this.isLoading = true;
    if (this.statusSelected === 'Approve') {
      const isValid = await onBeforeApproveValidationByDisclosureId({ id: this.disclosure.id })
        .catch(error => {
          console.log('🔴 [VALIDATION ERROR]', error)
          LightningAlert.open({
            message: this.errorToContentList(error),
            theme: 'error',
            label: 'Validation Error',
          });
          this.error = error;
          this.isLoading = false;
        })
      console.log(' [VALIDATION]', isValid)
      if (isValid) {
        this.onApprove();
      }
    } else if (this.statusSelected === 'Reject') {
      const fields = {};
      fields[ID_FIELD.fieldApiName] = this.disclosure.id;
      fields[STATUS_FIELD.fieldApiName] = 'Rejected';
      fields[REJECTION_REASON.fieldApiName] = this.rejectionReason;
      fields[REJECTED_BY.fieldApiName] = 'TLO Admin';
      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          this.showNotification('Status Updated', 'success', 'The disclosure has successfully been rejected')
          this.addStylingWhenRejected();
          this.toggleModal();
        })
        .catch(error => {
          console.log('🔴 [REJECT UPDATE ERROR]', error)
          LightningAlert.open({
            message: this.errorToContentList(error),
            theme: 'error',
            label: 'The status could not be updated',
          });
          this.error = error;
          this.isLoading = false;
        })
    }
  }

  /*
   On network errors the error.body.error is set
   On SF Validation or triggers the  error.body.message is set
   Java script standard error uses error.message.
   */
  errorToContentList(error) {

    const messages = []
    if (error.message) {
      messages.push(filterAWSErrorMessage(error.message));
    }
    if (error.body?.error) {
      messages.push(filterAWSErrorMessage(error.body?.error));
    }
    if (error.body?.message) {
      messages.push(filterAWSErrorMessage(error.body?.message));
    }
    if (error.body?.output?.errors) {
      error.body?.output?.errors.forEach(x => {
        messages.push(filterAWSErrorMessage(x.message))
      })
    }

    return messages.join('\r\n');

  }
  get checkHasDisclosureConcluded() {
    if (!this.disclosure || (allowDisclosureApproveReject === true && this.disclosureStatus === 'Inventor Submitted')) {
      return false;
    }
    return allowDisclosureApproveReject === undefined || this.disclosure.fields.Status__c.value === 'Approved' || this.disclosure.fields.Status__c.value === 'Rejected' || this.disclosureStatus !== 'Inventor Submitted';
  }

  get rejectedOptionSelected() {
    if (!this.showModal) {
      return false;
    }
    return this.statusSelected === 'Reject';
  }

  get submitButtonDisabled() {
    if (!this.showModal) {
      return true;
    }
    return this.statusSelected === 'Reject' && this.rejectionReason.trim() === '' || this.isLoading;
  }

  addStylingWhenRejected() {
    this.currentStage = 'Processed';
    this.pathStepClosed.label = 'Rejected';
    this.pathStepClosed.classList.add('slds-is-lost');
    this.pathStepClosed.classList.add('slds-path__item');
  }

  addStylingWhenApproved() {
    this.currentStage = 'Processed';
    this.pathStepClosed.label = 'Approved';
    this.pathStepClosed.classList.add('slds-is-complete');
    this.pathStepClosed.classList.add('slds-path__item');
  }

  showNotification(title, variant, message) {
    const event = new ShowToastEvent({
      title: title,
      variant: variant,
      message: message
    });
    this.dispatchEvent(event);
  }


  @wire(getRecord, { recordId: Id, fields: [NAME_FIELD] })
  handleUser({ error, data }) {
    if (data != null) {
      this.user = data;
      console.log('✅ User Assigned', this.user)
    } else if (error) {
      console.log('🔴', error.body)
      throw error
    }
  }

  headerData = {
    'Content-Type': 'application/json;charset=UTF-8'
  }

  onApprove() {
    this.isLoading = true;
    const headingLabel = 'Disclosure could not be approved'
    this.isLoading = true;
    if (this.statusSelected === 'Approve') {
      if (this.disclosure == null) {
        throw new Error('Unable to find record matching id: ' + this.recordId)
      }
      createGuestAccounts({ disclosureId: this.disclosure.id }).then(result => {
        console.log('createGuestAccounts result', result)
        this.postToForrester();
      }).catch(error => {
        this.error = error;
        console.error('🔴 On Approve :', error)
        LightningAlert.open({
          message: this.errorToContentList(error),
          theme: 'error',
          label: headingLabel,
        });
        this.isLoading = false;
      });

    }
  }

  postToForrester() {
    this.isLoading = true;
    const headingLabel = 'Disclosure could not be approved'
    let reviewClose = this.template.querySelector('lightning-progress-step.path-closed');
    const apiName = 'forresterApi'
    console.log('💻 Testing Post to Forrester')
    if (this.disclosure == null) {
      console.error('🔴 Error: Unable to find record matching id: ' + this.recordId)
      throw new Error('Unable to find record matching id: ' + this.recordId)
    } else {
      this.populateBodyData().then((bodyData) => {
        console.log('📄', bodyData)
        console.log('stringify bodyData', JSON.stringify(bodyData))
        restPost({ api: apiName, resource: `/disclosures`, headers: this.headerData, body: JSON.stringify(bodyData) })
          .then(result => {
            result = JSON.parse(result)
            console.debug('result', result)
            if (result.message === 'Success' || result.status === 'SUCCESS' || result.status === 'SUCCESS_WITH_WARNING') {
              const status = 'Approved';
              const messages = []
              if (result.status === 'SUCCESS_WITH_WARNING') {
                // a case number was generated but there was errors on inserting inventors for example
                // Cannot re-submit will cause duplicate Mendix ID error.
                result.dataObject.forEach(x => {
                  if (x.status === 'ERROR') {
                    messages.push(filterAWSErrorMessage(x.message));
                  }
                });

              }
              reviewClose.className = 'path-closed slds-path__item slds-is-complete';
              this.template.querySelector('lightning-button.set-stage').disabled = true;
              this.updateDisclosure(result.caseNumber, result.caseRecid, status, messages)
              this.isLoading = false;
              this.isClosed = true;

            } else {
              LightningAlert.open({
                message: filterAWSErrorMessage(result.message),
                theme: 'error',
                label: headingLabel,
              });
              this.postError = result.message;
              this.isLoading = false;
            }
          })
          .catch(error => {
            this.error = error;
            console.error('🔴 restPost forrester api :', error)
            LightningAlert.open({
              message: this.errorToContentList(error),
              theme: 'error',
              label: headingLabel,
            });
            this.isLoading = false;
          })
      })
    }
  }
  populateBodyData() {
    console.debug(this.disclosure)
    console.debug(this.disclosure.fields.RecordType.value.fields.DeveloperName.value)
    if (this.disclosure != null && this.disclosure.fields.RecordType.value.fields.DeveloperName.value=== 'BioTang_Disclosure') {
      console.log('BioTang object type')
      return populateBioTangData(this.disclosure, this.user)
    } else if (this.disclosure != null && this.disclosure.fields.RecordType.value.fields.DeveloperName.value === 'Invention_Disclosure') {
      console.log('Invention object type')
      return populateInventionData(this.disclosure, this.user)
    } else if (this.disclosure != null && this.disclosure.fields.RecordType.value.fields.DeveloperName.value === 'Copyright_Disclosure') {
      console.log('Copyright object type')
      return populateCopyrightData(this.disclosure, this.user)
    } else if (this.disclosure != null && this.disclosure.fields.RecordType.value.fields.DeveloperName.value === 'Software_Code_Disclosure') {
      console.log('Software Code object type')
      return populateSoftwareCodeData(this.disclosure, this.user)
    }
    LightningAlert.open({
      message: this.disclosure.recordTypeInfo.name,
      theme: 'error',
      label: 'Un-supported record type.',
    });

    this.isLoading = false;
    return null;
  }

  connectedCallback() {
    loadStyle(this, globalStyles);
  }

  renderedCallback() {
    this.reviewClose = this.template.querySelector('lightning-progress-step.path-closed');
    this.reviewPath = this.template.querySelector('lightning-progress-step.path-review');
  }
}