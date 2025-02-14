import { LightningElement, track } from 'lwc'
import restGet from '@salesforce/apex/AwsApiCall.restGet'
import getSandboxJITEmail from '@salesforce/apex/GuestAccount.getSandboxJITEmail'
import { NavigationMixin } from 'lightning/navigation'

import globalStyles from '@salesforce/resourceUrl/globalStyles'
import { loadStyle } from 'lightning/platformResourceLoader'

import {
    asStringIgnoreCase,
    determineActiveStatus,
    determineAffiiation,
    getFullName,
    getBirthdate,
    getDisplayName,
    getEmail,
    getInstitution,
    jitGetCreateContact,
    reduceErrors,
    sortBy
} from 'c/utils'

const actions = [{ label: 'View', name: 'view' }]

const columns = [
    {
        label: 'Name',
        type: 'button',
        sortable: true,
        fieldName: 'name',
        typeAttributes: {
            label: { fieldName: 'name' },
            name: { fieldName: 'name' },
            alternativeText: { fieldName: 'name' },
            disabled: false,
            variant: 'base',
            action: actions
        },

        cellAttributes: {
            class: 'custom-button',
            alignment: 'left'
        }
    },
    {
        label: 'Email',
        fieldName: 'email',
        sortable: true,
        hideDefaultActions: true,
        type: 'text',
        initialWidth: 250
    },
    {
        label: 'Institution',
        fieldName: 'finalInstitution',
        sortable: true,
        wrapText: true,
        hideDefaultActions: true,
        type: 'text'
    },
    {
        label: 'Current Department',
        fieldName: 'dlcName',
        hideDefaultActions: true,
        type: 'text',
        sortable: true,
        cellAttributes: {
            class: 'text-capitalize'
        },
        initialWidth: 160
    },
    {
        label: 'Current Affiliation',
        fieldName: 'affiliation',
        hideDefaultActions: true,
        type: 'text',
        sortable: true,
        cellAttributes: {
            class: 'text-capitalize'
        },
        initialWidth: 160
    },
    {
        label: 'MIT ID',
        fieldName: 'mitId',
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 200
    },
    {
        label: 'Kerberos',
        fieldName: 'krbName',
        hideDefaultActions: true,
        sortable: true,
        type: 'text',
        initialWidth: 110
    },
    {
        label: 'Kerberos Status',
        fieldName: 'kerbStatus',
        hideDefaultActions: true,
        sortable: true,
        initialWidth: 150
    }
]

