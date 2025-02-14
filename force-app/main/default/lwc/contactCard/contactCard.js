import { LightningElement, api, wire } from 'lwc';
import getContactById from "@salesforce/apex/DisclosureRecordFetch.getContactById";
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

let fieldArray = [];

export default class ContactCard extends LightningElement {
    //These configurations are retrieved from the XML file for this component
    @api relatedList;
    @api relatedListField;
    @api cardTitle;

    @api recordId


    loading = true;
    contact = {};
    hasResults = true;
    errorLoading = false;
    relatedLists;
    contactId;
    records;

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: '$relatedList',
        fields: fieldArray
    })
    listInfos({ error, data }) {
        if (data) {
            this.records = data.records;
            this.errorLoading = false;

            if (this.records[0]) {
                this.contactId = this.records[0].fields[this.splitField(this.relatedListField)].value
                this.getContact();
            }
            if (!this.records[0]) {
                this.hasResults = false;
                this.contact = {};
                this.loading = false;
            }
        }
        if (error) {
            console.error(error)
            this.errorLoading = true;
            this.records = null;
            this.loading = false;
        }
    }

    async getContact() {
        this.loading = true;
        this.errorLoading = false;

        try {
            const contact = await getContactById({ id: this.contactId })

            if (contact == null) {
                this.hasResults = false;
                this.loading = false;
                this.contact = {};
                return;
            }

            this.contact = contact;
            this.hasResults = true;
        } catch (error) {
            this.errorLoading = true;
            console.error(error)
        }

        this.loading = false;
    }

    connectedCallback() {
        fieldArray = [this.relatedListField];
    }

    splitField(f) {
        let fields = f.split(".")
        return fields[1]
    }

    get renderDetails() {
        return this.hasResults && !this.errorLoading && !this.loading;
    }

    get renderNoResults() {
        return !this.hasResults && !this.errorLoading && !this.loading;
    }
}