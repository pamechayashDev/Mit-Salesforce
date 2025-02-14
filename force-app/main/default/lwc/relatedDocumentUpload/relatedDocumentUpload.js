/**
* @description       : JavaScript file for handling the upload file modal functionality
**/
import { LightningElement, api, track } from 'lwc';
import uploadRelatedDocuments from '@salesforce/apex/GlobalRecordSearchController.uploadRelatedDocuments'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const MAX_FILE_SIZE = 2500000;

export default class RelatedDocumentUpload extends LightningElement {
    @api recordId;
    @api contentVersionRecordTypeId;
    @api documentTypeOptions;
    @api agreementDataSubTypeValue;
    @api agreementRecId;
    @track selectedDocumentTypeOptions;
    @track filesData = [];
    showSpinner = false;
    showUploadSpinner = false;
    uploadValidationCreation = {};
    validationErrorMessage ='';



    handleDocumentTypeOptionsChange(event) {
        this.selectedDocumentTypeOptions = event.detail.value;
        const documentTypeChangeEvent = new CustomEvent('documentTypeChange', {
            detail: { selectedDocumentTypeOptions: this.selectedDocumentTypeOptions}
        });
        this.dispatchEvent(documentTypeChangeEvent);
    }

    scrollPageToSearchResults() {
        const modalContent = this.template.querySelector('.slds-modal__content');
        if (modalContent) {
            const searchResultsSection = modalContent.querySelector('.slds-dropdown_fluid');
            if (searchResultsSection) {
                searchResultsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
    }



    handleCancelClick(event) {
        this.selectedDocumentTypeOptions;
        const cancelEvent = new CustomEvent('cancelmodal');
        this.dispatchEvent(cancelEvent);
    }

    handleFilesChange(event) {
        const files = event.target.files;
        if (files.length > 0) {
            for (let i = 0; i < files.length; i++) {
                const file = files[i];

                if (file.size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded. A file is larger than 2.4MB.');
                    return;
                }
                const reader = new FileReader();
                reader.onload = (e) => {
                    const fileContents = reader.result.split(',')[1];
                    this.filesData.push({ fileName: file.name, fileContent: fileContents });
                };
                reader.readAsDataURL(file);
            }
            this.validationErrorMessage = '';
        }else {
            this.validationErrorMessage = 'Complete this field';
        }
    }


    handleUpload(event) {
        if (!this.isInputValid()) {
            return;
        }

        this.showUploadSpinner = true;

        const uploadData = {
            recordId: this.recordId,
            contentVersionRecordTypeId: this.contentVersionRecordTypeId,
            agreementDataSubTypeValue : this.agreementDataSubTypeValue,
            agreementRecId: this.agreementRecId,
            selectedDocumentTypeOptions: this.selectedDocumentTypeOptions,
        };

        const uploadPromises = [];

        this.filesData.forEach(file => {
            uploadPromises.push(this.uploadFile(uploadData, file));
        });

        Promise.all(uploadPromises)
            .then(() => {
                this.showToast('Success', 'success', 'All files uploaded successfully');
                const successEvent = new CustomEvent('uploadsuccess');
                this.dispatchEvent(successEvent);
            })
            .catch(error => {
                this.showToast('Error', 'error', 'An error occurred while uploading files: ' + error.message);
            })
            .finally(() => {
                this.showUploadSpinner = false;
            });
    }


    uploadFile(uploadData, file) {
        return new Promise((resolve, reject) => {
            uploadData.filedata = JSON.stringify([file]);
            uploadRelatedDocuments(uploadData)
                .then(result => {
                    if (result === 'success') {
                        resolve();
                    } else {
                        reject(new Error(result));
                    }
                })
                .catch(error => {
                    reject(error);
                });
        });
    }


    removeFile(event){
        let fileName = event.currentTarget.dataset.name;
        const index = this.filesData.findIndex(obj => obj.fileName === fileName);
        if (index !== -1) {
            this.filesData.splice(index, 1);
        }
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }


    isInputValid() {
        let isValid = true;
        let errorMessage = '';

        if (this.filesData.length === 0) {
            this.validationErrorMessage ='Complete this field';
            isValid = false;
            errorMessage = 'Please ensure you have selected a file';
        }

        const combobox = this.template.querySelector('.validate');
        if (!combobox.checkValidity()) {
            combobox.reportValidity();
            isValid = false;
            errorMessage = `Please enter a valid value for ${combobox.label || combobox.name}`;
        }

        if (this.filesData.length === 0) {
            if (!combobox.checkValidity()) {
                combobox.reportValidity();
                isValid = false;
                this.validationErrorMessage ='Complete this field';
                errorMessage = `Please ensure you have selected a file and populated the required field ${combobox.label || combobox.name}`;
            }
        }

        if (!isValid) {
            this.showToast('Error', 'error', errorMessage);
        }

        return isValid;
    }


}