export default class DemographicDataSearch extends NavigationMixin(
    LightningElement
) {
    validationError = false
    errorMessage
    searchResults
    dataFound = false
    selectedPerson
    loading = false
    loadMoreLoading = false
    searchAmount = 0
    noResults = false
    firstSearch = true
    indexedData = []
    loadMoreStatus
    @track pagination = 0

    // data-table varaibles
    columns = columns
    defaultSortDirection = 'asc'
    sortDirection = 'asc'
    sortedBy = 'legalFirstName'
    @track isInfiniteScroll = false

    @track personSearchParam = ''

    setValue(event) {
        this.pagination = 0
        this.personSearchParam = event.detail.value
    }

    handleKeyUp(evt) {
        //checks if user pressed enter
        if (evt.keyCode === 13) {
            this.searchPerson()
        }
    }

    searchPerson(previousSearchResults) {
        this.dataFound = false
        this.searchResults = undefined
        this.template.querySelector('.data-table-container').style.display =
            'none'

        // replace multiple spaces with just one space
        this.personSearchParam = `${this.personSearchParam.replace(
            /[ ]{2,}/,
            ' '
        )}`

        //remove any wildcards from search string
        this.personSearchParam = this.personSearchParam.startsWith('*')
            ? this.personSearchParam.substring(1, this.personSearchParam.length)
            : this.personSearchParam
        this.personSearchParam = `${this.personSearchParam.replace('*', ' ')}`

        if (this.personSearchParam.length === 0) {
            this.validationError = true
            this.errorMessage = 'Please search for a person'
            this.dataFound = false
            this.loading = false
            return
        }
        if (this.personSearchParam.length < 3) {
            this.validationError = true
            this.errorMessage = 'Please enter at least 3 characters'
            this.dataFound = false
            this.loading = false
            return
        }

        this.validationError = false
        this.noResults = false
        this.errorMessage = ''
        this.loading = true

        try {
            const apiName = 'peopleSearchApi'
            restGet({
                api: apiName,
                resource: `/search?query=${encodeURIComponent(
                    this.personSearchParam
                )}&krbStatus=any&pageFrom=${encodeURIComponent(
                    this.pagination
                )}&pageSize=50&onlyResultsWithEmail=true`
            }).then((result) => {
                // Unauthorized or Forbidden error checks
                if (
                    result.includes('Forbidden') ||
                    result.includes('Unauthorized') ||
                    result.includes('status code 401')
                ) {
                    this.validationError = true
                    this.errorMessage =
                        'You are not authorized to access this resource'
                    this.dataFound = false
                    this.loading = false
                    return
                }
                if (result.includes('timed out')) {
                    this.validationError = true
                    this.errorMessage =
                        'The requested resource has timed out. Please try again'
                    this.dataFound = false
                    this.loading = false
                    return
                }

                if (result.includes('Internal server error')) {
                    this.validationError = true
                    this.errorMessage =
                        'Something went wrong. Please try again'
                    this.dataFound = false
                    this.loading = false
                    return
                }


                //check to see if there are no results
                if (JSON.parse(result).length < 1) {
                    this.noResults = true
                    this.template.querySelector(
                        '.data-table-container'
                    ).style.display = 'none'
                    this.dataFound = false
                    this.searchAmount = 0
                    this.loading = false
                    return
                }

                this.dataFound = true
                this.template.querySelector(
                    '.data-table-container'
                ).style.display = 'block'
                this.searchResults = JSON.parse(result)
                this.pagination =
                    this.searchResults.pagination?.nextPageFrom ?? 0
                this.searchResults = this.searchResults.people
                this.isInfiniteScroll =
                    !this.pagination || this.pagination === 500 ? false : true


                //loop through the data and replace the moira status with a text variant
                for (let i = 0; i < this.searchResults?.length; i++) {
                    //console.log('🧍searchResults', JSON.parse(JSON.stringify(this.searchResults[i])))
                    this.searchResults[i].kerbStatus = determineActiveStatus(
                        this.searchResults[i].moiraStatus
                    )
                    this.searchResults[i].email = getEmail(
                        this.searchResults[i].kerbStatus,
                        this.searchResults[i].mitPreferredEmail,
                        this.searchResults[i].mitEmail,
                        this.searchResults[i].alumni,
                        this.searchResults[i].alumniEmail,
                        this.searchResults[i].nonMitEmail
                    )
                    this.searchResults[i].name = getDisplayName(
                        this.searchResults[i].preferredName,
                        this.searchResults[i].legalFirstName,
                        this.searchResults[i].legalMiddleName,
                        this.searchResults[i].legalLastName
                    )
                    this.searchResults[i].fullName = getFullName(
                        this.searchResults[i].legalFirstName,
                        this.searchResults[i].legalMiddleName,
                        this.searchResults[i].legalLastName
                    )
                    this.searchResults[i].birthDate = getBirthdate(
                        this.searchResults[i].dobMonth,
                        this.searchResults[i].dobDay
                    )
                    this.searchResults[i].affiliation = determineAffiiation(
                        this.searchResults[i].affiliate,
                        this.searchResults[i].student,
                        this.searchResults[i].staff,
                        this.searchResults[i].alumni,
                        this.searchResults[i].guest
                    )
                    this.searchResults[i].finalInstitution = getInstitution(
                        this.searchResults[i].kerbStatus,
                        this.searchResults[i].institution
                    )
                }

                if (previousSearchResults?.length > 0) {
                    const newSearchResults = previousSearchResults.concat(
                        this.searchResults
                    )
                    this.searchResults = newSearchResults
                }

                // Sets search amount/items on data table
                this.searchAmount =
                    !this.pagination || this.pagination === 500
                        ? this.searchResults.length
                        : this.searchResults.length + '+'

                this.loading = false
                console.log(this.searchResults)
            })
        } catch (error) {
            this.validationError = true
            this.errorMessage =
                'Failed to search for a person, please try again. If this problem persits please contact your administrator'
            this.loading = false
        }
        this.firstSearch = false
    }

    loadMoreData() {
        if (this.isInfiniteScroll) {
            let currentSearchResults = this.searchResults
            this.searchPerson(currentSearchResults)
        }
    }

    enableWidthButton() {
        const button = this.template.querySelector(
            'lightning-menu-item.reset-column-width'
        )
        button.disabled = false
    }

    async navToContact(event) {
        this.loading = true
        try {
            const detailRow = JSON.parse(JSON.stringify(event.detail.row))
            const guestAccountNeeded = (detailRow.kerbStatus === 'Active' || detailRow.alumni === true) ? false : true
            if (guestAccountNeeded) {
                detailRow.email = await getSandboxJITEmail({email: event?.detail?.row?.email})
            }
            const response = await jitGetCreateContact(
                detailRow
            )
            const tloContact = response.data
            const error = response.error
            if (error) {
                throw error
            } else if (tloContact) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: tloContact.Id,
                        actionName: 'view'
                    }
                })
            }
        } catch (e) {
            this.validationError = true
            this.errorMessage = reduceErrors(e)[0]
        } finally {
            this.loading = false
        }
    }

    renderedCallback() {
        loadStyle(this, globalStyles)
        this.columnInfo = this.template.querySelector(
            'lightning-datatable'
        ).columns
    }

    resetColumnWidth() {
        this.template.querySelector('lightning-datatable').columns =
            this.columnInfo
    }

    refreshAll() {
        this.dataFound = false
        this.template.querySelector('lightning-datatable').columns =
            this.columnInfo
        this.searchAmount = 0
        this.template.querySelector('lightning-input').value = ''
        this.searchResults = []
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail
        const cloneData = [...this.searchResults]

        cloneData.sort(
            sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1, (x) =>
                asStringIgnoreCase(x)
            )
        )
        this.searchResults = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }
}