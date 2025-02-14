import { api, wire } from 'lwc';
import CrdrLevelUtils from "c/crdrLevelUtils";
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { asStringIgnoreCase, determineSortPrimer, formatCurrency, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";

const deductionsColumns = [
    {   label: 'ID', fieldName: 'RECIPIENT_ID__c', type: 'text', initialWidth: 70, sortable: true, hideDefaultActions: true, },
    {   label: 'Description', fieldName: 'RECIPIENT_NAME__c', type: 'text', sortable: true, hideDefaultActions: false, wrapText: true },
    {   label: '% of D', fieldName: 'ROYALTY_PCT__c', 
            type:'percent',   
            typeAttributes: {
                maximumFractionDigits: '6',
            },
            cellAttributes: { alignment: 'left' },
            initialWidth: 95, sortable: true, hideDefaultActions: true,
    },
    {   label: '', fieldName: 'YTD_SHARE_AMOUNT__c', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'YTD_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'EARLY_SHARE_AMOUNT__c', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'EARLY_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'CURRENT_SHARE_AMOUNT__c', type: 'text', initialWidth: 140, sortable: true, hideDefaultActions: true, sortFieldName: 'CURRENT_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'MAX_DISTRIBUTION__c', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'MAX_DISTRIBUTION__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER}
];


export default class CrdrLevelD extends CrdrLevelUtils {
    
    @api recordId;

    error;

    sortDirection = 'asc'
    sortedBy = ''

    earlyShareLvlD = 0;
    currentShareLvlD = 0;
    
    deductionsColumns = deductionsColumns;    
    deductionsLoading = true;
    deductionsData = [];

    dynamicFields = [];
    objColumns = [];
    @wire(getObjectInfo, { objectApiName: 'Forrester_SHIR_CASE_CRDR_SHARE__x' })
    deductionsObjecInfo({ data, error }) {
        if (data) {
            const options = Object.keys(data.fields).map((curField) => {
                const field = data.fields[curField];                
                return 'Forrester_SHIR_CASE_CRDR_SHARE__x.' + field.apiName
            });
            this.dynamicFields = options;      
            
            //set column labels for the fields we want to show from 
            const options2 = Object.keys(data.fields).map((curField) => {
                const field = data.fields[curField];
                
                return {
                    label: field.label,
                    fieldName: field.apiName, 
                };
            });

            this.objColumns = options2;
        }

        if (error) {
            console.error(error);   
        }
    }

    //https://developer.salesforce.com/docs/platform/lwc/guide/reference-wire-adapters-get-related-list-records.html
    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId",
        relatedListId: 'Forrester_SHIR_CASE_CRDR_SHARE__r',
        optionalFields: '$dynamicFields',
        where: '{ SHARE_LEVEL__c: { eq: "D" }}',
        sortBy: ['Forrester_SHIR_CASE_CRDR_SHARE__x.RECIPIENT_NAME__c']
    })
    deductionsInfo({ error, data }) {
        if (data) {
            this.earlyShareLvlD = 0;
            this.currentShareLvlD = 0;

            //match labels from Object Definition to our Columns
            this.deductionsColumns.forEach(x => {
                let fieldData = this.objColumns.filter(obj => {
                    return obj.fieldName === x.fieldName
                });

                if (x.label === '' && fieldData.length >= 1) {
                    x.label = fieldData[0].label;
                }
            } );

            let recordList2 = [];
            data.records.forEach( obj2 => {
                let recordobj2 = {};
                recordobj2.Id = obj2.fields.Id.value;
                recordobj2.SHARE_LEVEL__c = obj2.fields.SHARE_LEVEL__c.value;
                recordobj2.RECIPIENT_ID__c = obj2.fields.RECIPIENT_ID__c.value;
                recordobj2.RECIPIENT_NAME__c = obj2.fields.RECIPIENT_NAME__c.value;
                recordobj2.ROYALTY_PCT__c = obj2.fields.ROYALTY_PCT__c.displayValue ?? obj2.fields.ROYALTY_PCT__c.value;
                recordobj2.YTD_SHARE_AMOUNT__c = obj2.fields.YTD_SHARE_AMOUNT__c.displayValue ?? obj2.fields.YTD_SHARE_AMOUNT__c.value;
                recordobj2.YTD_SHARE_AMOUNT__c_value = obj2.fields.YTD_SHARE_AMOUNT__c.value;
                recordobj2.EARLY_SHARE_AMOUNT__c = obj2.fields.EARLY_SHARE_AMOUNT__c.displayValue ?? obj2.fields.EARLY_SHARE_AMOUNT__c.value;
                recordobj2.EARLY_SHARE_AMOUNT__c_value = obj2.fields.EARLY_SHARE_AMOUNT__c.value;
                recordobj2.CURRENT_SHARE_AMOUNT__c = obj2.fields.CURRENT_SHARE_AMOUNT__c.displayValue ?? obj2.fields.CURRENT_SHARE_AMOUNT__c.value;
                recordobj2.CURRENT_SHARE_AMOUNT__c_value = obj2.fields.CURRENT_SHARE_AMOUNT__c.value;
                recordobj2.MAX_DISTRIBUTION__c = obj2.fields.MAX_DISTRIBUTION__c.displayValue ?? obj2.fields.MAX_DISTRIBUTION__c.value;
                recordobj2.MAX_DISTRIBUTION__c_value = obj2.fields.MAX_DISTRIBUTION__c.value;

                recordList2.push( recordobj2 );
            } );

            this.earlyShareLvlD = data.records.reduce((sum, item) => sum + item.fields.EARLY_SHARE_AMOUNT__c.value, 0);
            this.currentShareLvlD = data.records.reduce((sum, item) => sum + item.fields.CURRENT_SHARE_AMOUNT__c.value, 0);

            this.deductionsData = recordList2;
            this.error = undefined;

            this.deductionsLoading = false;
        } else if (error) {
            this.error = error;
            this.deductionsData = undefined;
        }
    }

    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.deductionsData];
        const sortFieldType = this.deductionsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.deductionsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.deductionsData = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }

    get levelLoading() {
        return this.deductionsLoading;
    }

    get hasDecuctionsData() {
        return (this.deductionsData.length > 0);
    }

    get deductionsHeaderTitle() {
        return 'Deductions (' + this.deductionsData.length + ')' ;
    }

    get formattedEarlyShareLvlD(){
        return formatCurrency(this.earlyShareLvlD, true);
    }

    get formattedCurrentShareLvlD(){
        return formatCurrency(this.currentShareLvlD, true);
    }
}