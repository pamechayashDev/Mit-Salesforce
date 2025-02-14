/**
 * Created by Andreas du Preez on 2024/02/23.
 */

import { determineSortPrimer, formatCurrency, SORT_BY_TYPE_ENUMS, sortBy } from 'c/utils';
import { api, LightningElement, wire } from "lwc";
import getPatentBreakdownIncomeSummary from '@salesforce/apex/ExternalObjectRepository.getPatentBreakdownIncomeSummary';
import getOutstandingPatentCosts from '@salesforce/apex/ExternalObjectRepository.getOutstandingPatentCosts';
import getUnpaidInvoices from '@salesforce/apex/ExternalObjectRepository.getUnpaidInvoices';
import PFC_SVG_ICON from '@salesforce/resourceUrl/partner_fund_claim_svg';
import { NavigationMixin } from "lightning/navigation";

const invoiceColumns = [
    {
        label: 'Invoice',
        fieldName: 'INVOICE_NUM__c',
        type: 'text',
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: 'Agreement',
        type: 'button',
        fieldName: 'AGREEMENT_RECID__c',
        typeAttributes: {
            label: { fieldName: 'AGREEMENT_RECID__c' },
            name: { fieldName: 'AGREEMENT_RECID__c' },
            alternativeText: { fieldName: 'AGREEMENT_RECID__c' },
            disabled: false,
            variant: 'base',
            action: { label: 'ViewAgreement', name: 'viewAgreement' }
        },
        cellAttributes: {
            alignment: 'left'
        },
        sortable: true, hideDefaultActions: true,
        sortFieldName: 'AGREEMENT_RECID__c',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Licensee',
        type: 'text',
        fieldName: 'LICENSEE__c',
        sortable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: 'Amount',
        fieldName: 'INVOICE_LINE_ITEM_AMT__c_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'INVOICE_LINE_ITEM_AMT__c',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Type',
        fieldName: 'DOM_FOREIGN__c',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true
    },
    {
        label: 'Due Date',
        fieldName: 'DUE_DATE__c',
        type: 'date',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true
    }
];

const incomeSummaryColumns = [
    {
        label: 'Agreement',
        type: 'button',
        fieldName: 'AGREEMENT_RECID__c',
        typeAttributes: {
            label: { fieldName: 'AGREEMENT_RECID__c' },
            name: { fieldName: 'AGREEMENT_RECID__c' },
            alternativeText: { fieldName: 'AGREEMENT_RECID__c' },
            disabled: false,
            variant: 'base',
            action: { label: 'ViewAgreement', name: 'viewAgreement' }
        },
        cellAttributes: {
            alignment: 'left'
        },
        sortable: true, hideDefaultActions: true,
        sortFieldName: 'AGREEMENT_RECID__c',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Licensee',
        fieldName: 'LICENSEE__c',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
    },
    {
        label: 'Type',
        fieldName: 'AGREEMENT_TYPE__C',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
    },
    {
        label: 'Domestic Reimburse',
        fieldName: 'domesticReimburse_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'domesticReimburse_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
    },
    {
        label: 'Fees',
        fieldName: 'fees_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'fees_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
    },
    {
        label: 'Foreign Reimburse',
        fieldName: 'foreignReimburse_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'foreignReimburse_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
    },
    {
        label: 'Interest',
        fieldName: 'interest_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'interest_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Running Royalties',
        fieldName: 'runningRoyalties_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'runningRoyalties_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Total',
        fieldName: 'total_displayValue',
        type: 'text',
        sortable: true,
        hideDefaultActions: false,
        wrapText: true,
        sortFieldName: 'total_value',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    }
];
const outstandingPatentCostsColumns = [
    {
        label: 'Type',
        fieldName: 'LINE_TYPE__c',
        type: 'text',
        sortable: false,
        hideDefaultActions: false,
        wrapText: true,
        initialWidth: 200
    },
    {
        label: 'Domestic',
        fieldName: 'DOMESTIC__c_displayValue',
        type: 'text',
        sortable: false,
        hideDefaultActions: false,
        wrapText: true
    },
    {
        label: 'Foreign',
        fieldName: 'FOREIGN__c_displayValue',
        type: 'text',
        sortable: false,
        hideDefaultActions: false,
        wrapText: true
    },
    {
        label: 'Total',
        fieldName: 'TOTAL__c_displayValue',
        type: 'text',
        sortable: false,
        hideDefaultActions: false,
        wrapText: true
    }
];

