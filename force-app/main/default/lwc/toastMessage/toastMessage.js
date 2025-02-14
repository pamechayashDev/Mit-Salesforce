import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
//you can't directly dispatch events from a component that doesn't extend LightningElement
export default class ToastMessage extends LightningElement {
    @api
    showToast(toastMessageDetails) {
        this.dispatchEvent(new ShowToastEvent(toastMessageDetails));
    }
}