import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { fileIcon, getFileSize, DOCUMENT_CLASSIFICATIONS, DOCUMENT_FOR_RECORDTYPE, sortBy, asStringIgnoreCase, FILTER_FILES_ENUMS, determineFilterTypeByDocQueryType, determineFileClassifactionName } from 'c/utils';
import { getDocumentFieldsByRecordTypeAndClassification, getDocumentEntityIdFieldByRecordTypeAndClassification, isEntityIdDocumentByRecordType } from 'c/utils';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import getFilesByType from '@salesforce/apex/FileRepository.getFilesByType';
import getFileContentVersionsByEntityRecId from '@salesforce/apex/FileRepository.getFileContentVersionsByEntityRecId';
import getThirdPartyContentFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyContentFilesByDisclosureId';
import getThirdPartyCodeFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyCodeFilesByDisclosureId';

import { getRecord } from 'lightning/uiRecordApi';
import Disclosure_Documents_Header_TechnicalDescription from '@salesforce/label/c.Disclosure_Documents_Header_TechnicalDescription';
import Disclosure_Documents_Header_PublicationsManuscripts from '@salesforce/label/c.Disclosure_Documents_Header_PublicationsManuscripts';

export default class DocumentsTable extends NavigationMixin(LightningElement) {
    recordId;
    filterBy;
    objectApi;
    documentForRecordType;

    noFiles = false;
    loadError = false;
    loading = false;

    //genesis files are the original copy of all the files
    genesisFiles = [];
    //this data is used to pass to the data table and is open to mutations from filtering
    fileSetData = [];
    fileSet = [];

    sortDirection = 'asc';
    showFilterDropdown = false;
    filterableOptions;
    recordName;
    entityRecId;

    CLABEL__TechDisc = Disclosure_Documents_Header_TechnicalDescription;
    CLABEL__PubMan = Disclosure_Documents_Header_PublicationsManuscripts;

