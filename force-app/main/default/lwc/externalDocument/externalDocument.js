import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { fileIcon } from 'c/utils';
import getRecordsByProvider from '@salesforce/apex/ExternalDocumentController.getRecordsByProvider';
const columns = [

    {
        label: 'External Document',
        fieldName: 'url',
        type: 'url',
        sortable: false,
        wrapText: true,
        typeAttributes: {
            label: {
                fieldName: 'name'
            }
        },
         cellAttributes: {
             iconName: { fieldName: 'dynamicIcon' },
             class: 'record'
        }

    }
];

export default class ExternalDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordData
    @api providerType;
    @api cardTitle;

    columns = columns;
    loading = true;
    loadError = false;
    enableDataTable = false;
    rows = [];

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            await this.loadFiles( );
        }
    }

    loadFiles = async () => {
        this.loading = true;
        const data = await getRecordsByProvider({provider: this.providerType , recordId: this.recordId})
        this.rows = [];
        let idCount = 0;
        data.forEach( (x) => {
            this.rows.push({
                id: ++idCount,
                name: x.name,
                dynamicIcon: fileIcon(x.recordType),
                url: x.url
            })
        })
        if (this.enableDataTable) {
            this.template.querySelector('lightning-datatable').columns = columns;
        }

        this.loading = false;

    }
    get title() {
        return this.cardTitle ?? 'External Document'
    }

    get showDataTable() {
        return (!this.loadError);
    }

}