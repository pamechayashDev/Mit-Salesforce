import { LightningElement,api,wire } from 'lwc';
import getExternalCRDRRecordId from '@salesforce/apex/containerObjectRepository.getExternalCRDRRecordId';

export default class RedirectToCRDR extends LightningElement {

    parameters = {};
    @api recordId;
    base_URL;
    connectedCallback() {

        this.base_URL = window.location.origin;

    }

    @wire(getExternalCRDRRecordId, {
        containerId: '$recordId'
    })
    handleLoadData(result) {
        console.log('wire recordId--',this.recordId);
        const {data, error} = result;
        if (data) {
            
            let url = this.base_URL+'/'+data;
            //window.open(url,"_blank");
            window.open('/'+data,"_blank");
            
        }
        if (error) {
            console.error(error);
        }
    }

    
}