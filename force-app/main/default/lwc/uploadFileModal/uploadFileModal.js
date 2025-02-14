/**
* @description       : JavaScript file for handling the upload file modal functionality
**/
import { LightningElement, api, track , wire} from 'lwc';
import  getDefaultCrdr from '@salesforce/apex/GlobalRecordSearchController.getDefaultCrdr';
import uploadFiles from '@salesforce/apex/GlobalRecordSearchController.uploadFiles'
import fetchRelatedToRecords from '@salesforce/apex/GlobalRecordSearchController.fetchRelatedToRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MAX_FILE_SIZE = 2500000;

export default class UploadFileModal extends LightningElement {
    @api recordId;
    @api recordTypes;
    @track selectedRecordType;
    @api entitySubTypeOptions;
    selectedEntitySubType;
    @api documentTypeOptions;
    @track selectedDocumentTypeOptions;
    selectSubtype = 'Select data subtype';
    selectType = 'Select data type';
    @track globalSelectedItems = [];
    @api labelName;
    @track items = [];
    @track selectedItems = [];
    searchTerm;
    @track value = [];
    searchInput = '';
    isDialogDisplay = false;
    isDisplayMessage = false;
    recordsList = [];
    @track filesData = [];
    showSpinner = false;
    showUploadSpinner = false;
    filteredRecords = [];
    @track isDropdownDisabled = true;
    @track isDropdDisabledSubEntity = true;
    hasSelectedValuesRelatedTo = true;
    hasSelectedDocumentTypes = true;
    hasSelectedDataSubTypes = true;
    hasSelectedDataTypes = true;


    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;

        this.isDropdownDisabled = !this.selectedRecordType;
        this.isDropdDisabledSubEntity = !this.selectedRecordType;
        // Clear all fields, comboboxes, and input fields
        this.selectedEntitySubType = null;
        this.selectedDocumentTypeOptions = null;
        this.searchInput = '';
        this.isDialogDisplay = false;
        this.recordsList = [];
        this.globalSelectedItems = [];
        this.items = [];
        this.value = [];
        const recordTypeChangeEvent = new CustomEvent('recordtypechange', {
            detail: { selectedRecordType: this.selectedRecordType }
        });
        this.dispatchEvent(recordTypeChangeEvent);

