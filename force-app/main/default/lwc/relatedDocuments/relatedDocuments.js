import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedFilesByAgreementRecId from '@salesforce/apex/FileRepository.getRelatedFilesByAgreementRecId';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import { fileIcon, getFileSize, sortBy, asStringIgnoreCase} from 'c/utils';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ContentVersion_OBJECT from '@salesforce/schema/ContentVersion';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

//Using the schema '@salesforce/schema/Forrester_SHIR_AGREEMENT_VIEW__x.TYPE_DESCRIPTION__c'
//We sometimes get errors, when clicking on tabs before the page have loaded.
//Random failures where [Forrester_SHIR_AGREEMENT_VIEW__c] is queried instead of [Forrester_SHIR_AGREEMENT_VIEW__x]
const AGREEMENT_FIELDS = [
    'Forrester_SHIR_AGREEMENT_VIEW__x.TYPE_DESCRIPTION__c',
    'Forrester_SHIR_AGREEMENT_VIEW__x.AGREEMENT_RECID__c'
]

const columns = [
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
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
    },
    {
        label: 'Document Type',
        fieldName: 'renderedClassification',
        sortable: true,
    },
    {
        label: 'Created Date',
        sortable: true,
        fieldName: 'CreatedDate',
        type: "date",
        typeAttributes: {
            year: "numeric",
            month: "numeric",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {
        label: 'Uploaded By',
        sortable: true,
        fieldName: 'CreatedBy',
        type: "text",
    },
];
export default class RelatedDocuments extends NavigationMixin(LightningElement) {
    @api recordId;
    sortDirection = 'asc';
    fileSet = [];
    fileSetCount = '';
    fileSetData = [];
    fileIds = [];

    loading = true;
    wiredLoading = true;
    objectInfoLoading = true;
    documentTypeLoading = true;

    noFiles = false;
    loadError = false;
    showModal = false;
    documentTypeOptions = [];
    selectedDocumentTypeOptions;
    contentVersionRecordTypeId;
    agreementDataSubTypeValue;
    agreementRecId;
    typeDescription;

    contentVersionRecordTypeData

    get showLoading() {
        return this.wiredLoading  || this.objectInfoLoading || this.documentTypeLoading || this.loading
    }
    @wire(getRelatedFilesByAgreementRecId, { recordId: '$recordId'})
    async relatedAgreement(result) {
        this.loading = true;
        this.wiredResult = result;
        const { error, data } = result;
        if (data) {
            this.fileIds = data;
            this.generateFileData();
        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
        this.onWiredEvent('relatedAgreement')
    }



    generateFileData = async () => {
        this.loading = true;
        this.fileSet = [];
        this.fileSetData = [];
        this.loadError = false;
        this.noFiles = false;

        try {

            const contentDocumentIds = this.fileIds.map(x => x.ContentDocumentId);
            this.fileSet = await getFileContentVersionsByDocumentIds({ contentDocumentIds: contentDocumentIds });

            this.fileSetCount = this.fileSet.length;

            this.fileSetData = await Promise.all(
                this.fileSet.map(async (x) => {
                    x.Type = `${x.RecordType.Name}`
                    x.Title = x.Title,
                    x.CreatedBy = x.CreatedBy.Name
                    x.ContentSize = getFileSize(x.ContentSize)
                    x.fileUrl = await this.navigateToPreviewFileUrl(x.ContentDocumentId)
                    x.dynamicIcon = fileIcon(x.FileExtension)
                    x.renderedClassification = x.Document_Classification_Label
                    return x
                })
            )

            if (this.fileSetData.length === 0) {
                this.noFiles = true;
                this.loading = false;
                return;
            }
            this.template.querySelector('lightning-datatable').columns = columns;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.loadError = true;
        }
        this.loading = false;
    }

    onHandleSort(event) {
        let { fieldName: sortedBy, sortDirection } = event.detail;
        const tempSorting = [...this.fileSetData]

        if (sortedBy === 'fileUrl') {
            sortedBy = 'Title'
        }

        tempSorting.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) => asStringIgnoreCase(x)));
        this.fileSetData = tempSorting;
        this.sortDirection = sortDirection;

        if (sortedBy === 'Title') {
            sortedBy = 'fileUrl'
        }

        this.sortedBy = sortedBy;
    }

   //function to generate the url for file preview
   async navigateToPreviewFileUrl(id) {
    const url = await this[NavigationMixin.GenerateUrl]({
        type: "standard__namedPage",
        attributes: {
            pageName: "filePreview"
        },
        state: {
            selectedRecordId: id
        }
    });
    return url
}

