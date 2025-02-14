import { LightningElement, api, track } from "lwc";
import getBipInfo from "@salesforce/apex/GetBipWithCases.getBipInfo";

export default class ChildDetail extends LightningElement {

    @api recdata;
    @track rows = [];

    receivedData;
    status = "";
    owner = "";
    feedbackRequested = "";
    comments = "";
    role = "";
    pifeedback = "";
    PiName = "";

    // Close the modal
    connectedCallback() {
        console.log("recData--", JSON.stringify(this.recdata));
        let recoId;

        let  data= this.recdata.split(',');

         recoId = data[0];
        console.log("recoId", recoId);
        if (recoId) {
            getBipInfo({ recordIds: [recoId] ,reqFrom: data[1]}).then(result => {
                if (result) {
                    console.log(result);
                    this.receivedData = result[0];
                    console.log("this.receivedData--modal ", this.receivedData);
                     this.status=this.receivedData.Status__c ==undefined?'':this.receivedData.Status__c;
                   
                    if(data[1]=='parent'){
                            this.owner= this.receivedData.Owner.Name==undefined?'':this.receivedData.Owner.Name;
                            this.PiName = this.receivedData.Primary_PI_Lookup__r.Name == undefined ? "" : this.receivedData.Primary_PI_Lookup__r.Name;
                           this.comments = this.receivedData.Comments__c == undefined ? "" : this.receivedData.Comments__c;
                    }
                     else{
                        this.owner= this.receivedData.CreatedBy.Name==undefined?'':this.receivedData.CreatedBy.Name;
                        this.PiName = this.receivedData.PI__r.Name==undefined?'':this.receivedData.PI__r.Name;
                        this.role = this.receivedData.Role__c == undefined ? "" : this.receivedData.Role__c;
                        this.feedbackRequested = this.receivedData.Requested_Action__c === undefined ? "" : this.receivedData.Requested_Action__c;
                        this.comments = this.receivedData.Comment__c === undefined ? "" : this.receivedData.Comment__c;
                     }

                    this.rows = this.receivedData.BIP_Case_Junctions__r?.map((bipCaseJunction) => bipCaseJunction.Case__r) ?? [];
                    this.numOfCases = this.rows.length;

                    for (let i = 0; i < this.numOfCases; i++) {
                        this.rows[i].ind = i + 1;
                    }
                    console.log("Rows---", JSON.parse(JSON.stringify(this.rows)));
                }

            }).catch(error => {
                console.log(error);
            });
        }
    }

    handleTLOIconClick() {
        this.template.querySelector(".TLO").disabled = false;
        console.log("clicked");
    }

    handlePIFeedbackIconClick() {
        this.template.querySelector(".PIFeedback").disabled = false;
        console.log("clicked");
    }

    handleCommentIconClick() {
        this.template.querySelector(".Comment").disabled = false;
    }

    handleStatusChange(event) {

        this.status = event.target.value;
    }

    handleRoleChange(event) {
        this.role = event.target.value;
    }

    handleOwnerChange(event) {
        this.owner = event.target.value;
    }

    handleFeedbackChange(event) {
        this.feedbackRequested = event.target.value;
    }

    handleCommentsChange(event) {
        this.comments = event.target.value;
    }

    handlePifeedbackChange(event) {
        this.pifeedback = event.target.value;
    }
    
    handleClose() {
        const closeEvent = new CustomEvent("closemodal");
        this.dispatchEvent(closeEvent);
    }

    // Handle confirmation button click (you can implement further logic here)
}