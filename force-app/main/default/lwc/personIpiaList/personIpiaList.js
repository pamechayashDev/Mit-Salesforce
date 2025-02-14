/**
 * Created by Andreas du Preez on 2024/07/30.
 */

import { api, LightningElement, wire } from "lwc";
import getIPIARecordsDS from "@salesforce/apex/IPIAController.getIPIARecords";
import getCreateAccess from "@salesforce/apex/IPIAController.userHasIPIARecordCreatePermission";
import { determineSortPrimer, reduceErrors, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import ipiaNewRecordModal from "c/ipiaNewRecordModal";
import { NavigationMixin } from "lightning/navigation";
import msgService from "@salesforce/messageChannel/ipiaCurrentChange__c";
import { subscribe, MessageContext, APPLICATION_SCOPE, unsubscribe, publish } from "lightning/messageService";

const signedIPIAColumns = [
    {
        label: "IPIA ID",
        fieldName: "IPIANameUrl",
        type: "url",
        typeAttributes: {
            label: {
                fieldName: "Name"
            },
            target: "_self"
        },
        sortable: true, sortFieldName: "Name", sortFieldType: SORT_BY_TYPE_ENUMS.STRING,
        hideDefaultActions: true, initialWidth: 150
    },
    {
        label: "IPIA Type",
        fieldName: "ipiaType",
        type: "customUrlOrTextType",
        typeAttributes: {
            isUrl: { fieldName: "ipiaTypeIsUrl" },
            value: { fieldName: "ipiaTypeUrl" },
            target: { fieldName: "ipiaTypeTarget" },
            label: { fieldName: "ipiaTypeLabel" },
        },

        sortable: true, sortFieldName: "FormName__c", sortFieldType: SORT_BY_TYPE_ENUMS.STRING,
    },
    {
        label: "Effective Date",
        fieldName: "SignDatetime__c",
        type: "date",
        typeAttributes: {
            label: {
                fieldName: "SignDatetime__c"
            },
            target: "_blank",
            year: "numeric",
            month: "numeric",
            day: "numeric",
            timeZone: "UTC"
        },
        sortable: true, sortFieldName: "SignDatetime__c", sortFieldType: SORT_BY_TYPE_ENUMS.DATE,
        hideDefaultActions: true,
        initialWidth: 140
    },
    {
        label: "IPIA Type Status",
        fieldName: "ipiaTypeStatus",
        type: "text",
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 145
    },
    {
        label: "Current",
        fieldName: "currentIPIA",
        type: "boolean",
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 85
    },
    {
        label: "Exemption",
        fieldName: "ipiaExemption",
        type: "boolean",
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 100
    },
    {
        label: "Has Document",
        fieldName: "ipiaHasDoc",
        type: "boolean",
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 130
    }
];

export default class PersonIpiaList extends NavigationMixin(LightningElement) {

    @api recordId;
    @api mitIdField;
    @api newButtonEnabled;

    record = {};
    currentIPIAData;
    signedIPIAData = [];
    sortDirection = "asc";
    sortedBy = "";
    RowOffset = 0;
    createAccess;
    signedIPIAColumns = signedIPIAColumns;
    isLoading = true;

    // Getters
    get getCardTitle() {
        return `IPIA  (${this.signedIPIAData.length})`;
    }

    get mitId() {
        if (this.record) {
            return getFieldValue(this.record.data, this.mitIdField)
        }
        return null
    }

    get headerCurrentActions() {
        return this.newButtonEnabled && this.mitId && this.createAccess ? [{label: "New IPIA", eventName: "new"}] : [];
    }

    get hasSignedIPIAData() {
        return this.signedIPIAData?.length > 0;
    }

    connectedCallback() {
        this.subscribeHandler();
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    // Wire Methods
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: '$mitIdField' })
    async handleGetRecord(record) {
        if (record.data) {
            this.record = record;
            await this.getCreateAccess();
            await this.getIPIARecords();
        }
        if (record.error) {
            this.error = true
        }
    }

    // Helper Methods
    async getIPIARecords() {
        getIPIARecordsDS({ mitId: this.mitId }).then((result) => {
            this.signedIPIAData = [];

            // Set the current IPIA Record
            let previousCurrentIPIAData = this.currentIPIAData;
            this.currentIPIAData = result.currentIPIARecord;
            if (this.currentIPIAData) {
                if (previousCurrentIPIAData && previousCurrentIPIAData.Id !== this.currentIPIAData.Id) {
                    this.publishCurrentIPIAChangeMessage();
                }

                this.currentIPIAData.currentIPIA = true;
                this.signedIPIAData.push(this.currentIPIAData);
            }

            this.tempHistroryIPIAData = result.historicIPIARecords;
            this.tempHistroryIPIAData.forEach((record) => {
                record.currentIPIA = false;
            });

            // Set the IPIA Records
            if (this.tempHistroryIPIAData.length) {
                this.signedIPIAData.push(...this.tempHistroryIPIAData);
            }

            console.log(JSON.parse(JSON.stringify(this.signedIPIAData)));
            this.signedIPIAData.forEach((record) => {
                record.IPIANameUrl = `/${record.Id}`;
                record.ipiaTypeIsUrl = !!record.IPIA_Type__c;
                record.ipiaTypeUrl = `/${record.IPIA_Type__c}`;
                record.ipiaTypeTarget = '_self';
                record.ipiaTypeLabel = record?.IPIA_Type__r?.Name ?? record.FormName__c;
                record.ipiaExemption = record.IPIA_Type__r?.Exemption__c;
                record.ipiaHasDoc = record.ContentDocumentLinks?.length > 0;
                record.ipiaTypeStatus = record.IPIA_Type__r?.Status__c;
            });
            this.isLoading = false;
        }).catch(error => {
            console.error("Error loading IPIA Records", error);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error loading IPIA Records",
                    message: reduceErrors(error),
                    variant: "error"
                })
            );
            this.isLoading = false;
        });
    }

    async getCreateAccess() {
        getCreateAccess().then((result) => {
            this.createAccess = result;
        }).catch(() => {
            this.createAccess = false;
        });
    }

    navToIPIAId(Id) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: Id,
                objectApiName: "IPIA__c",
                actionName: "view"
            }
        })
    }

    // Event Handlers
    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.signedIPIAData];
        const sortFieldType = this.signedIPIAColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.signedIPIAColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === "asc" ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        );
        this.signedIPIAData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    handleMessage(message){
        if (message.mitId === this.mitId) {
            this.isLoading = true;
            this.getIPIARecords();
        }
    }

    publishCurrentIPIAChangeMessage() {
        publish(this.messageContext, msgService, {
            mitId: this.mitId
        });
    }

    async handleCurrentOnHeaderActionClick(event) {
        if (event.detail.eventName === "new") {
            await ipiaNewRecordModal.open({
                mitId: this.mitId,
                size: "small"
            }).then(() => {
                    this.getIPIARecords();
            });
        }
    }
}