get documentCardTitleWithCount() {
    return "All Documents (" + this.fileSet.length + ")"
}

    get datatableHeight() {
        if ( this.fileSet.length >= 8) {
            return 'height: 250px;';
        }
        return 'height: 100%';
    }

    handleUploadModal() {
        this.showModal = true;
    }


    handleCancelModal() {
        this.showModal = false;
    }


    @wire(getRecord, { recordId: '$recordId', fields: AGREEMENT_FIELDS })
    wiredRecord({ error, data }) {
        this.wiredLoading = true;
        if (data) {
            this.typeDescription = data.fields.TYPE_DESCRIPTION__c.value;
            this.agreementRecId = data.fields.AGREEMENT_RECID__c.value;
        } else if (error) {
            console.error('Error fetching record:', JSON.stringify(error));
        }
        this.wiredLoading = false;
        this.onWiredEvent('wiredRecord')
    }

    @wire(getObjectInfo, { objectApiName: ContentVersion_OBJECT })
    ContentVersionInfo({ error, data }) {
        this.objectInfoLoading = true;
        if (data) {
            this.getContentVersionRecordTypeId(data);
        } else if (error) {
            console.error('Error retrieving object info:', JSON.stringify(error));
        }
        this.objectInfoLoading = false;
        this.onWiredEvent('ContentVersionInfo')
    }

    getContentVersionRecordTypeId(objectInfo) {
        const recordTypeInfos = objectInfo.recordTypeInfos;
        for (const recordTypeInfo in recordTypeInfos) {
            if (recordTypeInfos[recordTypeInfo].name === 'TLO Agreement') {
                this.contentVersionRecordTypeId = recordTypeInfos[recordTypeInfo].recordTypeId;
                break;
            }
        }
    }

    getDataSubTypePicklistValues(data) {
        if (data.picklistFieldValues && data.picklistFieldValues.Entity_Sub_Type__c) {
            let picklistValues = data.picklistFieldValues.Entity_Sub_Type__c.values;
            const filteredOptions = picklistValues.find(option => option.label === this.typeDescription);

            if (filteredOptions) {
                this.agreementDataSubTypeValue = filteredOptions.value;
                console.info('Matching picklist value found for typeDescription:', this.typeDescription);
            } else {
                console.error('No matching picklist value found for typeDescription:', this.typeDescription);
            }
        } else {
            console.error('Picklist values for Entity_Sub_Type__c are undefined.');
        }
    }


    @wire(getPicklistValuesByRecordType, { objectApiName: ContentVersion_OBJECT, recordTypeId: '$contentVersionRecordTypeId'})
    wiredDocumentTypeOptions({ error, data }) {
        this.documentTypeLoading = true;
        if (data) {
            this.contentVersionRecordTypeData = data;
            this.getDataSubTypePicklistValues(data);
            if (data.picklistFieldValues && data.picklistFieldValues.Document_Classification__c) {
                let picklistValues = data.picklistFieldValues.Document_Classification__c.values;

                this.documentTypeOptions = picklistValues.map(option => ({
                    label: option.label,
                    value: option.value
                }));
            } else {
                console.error('Picklist values are undefined.');
            }
        } else if (error) {
            console.error(error);
        }
        this.documentTypeLoading = false;
        this.onWiredEvent('wiredDocumentTypeOptions')
    }

    onWiredEvent(context) {
        if (this.contentVersionRecordTypeData) {
            this.getDataSubTypePicklistValues(this.contentVersionRecordTypeData);
        }
    }


    handleDocumentTypeOptionsChange(event) {
        this.selectedDocumentTypeOptions = event.detail.selectedDocumentTypeOptions;
    }


    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args) {
        this.values = [];
        args.map(element => {
            this.values.push(element.label);
        });

        this.isItemExists = (args.length > 0);
        this.selectedItemsToDisplay = this.values.join(', ');
    }

    wiredResult;
    // Handle upload success event
    handleUploadSuccess() {

    // Close the modal
    this.showModal = false;

    // Refresh the wired result to fetch the latest data
    return refreshApex(this.wiredResult);
    }

}