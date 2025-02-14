import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getBioTangData } from 'c/utils';

import { DISCLOSURE_FIELDS } from 'c/utils';

import getLabMaterialsByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getLabMaterialsByBioTangId"
import getMouseStrainByBioTangId from "@salesforce/apex/DisclosureRecordFetch.getMouseStrainByBioTangId"


export default class BioTangMaterials extends NavigationMixin(LightningElement) {
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
    @track mouseStrainCrossDetails = null

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    handleDisclosure({ error, data }) {
        if (data) {
            console.log(`%c [DISCLOSURE DATA]`, `color: green`, data);
            this.disclosureData = data;

            this.biotangDataHelper();

        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }
    }

    get isMouseStrain() {
        return this.recordData.RecordType.DeveloperName === "mouseStrain";
    }

    get bioTangType() {
        return this.recordData.RecordType.Name;
    }

    biotangDataHelper() {
        getBioTangData(this.recordId).then(result => {
            console.log(`%c [BIO TANG DATA]`, `color: green`, result);
            this.recordData = result;
            this.getMaterialsList();

            if (this.recordData.RecordType.DeveloperName === 'mouseStrain') {
                this.getMouseStrainDetails();
            }
        }).catch(error => {
            console.error(error);
        })
    }


    getMouseStrainDetails() {
        getMouseStrainByBioTangId({ biotangId: this.recordData.Id }).then(result => {
            if (result.length > 0) {
                this.mouseStrainCross = result[0].Mouse_Gen_Cross_Other__c;
                this.mouseStrainCrossDetails = result[0].Mouse_Strain_Gen_Details__c;
            }
        }).catch(error => {
            console.error(error);
        }
        )
    }

    async getMaterialsList() {
        try {
            const result = await getLabMaterialsByBioTangId({ biotangId: this.recordData.Id })
            if (result.length <= 0) {
                this.noResults = true;
                this.materialsCount = 0;
            }
            if (result.length > 0) {
                this.materialsCount = result.length > 2 ? '2+' : result.length;
                this.materialsList = result.slice(0, 2);
                this.noResults = false;
            }

            this.error = false;
            this.errorText = undefined;
            this.loading = false;
        }
        catch (error) {
            this.errorText = 'Failed Loading Materials For this BioTang Record';
            this.error = true;
            this.loading = false;
            console.error(error);
        }
    }

    navigateToAllMaterials() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordData.Id,
                objectApiName: 'BioTang_Disclosure__c',
                relationshipApiName: 'Lab_Materials__r',
                actionName: 'view'
            },
        });
    }
}