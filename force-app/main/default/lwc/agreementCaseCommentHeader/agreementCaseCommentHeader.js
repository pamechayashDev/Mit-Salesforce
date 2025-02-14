/**
 * Created by Andreas du Preez on 2024/04/11.
 */

import { api, LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { CurrentPageReference } from "lightning/navigation";
import { getAllTabInfo, getFocusedTabInfo, getTabInfo, setTabLabel } from "lightning/platformWorkspaceApi";

const FIELDS = [
    "Forrester_SHIR_AGR_CASE_COMMENT__x.AGREEMENT_RECID__c",
    "Forrester_SHIR_AGR_CASE_COMMENT__x.LICENSEE__c",
    "Forrester_SHIR_AGR_CASE_COMMENT__x.CONTRACT_CASE_NUM__c"
];

export default class AgreementCaseCommentHeader extends LightningElement {

    @api recordId;
    title = "";
    tabId;

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    async agreementCaseComment({ error, data }) {
        if (data) {
            this.title = `${data.fields.AGREEMENT_RECID__c.value} (${data.fields.LICENSEE__c.value}) - ${data.fields.CONTRACT_CASE_NUM__c.value}`;
            setTabLabel(this.tabId, this.title);
        }
        if (error) {
            console.error(error);
        }
    }

    @wire(CurrentPageReference) pageRef() {
        getFocusedTabInfo().then((tabInfo) => {
            this.tabId = tabInfo.tabId;
        });
    }
}