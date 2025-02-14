import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDisclosureByCaseRecId from '@salesforce/apex/DisclosureRecordFetch.getDisclosureByCaseRecId';
import getCrdrAgreementFilesByCaseRecId from '@salesforce/apex/FileRepository.getCrdrAgreementFilesByCaseRecId';
import getCaseRelatedFilesByCaseRecId from '@salesforce/apex/FileRepository.getCaseRelatedFilesByCaseRecId';
import getFilesByType from '@salesforce/apex/FileRepository.getFilesByType';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import getThirdPartyContentFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyContentFilesByDisclosureId';
import getThirdPartyCodeFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyCodeFilesByDisclosureId';
 import relatedTLOAgreementDataSubTypes from '@salesforce/apex/FileRepository.relatedTLOAgreementDataSubTypes'
import { DOCUMENT_FORRESTER_CASE_CRDR_FIELDS, fileIcon, getFileSize, DOCUMENT_FOR_RECORDTYPE, sortBy, asStringIgnoreCase, determineFileClassifactionName } from 'c/utils';
import { getRecord } from "lightning/uiRecordApi";
import getContentVersionRecordTypes from '@salesforce/apex/GlobalRecordSearchController.getContentVersionRecordTypes';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ContentVersion_OBJECT from '@salesforce/schema/ContentVersion';
import getContentDocumentLinks from '@salesforce/apex/GlobalRecordSearchController.getContentDocumentLinks';

const columns = [
    {
        label: 'File Name',
        fieldName: 'fileUrl',
        type: 'url',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {
            label: {
                fieldName: 'Title'
            }
        },
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
    },
    {
        label: 'Data Type',
        fieldName: 'Type',
        sortable: false,
    },
    {
        label: 'Data Sub Type',
        fieldName: 'entitySubType',
        sortable: true,
    },
    {
        label: 'Document Type',
        fieldName: 'renderedClassification',
        sortable: true,
    },
    {
        label: 'Related To',
        fieldName: 'sObjectUrl',
        initialWidth: 130,
        type: 'relatedToCustomDataTypeTemplate',
        sortable: true,
        typeAttributes: {
            RelatedTo: {
                fieldName: 'RelatedTo'
            },
            sObjectUrl:{
                fieldName: 'sObjectUrl'
            },
            recordTypeName: {
                fieldName: 'Type'
            },
            relatedToData:{
                fieldName:'relatedToData'
            }


        }
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
        }
    },
    {
        label: 'Uploaded By',
        sortable: true,
        fieldName: 'CreatedBy',
        type: "text",
    },

];

