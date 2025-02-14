import { LightningElement, api } from 'lwc';

export default class FilterModal extends LightningElement {
    @api profileData;
    showModal = false;
    
    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    inputJobTitleChange(event){
        console.log('there: ',event.target.value);
        event.preventDefault();

        const selectEvent = new CustomEvent('selection', {
            detail: event.target.value
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
     }
}