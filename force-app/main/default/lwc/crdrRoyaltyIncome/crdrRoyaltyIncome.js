import { api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import CrdrIncomeBreakdownModal from "c/crdrIncomeBreakdownModal";
import CrdrLevelUtils from "c/crdrLevelUtils";
import { sortBy, determineSortPrimer, SORT_BY_TYPE_ENUMS } from "c/utils";
import { NavigationMixin } from "lightning/navigation";

const actions = [{ label: 'View', name: 'view' }]
const incomeColumns = [
    {
        label: 'Licensee',
        fieldName: 'COMPANY_NAME__c',
        initialWidth: 450, 
        sortable: true, hideDefaultActions: false, wrapText: true
    },
    {
        label: 'Income ID',
        type: 'button',
        fieldName: 'AGREEMENT_RECID__c',
        typeAttributes: {
            label: { fieldName: 'incomeId' },
            name: { fieldName: 'incomeId' },
            alternativeText: { fieldName: 'incomeId' },
            disabled: false,
            variant: 'base',
            action: actions
        },
        cellAttributes: {
            class: 'custom-button',
            alignment: 'left'
        },
        initialWidth: 150,
        sortable: true, hideDefaultActions: true,
    },
    {
        label: 'Agreement',
        fieldName: 'agreementLink',
        type: 'url',
        typeAttributes: {                
            label: {
                fieldName: 'AGREEMENT_RECID__c'
            },
        },
        initialWidth: 115,
        sortable: true, sortFieldName: 'AGREEMENT_RECID__c', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: false, wrapText: true
    },
    {   label: 'Case %', fieldName: 'AGREEMENT_CASE_PCT__c', 
            type:'percent',   
            typeAttributes: {
                maximumFractionDigits: '6',
            },
            cellAttributes: { alignment: 'left' },
            sortable: true, hideDefaultActions: true,
    },
    {   
        label: 'FY Agreement Income', fieldName: 'YTD_AGREEMENT_INCOME__c', hideDefaultActions: true,
            sortable: true, sortFieldName: 'YTD_AGREEMENT_INCOME__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER, initialWidth: 170
    },
    {   
        label: 'FY Case Agreement Income', fieldName: 'YTD_CASE_AGREEMENT_INCOME__c', hideDefaultActions: true,
        sortable: true, sortFieldName: 'YTD_CASE_AGREEMENT_INCOME__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER, initialWidth: 200
    },
];

export default class CrdrRoyaltyIncome extends NavigationMixin(CrdrLevelUtils) {
    @api recordId;   
    
    sortDirection = 'asc'
    sortedBy = ''
    
    incomeColumns = incomeColumns;
    incomeError;
    incomeRecords = [];
    incomeLoading = true;

    //https://developer.salesforce.com/docs/platform/lwc/guide/reference-wire-adapters-get-related-list-records.html
    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId", 
        relatedListId: 'Forrester_Case_CRDR_Revenues__r',
        fields: ['Forrester_Case_CRDR_Revenue__x.Id', 
                 'Forrester_Case_CRDR_Revenue__x.AGREEMENT_RECID__c', 
                 'Forrester_Case_CRDR_Revenue__x.CASE_CRDR_RECID__c', 
                 'Forrester_Case_CRDR_Revenue__x.AGREEMENT_CASE_PCT__c', 
                 'Forrester_Case_CRDR_Revenue__x.YTD_AGREEMENT_INCOME__c',
                 'Forrester_Case_CRDR_Revenue__x.YTD_CASE_AGREEMENT_INCOME__c',
                 'Forrester_Case_CRDR_Revenue__x.AGREEMENT_RECID__r.COMPANY_NAME__c',
                 'Forrester_Case_CRDR_Revenue__x.AGREEMENT_RECID__r.Id',
                ],
        pageSize: 500
        //where: '{ Name: { like: "Bob%" }}',
        //sortBy: [ 'Forrester_Case_CRDR_Revenue__x.AGREEMENT_RECID__c']
    })
    incomeData({ error, data }) {
        if (data) {
            let recordList = [];
            data.records.forEach( obj => {
                let recordobj = {};
        
                recordobj.Id = obj.fields.Id.value;
                recordobj.incomeId = obj.fields.AGREEMENT_RECID__c.value + '-' + obj.fields.CASE_CRDR_RECID__c.value;
                recordobj.AGREEMENT_RECID__c = obj.fields.AGREEMENT_RECID__c.value;
                recordobj.AGREEMENT_CASE_PCT__c = obj.fields.AGREEMENT_CASE_PCT__c.value;
                recordobj.YTD_CASE_AGREEMENT_INCOME__c = obj.fields.YTD_CASE_AGREEMENT_INCOME__c.displayValue;
                recordobj.YTD_CASE_AGREEMENT_INCOME__c_value = obj.fields.YTD_CASE_AGREEMENT_INCOME__c.value;
                recordobj.YTD_AGREEMENT_INCOME__c = obj.fields.YTD_AGREEMENT_INCOME__c.displayValue;
                recordobj.YTD_AGREEMENT_INCOME__c_value = obj.fields.YTD_AGREEMENT_INCOME__c.value;
                recordobj.COMPANY_NAME__c = obj.fields.AGREEMENT_RECID__r.value.fields.COMPANY_NAME__c.value;

                recordobj.agreementLink =  '/lightning/r/' + obj.fields.AGREEMENT_RECID__r.value.fields.Id.value + '/view';
                
                recordList.push( recordobj );

            } );
            
            this.incomeRecords = recordList;
            
            this.incomeError = undefined;
            this.incomeLoading = false;
        } else if (error) {
            this.incomeError = error;
            this.incomeRecords = undefined;
        }
    }

    async handleRowAction(event) {
        const row = event.detail.row;

        const result = await CrdrIncomeBreakdownModal.open({
            label: 'Breakdown',
            size: 'large',
            crdrRecordId: this.recordId + '',
            agreementRecIdStr: row.AGREEMENT_RECID__c, 
            agrName: row.COMPANY_NAME__c,
            caseAgrIncome: row.YTD_CASE_AGREEMENT_INCOME__c,            
            agrCasePct: row.AGREEMENT_CASE_PCT__c
        });

        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log('result ==> ', result);
        console.log('crdr:', JSON.parse(JSON.stringify(this._crdr)));

        if (result === 'navigateToTab') {
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'CRDR_Royalty_Income_Breakdown_Tab',
                    recordId: this.generateRandomId() // Random ID to force LWC to always open a new tab, although the id never gets used
                },
                state: {
                    c__crdrRecordId: this.recordId + '',
                    c__crdrLabel: this._crdr.fields.DISCLOSURE_TITLE__c?.value ?? '',
                    c__agreementRecIdStr: row.AGREEMENT_RECID__c,
                    c__agrName: row.COMPANY_NAME__c,
                    c__caseAgrIncome: row.YTD_CASE_AGREEMENT_INCOME__c,
                    c__agrCasePct: row.AGREEMENT_CASE_PCT__c
                }
            });
        }
    }

    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.incomeRecords]
        const sortFieldType = this.incomeColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.incomeColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.incomeRecords = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }

    get hasData() {
        return this.incomeRecords.length > 0;
    }

    get incomeLabel() {
        return 'Income (' + this.incomeRecords.length + ')' ;
    }

    generateRandomId() {
        const validChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let randomId = '001'; // Prefix for Account object

        while(randomId.length < 15) {
            const idx = Math.floor(Math.random() * validChars.length);
            randomId += validChars.charAt(idx);
        }

        return randomId;
    }
}