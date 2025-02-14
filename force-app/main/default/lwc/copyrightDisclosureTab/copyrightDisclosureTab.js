import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getCopyrightData } from 'c/utils';

import { DISCLOSURE_FIELDS, DOCUMENT_CLASSIFICATIONS } from 'c/utils';

import getThirdPartyContentByCopyrightId from '@salesforce/apex/DisclosureRecordFetch.getThirdPartyContentByCopyrightId';
import getOpenSourceByCopyrightId from '@salesforce/apex/DisclosureRecordFetch.getOpenSourceByCopyrightId';

export default class CopyrightDisclosureTab extends NavigationMixin(LightningElement) {
    @api recordId;

    recordData;
    disclosureData;

    thirdPartyList = [];
    thirdPartyFullList = [];
    loadingThirdParty = true;
    errorThirdParty = false;
    noThirdParty = false;

    openSourceList = [];
    loadingOpenSource = true;
    errorOpenSource = false;
    noOpenSource = false;

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;

            this.recordData = await getCopyrightData(this.recordId);

            await this.getOpenSourceList();
            await this.getThirdPartyList();
        } else if (error) {
            console.log(error);
            console.log(error.body.message);
        }
    }

    get documentQueryType() {
        return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS;
    }

    async getThirdPartyList() {
        if (!this.recordData) return;
        this.loadingThirdParty = true;
        this.errorThirdParty = false;
        this.noThirdParty = false;

        try {
            let res = await getThirdPartyContentByCopyrightId({ copyrightId: this.recordData.Id })
            if (res.length <= 0) {
                this.noThirdParty = true;
            }
            this.thirdPartyFullList = res
            this.thirdPartyList = res?.slice(0, 2);
        } catch (error) {
            console.log(error);
            this.errorThirdParty = true;
        }
        this.loadingThirdParty = false;
    }

    get thirdPartyContentCount() {
        return this.thirdPartyFullList?.length ?? 0;
    }

    async getOpenSourceList() {
        if (!this.recordData) return;
        this.loadingOpenSource = true;
        this.errorOpenSource = false;
        this.noOpenSource = false;

        try {
            let res = await getOpenSourceByCopyrightId({ disclosureId: this.recordData.Id })
            if (res.length <= 0) {
                this.noOpenSource = true;
            }
            this.openSourceList = res?.slice(0, 2);

            this.openSourceList.forEach(e => {
                if (e.Open_Source_Licensing_Type__c === 'Other') {
                    e.Open_Source_Other = true;
                }
            });
        } catch (error) {
            console.log(error);
            this.errorOpenSource = true;
        }
        this.loadingOpenSource = false;
    }

    navigateToAllThirdParty(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordData.Id,
                objectApiName: 'Copyright_Disclosure__c',
                relationshipApiName: 'Third_Party_Contents__r',
                actionName: 'view'
            },
        });
    }
}