const PFC_ICON_SVG_ID = 'pfc_icon';

export default class CrdrLevelBPatentBreakdown extends NavigationMixin(LightningElement) {
    @api caseRecId;
    @api containerComponent;

    activeSections = ['Invoices', 'IncomeSummary', 'OutstandingPatentCosts', 'Comments'];

    invoiceColumns = invoiceColumns;
    incomeSummaryColumns = incomeSummaryColumns;
    outstandingPatentCostsColumns = outstandingPatentCostsColumns;

    // Invoice
    invoiceData = [];
    invoiceSortedBy = '';
    invoiceSortDirection = '';
    invoiceError = false;
    invoiceLoading = true;

    // Income Summary
    incomeSummaryData = [];
    incomeSummarySortedBy = '';
    incomeSummarySortDirection = '';
    incomeSummaryError = false;
    incomeSummaryLoading = true;

    domesticReimburseTotal = 0;
    feesTotal = 0;
    foreignReimburseTotal = 0;
    interestTotal = 0;
    runningRoyaltiesTotal = 0;
    totalTotal = 0;

    // Outstanding Patent Costs
    outstandingPatentCostsData = [];
    outstandingPatentCostsError = false;
    outstandingPatentCostsLoading = true;

    // Wires
    @wire(getPatentBreakdownIncomeSummary, {
        caseRecId: '$caseRecId'
    })
    loadIncomeSummaryData({ error, data }) {
        if (data) {
            Map.groupBy(data, row => {
                return row.AGREEMENT_RECID__c;
            }).forEach((rows, key) => {
                let domesticReimburse = rows.filter(row => row.INCOME_TYPE__c === 'Domestic Reimb')?.reduce((acc, curr) => acc + curr.AMOUNT__c, 0) ?? 0;
                let fees = rows.filter(row => row.INCOME_TYPE__c === 'Fees')?.reduce((acc, curr) => acc + curr.AMOUNT__c, 0) ?? 0;
                let foreignReimburse = rows.filter(row => row.INCOME_TYPE__c === 'Foreign Reimb')?.reduce((acc, curr) => acc + curr.AMOUNT__c, 0) ?? 0;
                let interest = rows.filter(row => row.INCOME_TYPE__c === 'Interest')?.reduce((acc, curr) => acc + curr.AMOUNT__c, 0) ?? 0;
                let runningRoyalties = rows.filter(row => row.INCOME_TYPE__c === 'Running Royalties')?.reduce((acc, curr) => acc + curr.AMOUNT__c, 0) ?? 0;
                let total = domesticReimburse + fees + foreignReimburse + interest + runningRoyalties;

                this.domesticReimburseTotal += domesticReimburse;
                this.feesTotal += fees;
                this.foreignReimburseTotal += foreignReimburse;
                this.interestTotal += interest;
                this.runningRoyaltiesTotal += runningRoyalties;
                this.totalTotal += total;

                this.incomeSummaryData.push({
                    AGREEMENT_RECID__r: {Id: rows[0].AGREEMENT_RECID__r.Id},
                    AGREEMENT_RECID__c: key,
                    LICENSEE__c: rows[0].LICENSEE__c,
                    AGREEMENT_TYPE__C: rows[0].AGREEMENT_TYPE__c,
                    domesticReimburse_displayValue: formatCurrency(domesticReimburse, true),
                    domesticReimburse_value: domesticReimburse,
                    fees_displayValue: formatCurrency(fees, true),
                    fees_value: fees,
                    foreignReimburse_displayValue: formatCurrency(foreignReimburse, true),
                    foreignReimburse_value: foreignReimburse,
                    interest_displayValue: formatCurrency(interest, true),
                    interest_value: interest,
                    runningRoyalties_displayValue: formatCurrency(runningRoyalties, true),
                    runningRoyalties_value: runningRoyalties,
                    total_displayValue: formatCurrency(total, true),
                    total_value: total
                });
            });

            this.incomeSummaryLoading = false;
            this.incomeSummaryError = undefined;
        } else if (error) {
            this.incomeSummaryError = error;
            this.incomeSummaryData = undefined;
        }

        if (error) {
            console.error(error);
        }
    }

