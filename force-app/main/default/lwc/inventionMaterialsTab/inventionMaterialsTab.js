import { DISCLOSURE_FIELDS, getInventionData } from 'c/utils';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

import getThirdPartyMaterialsByInventionId from "@salesforce/apex/DisclosureRecordFetch.getThirdPartyMaterialsByInventionId";

export default class InventionMaterialsTab extends NavigationMixin(LightningElement) {
    @api recordId;

    disclosureData
    @track recordData

    @track materialsList
    @track materialsCount

    @track loading = true;
    @track noResults = false;
    @track error = false;
    @track errorText;

    @track mouseStrainCross = null

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;

            this.inventionHelper();

        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }
    }

    inventionHelper() {
        getInventionData(this.recordId).then(result => {
            console.log(`%c [BIO TANG DATA]`, `color: green`, result);
            this.recordData = result;
            this.getMaterialsList();
        }).catch(error => {
            console.error(error);
        })
    }

    async getMaterialsList() {
        this.loading = true;
        try {
            const result = await getThirdPartyMaterialsByInventionId({ inventionId: this.recordData.Id })
            if (result.length <= 0) {
                this.noResults = true;
                this.materialsCount = 0;
            }
            if (result.length > 0) {
                console.log(`%c [3rd Party Materials]`, `color: gold`, result);
                this.materialsCount = result.length > 2 ? '2+' : result.length;
                this.materialsList = result.slice(0, 2);
                this.noResults = false;
            }

            this.error = false;
            this.errorText = undefined;
            this.loading = false;
        }
        catch (error) {
            this.errorText = 'Failed Loading Materials For this Invention Record';
            this.error = true;
            this.loading = false;
            console.error(error);
        }
    }

    navigateToAllMaterials(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordData.Id,
                objectApiName: 'Invention_Disclosure__c',
                relationshipApiName: 'Third_Party_Material__r',
                actionName: 'view'
            },
        });
    }
}