export default class CrdrRelatedDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    caseRecId
    disclosureData;
    disclosureRecordId;
    financialYear;

    sortDirection = 'asc';
    fileSet = [];
    fileSetData = [];
    agreementSRA = [];

    loading = false;
    noFiles = false;
    loadError = false;

    showModal = false;
    selectedRecordType;
    entitySubTypeOptions = [];
    selectedEntitySubType;
    recordTypes = [];
    documentTypeOptions = [];
    selectedDocumentTypeOptions;


    selectedCrdr;
    selectedItemsToDisplay = '';
    values = [];
    isItemExists = false;

    @wire(getRecord, { recordId: '$recordId', fields: DOCUMENT_FORRESTER_CASE_CRDR_FIELDS })
    async handleRelated({ error, data }) {
        this.loading = true;
        if (data) {
            console.log(`%c [CRDR: DATA]`, `color: green`, data);
            this.caseRecId = data.fields?.CASE_RECID__c?.value;
            this.financialYear = data.fields?.FY__c?.value;

            this.disclosureData = await getDisclosureByCaseRecId({caseRecId: this.caseRecId});
            console.log(`%c [DISCLOSURE: DATA]`, `color: green`, this.disclosureData);
            this.disclosureRecordId = this.disclosureData?.Id
            this.generateFileData();


        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

    determineCaseTypeEnumDisplay() {
        if (!this.disclosureData) return '';
        if (this.disclosureData) {
            switch (this.disclosureData?.RecordType?.DeveloperName) {
                case 'Waiver':
                    return DOCUMENT_FOR_RECORDTYPE.WAIVER;
                case 'BioTang_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.BIO_TANG;
                case 'Software_Code_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.SOFTWARE_CODE;
                case 'Copyright_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.COPYRIGHT;
                case 'Invention_Disclosure':
                    return DOCUMENT_FOR_RECORDTYPE.INVENTION;
                default:
                    return undefined;
            }
        }
        return undefined
    }

    generateFileData = async () => {
        this.loading = true;
        this.fileSet = [];
        this.fileSetData = [];
        this.loadError = false;
        this.noFiles = false;

        try {
            const fileIds = this.disclosureRecordId ? await getFilesByType({ linkedRecId: this.disclosureRecordId, recordType: 'Disclosure' }) : [];


            const documentRecordType = this.determineCaseTypeEnumDisplay();


            if (this.caseRecId) {
                const agreementFileIds = await getCrdrAgreementFilesByCaseRecId({ caseRecId: this.caseRecId, financialYear: this.financialYear });
                if (agreementFileIds) {
                    console.debug('add agreement documents:', agreementFileIds);
                    agreementFileIds.forEach(x => {
                        x.ContentDocumentId = x.contentDocumentId
                        fileIds.push(x);
                    })
                }

                const relatedFileIds = await getCaseRelatedFilesByCaseRecId({ caseRecId: this.caseRecId});
                console.debug('add case related documents:', relatedFileIds);
                if (relatedFileIds) {
                    relatedFileIds.forEach(x => {
                        x.ContentDocumentId = x.contentDocumentId
                        fileIds.push(x);
                    })
                }
            }

            if (documentRecordType === DOCUMENT_FOR_RECORDTYPE.COPYRIGHT) {
                const licenseFileIds = await getThirdPartyContentFilesByDisclosureId({ disclosureId: this.disclosureRecordId });
                if (licenseFileIds) {
                    licenseFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }

            if (documentRecordType === DOCUMENT_FOR_RECORDTYPE.SOFTWARE_CODE) {
                const codeFileIds = await getThirdPartyCodeFilesByDisclosureId({ disclosureId: this.disclosureRecordId });
                if (codeFileIds) {
                    codeFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }



            const contentDocumentIds = fileIds.map(x => x.ContentDocumentId  );
            this.fileSet = await getFileContentVersionsByDocumentIds({ contentDocumentIds: contentDocumentIds });
            this.fileSetData = await Promise.all(
                this.fileSet.map(async (x) => {
                    x.Type = `${x.RecordType.Name}`
                    x.ContentSize = getFileSize(x.ContentSize)
                    x.fileUrl = await this.navigateToPreviewFileUrl(x.ContentDocumentId)
                    x.dynamicIcon = fileIcon(x.FileExtension)
                    x.renderedClassification = determineFileClassifactionName(x.Document_Classification_Label)
                    x.entitySubType = x.Entity_Sub_Type_Label
                    x.CreatedBy = x.CreatedBy.Name
                    x.CreatedDate = x.CreatedDate
                    x.contentDocumentId = x.ContentDocumentId
                    x.entitySubTypeDevName = x.Entity_Sub_Type__c
                    x.recordId = this.recordId
                    x.relatedToData = await getContentDocumentLinks({ contentDocumentId: x.ContentDocumentId,recordTypeId: x.RecordTypeId, currentRecordId: this.recordId,entitySubType: x.Entity_Sub_Type__c});
                    let fileResponse = fileIds.find((element) => element.ContentDocumentId === x.ContentDocumentId)
                    if(fileResponse && fileResponse.recordId) {
                        x.sObjectUrl = await this.navigateToSObjectUrl(fileResponse.recordId)
                        x.sObjectLabel = fileResponse.recordLabel
                        x.RelatedTo = fileResponse.recordLabel
                    } else if(this.disclosureRecordId) {
                        x.sObjectUrl = await this.navigateToSObjectUrl(this.disclosureRecordId)
                        x.sObjectLabel = this.disclosureData?.Name
                        x.RelatedTo = this.disclosureData?.Name
                    }
                    return x
                })
            )
             // Sort the fileSetData array by CreatedDate
             this.fileSetData.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));

            if (this.fileSetData.length === 0) {
                this.noFiles = true;
                this.loading = false;
                return;
            }
            this.template.querySelector('c-custom-lightning-datatable').columns = columns;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.loadError = true;
        }
        this.loading = false;
    }



    //this sorts the names of the files when the user clicks on the column header
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
    async navigateToSObjectUrl(recordId) {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        })
        return url
    }

    get documentCardTitleWithCount() {
        return "Related Documents (" + this.fileSet.length + ")"
    }

    get datatableHeight() {
        if ( this.fileSet.length >= 8) {
            return 'height: 250px;';
        }

        return 'height: 100%';
    }

    handleUploadModal() {
        // Show the modal when the "Upload" button is clicked
        this.showModal = true;
    }
    // Handle cancel modal event
    handleCancelModal() {
        this.showModal = false;
    }

    // Wire method to fetch record types
    @wire(getContentVersionRecordTypes)
    wiredRecordTypes({ error, data }) {
    if (data) {
        // Map the data to record types
        this.recordTypes = data.map(item => ({
            label: item.name,
            value: item.recordTypeId,
            developerName: item.developerName
        }));

        // Sort the record types alphabetically in reverse order
        this.recordTypes.sort((a, b) => b.label.localeCompare(a.label));

    } else if (error) {
        console.error(error);
    }
    }


    // Ensure initialization and handle asynchronous loading
    connectedCallback() {
        this.selectedRecordType = '';
        this.selectedEntitySubType = '';

        // Call the method to fetch relatedTLOAgreementDataSubTypes when the component is connected
        this.fetchRelatedTLOAgreementDataSubTypes();
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.selectedRecordType;
    }


        // Handle entitySubTypeChange event from the child component
    handleEntitySubTypeChange(event) {
        this.selectedEntitySubType = event.detail.selectedEntitySubType;

        // Reset entitySubTypeOptions when the record type changes
        this.entitySubTypeOptions = [];
    }

    async fetchRelatedTLOAgreementDataSubTypes() {
        try {
            const result = await relatedTLOAgreementDataSubTypes({ crdrRecordId: this.recordId });
            this.tloAgreementDataSubTypes = result;
        } catch (error) {
            console.error('Error fetching TLO Agreement data subtypes: ', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: ContentVersion_OBJECT })
    ContentVersionInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: ContentVersion_OBJECT, recordTypeId: '$selectedRecordType' })
    wiredEntitySubTypeOptions({ error, data }) {
        if (data) {
            if (data.picklistFieldValues && data.picklistFieldValues.Entity_Sub_Type__c) {
               // Retrieve picklist values from the data
               let picklistValues = data.picklistFieldValues.Entity_Sub_Type__c.values;
               if (this.recordTypes) {
                   let selectedRecordTypeDeveloperName = this.recordTypes.find(recordType => recordType.value === this.selectedRecordType).developerName;
                   if (selectedRecordTypeDeveloperName === 'TLO_Agreement' && this.tloAgreementDataSubTypes) {
                       // Filter the picklist values based on fetched TLO Agreement data subtypes
                       let filteredOptions = picklistValues.filter(option => this.tloAgreementDataSubTypes.includes(option.value));
                       this.entitySubTypeOptions = filteredOptions.map(option => ({
                           label: option.label,
                           value: option.value
                       }));
                   } else {
                       // Use all picklist values if not TLO_Agreement or TLO Agreement data subtypes not fetched yet
                       this.entitySubTypeOptions = picklistValues.map(option => ({
                           label: option.label,
                           value: option.value
                       }));
                       // Sort entitySubTypeOptions alphabetically
                    this.entitySubTypeOptions.sort((a, b) => a.label.localeCompare(b.label));
                   }
               }
            }
           } else if (error) {
               console.error(error);
       }
    }


    @wire(getPicklistValuesByRecordType, { objectApiName: ContentVersion_OBJECT, recordTypeId: '$selectedRecordType' })
    wiredDocumentTypeOptions({ error, data }) {
        if (data) {
            // Check if data.picklistFieldValues is not undefined before accessing its properties
            if (data.picklistFieldValues && data.picklistFieldValues.Document_Classification__c) {
                let picklistValues = data.picklistFieldValues.Document_Classification__c.values;
                 // Find the developer name of the selected record type
            let selectedRecordTypeDeveloperName = this.recordTypes.find(recordType => recordType.value === this.selectedRecordType).developerName;

            // Filter out document type options if the record type is "CRDR" or "Case"
            if (selectedRecordTypeDeveloperName === 'CRDR' || selectedRecordTypeDeveloperName === 'Case') {
                this.documentTypeOptions = picklistValues.filter(option => {
                    return option.value !== 'Finalised_CRDR' && option.value !== 'Draft_CRDR';
                }).map(option => ({
                    label: option.label,
                    value: option.value
                }));
            } else {
                this.documentTypeOptions = picklistValues.map(option => ({
                    label: option.label,
                    value: option.value
                }));
            }
                console.log('wire this.documentTypeOptions  ====> ', JSON.stringify(this.documentTypeOptions));
            } else {
                console.error('Picklist values are undefined.');
            }
        } else if (error) {
            console.error(error);
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

    // Handle upload success event
    handleUploadSuccess() {
        // Refresh the data table
        this.generateFileData();

        // Close the modal
        this.showModal = false;
    }

}