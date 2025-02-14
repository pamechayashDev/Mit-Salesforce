import { LightningElement, api } from 'lwc';

export default class UtilizationReportErrorTableModal extends LightningElement {
    @api errorData; // Error data passed from the parent component

    columns = [
        { label: 'Field', fieldName: 'field'},
        { label: 'Message', fieldName: 'message', wrapText: true }
    ];

    handleCloseClick() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    get errorTitleWithCount() {
        // Check if errorData is present and is an array
        const count = Array.isArray(this.errorData) ? this.errorData.length : 0;
        return `Errors (${count})`;
    }

    get isDataPresent() {
        return this.errorData && this.errorData.length > 0;
    }
    
}