    @wire(getOutstandingPatentCosts, {
        caseRecId: '$caseRecId'
    })
    loadOutstandingPatentCosts({ error, data }) {
        if (data) {
            let tempOutstandingPatentCostsData = [];
            Map.groupBy(data, row => {
                return row.AGREEMENT_NUM__c;
            }).forEach((rows, key) => {
                let dataTableMetaData = {
                    id: key,
                    title: `${rows[0].LICENSEE__c} (${key} - ${rows[0].AGREEMENT_STATUS_DESCRIPTION__c})`,
                    licensee: rows[0].LICENSEE__c,
                    data: [...rows.map(row => ({
                        ...row,
                        DOMESTIC__c_displayValue: formatCurrency(row.DOMESTIC__c ?? 0, true),
                        FOREIGN__c_displayValue: formatCurrency(row.FOREIGN__c ?? 0, true),
                        TOTAL__c_displayValue: formatCurrency(row.TOTAL__c ?? 0, true)
                    }))],
                    sortedBy: '',
                    sortDirection: ''
                };

                tempOutstandingPatentCostsData.push(dataTableMetaData);
            });

            tempOutstandingPatentCostsData.sort((a, b) => a.licensee.localeCompare(b.licensee));
            this.outstandingPatentCostsData = tempOutstandingPatentCostsData;

            this.outstandingPatentCostsLoading = false;
            this.outstandingPatentCostsError = undefined;

        } else if (error) {
            this.outstandingPatentCostsError = error;
            this.outstandingPatentCostsData = undefined;
        }

        if (error) {
            console.error(error);
        }
    }

    @wire(getUnpaidInvoices, {
        caseRecId: '$caseRecId'
    })
    unpaidInvoices({ error, data }) {
        if (data) {
            this.invoiceData = data.map(row => ({
                ...row,
                INVOICE_LINE_ITEM_AMT__c_displayValue: formatCurrency(row.INVOICE_LINE_ITEM_AMT__c ?? 0, true),
            }));
            this.invoiceLoading = false;
        } else if (error) {
            this.invoiceError = error;
            this.invoiceData = undefined;
        }

        if (error) {
            console.error(error);
        }
    }

    // Event handlers
    onHandleInvoiceSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const sortFieldType = this.invoiceColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.invoiceColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        this.invoiceData = this.sortData([...this.invoiceData], sortFieldName, sortDirection, sortFieldType);
        this.invoiceSortDirection = sortDirection;
        this.invoiceSortedBy = sortedBy;
    }

    onHandleIncomeSummarySort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const sortFieldType = this.incomeSummaryColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.incomeSummaryColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        this.incomeSummaryData = this.sortData([...this.incomeSummaryData], sortFieldName, sortDirection, sortFieldType);
        this.incomeSummarySortDirection = sortDirection;
        this.incomeSummarySortedBy = sortedBy;
    }

    // Helper methods
    sortData(clonedData, sortFieldName, sortDirection, sortFieldType) {
        return clonedData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        );
    }

    async handleRowAction(event) {
        const row = event.detail.row;
        if (event.detail?.action?.action?.name === 'viewAgreement') {
            if (this.containerComponent === "tab") {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.AGREEMENT_RECID__r.Id,
                        actionName: 'view'
                    }
                });
            } else {
                this.dispatchEvent(new CustomEvent('openagreement', {
                    detail: {
                        recordId: row.AGREEMENT_RECID__r.Id
                    }
                }));
            }
        }
    }

    // Getters
    get partnerFundClaimIconUrl() {
        return `${PFC_SVG_ICON}#${PFC_ICON_SVG_ID}`;
    }

    get invoicesHeaderTitle() {
        return `Unpaid Invoices (${this.invoiceData.length})`;
    }

    get incomeSummaryHeaderTitle() {
        return `Income Summary (${this.incomeSummaryData.length})`;
    }

    get hasInvoicesData() {
        return (this.invoiceData.length > 0);
    }

    get hasIncomeSummaryData() {
        return (this.incomeSummaryData.length > 0);
    }

    get formattedDomesticReimburseTotal() {
        return formatCurrency(this.domesticReimburseTotal, true);
    }

    get formattedFeesTotal() {
        return formatCurrency(this.feesTotal, true);
    }

    get formattedForeignReimburseTotal() {
        return formatCurrency(this.foreignReimburseTotal, true);
    }

    get formattedInterestTotal() {
        return formatCurrency(this.interestTotal, true);
    }

    get formattedRunningRoyalties() {
        return formatCurrency(this.runningRoyaltiesTotal, true);
    }

    get formattedTotalTotal() {
        return formatCurrency(this.totalTotal, true);
    }
}