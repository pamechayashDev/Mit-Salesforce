import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { fileIcon, getFileSize, sortBy, asStringIgnoreCase} from 'c/utils';
import getFilesByRecordId from '@salesforce/apex/FileRepository.getFilesByRecordId';
import getFileContentVersionsByDocumentIds from '@salesforce/apex/FileRepository.getFileContentVersionsByDocumentIds';
import msgServiceDocument from "@salesforce/messageChannel/utilizationReportDocumentRefresh__c";
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe } from "lightning/messageService";
import TIME_ZONE  from '@salesforce/i18n/timeZone';

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
        label: 'Submitted By',
        sortable: true,
        fieldName: 'CreatedBy',
        type: "text",
    },
    {
        label: 'Submitted Date',
        sortable: true,
        fieldName: 'CreatedDate',
        type: "date",
        typeAttributes: {
            year: "numeric",
            month: "numeric",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            timeZone: TIME_ZONE
        }
    }
];
export default class UtilizationSubmittionHistory  extends NavigationMixin(LightningElement) {
    
    @api recordId;
    wiredResult;
    records;

    sortDirection = 'asc';
    fileSet = [];
    fileSetCount = '';
    fileSetData = [];
    fileIds = [];
    
    loading = true;

    noFiles = true;
    loadError = false;

    connectedCallback() {
        this.subscribeHandler();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    @wire(getFilesByRecordId, { recordId: '$recordId' , dataType: 'Compliance', subType: 'Utilization_Report', docType: 'Original_Document'})
    async relatedContentVersions(wireResult) {

        const { data, error } = wireResult;
        this.wiredResult = wireResult;
        this.loading = true;
        
        if (data) {
            this.records = data;
            this.generateFileData();
        } else if (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.records =  undefined;
            this.loadError = true;
            this.loading = false;
        }
    }

    @wire(MessageContext)
    messageContext;

    //https://medium.com/@aleksej.gudkov/refresh-apex-lwc-not-working-4d31571ecc96#:~:text=Common%20Reasons%20refreshApex%20is%20Not%20Working&text=If%20the%20variable%20isn't,change%2C%20preventing%20a%20proper%20refresh.
    //https://github.com/navikt/crm-nks-base/blob/47d0213c9274b1383d7cf9a3cb9f848c71e4906b/force-app/main/default/lwc/nksNewsArticle/nksNewsArticle.js#L7
    async handleTryAgain() {
        console.log('in handleTryAgain');
        this.loadError = false;
        this.loading = true;
        
        await refreshApex(this.wiredResult);

        this.generateFileData();
    }

    async generateFileData() {
        this.loading = true;
        this.fileSet = [];
        this.fileSetData = [];
        this.loadError = false;
        this.noFiles = false;

        try {
            this.fileSet = this.records;
            this.fileSetCount = this.fileSet.length;

            await Promise.all(
                this.fileSet.map(async(x) => {
                    this.fileSetData.push({
                        Type: `${x.RecordType.Name}`,
                        Title: x.Title,
                        CreatedBy: x.CreatedBy.Name,
                        ContentSize: getFileSize(x.ContentSize),
                        fileUrl: await this.navigateToPreviewFileUrl(x.ContentDocumentId),                        
                        dynamicIcon: fileIcon(x.FileExtension), 
                        CreatedDate: x.CreatedDate
                    })
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
            this.noFiles = true;
            this.loading = false;

            this.fileSet = [];
            this.fileSetCount = '';
            this.fileSetData = [];
            this.fileIds = [];

        }
        this.loading = false;
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

    //===
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

    get datatableHeight() {
        if ( this.fileSet.length >= 8) {
            return 'height: 250px;';
        }
        return 'height: 100%';
    }

    get showLoading() {
        return this.loading
    }

    get documentCardTitleWithCount() {
        return "Submission History (" + this.fileSet.length + ")"
    }

    // Event handlers
    subscribeHandler() {
        this.messageSubscriptionDocument = subscribe(this.messageContext, msgServiceDocument, (message) => {this.handleMessageDocumentRefresh(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscriptionDocument);
        this.messageSubscriptionDocument = null;
    }

    handleMessageDocumentRefresh(message){
        if (message.utilizationReportId === this.recordId) {
            this.handleTryAgain();
        }
    }
}