import { api, LightningElement, wire } from "lwc";
import { getFieldValue, getRecord, deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { fileIcon, sortBy, asStringIgnoreCase, determineSortPrimer, reduceErrors, SORT_BY_TYPE_ENUMS } from 'c/utils';
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe, publish } from "lightning/messageService";
import ipiaNewRecordModal from "c/ipiaNewRecordModal";
import ipiaExistingIpiaRecordModal from "c/ipiaExistingIpiaRecordModal";
import msgService from "@salesforce/messageChannel/ipiaCurrentChange__c";
import deleteFile from '@salesforce/apex/IPIAController.deleteFile';
import getUnlinkedDocumentsDS from "@salesforce/apex/IPIAController.getUnlinkedDocuments";
import getCreateAccess from "@salesforce/apex/IPIAController.userHasIPIARecordCreatePermission";

const actions = [
    { label: "Attach to New IPIA Record", name: "attachToNewIpia" },
    { label: "Attach to Existing IPIA Record", name: "attachToExitingIpia" },
    { label: "Delete", name: "deleteDocument" }
];
const unlinkedDocsColumns = [
    {
        label: 'File Name',
        fieldName: 'fileUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {
            label: {
                fieldName: 'Title'
            }
        },
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } },         
    },
    {
        label: "ImageSilo File Date",
        fieldName: "imageSiloWriteDate",
        type: "text",
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 150
    }
];
export default class PersonIpiaUnlinkedDocs extends NavigationMixin(LightningElement) {

    @api recordId;
    @api mitIdField;

    createAccess;
    record = {};
    isLoading = true;
    showDeleteConfirmationModal = false;
    unlinkedIpiaDocuments = [];
    fileSetData = [];
    sortDirection = "asc";
    sortedBy = "";
    unlinkedDocsColumns = unlinkedDocsColumns;
    docRowToDelete;

    // Getters
    get getCardTitle() {
        return `Unlinked IPIA Document(s) (${this.unlinkedIpiaDocuments.length})`;
    }

    get mitId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.mitIdField)
        }
        return null
    }

    get hasUnlinkedFiles() {
        return this.unlinkedIpiaDocuments?.length > 0;
    }

    get datatableHeight() {
        if ( this.unlinkedIpiaDocuments.length >= 8) {
            return 'height: 250px;';
        }
        return 'height: 100%';
    }

    // Wire Methods
    @wire(MessageContext)
    messageContext;
    
    @wire(getRecord, { recordId: '$recordId', fields: '$mitIdField' })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            await this.getCreateAccess();
            await this.getUnlinkedDocuments();
        }
        if (record.error) {
            this.error = true
        }
    }

    // Helper Methods
    async getCreateAccess() {
        getCreateAccess().then((result) => {
            this.createAccess = result;
        }).catch(() => {
            this.createAccess = false;
        });
    }

    getRowActions() {
        const filteredCols = this.unlinkedDocsColumns.filter(col => {
            return col.type == 'action';
        });
        if (this.createAccess && filteredCols?.length <= 0) {
            this.unlinkedDocsColumns.push({
                type: 'action',
                typeAttributes: { rowActions: actions }
            })
        }
    }

    async getUnlinkedDocuments() {
        try {
            const unlinkedDocs = await getUnlinkedDocumentsDS({ mitId: this.mitId });
            
            this.unlinkedIpiaDocuments = [];            
            await Promise.all(
                unlinkedDocs.map(async (obj) => {
                    obj.dynamicIcon = fileIcon(obj.FileExtension);                    
                    obj.fileUrl = await this.navigateToPreviewFileUrl(obj.ContentDocumentId);
                    obj.imageSiloWriteDate = this.getImageSiloWriteDate(obj.Description);
                })
            )
            this.unlinkedIpiaDocuments = unlinkedDocs;
            this.getRowActions();

            this.isLoading = false;
        } catch(error) {
            console.error("Error loading Unlinked Documents", error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading Unlinked Documents",
                    message: reduceErrors(error),
                    variant: "error"
                })
            );
            this.isLoading = false;
        }
    }

    //method to parse string of the following formate, and only return the FileWriteDate in US format
    //MitId: 923583401 ContactId: 103957 FileWriteDate: 2024/05/30 00:00:00
    getImageSiloWriteDate(description) {
        const partsArray = description.split('FileWriteDate: ');
        const fileWriteDateArray = partsArray[1].split(' ');
        const dateArray = fileWriteDateArray[0].split('/');

        const yr = dateArray[0];
        const mm = dateArray[1];
        const day = dateArray[2];

        return mm + '/' + day + '/' + yr;
    }

    //function to generate the url for file preview
    async navigateToPreviewFileUrl(id) {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "filePreview"
            },
            state: {
                selectedRecordId: id //your ContentDocumentId here
            }
        });
        return url
    }

    //this sorts the names of the files when the user clicks on the column header
    onHandleSort(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;

        if (sortedBy === 'fileUrl') {
            sortedBy = 'Title'
        }

        const tempSorting = [...this.unlinkedIpiaDocuments]

        tempSorting.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) => asStringIgnoreCase(x)));
        this.unlinkedIpiaDocuments = tempSorting;
        this.sortDirection = sortDirection;

        if (sortedBy === 'Title') {
            sortedBy = 'fileUrl'
        }

        this.sortedBy = sortedBy;
    }

    async handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        switch (action.name) {
            case "attachToNewIpia":
                await ipiaNewRecordModal.open({
                    mitId: this.mitId,
                    docDetails: row,
                    size: "small"
                }).then(async () => {                    
                    await this.getUnlinkedDocuments();
                    this.publishIpiaDocChangeMessage();                                    
                });
                break;
            case "attachToExitingIpia":
                await ipiaExistingIpiaRecordModal.open({
                    recordId: this.recordId,
                    docDetails: row,
                    size: "small"
                }).then(async () => {                    
                    await this.getUnlinkedDocuments();
                    this.publishIpiaDocChangeMessage();                                    
                });
                break;
            case "deleteDocument":
                this.docRowToDelete  = row;
                this.showDeleteConfirmation();
                break;
            default:
        }
    }

    // Event Handlers
    docTileToDelete = '';
    showDeleteConfirmation() {
        this.docTileToDelete = this.docRowToDelete.Title;
        this.showDeleteConfirmationModal = true;
    }

    handleDeleteCancel() {
        this.docTileToDelete = '';
        this.showDeleteConfirmationModal = false;
    }

    deleteDisabled = false;
    async handleDelete() {
        this.deleteDisabled = true;
        deleteFile({ contentVersionId: this.docRowToDelete.Id }).then(async (result) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Document "' + this.docRowToDelete.Title + '" deleted',
                    variant: 'success'
                })
            );
            
            await this.getUnlinkedDocuments();
            this.deleteDisabled = false;
            this.showDeleteConfirmationModal = false;
            this.docTileToDelete = '';
        }).catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting document',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
            this.deleteDisabled = false;
            this.showDeleteConfirmationModal = false;
            this.docTileToDelete = '';
        });
    }

    publishIpiaDocChangeMessage() {
        publish(this.messageContext, msgService, {
            mitId: this.mitId
        });
    }
}