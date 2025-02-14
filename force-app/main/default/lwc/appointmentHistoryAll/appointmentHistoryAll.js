import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import restGet from '@salesforce/apex/AwsApiCall.restGet';
import { CurrentPageReference } from 'lightning/navigation';
import {
    asStringIgnoreCase, filterDateAsOf, filterDateRangeBetweenDateRange,
    filterArrayWithUserText, filterArrayByUserBoolean,
    generateCommaSeparatedString, sortBy
} from 'c/utils'
import { invokeWorkspaceAPI } from 'c/workspaceApiUtils';

const columns = [
    {
        label: 'Job Title',
        fieldName: 'jobTitle',
        sortable: true,
        initialWidth: 200,
        wrapText: true,
    },
    {
        label: 'Position Title',
        fieldName: 'positionTitle',
        sortable: true,
        wrapText: true,
    },
    {
        label: 'Start Date',
        fieldName: 'startDate',
        type: 'date-local',
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 150,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit",
            year: "numeric"
        },
        wrapText: true,
    },
    {
        label: 'End Date',
        fieldName: 'endDate',
        type: 'date',
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 150,
        wrapText: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit",
            year: "numeric"
        }
    },
    {
        label: 'Department Name',
        initialWidth: 200,
        fieldName: 'hrDepartmentName',
        sortable: true,
        wrapText: true,
    },
    {
        label: 'Department Number',
        fieldName: 'hrDepartmentCode',
        hideDefaultActions: true,
        initialWidth: 150,
        wrapText: true,
    },
    {
        label: 'Appointment Type',
        fieldName: 'hrAppointmentTypeDesc',
        sortable: true,
        wrapText: true,
    },
    {
        label: 'Position Type',
        fieldName: 'positionType',
        sortable: true,
        initialWidth: 150,
        wrapText: true,
    },
    {
        label: 'Primary',
        fieldName: 'isPrimary',
        type: 'boolean',
        initialWidth: 65,
    },
];

const APT_HIST_KEYS = {
    appointmentPercentage: 'appointmentPercentage',
    endDate: 'endDate',
    hrAppointmentTypeCode: 'hrAppointmentTypeCode',
    hrAppointmentTypeDesc: 'hrAppointmentTypeDesc',
    hrDepartmentCode: 'hrDepartmentCode',
    hrDepartmentName: 'hrDepartmentName',
    isPrimary: 'isPrimary',
    jobTitle: 'jobTitle',
    krbName: 'krbName',
    mitId: 'mitId',
    positionCode: 'positionCode',
    positionTitle: 'positionTitle',
    positionType: 'positionType',
    startDate: 'startDate'
}

export default class AppointmentHistoryAll extends NavigationMixin(LightningElement) {
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    contactName;
    contactRecordId;
    contactUrl;
    contactMitId;
    profileAmt = 0;
    personDetailsTabId;
    loading = true;
    loadError = false;

    genesisHistories = [];
    filteredDates = [];

    //these are represented as a string since dropdown values in SF has to be strings
    //this value does get parsed to a boolean when the data is filtered
    primaryOptions = [
        { label: 'All', value: 'null' },
        { label: 'Checked', value: 'true' },
        { label: 'Not Checked', value: 'false' },
    ];

    @track filterButtonState = 'border-filled';

