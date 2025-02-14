import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDisclosureByCaseRecId from '@salesforce/apex/DisclosureRecordFetch.getDisclosureByCaseRecId';
import getCrdrSponsorSRAFilesByCaseRecId from '@salesforce/apex/FileRepository.getCrdrSponsorSRAFilesByCaseRecId';
import { DOCUMENT_FORRESTER_CASE_CRDR_FIELDS, fileIcon, sortBy, asStringIgnoreCase} from 'c/utils';
import { getRecord } from "lightning/uiRecordApi";


const columns = [
    {
        label: 'Sponsor Name',
        fieldName: 'fileUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {
            label: {
                fieldName: 'sponsorName'
            }
        },
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
    },
    {
        label: 'Project Number',
        fieldName: 'accountNumber',
        type: 'Text',
        sortable: true,
    },
    {
        label: 'Type',
        fieldName: 'Type',
        sortable: false,
    },
    {
        label: 'Source',
        fieldName: 'awardName',
        type: 'Text',
        sortable: true,
    },
    {
        label: 'Award Name',
        fieldName: 'fileUrl',
        type: 'url',
        sortable: true,
        typeAttributes: {
            label: {
                fieldName: 'Title'
            }
        }
    }

];

export default class CrdrKualiDocuments extends NavigationMixin(LightningElement) {
    @api recordId;

    sortDirection = 'asc';
    fileSet = [];
    fileSetCount = '';
    fileSetData = [];
    fileIds = [];
    agreementSRA = [];

    loading = true;
    noFiles = false;
    loadError = false;

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



    generateFileData = async () => {
        this.loading = true;
        this.fileSetData = [];
        this.loadError = false;
        this.noFiles = false;

        try {

            console.debug('add agreement SRA caseRecId:', this.caseRecId);
            this.agreementSRA = await getCrdrSponsorSRAFilesByCaseRecId({ caseRecId: this.caseRecId });
            console.debug('add agreement SRA documents:', JSON.stringify(this.agreementSRA));
            await Promise.all(
                this.agreementSRA.map(async(sra) => {
                    console.debug('add agreement SRA sra:', JSON.stringify(sra));
                this.fileSetData.push({
                    Type: sra.documentType,
                    ContentSize: undefined,
                    fileUrl: sra.url,
                    sponsorName: sra.sponsorName,
                    accountNumber: sra.accountNumber,
                    Title: sra.title,
                    dynamicIcon: fileIcon(sra.fileExtension),
                   // renderedClassification: sra.documentClassification,
                    awardName : sra.entitySubType,
                    sObjectUrl: await this.navigateToSObjectUrl(sra.recordId),
                    sObjectLabel: sra.recordLabel,
                })
            })
            )

            console.log('this.fileSetData-----------------', JSON.stringify(this.fileSetData))

            if (this.fileSetData.length === 0) {
                this.noFiles = true;
                this.loading = false;
                return;
            }
            this.template.querySelector('lightning-datatable').columns = columns;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            console.log(' error-----------------', JSON.stringify(error))
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
        return "Kuali Documents (" + this.fileSetData.length + ")"
    }

    get datatableHeight() {
        if ( this.fileSetData.length >= 8) {
            return 'height: 250px;';
        }

        return 'height: 100%';
    }


}