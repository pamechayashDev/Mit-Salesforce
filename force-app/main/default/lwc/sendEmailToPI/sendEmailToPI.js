import { LightningElement, api } from 'lwc';
import sendEmail from '@salesforce/apex/SendEmailToPIController.sendEmailUsingTemplate';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class SendEmailToPI extends LightningElement {

@api recordId;
spinnerActive = false;
modalOpen = true;

renderedCallback(){
    if (this.recordId){
        modalOpen = true;
    }
}

handleClose() {
   this.modalOpen = false; 
}

sendEmail() {
    this.spinnerActive = true;
    console.log('record Id: ',this.recordId);
    console.log('Quick Action Called');
    if(this.recordId){
        this.sendEmailMethod();
    }else{
        this.spinnerActive = false;
        const evt = new ShowToastEvent({
                title: 'Error! ',
                message: 'No Record Found',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
    }
    
}

sendEmailMethod(){
    sendEmail({ recId : this.recordId})
        .then((result) => {
            this.spinnerActive = false;
            const evt = new ShowToastEvent({
                title: 'Success! ',
                message: 'Email has been sent.',
                variant: 'success',
            });
            this.dispatchEvent(evt);
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


}