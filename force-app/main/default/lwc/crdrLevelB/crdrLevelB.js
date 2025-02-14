import { wire, api } from 'lwc';
import CrdrLevelUtils from "c/crdrLevelUtils";
import { getFieldDisplayValue, getFieldValue } from "lightning/uiRecordApi";
import { determineSortPrimer, formatCurrency, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import CrdrLevelBPatentBreakdownModal from "c/crdrLevelBPatentBreakdownModal";
import { NavigationMixin } from "lightning/navigation";

const deductionsColumns = [
    {   label: 'ID', fieldName: 'RECIPIENT_ID__c', type: 'text', sortable: true, hideDefaultActions: true, },
    {   label: 'Description', fieldName: 'RECIPIENT_NAME__c', type: 'text', sortable: true, hideDefaultActions: false, wrapText: true },
    {   label: '% of B', fieldName: 'ROYALTY_PCT__c',
        type:'percent',
        typeAttributes: {
            maximumFractionDigits: '6',
        },
        cellAttributes: { alignment: 'left' },
        initialWidth: 95, sortable: true, hideDefaultActions: true,
    },
    {   label: '', fieldName: 'YTD_SHARE_AMOUNT__c', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'YTD_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'EARLY_SHARE_AMOUNT__c', type: 'text', initialWidth: 100 , sortable: true, hideDefaultActions: true, sortFieldName: 'EARLY_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'CURRENT_SHARE_AMOUNT__c', type: 'text', initialWidth: 140, sortable: true, hideDefaultActions: true, sortFieldName: 'CURRENT_SHARE_AMOUNT__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: '', fieldName: 'MAX_DISTRIBUTION__c', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'MAX_DISTRIBUTION__c_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER}
];

const patentCostsColumns = [
    {
        label: 'Description',
        type: 'button',
        fieldName: 'description',
        typeAttributes: {
            label: { fieldName: 'description' },
            name: { fieldName: 'description' },
            alternativeText: { fieldName: 'description' },
            disabled: false,
            variant: 'base',
            action: [{ label: 'View', name: 'view' }]
        },
        cellAttributes: {
            class: 'custom-button',
            alignment: 'left'
        },
        initialWidth: 305,
        sortable: true, hideDefaultActions: true,
    },
    {   label: 'Deduction', fieldName: 'deductionPct', 
            type:'percent',   
            typeAttributes: {
                maximumFractionDigits: '6',
            },
            cellAttributes: { alignment: 'left' },
            sortable: true, hideDefaultActions: true,
    },
    {   label: 'FY', fieldName: 'fy', type: 'text', initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'fy_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Costs', fieldName: 'withholdingCosts', type: 'text',  initialWidth: 100, sortable: true, hideDefaultActions: true, sortFieldName: 'withholdingCosts_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Reimbursed', fieldName: 'withholdingReimb', type: 'text', initialWidth: 140, sortable: true, hideDefaultActions: true, sortFieldName: 'withholdingReimb_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Unreimbursed', fieldName: 'withholdingUnreimb', type: 'text',  initialWidth: 160, sortable: true, hideDefaultActions: true, sortFieldName: 'withholdingUnreimb_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Prior Deduction', fieldName: 'withholdingPrior', type: 'text',  initialWidth: 160, sortable: true, hideDefaultActions: true, sortFieldName: 'withholdingPrior_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
];

const withheldColumns = [
    {   label: 'Description', fieldName: 'description', type: 'text', sortable: false, hideDefaultActions: false,  wrapText: true},
    {   label: 'Intended Reserve', fieldName: 'intentedReserve', type: 'text',  initialWidth: 130, sortable: false, hideDefaultActions: true},
    {   label: 'FY', fieldName: 'fy',  initialWidth: 100, sortable: false, hideDefaultActions: true},
    {   label: 'Total Prior Withholding', fieldName: 'totalWithHoldingPrior',  initialWidth: 200, sortable: false, hideDefaultActions: true}
];

const outsideMattersColumns = [
    {
        label: 'ID',
        fieldName: 'outsideMatterLink',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'id'
            },
        },
        initialWidth: 60, sortable: true, sortFieldName: 'id', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: true, wrapText: true
    },
    {   label: 'Description', fieldName: 'description', type: 'text', 
        sortable: true, 
        hideDefaultActions: false,  wrapText: true, initialWidth: 350,  },
    {   label: 'Deduction', fieldName: 'deductionPct',
        type:'percent',
        typeAttributes: {
            maximumFractionDigits: '6',
        },
        cellAttributes: { alignment: 'left' },
        initialWidth: 105, sortable: true, 
        hideDefaultActions: true,
    },
    {   label: 'FY', fieldName: 'fy', type: 'text', initialWidth: 100, 
        sortable: true, 
        hideDefaultActions: true, sortFieldName: 'fy_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Costs', fieldName: 'withholdingCosts', type: 'text',  initialWidth: 100, 
        sortable: true, 
        hideDefaultActions: true, sortFieldName: 'withholdingCosts_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Reimbursed', fieldName: 'withholdingReimb', type: 'text', initialWidth: 140, 
        sortable: true, 
        hideDefaultActions: true, sortFieldName: 'withholdingReimb_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Unreimbursed', fieldName: 'withholdingUnreimb', type: 'text',  initialWidth: 160, 
        sortable: true, 
        hideDefaultActions: true, sortFieldName: 'withholdingUnreimb_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
    {   label: 'Total Prior Deduction', fieldName: 'withholdingPrior', type: 'text',  initialWidth: 160, 
        sortable: true, 
        hideDefaultActions: true, sortFieldName: 'withholdingPrior_value', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER},
];

const outsideMattersWithheldColumns = [
    {
        label: 'ID',
        fieldName: 'outsideMatterLink',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'id'
            },
        },
        initialWidth: 60, sortable: true, sortFieldName: 'id', sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        hideDefaultActions: true, wrapText: true
    },
    {   label: 'Description', fieldName: 'description', type: 'text', 
        sortable: true, 
        hideDefaultActions: false,  wrapText: true, initialWidth: 350,  },
    {   label: 'Intended Reserve', fieldName: 'intentedReserve', type: 'text',  initialWidth: 130, 
        sortable: true, 
        hideDefaultActions: true},
    {   label: 'FY', fieldName: 'fy',  initialWidth: 100, 
        sortable: true, 
        hideDefaultActions: true},
    {   label: 'Total Prior Withholding', fieldName: 'totalWithHoldingPrior',  initialWidth: 200, 
        sortable: true, 
        hideDefaultActions: true}
];

