/**
 * Created by Andreas du Preez on 2025/02/05.
 */

import { LightningElement, api } from "lwc";
import { determineSortPrimer, SORT_BY_TYPE_ENUMS, sortBy } from "c/utils";
import TIME_ZONE  from '@salesforce/i18n/timeZone';
import PFA_SVG_ICON from '@salesforce/resourceUrl/partner_fund_allocation_svg';
import { NavigationMixin } from "lightning/navigation";

const CASES_COLUMNS = [
    {
        label: 'TLO Officer',
        fieldName: 'TLO_NAME__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Case',
        type: 'button',
        fieldName: 'CASE_RECID__c',
        typeAttributes: {
            label: { fieldName: 'CONTRACT_CASE_NUM__c' },
            name: { fieldName: 'CONTRACT_CASE_NUM__c' },
            alternativeText: { fieldName: 'CONTRACT_CASE_NUM__c' },
            disabled: false,
            variant: 'base',
            action: { label: 'ViewCase', name: 'viewCase' }
        },
        cellAttributes: {
            alignment: 'left'
        },
        sortable: true, hideDefaultActions: true,
        sortFieldName: 'CONTRACT_CASE_NUM__c',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER
    },
    {
        label: 'Title',
        fieldName: 'DISCLOSURE_TITLE__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Status',
        fieldName: 'STATUS__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Opened Date',
        fieldName: 'OPEN_DATE__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'date',
        typeAttributes: {
            month: "2-digit",
            day: "2-digit",
            year: "numeric",
            timeZone: TIME_ZONE
        },
        sortFieldType: SORT_BY_TYPE_ENUMS.DATE
    },
    {
        label: 'Co-Inventors',
        fieldName: 'CO_INVENTORS__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Sponsors',
        fieldName: 'CASE_SPONSOR_NAMES__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Case Type',
        fieldName: 'CASE_TYPE__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Patents',
        fieldName: 'PATENT_COUNT__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'number',
        sortFieldType: SORT_BY_TYPE_ENUMS.NUMBER,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Anticipated Publish Date',
        fieldName: 'ANTIC_PUBLISH_DATE__c',
        sortable: true,
        hideDefaultActions: true,
        type: 'date',
        typeAttributes: {
            month: "2-digit",
            day: "2-digit",
            year: "numeric",
            timeZone: TIME_ZONE
        },
        wrapText: true,
        sortFieldType: SORT_BY_TYPE_ENUMS.DATE
    }
];

const PFA_ICON_SVG_ID = 'pfa_icon';

export default class BipPiCaseInventorsDataTable extends NavigationMixin(LightningElement) {

    @api
    set tableData(value) {
        this._tableData = value;
        this.numOfCases = this._tableData.length;
    }
    get tableData() {
        return this._tableData;
    }

    @api tableHeaderLabelOverride;
    _tableData = [];
    casesColumns = CASES_COLUMNS;
    casesSortedBy = '';
    casesSortDirection = 'asc';
    numOfCases = 0;

    // Getters
    get partnerFundAllocationIconUrl() {
        return `${PFA_SVG_ICON}#${PFA_ICON_SVG_ID}`;
    }

    get getTableHeaderLabel() {
        return `${this.tableHeaderLabelOverride ?? 'Cases'} (${this.numOfCases})`;
    }

    // Event handlers
    onHandleSort(event) {
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this._tableData];
        const sortFieldType = this.casesColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldType ?? SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE;
        const sortFieldName = this.casesColumns.find(column => column.fieldName === event.detail.fieldName)?.sortFieldName ?? event.detail.fieldName;

        cloneData.sort(
            sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1, (x) =>
                determineSortPrimer(sortFieldType, x)
            )
        )
        this._tableData = cloneData
        this.casesSortDirection = sortDirection
        this.casesSortedBy = sortedBy
    }

    async handleRowAction(event) {
        const row = event.detail.row;
        if (event.detail?.action?.action?.name === 'viewCase') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Forrester_Case__x',
                    actionName: 'view'
                }
            });
        }
    }
}