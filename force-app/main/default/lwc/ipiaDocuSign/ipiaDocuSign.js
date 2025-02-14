/**
 * Created by Andreas du Preez on 2024/07/24.
 */

import { NavigationMixin } from "lightning/navigation";
import { api, LightningElement, wire , track } from "lwc";
import { getFieldValue, getRecord, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import getFilesByType from '@salesforce/apex/FileRepository.getFilesByType';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import IPIA_DOCUSIGN_TEMPLATE_FIELD from "@salesforce/schema/IPIA_Record__c.DocusignTemplate__c";
import IPIA_DOCUSIGN_ENVELOPE_ID_FIELD from "@salesforce/schema/IPIA_Record__c.DocusignEnvelopeId__c";
import IPIA_MIT_ID_FIELD from "@salesforce/schema/IPIA_Record__c.MitId__c";
import getContactByMitId from '@salesforce/apex/DisclosureRecordFetch.getContactByMitId'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFileSize, getFullName } from 'c/utils'
import { refreshApex } from '@salesforce/apex';
import { registerRefreshHandler, unregisterRefreshHandler } from "lightning/refresh";
import getCreateAccess from "@salesforce/apex/IPIAController.userHasIPIARecordCreatePermission";

const IPIA_FIELDS = [
    IPIA_DOCUSIGN_TEMPLATE_FIELD,
    IPIA_DOCUSIGN_ENVELOPE_ID_FIELD,
    IPIA_MIT_ID_FIELD
];

const MAX_FILE_SIZE = 2500000;
export default class IPIADocuSign extends NavigationMixin(LightningElement) {
    @api recordId

    fileDetail = undefined
    @track filesData = [];
    loading = true;
    showUploadProgressModal = false;
    wiredResultRecord;
    contact = undefined
    createAccess = false;
    refreshHandlerId;


    connectedCallback() {
        this.refreshHandlerId = registerRefreshHandler(
            this.template.host,
            this.refreshHandler.bind(this)
        );
    } 

    disconnectedCallback() {
        unregisterRefreshHandler(this.refreshHandlerId);
    }

    async refreshHandler() {
        await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
        this.fileDetail = await this.generatePdfLink();
    }


    // Getters
    get docusignTemplate() {
        return this.record ? getFieldValue(this.record.data, IPIA_DOCUSIGN_TEMPLATE_FIELD) : null;
    }

    get docusignEnvelopeId() {
        return this.record ? getFieldValue(this.record.data, IPIA_DOCUSIGN_ENVELOPE_ID_FIELD) : null;
    }

    get mitId() {
        return this.record ? getFieldValue(this.record.data, IPIA_MIT_ID_FIELD) : null;
    }

    get fileExtension() {
        if (this.fileDetail) {
            return this.fileDetail.FileExtension
        }
        return 'pdf'
    }

    get fileName() {
        if (this.fileDetail) {
            return this.fileDetail.Title
        }
        return this.record ? 'document.pdf' : '';
    }

    get fileExist() {
        return this.fileDetail !== undefined && this.fileDetail !== null;
    }

    get showUploadButton() {
        return !this.fileDetail && this.createAccess && !this.docusignTemplate && !this.docusignEnvelopeId;
    }


    // Wire methods
    @wire(getRecord, { recordId: "$recordId", fields: IPIA_FIELDS })
    async handleGetRecord(record) {
        this.wiredResultRecord = record;
        if (record.data) {
            this.record = record;
            this.loading = false;
            await this.getCreateAccess();
            this.fileDetail = await this.generatePdfLink();
            const ipiaMitId = this.mitId;
            if (ipiaMitId) {
                this.contact = await getContactByMitId({
                    mitId: ipiaMitId
                })
            }
        }
        if (record.error) {
            this.error = true;
        }
    }

    async getCreateAccess() {
        getCreateAccess().then((result) => {
            this.createAccess = result;
        }).catch(() => {
            this.createAccess = false;
        });
    }

    async generatePdfLink() {
        const fileIds = await getFilesByType({ linkedRecId: this.recordId, recordType: 'IPIA' });
        console.debug('generatePdfLink:', fileIds)
        if(fileIds && fileIds.length > 0) {
            const contentDocumentIds = fileIds.map(x => x.ContentDocumentId);
            let fileSet = await getFileContentVersionsByDocumentIds({contentDocumentIds: contentDocumentIds})
            fileSet.sort(function(a,b){
                // Turn your strings into dates, and then subtract them
                // to get a value that is either negative, positive, or zero.
                // 2024-09-04T14:26:12.000Z
                return Date.parse(b.CreatedDate) - Date.parse(a.CreatedDate);
            });
            console.debug('generatePdfLink.fileSet', fileSet)
            return fileSet[0]
        }
        return undefined
    }


    viewPdf(event) {
        console.log(event.currentTarget.dataset.value);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: event.currentTarget.dataset.value //your ContentDocumentId here
            }
        });
    }

    getUploadedFiles(filesData) {
        const modal = this.template.querySelector('c-ipia-upload-progress-modal');
        console.log('found modal:', JSON.stringify(modal));
        if (modal) {
            modal.uploadFiles(filesData);
        }
    }

    handleFileChange(event) {
        const files = event.target.files;
        console.log('found files:', JSON.stringify(files));
        if (files.length > 0) {
            this.filesData = [];
    
            Array.from(files).forEach(file => {
                if (file.size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded. A file is larger than 2.4MB.');
                    return;
                }
    
                const reader = new FileReader();
                reader.onload = () => {
                    const fileContents = reader.result.split(',')[1]; // Base64 encoded string
                    const fileType = file.type;
                    const fileSize = getFileSize(file.size);
    
                    this.filesData.push({
                        fileName: file.name,
                        fileSize: fileSize,
                        fileType: fileType,
                        percentComplete: 0,
                        inProgress: true,
                        successUpload: false,
                        cancelled: false,
                        rejected: false,
                        content: fileContents
                    });

                    // Open the modal and pass the file data
                    this.showUploadProgressModal = true;

                    // Query the child modal component after it is rendered
                    setTimeout(() => {
                        const modal = this.template.querySelector('c-ipia-upload-progress-modal');
                        if (modal) {
                            modal.uploadFiles(this.filesData);
                        }
                    }, 0);  // Small delay to ensure the modal is rendered
                };
                reader.readAsDataURL(file);
            });
        }
    }


    
    async handleFinishUpload(event) {
        const totalSuccess = event.detail.totalSuccess; // Access totalSuccess from event detail
        if (totalSuccess > 0) {
            this.showToast('Success', 'success', `${totalSuccess} file(s) was uploaded successfully.`);
        } else {
            this.showToast('Info', 'info', `${totalSuccess} file was uploaded.`);
        }
 

        await new Promise(resolve => setTimeout(resolve, 2000));  
        this.showUploadProgressModal = false;
        refreshApex(this.wiredResultRecord);
        await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
        this.fileDetail = await this.generatePdfLink();
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