        let findCrdrOrCase = this.recordTypes.find(item => item.value === this.selectedRecordType);
        if(findCrdrOrCase.developerName=='CRDR' || findCrdrOrCase.developerName=='Case' || findCrdrOrCase.developerName=='Other_Agreement' || findCrdrOrCase.developerName=='Sponsor_Agreement' ){
            setTimeout(() => {
                this.selectedEntitySubType=(this.entitySubTypeOptions.length>0)?this.entitySubTypeOptions[0].value:'';
            }, 1000);
            this.isDropdDisabledSubEntity = findCrdrOrCase.developerName=='CRDR' || findCrdrOrCase.developerName=='Case' ? true :false;
            // Set the default pill label to the selected record's ID
             this.showSpinner = true;
             getDefaultCrdr({ selectedRecordDeveloperName: findCrdrOrCase.developerName, crdrRecordId: this.recordId })
                 .then(result => {
                     this.showSpinner = false;
                     if (result && result.length > 0) {
                         // Set the default data subtype based on the result
                    const selectedItem = {
                        label: result[0].label,
                        value: result[0].value,
                        recordId: result[0].recordId,
                        icon: result[0].icon,
                        variant: result[0].variant,
                        Default: true // Set Default attribute to true for default item
                    };
                         this.globalSelectedItems.push(selectedItem);
                         // Disable the dropdown for selecting the data subtype
                         this.isDropdDisabledSubEntity = findCrdrOrCase.developerName=='CRDR' || findCrdrOrCase.developerName=='Case' ? true :false;
                     }

                  this.checkForDataValidity();
                 })
                 .catch(error => {
                     this.showSpinner = false;
                     console.error('Error fetching default CRDR: ', error);
                 });
         }
    }


    handleEntitySubTypeChange(event) {
        this.selectedEntitySubType = event.detail.value;
        this.checkForDataValidity();
        const entitySubTypeChangeEvent = new CustomEvent('entitySubTypechange',{
            detail: {selectedEntitySubType: this.selectedEntitySubType}
        });
        this.dispatchEvent(entitySubTypeChangeEvent);
    }

    handleDocumentTypeOptionsChange(event) {
        this.selectedDocumentTypeOptions = event.detail.value;
       this.checkForDataValidity();
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

    onchangeSearchInput(event) {
        this.searchInput = event.target.value;
        if (this.searchInput.length >= 3) {
            this.showSpinner = true;
            // Filter records based on the search input
            this.filteredRecords = this.recordsList.filter(record => {
                return record.label.toLowerCase().includes(this.searchInput.toLowerCase()) || record.description.toLowerCase().includes(this.searchInput.toLowerCase());
            });

            // Hide spinner when filtering is completed
            this.showSpinner = false;

            this.isDialogDisplay = true;
            this.isDisplayMessage = this.filteredRecords.length === 0; // Display message if no records found
            setTimeout(() => {
                this.scrollPageToSearchResults();
            }, 0);
        } else {
            // Clear filtered records if search input length is less than or equal to 3
            this.filteredRecords = [];
            this.isDialogDisplay = false;
            this.isDisplayMessage = false; // Hide the message
        }
        this.checkForDataValidity();
    }


            // Update the showOptions method to handle the logic
        showOptions(event) {
            // Check if the search input is less than 3 characters and the input is not disabled
            if (this.searchInput.length < 3 && !this.isDropdownDisabled && this.recordsList.length > 0) {
                // Reset filtered records to the default list of items
                this.filteredRecords = [...this.recordsList];
                this.isDialogDisplay = true;
                this.isDisplayMessage = false; // Hide the "No records found" message
                setTimeout(() => {
                    this.scrollPageToSearchResults();
                }, 0);
            } else {
                // Optionally, you can add other logic here such as filtering records based on the search input
                this.isDialogDisplay = false;
                this.isDisplayMessage = true;
            }
        }


    @wire(fetchRelatedToRecords, { selectedRecordType: '$selectedRecordType', crdrRecordId: '$recordId', selectedSubEntityType: '$selectedEntitySubType' })
    wiredFetchRelatedToRecords({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.recordsList = JSON.parse(JSON.stringify(data));
                // Update filtered records when new data is fetched
                this.onchangeSearchInput({ target: { value: this.searchInput } });
            }
        } else if (error) {
            this.error = error;
            // Display error message to the user
            this.showToast('Error', 'error', 'An error occurred while searching: ' + error.body.message);
        }
    }


    handleRemoveRecord(event) {
        const removeItem = event.target.dataset.item;
        // Check if the item being removed has Default: true
        const isDefaultItem = this.globalSelectedItems.some(item => item.value === removeItem && item.Default);

        // If the item being removed has Default: true, prevent its removal
        if (isDefaultItem) {
            //a toast message to notify the user that the default item cannot be removed
            this.showToast('Warning', 'warning', 'Default item cannot be removed.');
            return;
        }
        // If the item being removed is not the default item, proceed with removal
        const removedItemIndex = this.globalSelectedItems.findIndex(item => item.value === removeItem);
        const removedItem = this.globalSelectedItems.splice(removedItemIndex, 1)[0];

        // Add the removed item back to recordsList
        this.recordsList.push({
            label: removedItem.label,
            value: removedItem.value,
            recordId: removedItem.recordId,
            icon: removedItem.icon,
            Default: false // Assuming it's not a default item when added back
        });

        const arrItems = this.globalSelectedItems;
        this.initializeValues();
        this.value = [];
        const evtCustomEvent = new CustomEvent('remove', {
            detail: { removeItem, arrItems }
        });
        this.dispatchEvent(evtCustomEvent);
    }


    handleSelect(event) {
        let recordId = event.currentTarget.dataset.id;
        this.selectedItems = [];
        const selectedItem = this.recordsList.find(item => item.recordId === recordId);
    
        // Check if the item already exists in globalSelectedItems
        const alreadyExists = this.globalSelectedItems.some(item => item.value === selectedItem.value);
    
        // If the item is not already in globalSelectedItems, add it
        if (!alreadyExists) {
            this.selectedItems.push(selectedItem);
            this.globalSelectedItems.push({
                label: selectedItem.label,
                value: selectedItem.value,
                recordId: selectedItem.recordId,
                icon: selectedItem.icon,
                Default: false
            });

            // Remove the selected item from recordsList
            this.recordsList = this.recordsList.filter(item => item.recordId !== recordId);
        }

        const arrItems = this.globalSelectedItems;
        this.initializeValues();
        const evtCustomEvent = new CustomEvent('retrieve', {
            detail: { arrItems }
        });
        this.dispatchEvent(evtCustomEvent);
    }


    handleCancelClick(event) {
        this.searchInput = '';
        this.isDialogDisplay = false;
        this.selectedRecordType;
        this.selectedEntitySubType;
        this.selectedDocumentTypeOptions;
        const cancelEvent = new CustomEvent('cancelmodal');
        this.dispatchEvent(cancelEvent);
    }

    initializeValues() {
        this.searchInput = '';
        this.isDialogDisplay = false;
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
        }
    }


    handleUpload(event) {
       if (this.isInputValid()) {
            if (this.filesData.length === 0) {
                this.showToast('Error', 'error', 'Please ensure you have selected a file');
                return;
            }
        this.showUploadSpinner = true;

        const uploadData = {
            selectedItems: this.globalSelectedItems,
            selectedEntitySubType: this.selectedEntitySubType,
            selectedRecordType: this.selectedRecordType,
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
}}


    uploadFile(uploadData, file) {
        return new Promise((resolve, reject) => {
            uploadData.filedata = JSON.stringify([file]);
            uploadFiles(uploadData)
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

  //Get blank field names
  isInputValid() {
    let isValid = true;
    let blankFields = [];
    let inputFields = this.template.querySelectorAll('.validate');
    inputFields.forEach(inputField => {
        if (!inputField.value) {
            if(inputField.name ==='Data Type'){
                this.hasSelectedDataTypes = false;
            }else if(inputField.name ==='Data Sub Type'){
                this.hasSelectedDataSubTypes = false;
            }else if(inputField.name ==='Document Type'){
                    this.hasSelectedDocumentTypes = false;
            }
            isValid = false;
            blankFields.push(inputField.name);
        }
    });

    if(this.globalSelectedItems.length === 0){
        this.hasSelectedValuesRelatedTo = false;
        blankFields.push('Related To');
    }

    if(this.filesData.length === 0){
        blankFields.push('Upload Files');
    }

    if (!isValid) {
        this.displayErrorToast(blankFields);
    }

    return isValid;
}


displayErrorToast(blankFields) {
    let errorMessage = 'Please Review the following field(s): ' + blankFields.join(', ');
    const toastEvent = new ShowToastEvent({
        title: 'Error',
        message: errorMessage,
        variant: 'error'
    });
    this.dispatchEvent(toastEvent);
}

checkForDataValidity() {
    // Check for selected data types
    this.hasSelectedDataTypes = this.selectedRecordType !== '';

    // Check for selected data sub types
    this.hasSelectedDataSubTypes = this.selectedEntitySubType !== '';

    // Check for selected document types
    this.hasSelectedDocumentTypes = this.selectedDocumentTypeOptions !== '';

    // Check for selected related to
    this.hasSelectedValuesRelatedTo = this.globalSelectedItems.length > 0;
}



}