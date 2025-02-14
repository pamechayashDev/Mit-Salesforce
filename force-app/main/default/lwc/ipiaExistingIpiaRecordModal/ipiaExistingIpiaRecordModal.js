import LightningModal from "lightning/modal";
import { api, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { reduceErrors } from 'c/utils';
import getIPIARecordsDS from "@salesforce/apex/IPIAController.getIPIARecords";
import linkIPIARecordToDoc from "@salesforce/apex/IPIAController.linkIPIARecordToDoc";
import IPIA_RECORD_MIT_ID from "@salesforce/schema/IPIA_Record__c.MitId__c";
import IPIA_RECORD_FORM_NAME from "@salesforce/schema/IPIA_Record__c.FormName__c";
import IPIA_RECORD_IPIA_TYPE from "@salesforce/schema/IPIA_Record__c.IPIA_Type__c";
import IPIA_RECORD_SIGN_DATE from "@salesforce/schema/IPIA_Record__c.SignDatetime__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class IpiaExistingIpiaRecordModal extends LightningModal  {
    @api recordId;
    @api docDetails;

    mitIdField = 'Account.MitId__pc';
    searchResults;
    searchResultsCached;
    selectedSearchResult;
    isLoading = true;

    get getHeaderLabel() { "New Signed IPIA"; }
    get getSubmitButtonLabel() { "Attach"; }
    get hasDoc() { return this.docDetails != null }
    get docTitle() { return this.docDetails?.Title }
    get selectedValue() { return this.selectedSearchResult?.label ?? null; }

    get mitId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.mitIdField)
        }
        return null
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$mitIdField' })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            await this.getIPIARecords();
        }
        if (record.error) {
            this.error = true
            this.isLoading = false;
        }
    }

    
    async getIPIARecords() {
        getIPIARecordsDS({ mitId: this.mitId }).then((result) => {
            const currentIPIAData = result.currentIPIARecord;
            const tempHistroryIPIAData = result.historicIPIARecords;

            const ipiaNoDocs = [];
            const noCurrentDoc = (currentIPIAData.ContentDocumentLinks == null || currentIPIAData.ContentDocumentLinks === undefined);
            if (noCurrentDoc || currentIPIAData.ContentDocumentLinks?.length <= 0) {
                ipiaNoDocs.push(currentIPIAData);
            } 
            tempHistroryIPIAData.forEach((record) => {
                const noDoc = (record.ContentDocumentLinks == null || record.ContentDocumentLinks === undefined);
                if (noDoc || record.ContentDocumentLinks?.length <= 0) {
                    ipiaNoDocs.push(record);
                }            
            });
            
            this.searchResultsCached = ipiaNoDocs.map((element) => ({
                label: element.Name + ' • ' + element.IPIA_Type__r.Name, 
                value: element.Id
            })).sort((a, b) =>
                a.label.localeCompare(b.label)
            );

            this.isLoading = false;
        }).catch(error => {
            console.error("Error loading IPIA Records", error);

            document.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading IPIA Records",
                    message: reduceErrors(error),
                    variant: "error"
                })
            );
            this.isLoading = false;
        });
    }

    // Helper Methods    
    search(event) {
        const input = event.detail.value.toLowerCase();
        const result = this.searchResultsCached.filter((element) =>
            element.label.toLowerCase().includes(input)
        );
        this.searchResults = result;
    }

    showExistingIpiaOptions() {
        if (!this.searchResults) {
            this.searchResults = this.searchResultsCached;
        }
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.value;

        this.selectedSearchResult = this.searchResults.find(
            (pickListOption) => pickListOption.value === selectedValue
        );
        this.clearSearchResults();
    }

    clearSearchResults() {
        this.searchResults = null;
        let ipiaExistingIpiaLookup = this.template.querySelector("lightning-input[data-formfield=\"ipiaExistingIpiaLookup\"]");
        if (!this.selectedSearchResult) {
            ipiaExistingIpiaLookup.value = "";
        }
    }

    disabled = false;
    handleSubmitButton() {
        this.disabled = true;
        
        linkIPIARecordToDoc({ ipiaRecordId: this.selectedSearchResult.value, contentDocumentId: this.docDetails.ContentDocumentId }).then(async (result) => {
            document.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'IPIA Record created successfully',
                    variant: 'success'
                })
            );
            this.disabled = false;
            this.close();
        }).catch((error) => {
            let errorMessages = reduceErrors(error);            

            if (errorMessages.length > 0) {
                console.error("error", errorMessages);
                document.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessages.join(", "),
                        variant: TOAST_VARIANT_ERROR
                    })
                );
            }
        });
    }

    handleCancelButton() {
        this.close();
    }
}