export default class CrdrLevelB extends NavigationMixin(CrdrLevelUtils) {
   
    @api recordId;

    error;
    isLoading = true;

    deductionSortDirection = 'asc'
    deductionSortedBy = ''

    patentCostsSortDirection = 'asc'
    patentCostsSortedBy = ''

    deductionsColumns = deductionsColumns;
    deductionsLoading = true;
    deductionsData = [];

    ytdShareLvlB = 0;
    earlyShareLvlB = 0;
    currentShareLvlB = 0;

    ytdWithholdingLvlB = 0;
    totalCostsWithholdingLvlB = 0;
    totalReimbWithholdingLvlB = 0;
    totalUnreimbWithholdingLvlB = 0;
    totalUPriorWithholdingLvlB = 0;
    
    patentCostsColumns = patentCostsColumns;    
    patentCostsLoading = true;
    patentCostsData = [];
    
    withheldColumns = withheldColumns;
    withheldLoading = true;
    withheldData = [];

    outsideMattersColumns = outsideMattersColumns;
    outsideMattersData = [];
    outsideMatterFields = [];
    outsideSortDirection = 'asc'
    outsideSortedBy = ''

    outsideMattersWithheldColumns = outsideMattersWithheldColumns;
    outsideMattersWithheldData = [];
    outsideWithheldSortDirection = 'asc'
    outsideWithheldSortedBy = ''

