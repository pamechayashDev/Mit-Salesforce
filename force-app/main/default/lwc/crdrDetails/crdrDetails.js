import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class CrdrDetails extends LightningElement {
    @api recordId;
    activeSections = ['royaltyIncome', 'levelA', 'levelB', 'levelC', 'levelD'];
    loading = true;
    
    crdr;
    dynamicFields = [];
    //=============================

    @wire(getObjectInfo, { objectApiName: 'Forrester_SHIR_CRDR_VIEW__x' })
    crdrObjecInfo({ data, error }) {
        if (data) {
            const options = Object.keys(data.fields).map((curField) => {
                const field = data.fields[curField];                
                return 'Forrester_SHIR_CRDR_VIEW__x.' + field.apiName
            });

            this.dynamicFields = options;            
        }

        if (error) {
            console.error(error);
        }
    }
    
    @wire(getRecord, { recordId: '$recordId', optionalFields: '$dynamicFields' })
    async handleGetRecord(record) {
        if (record.data) {
            this.crdr = record.data;
            this.loading = false;
            
        }
        if (record.error) {
            this.error = true
        }
    }
}