    //this is used to return the column configurationn for the datatable columns based on the filtering applied by a user
    get columns() {
        if (this.filterBy === FILTER_FILES_ENUMS.ALL) {
            return [
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
                    label: 'Type',
                    fieldName: 'Type',
                    sortable: false,
                },
                {
                    label: 'Classification',
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
                    label: 'File Size',
                    fieldName: 'ContentSize',
                    sortable: false,
                    typeAttributes: {
                        label: {
                            fieldName: 'ContentSize'
                        }
                    }

                }
            ];

        }
        return [
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
                label: 'Type',
                fieldName: 'Type',
                sortable: false,
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
                label: 'File Size',
                fieldName: 'ContentSize',
                sortable: false,
                typeAttributes: {
                    label: {
                        fieldName: 'ContentSize'
                    }
                }

            }
        ];
    }

    get fields() {
        console.debug('fields: this.objectApi', this.objectApi)
        return getDocumentFieldsByRecordTypeAndClassification(this.objectApi, this.documentForRecordType)
    }
    //when we navigate to the coponent, we grab data from the state that we passed through from the Navigation
    @wire(CurrentPageReference) pageRef(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__id;
            this.filterBy = pageRef.state.c__f;
            this.objectApi = pageRef.state.c__o;
            this.documentForRecordType = pageRef.state.c__t;
            console.debug('documentTable CurrentPageReference:', this.documentForRecordType)
            console.debug('documentTable objectApi:', this.objectApi)
            console.debug('documentTable filterBy:', this.filterBy)
            console.debug('documentTable recordId:', this.recordId)
        }
    }

    //this is used to retrieve the name of the record to display in the breadcrumb on the top
    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    async handleDisclosure({ error, data }) {
        if (data) {
            this.recordName = data.fields?.Name__c?.value ?? this.documentForRecordType ?? 'Unknown';
            this.entityRecId = getDocumentEntityIdFieldByRecordTypeAndClassification(this.objectApi, this.documentForRecordType, data);
            console.debug('this.entityRecId', this.entityRecId)
            this.populateTableData()

        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }
    }

    //this function is used to retreive all the files related to this record and populate them into the data table
    async populateTableData() {
        this.loading = true;
        this.loadError = false;
        this.noFiles = false;

        if (!this.filterBy || !this.recordId || !this.objectApi) {
            console.debug('abort filterBy or recordId or objectApi is null');
            return;
        }

        try {
            const fileIds = await getFilesByType({ linkedRecId: this.recordId, recordType: this.objectApi });
            // Get All EntityRecIds for Forrester Cases
            if ( isEntityIdDocumentByRecordType(this.objectApi)) {
                const licenseFileIds = await getFileContentVersionsByEntityRecId({ entityRecId: this.entityRecId, recordType: this.objectApi, recordClassification: this.documentForRecordType  });
                console.debug('add case documents:', licenseFileIds);
                if (licenseFileIds) {
                    licenseFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }

            if (this.documentForRecordType === DOCUMENT_FOR_RECORDTYPE.COPYRIGHT) {
                const licenseFileIds = await getThirdPartyContentFilesByDisclosureId({ disclosureId: this.recordId });
                console.debug('add agreement:', licenseFileIds);
                if (licenseFileIds) {
                    licenseFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }

            if (this.documentForRecordType === DOCUMENT_FOR_RECORDTYPE.SOFTWARE_CODE) {
                const codeFileIds = await getThirdPartyCodeFilesByDisclosureId({ disclosureId: this.recordId });
                console.debug('add agreement:', codeFileIds);
                if (codeFileIds) {
                    codeFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }

            //early return for when there are no records
            if (fileIds.length === 0) {
                this.noFiles = true;
                this.loading = false;
                return;
            }

            const contentDocumentIds = fileIds.map(x => x.ContentDocumentId);
            this.fileSet = await getFileContentVersionsByDocumentIds({ contentDocumentIds: contentDocumentIds })

            this.genesisFiles = await Promise.all(
                this.fileSet.map(async (x) => {
                    x.Type = `${x.RecordType.Name}`
                    x.ContentSize = getFileSize(x.ContentSize)
                    x.fileUrl = await this.navigateToPreviewFileUrl(x.ContentDocumentId)
                    x.dynamicIcon = fileIcon(x.FileExtension)
                    x.renderedClassification = determineFileClassifactionName(x.Document_Classification__c)
                    return x
                })
            )
            this.fileSetData = this.genesisFiles;

            this.determineFilterableOptions();
            this.loading = false;

        } catch (error) {
            console.error(error);
            this.loadError = true;
            this.loading = false;
        }
    }

    //this is used to determine all the filter option available in the file filter dropdown
    determineFilterableOptions() {
        //the All filter must always be available
        this.filterableOptions = [{
            "label": "All Documents",
            "value": "all"
        },];

        //create a new Set. This helps intrinsically for not saving duplicates
        const uniqueClassifications = new Set();

        this.genesisFiles.forEach(file => {
            if (file.Document_Classification__c) {
                uniqueClassifications.add(file.Document_Classification__c);
            }
        });

        //now we map over all the unique items and create the filter options metadata that is passed to the dropdown filter
        let uniqueFilterItems = [...uniqueClassifications].map(x => {
            return {
                label: determineFileClassifactionName(x),
                value: determineFilterTypeByDocQueryType(x)
            }
        })
        //spread the newly generated label and value options with the all filter
        this.filterableOptions = [...this.filterableOptions, ...uniqueFilterItems]
    }

    get fileCount() {
        return this.filteredFiles.length ?? '0';
    }
    resetFiles() {
        this.filterBy = FILTER_FILES_ENUMS.ALL;
        this.fileSetData = this.genesisFiles;
    }
    handleFilterVisibility() {
        this.showFilterDropdown = !this.showFilterDropdown
    }
    handleFilterChange(event) {
        this.filterBy = event.detail.value;
    }
    get buttonStyling() {
        return this.showFilterDropdown ? 'brand' : 'border'
    }

    get objectCollectionName() {
        return this.objectApi ?? '';
    }
    get objectRecordName() {
        return this.recordName ?? '';
    }

    //this is used to convert the filter enums that we pass through the URL navigation into the document classifications counterpart
    get filteredFilesName() {
        switch (this.filterBy) {
            case FILTER_FILES_ENUMS.ALL:
                return 'All Documents';
            case FILTER_FILES_ENUMS.SIGNED_DISCLOSURE:
                return DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE;
            case FILTER_FILES_ENUMS.TECHNICAL_DESCRIPTION:
                return this.CLABEL__TechDisc;
            case FILTER_FILES_ENUMS.PUBLICATION_MANUSCRIPTS:
                return this.CLABEL__PubMan;
            case FILTER_FILES_ENUMS.SOFTWARE_CODE:
                return DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE;
            case FILTER_FILES_ENUMS.THIRD_PARTY_AGREEMENTS:
                return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS;
            case FILTER_FILES_ENUMS.THIRD_PARTY_CODE:
                return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE;
            default:
                return 'All Documents';
        }
    }

    renderedCallback() {
        document.title = this.filteredFilesName + ' | Salesforce';
    }

    //this passed the filtered data to the data table and conditionally filters the documents based on the state filter we passed through in the URL navigation state
    //it also dynamically filters the files based on the filter option we select in the filter dropdown 
    get filteredFiles() {
        switch (this.filterBy) {
            case FILTER_FILES_ENUMS.ALL:
                return this.fileSetData;
            case FILTER_FILES_ENUMS.SIGNED_DISCLOSURE:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE);
            case FILTER_FILES_ENUMS.TECHNICAL_DESCRIPTION:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION);
            case FILTER_FILES_ENUMS.PUBLICATION_MANUSCRIPTS:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.PUBLICATION_MANUSCRIPTS);
            case FILTER_FILES_ENUMS.SOFTWARE_CODE:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE);
            case FILTER_FILES_ENUMS.THIRD_PARTY_AGREEMENTS:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS);
            case FILTER_FILES_ENUMS.THIRD_PARTY_CODE:
                return this.fileSetData.filter(x => x.Document_Classification__c === DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE);
            default:
                return this.fileSetData;
        }
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

        const tempSorting = [...this.genesisFiles]

        tempSorting.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) => asStringIgnoreCase(x)));
        this.fileSetData = tempSorting;
        this.sortDirection = sortDirection;

        if (sortedBy === 'Title') {
            sortedBy = 'fileUrl'
        }

        this.sortedBy = sortedBy;
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApi,
                actionName: 'view'
            },
        });
    }
}