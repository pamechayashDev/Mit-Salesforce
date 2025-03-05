import { LightningElement, api, wire, track } from 'lwc';
import sendEmail from '@salesforce/apex/SendEmailController.sendEmail';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getEmailInfo from '@salesforce/apex/GetEmailData.getEmailInfo';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class SendMail extends LightningElement {

    @api recordId;
    spinnerActive = false;
    open = true;
    emailInfo;
    toEmail = '';
    ccEmail = '';
    emailBody = '';
    templateId = '';
    PersonContactId = '';
    isPrimaryPiLookupNull = false;
    renderedCallback() {
        if (this.recordId) {
            open = true;
            console.log('open===');


        }

    }


    @api invoke() {


        this.open = true;
        this.toEmail = '';
        getEmailInfo({ recId: this.recordId }).then(data => {
            console.log('----', data);
            if (data) {
                console.log('----', data);
                this.emailInfo = data;
                this.toEmail = data.to;
                this.templateId = data.templateId;
                console.log('personCon--', data.PersonContactId);
                this.PersonContactId = data.PersonContactId;
                this.isPrimaryPiLookupNull = String.valueOf(data.isPrimaryPiLookupNull) == 'true' ? true : false;
                let ccString = '';
                this.ccEmailsList = [];
                this.data = [];
                for (let i = 0; i < data.cc.length; i++) {
                    this.ccEmailsList.push({
                        label: data.cc[i]
                    });
                    this.data.push(data.cc[i]);
                }

                console.log('cc---Email', this.ccEmailsList);
                this.toEmail = data.to;
                this.editedEmailBody = data.templateBody;
                this.emailBody = data.templateBody;

                console.log('---', data);
                if (!this.toEmail) {
                    const evt = new ShowToastEvent({
                        title: 'Error! ',
                        message: 'PI Primary Email Address is blank',
                        variant: 'Error',
                    });
                    this.dispatchEvent(evt);
                }
            }


        })



    }
    @track ccEmailsList = [

    ];

    data = [];
   editedEmailBody = '';

    handleEmailBodyChange(event){
    this.editedEmailBody = event.detail.value;
    }


    handleToEmailChange(event) {
        this.toEmail = event.detail.value;
    }

    handleClose() {
        this.open = false;
    }
    emailBodyChanged = false; 
    sendEmail() {
        this.spinnerActive = true;
        console.log('record Id: ', this.recordId);
        console.log('Quick Action Called');
        if(this.editedEmailBody!=this.emailBody){
          this.emailBodyChanged = true;
        }
        if (this.recordId) {

            this.sendEmailMethod();
        } else {
            this.spinnerActive = false;
            const evt = new ShowToastEvent({
                title: 'Error! ',
                message: 'No Record Found',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }

    }

    handleCCEmailChange(event) {
        this.ccEmail = event.detail.value;
    }
    handleOnBlur(event) {
        let val = this.ccEmail;
        console.log(val);
        this.ccEmailsList.push({
            label: val
        });
        this.data.push(val);
        this.ccEmail = '';
    }


    handleItemRemove(event) {
        let index = event.detail.index;
        this.ccEmailsList.splice(index, 1);
        this.data.splice(index, 1);
    }


    sendEmailMethod() {
        console.log(this.ccEmailsList);
   
        sendEmail({
            recId: this.recordId,
            templateId: this.templateId,
            toEmail: this.toEmail,
            ccEmails: this.data,
             bodyChanged:  this.emailBodyChanged,
             changedBody : this.editedEmailBody,
            PersonContactId: this.PersonContactId,
            isPrimaryPiLookupNull: this.isPrimaryPiLookupNull,
            byStatusChange : false
        })
            .then((result) => {
                console.log('----', result);
                this.spinnerActive = false;
                if (result != 'Missing Primary PI') {
                    const evt = new ShowToastEvent({
                        title: 'Success! ',
                        message: 'Email has been sent.',
                        variant: 'success',
                    });
                    this.open = false;



                    this.dispatchEvent(evt);
                }
                else {
                    const evt = new ShowToastEvent({
                        title: 'Error! ',
                        message: 'Missing Primary PI Account',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);

                }

            }).catch((err) => {
                this.spinnerActive = false;
                const evt = new ShowToastEvent({
                    title: 'Error! ',
                    message: 'There was an error sending the email.',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            });
    }

    get checkSubmit() {
        if (!this.toEmail) {
            return true;
        }
        else {
            return false;
        }
    }




}