    @wire(getObjectInfo, { objectApiName: 'Forrester_SHIR_CASE_CRDR_MATTER__x' })
    caseCrdrMatterObjInfo({ data, error }) {
        if (data) {
            const externalObject = 'Forrester_SHIR_CASE_CRDR_MATTER__x'
            const options = Object.keys(data.fields).map((curField) => {
                const field = data.fields[curField];                
                return externalObject + '.' + field.apiName
            });
            this.outsideMatterFields = options;
            this.outsideMatterFields.push(externalObject + '.OUTSIDE_MATTER_RECID__r.Id')
        }

        if (error) {
            console.error(error);   
        }
    }

    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId",
        relatedListId: 'Forrester_SHIR_CASE_CRDR_MATTER__r',
        optionalFields: '$outsideMatterFields',
        sortBy: ['Forrester_SHIR_CASE_CRDR_MATTER__x.OUTSIDE_MATTER_NUM__c']
    })
    outsideMatterData({ error, data }) {
        if (data) {
            this.ytdWithholdingLvlB = 0;
            this.totalCostsWithholdingLvlB = 0;
            this.totalReimbWithholdingLvlB = 0;
            this.totalUnreimbWithholdingLvlB = 0;
            this.totalUPriorWithholdingLvlB = 0;
            
            let patentCostsTempList = [];
            let withholdingTempList = [];
            let outsideMattersTempData = [];
            let outsideMattersWithheldTempData = [];

            let foreignWithholding = {};
            foreignWithholding.description = 'Foreign Patent Cost Deduction';
            foreignWithholding.deductionPct = getFieldValue(this._crdr, this.crdrFieldNames.FOR_PATENT_DEDUCT_PCT);
            foreignWithholding.fy = getFieldDisplayValue(this._crdr, this.crdrFieldNames.FOREIGN_WITHHOLDING);
            foreignWithholding.fy_value = getFieldValue(this._crdr, this.crdrFieldNames.FOREIGN_WITHHOLDING);
            foreignWithholding.withholdingCosts = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_FOREIGN);
            foreignWithholding.withholdingCosts_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_FOREIGN);
            foreignWithholding.withholdingReimb = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_FOREIGN);
            foreignWithholding.withholdingReimb_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_FOREIGN);
            foreignWithholding.withholdingUnreimb = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_FOREIGN);
            foreignWithholding.withholdingUnreimb_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_FOREIGN);
            foreignWithholding.withholdingPrior = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_FOREIGN);
            foreignWithholding.withholdingPrior_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_FOREIGN);
            patentCostsTempList.push(foreignWithholding);

            let domesticWithholding = {};
            domesticWithholding.description = 'Domestic Patent Cost Deduction';
            domesticWithholding.deductionPct = getFieldValue(this._crdr, this.crdrFieldNames.DOM_PATENT_DEDUCT_PCT);
            domesticWithholding.fy = getFieldDisplayValue(this._crdr, this.crdrFieldNames.DOMESTIC_WITHHOLDING);
            domesticWithholding.fy_value = getFieldValue(this._crdr, this.crdrFieldNames.DOMESTIC_WITHHOLDING);
            domesticWithholding.withholdingCosts = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_DOMESTIC);
            domesticWithholding.withholdingCosts_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_DOMESTIC);
            domesticWithholding.withholdingReimb = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_DOMESTIC);
            domesticWithholding.withholdingReimb_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_DOMESTIC);
            domesticWithholding.withholdingUnreimb = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_DOMESTIC);
            domesticWithholding.withholdingUnreimb_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_DOMESTIC);
            domesticWithholding.withholdingPrior = getFieldDisplayValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_DOMESTIC);
            domesticWithholding.withholdingPrior_value = getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_DOMESTIC);
            patentCostsTempList.push(domesticWithholding);

            data.records.forEach( obj2 => {
                let recordobj2 = {};
                recordobj2.id = obj2.fields.OUTSIDE_MATTER_NUM__c.value;
                recordobj2.outsideMatterLink =  '/lightning/r/' + obj2.fields.OUTSIDE_MATTER_RECID__r.value.fields.Id.value + '/view';
                recordobj2.description = obj2.fields.DESCRIPTION__c.value;
                recordobj2.deductionPct = obj2.fields.WITHHOLDING_PERCENT__c.value;
                recordobj2.fy = obj2.fields.MATTER_WITHHOLDING__c.displayValue;
                recordobj2.fy_value = obj2.fields.MATTER_WITHHOLDING__c.value;
                recordobj2.withholdingCosts = obj2.fields.WITHHOLDING_COSTS__c.displayValue;
                recordobj2.withholdingCosts_value = obj2.fields.WITHHOLDING_COSTS__c.value;
                recordobj2.withholdingReimb = obj2.fields.WITHHOLDING_REIMBURSEMENT__c.displayValue;
                recordobj2.withholdingReimb_value = obj2.fields.WITHHOLDING_REIMBURSEMENT__c.value;
                recordobj2.withholdingUnreimb = obj2.fields.WITHHOLDING_UNREIMB__c.displayValue;
                recordobj2.withholdingUnreimb_value = obj2.fields.WITHHOLDING_UNREIMB__c.value;
                recordobj2.withholdingPrior = obj2.fields.WITHHOLDING_PRIOR__c.displayValue;
                recordobj2.withholdingPrior_value = obj2.fields.WITHHOLDING_PRIOR__c.value;

                outsideMattersTempData.push( recordobj2 );
            } );


            let caseReserveWithholding = {};
            caseReserveWithholding.description = 'Case Reserve Withholding';
            caseReserveWithholding.fy = getFieldDisplayValue(this._crdr, this.crdrFieldNames.RESERVE_WITHHOLDING);
            caseReserveWithholding.intentedReserve = getFieldDisplayValue(this._crdr, this.crdrFieldNames.RESERVE_WITHHOLDING_INTENDED);
            caseReserveWithholding.totalWithHoldingPrior = getFieldDisplayValue(this._crdr, this.crdrFieldNames.RESERVE_PRIOR);
            withholdingTempList.push(caseReserveWithholding);

            data.records.forEach( obj2 => {
                let recordobj2 = {};                
                recordobj2.id = obj2.fields.OUTSIDE_MATTER_NUM__c.value;
                recordobj2.outsideMatterLink =  '/lightning/r/' + obj2.fields.OUTSIDE_MATTER_RECID__r.value.fields.Id.value + '/view';
                recordobj2.outsideMatterFlag = true;
                recordobj2.description = obj2.fields.DESCRIPTION__c.value;
                recordobj2.fy = obj2.fields.MATTER_RESERVE__c.displayValue;
                recordobj2.intentedReserve = obj2.fields.MATTER_RESERVE_INTENDED__c.displayValue;
                recordobj2.totalWithHoldingPrior = obj2.fields.RESERVE_PRIOR__c.displayValue;

                outsideMattersWithheldTempData.push( recordobj2 );
            } );
            
            
            this.calculateLvlBWithholdingSubtotals(data);

            this.patentCostsData = patentCostsTempList;
            this.withheldData = withholdingTempList;
            this.outsideMattersData = outsideMattersTempData;
            this.outsideMattersWithheldData = outsideMattersWithheldTempData;
            this.patentCostsLoading = false;

            this.error2 = undefined;
        } else if (error) {
            this.error2 = error;
            this.patentCoststsData = undefined;
        }
    }

    calculateLvlBWithholdingSubtotals(data) {
        console.log('');

        this.ytdWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.FOREIGN_WITHHOLDING);
        this.totalCostsWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_FOREIGN);
        this.totalReimbWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_FOREIGN);
        this.totalUnreimbWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_FOREIGN);
        this.totalUPriorWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_FOREIGN);

        this.ytdWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.DOMESTIC_WITHHOLDING);
        this.totalCostsWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_COSTS_DOMESTIC);
        this.totalReimbWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_REIMB_DOMESTIC);
        this.totalUnreimbWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_UNREIMB_DOMESTIC);
        this.totalUPriorWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.WITHHOLDING_PRIOR_DOMESTIC);     

        data.records.forEach( obj2 => {
            this.ytdWithholdingLvlB += obj2.fields.MATTER_WITHHOLDING__c.value;
            this.totalCostsWithholdingLvlB += obj2.fields.WITHHOLDING_COSTS__c.value;
            this.totalReimbWithholdingLvlB += obj2.fields.WITHHOLDING_REIMBURSEMENT__c.value;
            this.totalUnreimbWithholdingLvlB += obj2.fields.WITHHOLDING_UNREIMB__c.value;
            this.totalUPriorWithholdingLvlB += obj2.fields.WITHHOLDING_PRIOR__c.value;
        });

        this.ytdWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.RESERVE_WITHHOLDING);
        this.totalUPriorWithholdingLvlB += getFieldValue(this._crdr, this.crdrFieldNames.RESERVE_PRIOR);  

        data.records.forEach( obj2 => {
            this.ytdWithholdingLvlB += obj2.fields.MATTER_RESERVE__c.value;
            this.totalUPriorWithholdingLvlB += obj2.fields.RESERVE_PRIOR__c.value;
        } );            
    }

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

    error2;
    //https://developer.salesforce.com/docs/platform/lwc/guide/reference-wire-adapters-get-related-list-records.html
    @wire(getRelatedListRecords, {
        parentRecordId: "$recordId",
        relatedListId: 'Forrester_SHIR_CASE_CRDR_SHARE__r',
        optionalFields: '$dynamicFields',
        where: '{ SHARE_LEVEL__c: { eq: "B" }}',
        sortBy: ['Forrester_SHIR_CASE_CRDR_SHARE__x.RECIPIENT_NAME__c']
    })
    deductionsInfo({ error, data }) {
        if (data) {
            this.ytdShareLvlB = 0;
            this.earlyShareLvlB = 0;
            this.currentShareLvlB = 0;

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

            this.ytdShareLvlB = data.records.reduce((sum, item) => sum + item.fields.YTD_SHARE_AMOUNT__c.value, 0);
            this.earlyShareLvlB = data.records.reduce((sum, item) => sum + item.fields.EARLY_SHARE_AMOUNT__c.value, 0);
            this.currentShareLvlB = data.records.reduce((sum, item) => sum + item.fields.CURRENT_SHARE_AMOUNT__c.value, 0);

            this.deductionsData = recordList2;
            this.error2 = undefined;

            this.deductionsLoading = false;
        } else if (error) {
            this.error2 = error;
            this.deductionsData = undefined;
        }
    }
    onHandleSortPatentCosts(event) {
        const patentCostsSortedBy = event.detail.fieldName;
        const patentCostsSortDirection = event.detail.sortDirection;
        const cloneData = [...this.patentCostsData];
        const sortFieldType = this.patentCostsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.patentCostsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, patentCostsSortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.patentCostsData = cloneData
        this.patentCostsSortDirection = patentCostsSortDirection
        this.patentCostsSortedBy = patentCostsSortedBy
    }

    onHandleSortDeductions(event) {
        const deductionSortedBy = event.detail.fieldName;
        const deductionSortDirection = event.detail.sortDirection;
        const cloneData = [...this.deductionsData];
        const sortFieldType = this.deductionsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.deductionsColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, deductionSortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.deductionsData = cloneData
        this.deductionSortDirection = deductionSortDirection
        this.deductionSortedBy = deductionSortedBy
    }

    onHandleSortOutside(event) {
        const outsideSortedBy = event.detail.fieldName;
        const outsideSortDirection = event.detail.sortDirection;
        const cloneData = [...this.outsideMattersData];
        const sortFieldType = this.outsideMattersColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.outsideMattersColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, outsideSortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.outsideMattersData = cloneData
        this.outsideSortDirection = outsideSortDirection
        this.outsideSortedBy = outsideSortedBy
    }

    onHandleSortOutsideWithheld(event) {
        const outsideWithheldSortedBy = event.detail.fieldName;
        const outsideWithheldSortDirection = event.detail.sortDirection;
        const cloneData = [...this.outsideMattersWithheldData];
        const sortFieldType = this.outsideMattersWithheldColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.outsideMattersWithheldColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, outsideWithheldSortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.outsideMattersWithheldData = cloneData
        this.outsideWithheldSortDirection = outsideWithheldSortDirection
        this.outsideWithheldSortedBy = outsideWithheldSortedBy
    }

    async onHandlePatentCostAction(event) {
        const result = await CrdrLevelBPatentBreakdownModal.open({
            label: 'Patent Breakdown',
            size: 'large',
            caseRecId: this._crdr?.fields?.CASE_RECID__c?.value,

        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log('result ==> ', result);

        if (result.action === 'navigateToTab') {
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'CRDR_Patent_Breakdown_Tab'
                },
                state: {
                    c__caseRecordId: this._crdr?.fields?.CASE_RECID__c?.value,
                    c__crdrLabel: this._crdr.fields.DISCLOSURE_TITLE__c?.value ?? '',
                }
            });
        } else if (result.action === 'navigateToAgreement') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.recordId,
                    actionName: 'view'
                }
            });
        }
    }

    get levelLoading() {
        return this.patentCostsLoading || this.deductionsLoading;
    }

    get hasDeductionsData() {
        return (this.deductionsData.length > 0);
    }

    get hasPatentCostsData() {
        return (this.patentCostsData.length > 0);
    }

    get hasWithheldData() {
        return (this.withheldData.length > 0);
    }

    get hasOutsideMattersData() {
        return (this.outsideMattersData.length > 0);
    }

    get hasOutsideMattersWithheldData() {
        return (this.outsideMattersWithheldData.length > 0);
    }

    get deductionsHeaderTitle() {
        return 'Deductions (' + this.deductionsData.length + ')' ;
    }

    get patentCostsHeaderTitle() {
        return 'Patent Costs (' + this.patentCostsData.length + ')' ;
    }

    get withheldHeaderTitle() {
        return 'Withheld (' + this.withheldData.length + ')' ;
    }

    get outsideMattersTitle() {
        return 'Outside Matters (' + this.outsideMattersData.length + ')' ;
    }

    get outsideMattersWithheldTitle() {
        return 'Outside Matters Withheld (' + this.outsideMattersWithheldData.length + ')' ;
    }

    get formattedYtdShareLvlB(){
        return formatCurrency(this.ytdShareLvlB, true);
    }

    get formattedEarlyShareLvlB(){
        return formatCurrency(this.earlyShareLvlB, true);
    }

    get formattedCurrentShareLvlB(){
        return formatCurrency(this.currentShareLvlB, true);
    }

    get formattedYtdWithholdingLvlB(){
        return formatCurrency(this.ytdWithholdingLvlB, true);
    }

    get formattedTotalCostsWithholdingLvlB(){
        return formatCurrency(this.totalCostsWithholdingLvlB, true);
    }

    get formattedTotalReimbWithholdingLvlB(){
        return formatCurrency(this.totalReimbWithholdingLvlB, true);
    }

    get formattedTotalUnreimbWithholdingLvlB(){
        return formatCurrency(this.totalUnreimbWithholdingLvlB, true);
    }

    get formattedTotalUPriorWithholdingLvlB(){
        return formatCurrency(this.totalUPriorWithholdingLvlB, true);
    }
}