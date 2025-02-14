import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import restGet from '@salesforce/apex/AwsApiCall.restGet';
import { CurrentPageReference } from 'lightning/navigation';
import { invokeWorkspaceAPI } from 'c/workspaceApiUtils';
import { asStringIgnoreCase, sortBy, generateCommaSeparatedString, filterArrayByUserBoolean, filterArrayWithUserText, dropdownListGenerator } from 'c/utils'

const columns = [
    {
        label: 'Year',
        fieldName: 'yearDesc',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
    },
    {
        label: 'Term Code',
        fieldName: 'termCode',
        hideDefaultActions: true,
    },
    {
        label: 'Home Department',
        fieldName: 'homeDeptDesc',
        sortable: true,
        wrapText: true,
    },
    {
        label: 'UROP Flag',
        fieldName: 'uropFlag',
        type: 'boolean',
        sortable: true,
        initialWidth: 90
    },
    {
        label: 'Registration Type',
        fieldName: 'registrationTypeDesc',
        wrapText: true,
        sortable: true,
        hideDefaultActions: true
    }
];

const ACAD_HIST_KEYS = {
    homeDeptCode: 'homeDeptDesc',
    homeDeptDesc: 'homeDeptDesc',
    homeDeptLongDesc: 'homeDeptLongDesc',
    krbName: 'krbName',
    levelCode: 'levelCode',
    levelDesc: 'levelDesc',
    mitId: 'mitId',
    registrationTypeCode: 'registrationTypeCode',
    registrationTypeDesc: 'registrationTypeDesc',
    termCode: 'termCode',
    uropFlag: 'uropFlag',
    yearCode: 'yearCode',
    yearDesc: 'yearDesc',
}

export default class AcademicHistoryAll extends NavigationMixin(LightningElement) {
    @track dynamicProfile;

    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    contactName;
    contactRecordId;
    contactUrl;
    contactMitId;
    personDetailsTabId;
    loadError = false;
    loading = true;
    profileAmt = 0;

    genesisHistories = [];
    filteredDates = [];

    //these are represented as a string since dropdown values in SF has to be strings
    //this value does get parsed to a boolean when the data is filtered
    uropFlagOptions = [
        { label: 'All', value: 'null' },
        { label: 'Checked', value: 'true' },
        { label: 'Not Checked', value: 'false' },
    ];

    //default sorting option that includes all the data
    yearOptions = [{ label: 'All', value: 'All' }];
    registrationTypeOptions = [{ label: 'All', value: 'All' }];

    @track filterButtonState = 'border-filled';

    //variable bank for filters
    yearFilter = 'All';
    termCodeFilter = '';
    homeDepartmentFilter = '';
    registrationTypeFilter = 'All';
    uropFlagFilter = 'null';
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
            await this.getPersonAcademicHistory();
        }
    }

    getPersonAcademicHistory = async () => {
        this.loading = true;
        this.genesisHistories = [];
        this.filteredDates = [];
        this.loadError = false;
        this.profileAmt = 0;
        try {
            const apiName = 'academicHistoryApi';
            const res = await restGet({ api: apiName, resource: (`/histories/${this.contactMitId}`) });
            this.genesisHistories = JSON.parse(res);
            this.yearOptions = [...this.yearOptions, ...dropdownListGenerator(this.genesisHistories, ACAD_HIST_KEYS.yearDesc)];
            this.registrationTypeOptions = [...this.registrationTypeOptions, ...dropdownListGenerator(this.genesisHistories, ACAD_HIST_KEYS.registrationTypeDesc)];
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
        const cloneData = [...this.filteredDates];

        cloneData.sort(sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) => asStringIgnoreCase(x)));
        this.filteredDates = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    get contactsUrl() {
        return window.location.origin + '/lightning/n/MIT_People_Search/'
    }

    resetColumnWidth() {
        this.template.querySelector('lightning-datatable').columns = columns;
    }

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

    //input field on change handlers
    handleYearSelectionChange({ detail: { value } }) {
        this.yearFilter = value;
    }
    handleTermCodeChange({ detail: { value } }) {
        this.termCodeFilter = value;
    }
    handleHomeDepartmentChange({ detail: { value } }) {
        this.homeDepartmentFilter = value;
    }
    handleUropFlagSelectionChange({ detail: { value } }) {
        this.uropFlagFilter = value;
    }
    handleRegistrationTypeSelectionChange({ detail: { value } }) {
        this.registrationTypeFilter = value;
    }

    applyFilters() {
        //reset the dates to initial state for proper filtering
        this.filteredDates = this.genesisHistories;
        this.profileAmt = this.filteredDates.length;
        this.filterByArray = [];
        this.filteredByText = '';
        this.showFilterTextSeperator = false;

        //if checks to see if the filter is empty, if it is, then it will not filter
        if (this.yearFilter !== 'All') {
            this.filterByArray.push('Year');
            this.filteredDates = filterArrayWithUserText(this.yearFilter, this.filteredDates, ACAD_HIST_KEYS.yearDesc);
        }
        if (this.termCodeFilter.length > 0) {
            this.filterByArray.push('Term Code');
            this.filteredDates = filterArrayWithUserText(this.termCodeFilter, this.filteredDates, ACAD_HIST_KEYS.termCode);
        }
        if (this.homeDepartmentFilter.length > 0) {
            this.filterByArray.push('Home Department');
            this.filteredDates = filterArrayWithUserText(this.homeDepartmentFilter, this.filteredDates, ACAD_HIST_KEYS.homeDeptDesc);
        }
        //Salesforce boolean and null input selections are saved as a string, JSON.parse the value first before passing it through
        if (JSON.parse(this.uropFlagFilter) !== null) {
            this.filterByArray.push('UROP Flag');
            this.filteredDates = filterArrayByUserBoolean(JSON.parse(this.uropFlagFilter), this.filteredDates, ACAD_HIST_KEYS.uropFlag);
        }
        if (this.registrationTypeFilter !== 'All') {
            this.filterByArray.push('Registration Type');
            this.filteredDates = filterArrayWithUserText(this.registrationTypeFilter, this.filteredDates, ACAD_HIST_KEYS.registrationTypeDesc);
        }

        this.filteredByText = generateCommaSeparatedString(this.filterByArray);
        this.profileAmt = this.filteredDates.length;
        this.filterByArray.length > 0 ? this.showFilterTextSeperator = true : this.showFilterTextSeperator = false;
    }

    resetFilters() {
        this.filteredDates = this.genesisHistories;
        this.profileAmt = this.filteredDates.length;
        this.yearFilter = 'All';
        this.termCodeFilter = '';
        this.homeDepartmentFilter = '';
        this.uropFlagFilter = 'null';
        this.registrationTypeFilter = 'All';
        this.filterByArray = [];
        this.filteredByText = '';
        this.showFilterTextSeperator = false;
    }
}