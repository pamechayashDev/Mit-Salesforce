import { LightningElement, wire, track } from 'lwc';
import executeUtilizationReportBatch from '@salesforce/apex/ComplianceUtilizationReportController.executeUtilizationReportBatch';
import getTotalCasesForUtilizationReports from '@salesforce/apex/ComplianceUtilizationReportController.getTotalCasesForUtilizationReports';
import { FlowNavigationFinishEvent } from "lightning/flowSupport";



export default class SubmitForUtilization extends LightningElement {
 
    @track showLoading = false;
    @track totalCases = 0;

    @track type='success';
    @track message;
    @track showToastBar = false;
    autoCloseTime = 3000;
    variant;
    disableButton = false;


    // Call Apex method to fetch case count
    @wire(getTotalCasesForUtilizationReports)
    wiredCaseCount({ error, data }) {
        this.showLoading = false;
        if (data) {
            this.totalCases = data; // Set total case count
        } else if (error) {
            console.error('Error fetching case count:', error);
            this.totalCases = 0; // Default to 0 on error
        }
    }

    // Make this function async for using `await`
    async handleContinueClick() {
        this.showLoading = true; // Show the spinner
        this.disableButton = true;
        try {
            const result = await executeUtilizationReportBatch();
            if (result === 'Success') {
                this.showLoading = false;
                this.variant = "success";
                this.showToast('success', 'Report(s) Submitted for Utilization.', 3000);
            } else {
                this.showLoading = false;
                this.variant = "error";
                this.showToast('error', 'Cases failed to be submitted for utilization.', 3000);
                console.error('Error submitting for utilization:', JSON.stringify(result));
            }
        } catch (error) {
            // Handle errors from Apex
            this.showLoading = false;
            this.variant = "error";
            this.showToast('error', error.body.message || 'An unexpected error occurred.', 3000);
            console.error('Error:', error);
        }
    }

    handleCloseClick(){
        this.closeModal();
    }

    closeModal() {
      this.dispatchEvent(new FlowNavigationFinishEvent());
      this.disableButton = false;
    }

    showToast(type, message,time) {
        this.type = type;
        this.message = message;
        this.autoCloseTime=time;
        this.showToastBar = true;
        if(type === 'success'){
            setTimeout(() => {
                this.closeModal();
            }, this.autoCloseTime);
        }else{
            setTimeout(() => {
            }, this.autoCloseTime);
        }

    }

    get isContinueButtonDisabled() {
        return this.totalCases === 0 || this.totalCases === null || this.totalCases === undefined || this.disableButton;
    }

    get getIconName() {
  
        return this.variant === "success" ? "utility:success" : "utility:error";
      }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-m-right_small slds-no-flex slds-align-top';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}