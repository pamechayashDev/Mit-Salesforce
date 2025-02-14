import { LightningElement, api } from 'lwc';

export default class BioTangMaterialsItem extends LightningElement {
    @api material;

    get name() {
        if (!this.material) {
            return '';
        }
        return this.material.Name ?? '';
    }

    get source() {
        if (!this.material) {
            return '';
        }
        return this.material.Source__c ?? '';
    }

    get obtainedHow() {
        if (!this.material) {
            return '';
        }
        return this.material.How_Was_Material_Obtained__c ?? '';
    }

    get obtainedDesc() {
        if (!this.material) {
            return '';
        }
        return this.material.Material_Obtained_Other_Desc__c ?? '';
    }
}