import { api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { LightningElement } from 'lwc';
import { determineSortPrimer, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";
import getFiscalYears from '@salesforce/apex/ExternalObjectRepository.getFiscalYears'

const incomeColumns = [
    {
        label: 'Case',
        fieldName: 'caseLink',
        type: 'url',
        typeAttributes: {                
            label: {
                fieldName: 'CONTRACT_CASE_NUM__c'
            },
        },
        sortable: true, hideDefaultActions: false, wrapText: true
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
        label: 'FY', fieldName: 'YTD_CASE_AGREEMENT_INCOME__c', hideDefaultActions: true, 
        sortable: true, sortFieldName: 'YTD_CASE_AGREEMENT_INCOME__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
];

const incomeBreakColumns = [
    {
        label: 'Case',
        fieldName: 'caseLink',
        type: 'url',
        typeAttributes: {                
            label: {
                fieldName: 'CONTRACT_CASE_NUM__c'
            },
        },
        sortable: true, hideDefaultActions: false, wrapText: true
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
        label: 'Income', fieldName: 'COLLECTED_AMT__c', hideDefaultActions: true, 
        sortable: true, sortFieldName: 'COLLECTED_AMT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
];

export default class AgreementRoyaltyIncome extends LightningElement {
    @api recordId;      

    selectedFy;
    selectedCase = 'all';
    whereCondition; // = '{ FY__c: { eq: "2023" }}';

    fyOptionsLoading = true;
    fyOptions = [];
    caseOptions = [];

    activeSections = ['totals'];
    sortDirection = 'asc'
    sortedBy = ''

    incomeColumns = incomeColumns;
    incomeError;
    incomeRecordsMain = [];
    incomeRecords = [];
    incomeLoading = true;

    incomeBreakColumns = incomeBreakColumns;
    incomeBreakError;
    sectionsDataMain = [];
    sectionsData = [];   

    @wire(getFiscalYears, { })
    async handleGetFiscalYears({data, error}) {
        if (data) {
            let recordList = [];
            data.forEach(obj => recordList.push( { label: obj.FY__c.toString(), value: obj.FY__c.toString()}));

            this.selectedFy = recordList[0].value;
            this.fyOptions = recordList.sort((a, b) => a.value - b.value);

            this.whereCondition = '{ FY__c: { eq: "' + this.selectedFy + '" }}';

            this.fyOptionsLoading = false;
        }

        if (error) {
            console.error(error);
        }
    }

     //https://developer.salesforce.com/docs/platform/lwc/guide/reference-wire-adapters-get-related-list-records.html
     @wire(getRelatedListRecords, {
        parentRecordId: "$recordId",
        relatedListId: 'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOWN__r',
        optionalFields: [ 
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.Id', 
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.CASE_RECID__c',
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.CONTRACT_CASE_NUM__c',

                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.CASE_RECID__r.CONTRACT_CASE_NUM__c',
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.CASE_RECID__r.Id',


                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.INVOICE_TYPE_ORIGINAL__c',
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.INVOICE_TYPE_ORIGINAL_DESC__c',                        

                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.AGREEMENT_CASE_PCT__c',
                        'Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.COLLECTED_AMT__c'],
        pageSize: 500,
        where: '$whereCondition',
        sortBy: ['Forrester_SHIR_AGR_CASE_CRDR_REV_BDOW__x.CASE_RECID__c']
    })
    breakDowns({ error, data }) {
        if (data) {
             // Grouping the array by INVOICE_TYPE_ORIGINAL_DESC__c attribute
            const groupedData = data.records.reduce((acc, obj) => {

                let desc = obj.fields.INVOICE_TYPE_ORIGINAL_DESC__c.value;                
                const key = obj.fields.INVOICE_TYPE_ORIGINAL__c.value + '|' + desc ;
                if (!acc[key]) {
                    acc[key] = [];
                }
                acc[key].push(obj);
                return acc;
            }, {});

            const tempAgain = Object.entries(groupedData).map(([key, value]) => {
                let recordobj = {}; 

                const myArray = key.split("|");
                recordobj.id = myArray[0];
                recordobj.name = myArray[1];   
                this.activeSections.push(myArray[1]);
                recordobj.data = [];

                value.forEach( obj => {
                    let dataRedordObj = {}; 
                    dataRedordObj.Id = obj.fields.Id.value;

                    dataRedordObj.AGREEMENT_CASE_PCT__c = obj.fields.AGREEMENT_CASE_PCT__c.value;

                    dataRedordObj.INVOICE_TYPE_ORIGINAL__c = obj.fields.INVOICE_TYPE_ORIGINAL__c.value; 
                    dataRedordObj.INVOICE_TYPE_ORIGINAL_DESC__c = obj.fields.INVOICE_TYPE_ORIGINAL_DESC__c.value;

                    dataRedordObj.COLLECTED_AMT__c = obj.fields.COLLECTED_AMT__c.displayValue;
                    dataRedordObj.COLLECTED_AMT__c_value = obj.fields.COLLECTED_AMT__c.value;
                
                    dataRedordObj.CONTRACT_CASE_NUM__c = obj.fields.CASE_RECID__r.value.fields.CONTRACT_CASE_NUM__c.value;
                    dataRedordObj.CASE_RECID__c = obj.fields.CASE_RECID__c.value;
                    dataRedordObj.caseLink =  `/lightning/r/${obj.fields.CASE_RECID__r.value.fields.Id.value }/view`;
                    
                    recordobj.data.push( dataRedordObj );                    
                })

                recordobj.hasData = (recordobj.data.length > 0);
                recordobj.headerTitle = `${myArray[1]} (${recordobj.data.length})` ;
                
                return recordobj
            });

            this.sectionsData = tempAgain;
            this.sectionsDataMain = tempAgain;
           
            let originalResult = data.records.reduce((acc, obj) => {
                acc[obj.fields.CASE_RECID__c.value] = { label: obj.fields.CONTRACT_CASE_NUM__c.value, value: obj.fields.CASE_RECID__c.value};
                return acc;
            }, {});
            
            // Convert the original result into an array of objects with label and value attributes            
            this.caseOptions = Object.entries(originalResult).map(([key, value]) => ({ label: value.label, value: value.value }));
            this.caseOptions.unshift({ label: 'All', value: 'all' });
            
            this.incomeBreakError = undefined;
            this.incomeBreakLoading = false;
        } else if (error) {
            this.incomeBreakError = error;
            this.sectionsData = undefined;
        }
    }

    //https://developer.salesforce.com/docs/platform/lwc/guide/reference-wire-adapters-get-related-list-records.html
    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId", 
        relatedListId: 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__r',
        fields: ['Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.Id', 
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.AGREEMENT_RECID__c', 
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CASE_CRDR_RECID__c', 
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.AGREEMENT_CASE_PCT__c', 
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.YTD_AGREEMENT_INCOME__c',
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.YTD_CASE_AGREEMENT_INCOME__c',
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.AGREEMENT_RECID__r.COMPANY_NAME__c',
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.AGREEMENT_RECID__r.Id',

                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CASE_RECID__c',
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CONTRACT_CASE_NUM__c',

                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CASE_RECID__r.CONTRACT_CASE_NUM__c',
                 'Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CASE_RECID__r.Id',
                ],
        pageSize: 500,
        where: '$whereCondition',
        sortBy: ['Forrester_SHIR_AGR_CASE_CRDR_REVENUE__x.CASE_RECID__c']
    })
    incomeData({ error, data }) {
        if (data) {
            let recordList = [];
            data.records.forEach( obj => {
                let recordobj = {};
        
                recordobj.Id = obj.fields.Id.value;

                recordobj.AGREEMENT_CASE_PCT__c = obj.fields.AGREEMENT_CASE_PCT__c.value;

                recordobj.YTD_CASE_AGREEMENT_INCOME__c = obj.fields.YTD_CASE_AGREEMENT_INCOME__c.displayValue;
                recordobj.YTD_CASE_AGREEMENT_INCOME__c_value = obj.fields.YTD_CASE_AGREEMENT_INCOME__c.value;
             
                recordobj.CONTRACT_CASE_NUM__c = obj.fields.CASE_RECID__r.value.fields.CONTRACT_CASE_NUM__c.value
                recordobj.CASE_RECID__c = obj.fields.CASE_RECID__c.value;
                recordobj.caseLink =  `/lightning/r/${obj.fields.CASE_RECID__r.value.fields.Id.value }/view`;
                
                recordList.push( recordobj );

            } );
            
            this.incomeRecords = recordList;
            this.incomeRecordsMain = recordList;
            
            this.incomeError = undefined;
            this.incomeLoading = false;
        } else if (error) {
            this.incomeError = error;
            this.incomeRecords = undefined;
        }
    }
    

    get hasSectionsData() {
        return (this.sectionsData.length > 0);
    }

    get hasTotalsData() {
        return (this.incomeRecords.length > 0);
    }

    get totalsHeaderTitle() {
        return `Total (${this.incomeRecords.length})`;
    }

    
    handleChangeFY(event) {
        this.incomeLoading = true;
        this.selectedFy = event.detail.value;
        this.selectedCase = 'all';

        this.whereCondition = '{ FY__c: { eq: "' + this.selectedFy + '" }}';
        this.caseOptions = ['all'];
        this.activeSections = ['totals'];
    }

    handleChangeCase(event) {
        this.selectedCase = event.detail.value;

        const sectionsDataMainCopy = JSON.parse(JSON.stringify(this.sectionsDataMain));
        sectionsDataMainCopy.forEach( obj => {
            if (this.selectedCase !== 'all') {
                const filteredArray = obj.data.filter(object => object.CASE_RECID__c === this.selectedCase);
                obj.data = filteredArray;
                obj.hasData = (obj.data.length > 0);
                obj.headerTitle = obj.name + ' (' + obj.data.length + ')' ;
            }            
        });
        this.sectionsData = sectionsDataMainCopy;


        const incomeRecordsMainCopy = JSON.parse(JSON.stringify(this.incomeRecordsMain));        
        if (this.selectedCase !== 'all') {
            const filteredArray = incomeRecordsMainCopy.filter(object => object.CASE_RECID__c === this.selectedCase);
            this.incomeRecords = filteredArray;
        } else {
            this.incomeRecords = incomeRecordsMainCopy;    
        }                 
    }

    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.incomeRecords];
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
}