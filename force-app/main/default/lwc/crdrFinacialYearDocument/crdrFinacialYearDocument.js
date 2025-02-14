import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCrdrFilesByCaseRecId from '@salesforce/apex/FileRepository.getCrdrFilesByCaseRecId';
import { fileIcon, sortBy, asStringIgnoreCase } from 'c/utils';
import { getRecord } from "lightning/uiRecordApi";
import { getDocumentFieldsByRecordTypeAndClassification, getDocumentEntityIdFieldByRecordTypeAndClassification } from 'c/utils';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const columns = [
    {
        label: 'File Name',
        fieldName: 'fileUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {
            label: {
                fieldName: 'title'
            }
        },
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
    },
    {
        label: 'FY',
        fieldName: 'financialYear',
        sortable: true,
    },
    {
        label: 'Created Date',
        sortable: true,
        fieldName: 'crdrDate',
        type: "date",
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            timeZone: TIME_ZONE
        }
    },
];

export default class CrdrFinacialYearDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @api documentCardTitle;
    @api documentQueryType

    crdrData;
    entityId;
    financialYear;

    sortDirection = 'asc';
    fileSet = [];
    fileSetData = [];

    loading = true;
    noFiles = false;
    loadError = false;

    get fields() {
        return getDocumentFieldsByRecordTypeAndClassification('CRDR', 'CRDR')
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    async handleCRDR({ error, data }) {
        if (data) {
            console.log(`%c [CRDR DATA]`, `color: green`, data);
            this.entityId =  getDocumentEntityIdFieldByRecordTypeAndClassification('CRDR', 'CRDR', data);
            this.caseRecId = data.fields?.CASE_RECID__c?.value;
            this.caseCrdrRecId = data.fields?.CASE_CRDR_RECID__c?.value;
            this.financialYear = data.fields?.FY__c?.value;
            this.crdrData = data;
            this.generateFileData();


        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

   
    generateFileData = async () => {
        this.loading = true;
        this.fileSet = [];
        this.fileSetData = [];
        this.loadError = false;
        this.noFiles = false;

        try {
            const fileIds = await getCrdrFilesByCaseRecId({ caseRecId: this.caseRecId, financialYear: this.financialYear, status: this.determineStatusToDisplay(), caseCrdrRecId: this.caseCrdrRecId,});
            console.log(`%c [CRDR FY FIELD_IDS]`, `color: green`, fileIds);
            if (!fileIds) {
                this.noFiles = true;
                this.loading = false;
                return;
            }         

            if (fileIds.length === 0) {
                this.noFiles = true;
                this.loading = false;
                return;
            }

            this.fileSet = fileIds


            this.fileSetData = await Promise.all(
                this.fileSet.map(async (x) => {
                    x.modifiedDate = x.contentModifiedDate
                    x.crdrDate = x.crdrDate
                    x.fileUrl = await this.navigateToPreviewFileUrl(x.contentDocumentId)
                    x.dynamicIcon = fileIcon(x.fileExtension)
                    x.financialYear = x.financialYear
                    return x
                })
            )
            // Sort the fileSetData array by CreatedDate
             this.fileSetData.sort((a, b) => new Date(b.crdrDate) - new Date(a.crdrDate));
            this.template.querySelector('lightning-datatable').columns = columns;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.loadError = true;
        }
        this.loading = false;
    }

    determineStatusToDisplay() {
        if (!this.documentQueryType) return undefined;
        if (this.documentQueryType) {
            switch (this.documentQueryType) {
                case 'Draft_CRDR':
                    return 'Draft';
                case 'Finalised_CRDR':
                    return 'Finalised';
                default:
                    return undefined;
            }
        }
        return undefined
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

    get documentCardTitleWithCount() {
        return this.documentCardTitle + " (" + this.fileSet.length + ")"
    }

    get datatableHeight() {
        if ( this.fileSet.length >= 8) {
            return 'height: 250px;';
        }
        return 'height: 100%';
    }

}