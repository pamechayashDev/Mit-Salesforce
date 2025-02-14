/**
 * Created by Andreas du Preez on 2025/02/05.
 */

import { api, LightningElement, wire } from "lwc";
import getBipPisForTLOAssignmentDS from "@salesforce/apex/BIPController.getBipPisForTLOAssignment";
import updateBipPiTLOAssignmentDS from "@salesforce/apex/BIPController.updateBipPiTLOAssignment";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import modalStyles from "@salesforce/resourceUrl/quickActionLWCStyles";
import { loadStyle } from "lightning/platformResourceLoader";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import msgService from "@salesforce/messageChannel/bipRequestStatusChange__c";
import { MessageContext, publish } from "lightning/messageService";


export default class bipAssignToTLOModal extends LightningElement {

    _recordId;
    bipPis = [];
    currentBipPiIndex = 0;
    isLoading = true;

    @api set recordId(value) {
        if (value) {
            this._recordId = value;
            this.getBipPIsForTLOAssignment();
        }
    }
    get recordId() {
        return this._recordId;
    }

    renderedCallback() {
        loadStyle(this, modalStyles);
    }

    @wire(MessageContext)
    messageContext;

    // Getters
    get getModalHeaderLabel() {
        return this.isLoading ? "Assign TLO" : this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Additional PI" ? "Assign TLO for Notifications" : "Assign Primary TLO";
    }

    get getBodySubHeaderRoleType() {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Additional PI" ? "Additional" : "Primary";
    }

    get isPrimaryPiNoCases() {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Primary PI" && (this.bipPis[this.currentBipPiIndex]?.bipPi?.BIP_Case_Junctions__r?.length ?? 0) === 0;
    }

    get isAdditionalPi() {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Additional PI";
    }

    get getTLOSelectionLabel() {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Additional PI" ? "TLO" : "Primary TLO";
    }

    get selectedTLOValue() {
        if (this.bipPis[this.currentBipPiIndex]?.bipPi?.TLO_Officer_MIT_ID__c === undefined && this.bipPis[this.currentBipPiIndex]?.recommendedTloOfficer) {
            this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_Email__c = this.bipPis[this.currentBipPiIndex]?.recommendedTloOfficer?.email;
            this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_MIT_ID__c = this.bipPis[this.currentBipPiIndex]?.recommendedTloOfficer?.mitId;
            this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_Name__c = this.bipPis[this.currentBipPiIndex]?.recommendedTloOfficer?.name;
        }

        return this.bipPis[this.currentBipPiIndex]?.bipPi?.TLO_Officer_MIT_ID__c;
    }

    get getTLOSelectionOptions() {
        // If there are no cases for the Primary PI, then we need to show all TLOs for all PIs
        if (this.isPrimaryPiNoCases) {
            return this.bipPis.flatMap((bipPi) => {return bipPi?.availableTloOfficers}).map(tlo => {
                return {
                    label: tlo.name,
                    value: tlo.mitId,
                    email: tlo.email
                };
            });
        }

        return this.bipPis[this.currentBipPiIndex]?.availableTloOfficers?.map(tlo => {
            return {
                label: tlo.name,
                value: tlo.mitId,
                email: tlo.email
            };
        });
    }

    get tloSelectionValidity () {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.TLO_Officer_MIT_ID__c !== undefined;
    }

    get getNextSubmitButtonLabel() {
        return this.currentBipPiIndex === this.bipPis.length - 1 ? "Submit" : "Next";
    }

    get getCasesTableData() {
        // If there are no cases for the Primary PI, then we need to show all cases for all PIs
        if (this.isPrimaryPiNoCases) {
            return this.bipPis.flatMap(bipPi => bipPi?.bipPi?.BIP_Case_Junctions__r ?? [])?.map(value => value?.Case__r);
        }

        return this.bipPis[this.currentBipPiIndex]?.bipPi?.BIP_Case_Junctions__r?.map((bipCaseJunction) => bipCaseJunction.Case__r) ?? [];
    }

    get getCasesTableHeaderLabel() {
        return this.bipPis[this.currentBipPiIndex]?.bipPi?.Role__c === "Additional PI" ? `Additional PI : ${this.bipPis[this.currentBipPiIndex]?.bipPi?.PI__r?.Name ?? ""}` : `Primary PI : ${this.bipPis[this.currentBipPiIndex]?.bipPi?.PI__r?.Name ?? ""}`;
    }

    get showBackButton() {
        return this.currentBipPiIndex > 0;
    }

    get getProgressBarValue() {
        return this.currentBipPiIndex + 1;
    }

    get getProgressBarSteps() {
        let stepCounter = 1;
        return this.bipPis.map((item) => {
            return { id: item.bipPi.Id, label: item.bipPi.PI__r.Name, value: stepCounter++ };
        });
    }

    // Apex Callbacks
    getBipPIsForTLOAssignment() {
        console.log("Getting BIP PIs with Record ID: ", this.recordId);
        getBipPisForTLOAssignmentDS({ bipRequestRecordId: this.recordId }).then(result => {
            if (result) {
                this.bipPis = result;
                this.isLoading = false;
                console.log("this.bipPis", JSON.parse(JSON.stringify(this.bipPis)));
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error?.body?.message,
                    variant: "error"
                })
            );
        });
    }


    // Event handlers
    handleTLOSelectionChange(event) {
        let selectedTLO = this.getTLOSelectionOptions.find(tlo => tlo.value === event.detail.value);

        this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_Email__c = selectedTLO.email;
        this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_MIT_ID__c = selectedTLO.value
        this.bipPis[this.currentBipPiIndex].bipPi.TLO_Officer_Name__c = selectedTLO.label;
    }

    handleCancelButton() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleNextSubmitButton() {
        if (!this.isTloSelectionValid()) {
            return;
        }

        if (this.currentBipPiIndex === this.bipPis.length - 1) {
            this.isLoading = true;

            let tloAssignmentData = this.bipPis.map((bipPi) => {return bipPi.bipPi;})

            updateBipPiTLOAssignmentDS({ bipPis: tloAssignmentData }).then(result => {
                if (result) {
                    notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                    this.publishStatusChangeMessage();
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "TLO Assignment successful",
                            variant: "success"
                        })
                    );
                }
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error?.body?.message,
                        variant: "error"
                    })
                );
            });
        } else {
            this.currentBipPiIndex++;
        }
    }

    handleBackButton() {
        this.currentBipPiIndex--;
    }

    // Helper functions
    isTloSelectionValid() {
        const formDescriptionField = this.template.querySelector("lightning-combobox[data-id=\"tloSelection\"]");
        if (this.bipPis[this.currentBipPiIndex]?.bipPi?.TLO_Officer_MIT_ID__c === undefined) {
            formDescriptionField.reportValidity();
            return false;
        }

        formDescriptionField.reportValidity();
        return true;
    }

    publishStatusChangeMessage() {
        publish(this.messageContext, msgService, {
            id: this.recordId
        });
    }
}