    //variable bank for filters
    jobTitleFilter = '';
    positionTitleFilter = '';
    hrDepartmentCodeFilter = '';
    hrDepartmentNameFilter = '';
    hrAppointmentTypeDescFilter = '';
    positionTypeFilter = '';
    endDate = null;
    startDate = null;
    useDateRange = false;
    isPrimaryFilter = 'null';
    filterByArray = [];
    filteredByText = '';
    showFilterTextSeperator = false;
    //end of variable bank

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.contactName = currentPageReference.state.c__name;
            this.contactRecordId = currentPageReference.state.c__recordId;
            this.contactUrl = currentPageReference.state.c__url;
            this.contactMitId = currentPageReference.state.c__mitid;
            this.personDetailsTabId = currentPageReference.state.c__personDetailsTabId;
            await this.getPersonAppointmentHistory();
        }
    }

    getPersonAppointmentHistory = async () => {
        this.loading = true;
        this.genesisHistories = [];
        this.filteredDates = [];
        this.loadError = false;
        this.profileAmt = 0;
        try {
            const apiName = 'appointmentHistoryApi'
            const res = await restGet({ api: apiName, resource: (`/histories/${this.contactMitId}`) });
            this.genesisHistories = JSON.parse(res);
            this.filteredDates = this.genesisHistories;
            this.profileAmt = this.filteredDates.length;
            this.template.querySelector('lightning-datatable').columns = columns;
        } catch (error) {
            console.error(`%c [ERROR]`, `color: red`, error);
            this.loadError = true;
        }
        this.loading = false;
    }

    navigateHome(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'MIT_People_Search'
            }
        });
    }

    handleNavigateToPersonDetails(event) {
        // prevent default navigation by href
        event.preventDefault();

        invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
            if (isConsole) {
                invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
                    invokeWorkspaceAPI('focusTab', {
                        tabId: this.personDetailsTabId
                    })
                });
            }
        });

    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const tempSorting = [...this.filteredDates]

        tempSorting.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) => asStringIgnoreCase(x)));
        this.filteredDates = tempSorting;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    get contactsUrl() {
        return window.location.origin + '/lightning/n/MIT_People_Search'
    }

    resetColumnWidth() {
        this.template.querySelector('lightning-datatable').columns = columns;
    }

    //this is a component lifecycle hook that runs when the component is done rendering
    renderedCallback() {
        this.checkFilterPopover();
    }

    toggleDrawer() {
        const drawer = this.template.querySelector('[data-id="appt-drawer"]');
        if (drawer.classList.contains('slds-is-open')) {
            drawer.classList.remove('slds-is-open');
            this.filterButtonState = 'border-filled';
        } else {
            drawer.classList.add('slds-is-open');
            this.filterButtonState = 'brand';
        }
    }

    closeDrawer() {
        const drawer = this.template.querySelector('[data-id="appt-drawer"]');
        drawer.classList.remove('slds-is-open');
        this.filterButtonState = 'border-filled';
    }

    toggleDateRangeSearch() {
        this.useDateRange = !this.useDateRange
    }

    handleStartDateChange({ detail: { value } }) {
        if (value >= this.endDate) {
            const tmpDate = new Date(value);
            tmpDate.setDate(tmpDate.getDate() + 1);
            this.endDate = tmpDate.toISOString().split('T')[0];
        }
        this.startDate = value;
    }

    handleEndDateChange({ detail: { value } }) {
        this.endDate = value;
        if (this.endDate <= this.startDate) {
            const tmpDate = new Date(this.endDate);
            tmpDate.setDate(tmpDate.getDate() - 1);
            this.startDate = tmpDate.toISOString().split('T')[0];
        }
        this.endDate = value;
    }

    //input field on change handlers
    handleJobTitleChange({ detail: { value } }) {
        this.jobTitleFilter = value;
    }
    handlePositionTitleChange({ detail: { value } }) {
        this.positionTitleFilter = value;
    }
    handleDepartmentNumberChange({ detail: { value } }) {
        this.hrDepartmentCodeFilter = value;
    }
    handleHrDepartmentNameChange({ detail: { value } }) {
        this.hrDepartmentNameFilter = value;
    }
    handleAppointmentTypeChange({ detail: { value } }) {
        this.hrAppointmentTypeDescFilter = value;
    }
    handlePrimarySelectionChange({ detail: { value } }) {
        this.isPrimaryFilter = value;
    }
    handlePositionTypeChange({ detail: { value } }) {
        this.positionTypeFilter = value;
    }

    applyFilters() {
        //reset the dates to initial state for proper filtering
        this.filteredDates = this.genesisHistories;
        this.profileAmt = this.filteredDates.length;
        this.filterByArray = [];
        this.filteredByText = '';
        this.showFilterTextSeperator = false;

        if (this.useDateRange === true && this.startDate !== null && this.endDate !== null) {
            this.filterByArray.push('Date');
            this.filteredDates = filterDateRangeBetweenDateRange(this.startDate, this.endDate, this.filteredDates);
        }
        if (this.useDateRange === false && this.startDate !== null) {
            this.filterByArray.push('Date');
            this.filteredDates = filterDateAsOf(this.startDate, this.filteredDates);
        }

        //if checks to see if the filter is empty, if it is, then it will not filter
        if (this.jobTitleFilter.length > 0) {
            this.filterByArray.push('Job Title');
            this.filteredDates = filterArrayWithUserText(this.jobTitleFilter, this.filteredDates, APT_HIST_KEYS.jobTitle);
        }
        if (this.positionTitleFilter.length > 0) {
            this.filterByArray.push('Position Title');
            this.filteredDates = filterArrayWithUserText(this.positionTitleFilter, this.filteredDates, APT_HIST_KEYS.positionTitle);
        }
        if (this.hrDepartmentCodeFilter.length > 0) {
            this.filterByArray.push('Department Number');
            this.filteredDates = filterArrayWithUserText(this.hrDepartmentCodeFilter, this.filteredDates, APT_HIST_KEYS.hrDepartmentCode);
        }
        if (this.hrDepartmentNameFilter.length > 0) {
            this.filterByArray.push('Department Name');
            this.filteredDates = filterArrayWithUserText(this.hrDepartmentNameFilter, this.filteredDates, APT_HIST_KEYS.hrDepartmentName);
        }
        if (this.hrAppointmentTypeDescFilter.length > 0) {
            this.filterByArray.push('Appointment Type');
            this.filteredDates = filterArrayWithUserText(this.hrAppointmentTypeDescFilter, this.filteredDates, APT_HIST_KEYS.hrAppointmentTypeDesc);
        }
        //Salesforce boolean and null input selections are saved as a string, JSON.parse the value first before passing it through
        if (JSON.parse(this.isPrimaryFilter) !== null) {
            this.filterByArray.push('Primary');
            this.filteredDates = filterArrayByUserBoolean(JSON.parse(this.isPrimaryFilter), this.filteredDates, APT_HIST_KEYS.isPrimary);
        }
        if (this.positionTypeFilter.length > 0) {
            this.filterByArray.push('Position Type');
            this.filteredDates = filterArrayWithUserText(this.positionTypeFilter, this.filteredDates, APT_HIST_KEYS.positionType);
        }

        this.filteredByText = generateCommaSeparatedString(this.filterByArray);
        this.profileAmt = this.filteredDates.length;
        this.filterByArray.length > 0 ? this.showFilterTextSeperator = true : this.showFilterTextSeperator = false;
    }

    resetFilters() {
        this.filteredDates = this.genesisHistories;
        this.profileAmt = this.filteredDates.length;
        this.jobTitleFilter = '';
        this.positionTitleFilter = '';
        this.hrDepartmentCodeFilter = '';
        this.hrDepartmentNameFilter = '';
        this.hrAppointmentTypeDescFilter = '';
        this.positionTypeFilter = '';
        this.isPrimaryFilter = 'null';
        this.useDateRange = false;
        this.startDate = null;
        this.endDate = null;
        this.filterByArray = [];
        this.filteredByText = '';
        this.showFilterTextSeperator = false;
    }

    checkFilterPopover() {
        const popover = this.template.querySelector('section[data-id="filter-popover-id"]');
        let state = JSON.parse(localStorage.getItem('filterPopoverViewed'));
        if (state === null) {
            //checks if this exists in storage, if it doesn't, initialize it
            localStorage.setItem('filterPopoverViewed', JSON.stringify({ viewed: false }));
            state = JSON.parse(localStorage.getItem('filterPopoverViewed'));
        }
        if (state.viewed !== true) {
            popover.classList.remove('slds-assistive-text');
        }
    }

    hideFilterPopover() {
        const popover = this.template.querySelector('section[data-id="filter-popover-id"]');
        popover.classList.add('slds-assistive-text');
        localStorage.setItem('filterPopoverViewed', JSON.stringify({ viewed: true }));
    }
}