import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFilesByType from '@salesforce/apex/FileRepository.getFilesByType';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import getThirdPartyContentFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyContentFilesByDisclosureId';
import getThirdPartyCodeFilesByDisclosureId from '@salesforce/apex/FileRepository.getThirdPartyCodeFilesByDisclosureId';
import { DISCLOSURE_FIELDS, fileIcon, getFileSize, DOCUMENT_FOR_RECORDTYPE, sortBy, asStringIgnoreCase, FILTER_FILES_ENUMS, determineFileClassifactionName } from 'c/utils';
import { getRecord } from "lightning/uiRecordApi";

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

export default class DisclosureDocumentAll extends NavigationMixin(LightningElement) {
    @api recordId;
    disclosureData;

    sortDirection = 'asc';
    fileSet = [];
    fileSetCount = '';
    fileSetData = [];

    loading = true;
    noFiles = false;
    loadError = false;


    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;
            this.userId = this.disclosureData.lastModifiedById;
            this.generateFileData();


        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

    determineCaseTypeEnumDisplay() {
        if (!this.disclosureData) return '';
        if (this.disclosureData) {
            switch (this.disclosureData.fields.RecordType.value.fields.DeveloperName.value) {
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
            const fileIds = await getFilesByType({ linkedRecId: this.recordId, recordType: 'Disclosure' });

            if (!fileIds) {
                this.noFiles = true;
                this.fileSetCount = '0';
                this.loading = false;
                return;
            }

            const documentRecordType = this.determineCaseTypeEnumDisplay();

            if (documentRecordType === DOCUMENT_FOR_RECORDTYPE.COPYRIGHT) {
                const licenseFileIds = await getThirdPartyContentFilesByDisclosureId({ disclosureId: this.recordId });
                if (licenseFileIds) {
                    licenseFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }

            if (documentRecordType === DOCUMENT_FOR_RECORDTYPE.SOFTWARE_CODE) {
                const codeFileIds = await getThirdPartyCodeFilesByDisclosureId({ disclosureId: this.recordId });
                if (codeFileIds) {
                    codeFileIds.forEach(x => {
                        fileIds.push(x);
                    })
                }
            }


            if (fileIds.length === 0) {
                this.noFiles = true;
                this.fileSetCount = '0';
                this.loading = false;
                return;
            }

            const contentDocumentIds = fileIds.map(x => x.ContentDocumentId);
            this.fileSet = await getFileContentVersionsByDocumentIds({ contentDocumentIds: contentDocumentIds });

            this.fileSetCount = this.fileSet.length;

            this.fileSetData = await Promise.all(
                this.fileSet.map(async (x) => {
                    x.Type = `${x.RecordType.Name}`
                    x.ContentSize = getFileSize(x.ContentSize)
                    x.fileUrl = await this.navigateToPreviewFileUrl(x.ContentDocumentId)
                    x.dynamicIcon = fileIcon(x.FileExtension)
                    x.renderedClassification = determineFileClassifactionName(x.Document_Classification__c)
                    return x
                })
            )

            console.log('this.fileSetData', this.fileSetData)
            this.template.querySelector('lightning-datatable').columns = columns;
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
                selectedRecordId: id //your ContentDocumentId here
            }
        });
        return url
    }

    navigateToAllFiles() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'All_Documents'
            },
            state: {
                c__id: this.recordId,
                c__f: FILTER_FILES_ENUMS.ALL,
                c__o: 'Disclosure',
                c__t: this.determineCaseTypeEnumDisplay()
            }
        });
    }


}