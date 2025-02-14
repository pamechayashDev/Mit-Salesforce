import { api, LightningElement, wire } from "lwc";
import getIncomeBreakdown from '@salesforce/apex/ExternalObjectRepository.getIncomeBreakdown'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { determineSortPrimer, formatCurrency, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";

const breakdownColumns = [
    { label: '', fieldName: 'INVOICE_LINE_ITEM_DESC__c', type:'text', sortable: true, hideDefaultActions: true, },
    {
        label: 'Agreement',
        fieldName: 'sObjectUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'AGREEMENT_RECID__c'
            },
        }, sortable: true, hideDefaultActions: true,
    },
    { label: 'Case%', fieldName: 'casePtc',
        type:'percent',
        typeAttributes: {
            maximumFractionDigits: '6',
        },
        cellAttributes: { alignment: 'left' },
        sortable: true, hideDefaultActions: true,
    },
    { label: '', fieldName: 'COLLECTED_AMT__c',
        cellAttributes: { alignment: 'left' },
        sortable: true, hideDefaultActions: true,
        sortFieldName: 'COLLECTED_AMT__c_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
];

// https://www.salesforcecodecrack.com/2023/01/dynamic-popupmodal-using-lightning.html
export default class CrdrIncomeBreakdown extends LightningElement {
    @api crdrRecordId; //
    @api agreementRecIdStr; //
    @api agrName;
    @api caseAgrIncome;
    @api agrCasePct;


    sortDirection = 'asc'
    sortedBy = ''

    breakdownColumns = breakdownColumns;

    loading = true;
    breakdownData = [];

    get headerLabel() {
        return this.agrName + ' - ' + this.caseAgrIncome;
    }

    @wire(getObjectInfo, { objectApiName: 'Forrester_SHIR_CASE_CRDR_REV_BREAKDOW__x' })
    objectInfo;


    @wire(getIncomeBreakdown, { crdrRecordId: '$crdrRecordId', agreementRecIdStr: '$agreementRecIdStr' })
    async handleIncomeBreakdown({data, error}) {
        if (data) {
            //match labels from Object Definition to our Columns
            this.breakdownColumns.forEach(x => {
                if (x.label === '') {
                    const objInfoFields = this.objectInfo.data.fields;
                    Object.keys(objInfoFields).forEach(key => {
                        if (key === x.fieldName) {
                            x.label = objInfoFields[key].label;
                        }
                    });
                }
            } );

            // add custom fields to data response for data-table
            let tempIncomeBreakdownData = [];
            data.forEach(async (x) => {
                let clone = {...x};

                //https://ktema.org/articles/lightning-data-table-record-link/
                clone.sObjectUrl = '/lightning/r/' + x.REV_BREAKDOWN_ID__r.AGREEMENT_RECID__r.Id + '/view';
                clone.casePtc = this.agrCasePct;
                clone.COLLECTED_AMT__c = formatCurrency(x.COLLECTED_AMT__c, true);
                clone.COLLECTED_AMT__c_value = x.COLLECTED_AMT__c

                tempIncomeBreakdownData.push(clone);
            })

            // Combine data by INVOICE_LINE_ITEM_DESC__c
            let tempCombinedIncomeBreakdownData = [];
            tempIncomeBreakdownData.reduce(function(res, value) {
                if (!res[value.INVOICE_LINE_ITEM_DESC__c]) {
                    res[value.INVOICE_LINE_ITEM_DESC__c] = { ...value, COLLECTED_AMT__c_value: 0 };
                    tempCombinedIncomeBreakdownData.push(res[value.INVOICE_LINE_ITEM_DESC__c])
                }
                res[value.INVOICE_LINE_ITEM_DESC__c].COLLECTED_AMT__c_value += value.COLLECTED_AMT__c_value;
                return res;
            }, {});

            // Format COLLECTED_AMT__c_value
            tempCombinedIncomeBreakdownData.forEach(row => {
                row.COLLECTED_AMT__c = formatCurrency(row.COLLECTED_AMT__c_value, true);
            });

            this.breakdownData = tempCombinedIncomeBreakdownData;
            this.loading = false;
        }

        if (error) {
            console.error(error);
        }
    }

    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.breakdownData];
        const sortFieldType = this.breakdownColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.breakdownColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this.breakdownData = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }

    get datatableHeight() {
        if ( this.breakdownData.length >= 10) {
            return 'height: 300px;';
        }

        return 'height: 100%';
    }
}