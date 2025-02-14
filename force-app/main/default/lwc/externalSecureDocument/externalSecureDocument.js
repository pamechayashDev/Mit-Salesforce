import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { fileIcon } from 'c/utils';
import getSessionIdFromVFPage from '@salesforce/apex/ExternalDocumentController.getSessionIdFromVFPage';
import getRecordsByProvider from '@salesforce/apex/ExternalDocumentController.getRecordsByProvider';
import { RefreshEvent } from 'lightning/refresh';

import {
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import columnClickMessageChannel from '@salesforce/messageChannel/customTableColumnAction__c';

const actions = [
    { label: 'View', name: 'download' },
];


const columns = [

    {
        label: 'External Document',
        fieldName: 'url',
        type: 'clickrow',
        sortable: false,
        wrapText: true,
        typeAttributes: {
            label: {
                fieldName: 'name'
            },
            iconName: { fieldName: 'dynamicIcon' },
        },

    },
    {
        label: '...',
        type: 'action',
        typeAttributes: { rowActions: actions
        },
    },
];

async function fetchDataHelper(urlEndpoint) {

    const sid = await getSessionIdFromVFPage()
    console.debug('sid', sid)
    return fetch('' +urlEndpoint, {
        cache: 'no-store',
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + sid,
        },
        body: undefined
    }).then((response) => response.blob())
        .then((response) =>  blobToBase64(response)
            .then(res => res)  );;
}

function blobToBase64(blob) {
    return new Promise((resolve, _) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.readAsDataURL(blob);
    });
}



export default class ExternalSecureDocument extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordData
    @api providerType;
    @api cardTitle;

    columns = columns;
    @track loading = false;
    loadError = false;
    enableDataTable = false;
    rows = [];

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            await this.loadFiles();
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


    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.debug('row', row)
        switch (actionName) {
            case 'download':
                this.viewDocument(row.url).then()
                break;
            default:
        }
    }


    async viewDocument(url) {
        try {
            this.loading = true;
            const dataBase64 = await fetchDataHelper(url);
            console.debug('data', dataBase64)
            let a = document.createElement("a");
            a.href = dataBase64
            a.download = "documentName.pdf"
            a.click();
            const delayInMilliseconds = 2000; //2 second
            setTimeout(function () {
                a.remove();
            }, delayInMilliseconds)
        } finally {
            this.loading = false;
        }

    }


    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        this.subscription = subscribe(
          this.messageContext,
            columnClickMessageChannel,
          (message) => {
              this.handleColumnAction(message);
          }
        );
    }

  disconnectedCallback() {
      unsubscribe(this.subscription);
      this.subscription = null;
  }


    handleColumnAction(filters) {
    console.log('execute');
    console.log(filters.selectedRecord);
    this.loading = true;
    try {
        this.dispatchEvent(new RefreshEvent());
        this.viewDocument(filters.selectedRecord).then()
    }finally {
        this.loading = false;
    }
  }

}