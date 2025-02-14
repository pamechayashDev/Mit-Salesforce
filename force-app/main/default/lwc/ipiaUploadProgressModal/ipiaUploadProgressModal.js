import { LightningElement, api, track } from 'lwc';
import uploadChunkedFile from '@salesforce/apex/IPIAController.uploadIPIADocuments';
import deleteFile from '@salesforce/apex/IPIAController.deleteFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fileMimeTypeIcon,  reduceErrors } from 'c/utils';

const CHUNK_SIZE = 750000;
export default class IpiaUploadProgressModal extends LightningElement {
    @api recordId;
    @track filesData = [];
    showSpinner = false;
    @track showModal = true;
    @track totalSuccess = 0;
    @track totalFiles = 0;

    @api
    uploadFiles(fileData) {
        this.totalFiles = fileData.length;
        this.filesData = fileData.map(file => ({
            ...file,
            percentComplete: 0,
            inProgress: true,
            cancelled: false,
            contentVersionId: null,
            deleted: false
        }));
        this.uploadFilesInChunks();
    }

    uploadFilesInChunks() {
        this.filesData.forEach(file => {
            if (file.inProgress && !file.cancelled && !file.rejected && !file.successUpload) {
                this.uploadFile(file);
            }
        });
    }

    uploadFile(file) {
        if (file.cancelled) {
            return;
        }

        this.showSpinner = true;
        const { content } = file;
        let fromIndex = 0;
        let toIndex = Math.min(content.length, fromIndex + CHUNK_SIZE);

        this.uploadChunk(file, content, fromIndex, toIndex, file.contentVersionId);
    }

    uploadChunk(file, fileContents, fromIndex, toIndex, cvId) {
        // Check if the file is cancelled before proceeding with the upload
        if (file.cancelled) {
            this.updateFileProgress(file, 0, fileContents.length);
            return;
        }

        const chunk = fileContents.substring(fromIndex, toIndex);

        uploadChunkedFile({
            recordId: this.recordId,
            fileName: file.fileName,
            base64FileContent: encodeURIComponent(chunk),
            contentVersionId: cvId
        })
        .then(result => {
            // After each chunk upload, check if the file has been cancelled
            if (file.cancelled) {
                // If cancelled, delete the partially uploaded ContentVersion from Salesforce
                deleteFile({ contentVersionId: result })
                    .catch(error => {
                        console.error('Error deleting file:', reduceErrors(error));
                    });
                return;
            }

            // Continue to the next chunk if the file is not cancelled
            file.contentVersionId = result;
            fromIndex = toIndex;
            toIndex = Math.min(fileContents.length, fromIndex + CHUNK_SIZE);
            this.updateFileProgress(file, fromIndex, fileContents.length);

            if (fromIndex < fileContents.length) {
                this.uploadChunk(file, fileContents, fromIndex, toIndex, file.contentVersionId);
            } else {
                // Upload is complete for this file
                this.onUploadComplete(file);
            }
        })
        .catch(error => {
            // Handle upload errors
            this.onUploadError(file, error);
        });
    }

    updateFileProgress(file, uploadedSize, totalSize) {
        const fileIndex = this.filesData.findIndex(f => f.fileName === file.fileName);
        if (fileIndex !== -1) {
            this.filesData[fileIndex].percentComplete = (uploadedSize / totalSize) * 100;
        }
    }

    onUploadComplete(file) {
        this.showSpinner = false;
        const fileIndex = this.filesData.findIndex(f => f.fileName === file.fileName);
        if (fileIndex !== -1) {
            this.filesData[fileIndex].inProgress = false;
            this.filesData[fileIndex].successUpload = true;
            this.filesData[fileIndex].percentComplete = 100;

            // Update the success count after each file upload is complete
            this.updateSuccessCount();
        }
    }

    updateSuccessCount() {
        this.totalSuccess = this.filesData.filter(file => file.successUpload).length;
    }

    onUploadError(file, error) {
        this.showSpinner = false;
        const fileIndex = this.filesData.findIndex(f => f.fileName === file.fileName);
        if (fileIndex !== -1) {
            this.filesData[fileIndex].inProgress = false;
            this.filesData[fileIndex].rejected = true;
            this.filesData[fileIndex].error = `Error uploading file`;
        }
    }

    handleCancelClick(event) {
        const fileName = event.target.dataset.name;
        const fileIndex = this.filesData.findIndex(file => file.fileName === fileName);

        if (fileIndex !== -1) {
            this.filesData[fileIndex].cancelled = true;
            this.filesData[fileIndex].percentComplete = 0;

            // Ensure the file contentVersionId exists before trying to delete it
            if (this.filesData[fileIndex].contentVersionId) {
                deleteFile({ contentVersionId: this.filesData[fileIndex].contentVersionId })
                .catch(error => {
                    console.error('Error deleting file:', reduceErrors(error));
                });
            }
        }
    }

    handleCloseClick(event) {
        // Cancel each file upload
        this.filesData.forEach(file => {
            if (file.inProgress) {
                file.cancelled = true; // Mark the file as cancelled
                this.updateFileProgress(file, 0, file.content.length); // Reset progress
    
                // Delete the file if it has been started
                if (file.contentVersionId) {
                    deleteFile({ contentVersionId: file.contentVersionId })
                        .catch(error => {
                            console.error('Error deleting file:', reduceErrors(error));
                        });
                }
            }
        });
    
        // Dispatch the event after handling the files
        const evtCustomEvent = new CustomEvent('finishupload', {
            detail: { totalSuccess: this.totalSuccess }
        });
        this.dispatchEvent(evtCustomEvent);
    }

    getFileIcon(fileType) {
        return fileMimeTypeIcon(fileType);
    }

    get processedFilesData() {
        return this.filesData.map(file => ({
            ...file,
            iconName: this.getFileIcon(file.fileType)
        }));
    }

    handleDoneUpload() {
        const evtCustomEvent = new CustomEvent('finishupload', {
            detail: { totalSuccess: this.totalSuccess }
        });
        this.dispatchEvent(evtCustomEvent);
    }

    get isUploading() {
        return this.filesData.some(file => file.inProgress && !file.cancelled);
    }

    get isDoneButtonDisabled() {
        // Enable the button if:
        // - No files are in progress (isUploading is false)
        // - All uploads are either successful or canceled
        const allFilesProcessed = this.filesData.every(file => file.successUpload || file.cancelled || file.rejected);
        return this.isUploading || !allFilesProcessed;
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
}