import { LightningElement, api, track, wire } from "lwc";
import getDataDS from '@salesforce/apex/GetChildBipPis.getChildBipPisData';
import msgService from "@salesforce/messageChannel/bipRequestStatusChange__c";
import { MessageContext, subscribe, APPLICATION_SCOPE, unsubscribe } from 'lightning/messageService';

export default class ChildBipComponent extends LightningElement {
    @api recordId;
      childBips=[];
    @track RecordsList = [];
     noOfBips = 0;
     isModalOpen = false;
     receivedId ='';
    messageSubscription;

    @wire(MessageContext)
    messageContext;

     // Open the modal
     handleOpenModal(event) {
        let clickedChildRecId;

        const element = event.target.closest('[data-id]');
        if (element) {
            clickedChildRecId = element.getAttribute('data-id');
            console.log('check--',clickedChildRecId);
            if(clickedChildRecId){
                this.receivedId = clickedChildRecId;
            }
    

        }
        this.isModalOpen = true;
     }
 
     // Close the modal
     handleCloseModal() {
         this.isModalOpen = false;
     }

    connectedCallback() {
        console.log("childBipComponent connectedCallback");
        this.getData();
       
        this.subscribeHandler();
    }

    getData() {
         this.RecordsList = [];
        getDataDS({recId : this.recordId}).then(res => {
            let result = res.childs;
            console.log('child data--' + result);
            let parentTile = res.primaryPiParent;
            console.log('results --='+ JSON.stringify(result));
            console.log('results res --='+ JSON.stringify(res));
            this.childBips = result;
            console.log('parentTile.Status',parentTile.Status==undefined);
            let pObj = {};

            pObj.PiLookupName = parentTile.PrimaryPIName==undefined ? '' : parentTile.PrimaryPIName;
            pObj.Role = 'Primary PI';
            pObj.Id = parentTile.Id+','+'parent';
            pObj.status = parentTile.Status == undefined ? '' : parentTile.Status;
            pObj.TLO = parentTile.TLO==undefined ? '':parentTile.TLO;
            pObj.primaryPiId = parentTile.PrimaryPIId;

            let presentInChilds=false;

            for(let i=0;i<result.length;i++){
                if(result[i].PI__r!=undefined && result[i].PI__r.Id ==pObj.primaryPiId){
                    presentInChilds=true;
                }
            }

            if(!presentInChilds){
                this.RecordsList.push(pObj);
            }

            for(let i=0;i<result.length;i++) {
                let recObj = {};
                recObj.PiLookupName = result[i].PI__r == undefined ? '' : result[i].PI__r.Name;
                recObj.Role = result[i].Role__c == undefined ? '' : result[i].Role__c;
                recObj.Id = result[i].Id+','+'child';
                recObj.status = result[i].Status__c==undefined ? '':result[i].Status__c;
                recObj.TLO = result[i].TLO_Officer_Name__c;

                this.RecordsList.push(recObj);
            }
            this.noOfBips = this.RecordsList.length;

            console.log('results --'+JSON.stringify(this.RecordsList));
        }).catch(error => {
            console.log('error --'+error);
        })
    }

    disconnectedCallback() {
        this.unsubscribeHandler();
    }

    get getHeaderCssClass() {
        return 'slds-grid slds-p-bottom_x-small slds-p-around_small slds-page-header' + (this.getRecordListHasItems ? ' headerCss' : '');
    }

    get getRecordListHasItems() {
        return this.RecordsList.length > 0;
    }

    subscribeHandler() {
        this.messageSubscription = subscribe(this.messageContext, msgService, (message) => {this.handleMessage(message)}, {scope: APPLICATION_SCOPE});
    }

    unsubscribeHandler() {
        unsubscribe(this.messageSubscription);
        this.messageSubscription = null;
    }

    handleMessage(message) {
        if (message.id === this.recordId) {
            this.getData();
        }
    }
}