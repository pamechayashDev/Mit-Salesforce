import { NavigationMixin } from "lightning/navigation";
import { LightningElement, api, wire, track } from 'lwc';
import getCasesRelated from '@salesforce/apex/ComplianceUtilizationReportController.getCasesRelatedToUtilizationReport';
import TIME_ZONE from "@salesforce/i18n/timeZone";

export default class UtilizationReportForresterCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @track forresterCases = [];
    @track error;
    isLoading = true;
    timeZone= TIME_ZONE;

    // Wire method to fetch related forresterCases
    @wire(getCasesRelated, { utilizationReportId: '$recordId' })
    wiredcases({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.forresterCases = data.map(singleCase => ({
                ...singleCase,
                caseUrl: '/' + singleCase.Id
            }));
            this.isLoading = false;
            this.error = undefined;
        } else if (error) {
            console.error('Error fetching forresterCases:', error);
            this.error = error.body.message;
            this.forresterCases = [];
        }
        this.isLoading = false;
    }

    // Getter to check if forresterCases exist
    get hasForresterCases() {
        return this.forresterCases && this.forresterCases.length > 0;
    }

    // Getter for total records count
    get totalRecords() {
        return this.forresterCases ? this.forresterCases.length : 0;
    }

    // Getter for the account title
    get getRecordTitle() {
        return `Case Details`;
    }

    get caseId() {
        return this.forresterCases ? this.forresterCases[0].Id : null;        
    }

    navToCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                objectApiName: 'Forrester_Case__x',
                actionName: 'view'
            },
        });
    }

}