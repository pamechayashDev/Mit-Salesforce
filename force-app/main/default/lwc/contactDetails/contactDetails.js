import { LightningElement, api, wire } from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { updateRecord } from 'lightning/uiRecordApi'
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import {
    determineActiveStatus,
    getBirthdate,
    getFormattedBirthdate,
    peopleSearch,
    peopleSearchWithSource,
    ACCOUNT_FIELDS,
    forresterOrganizationSearch
} from 'c/utils'

import updateContactDoB from '@salesforce/apex/UpdateRecordHelper.updateContactDoB'

// Contact Fields
import ACCOUNT_OBJECT from '@salesforce/schema/Account'

const WAIT_TIME = 250

export default class ContactDetails extends LightningElement {
    @api recordId
    @api objectApiName
    @api mitIdField
    @api label

    loading = true
    open = true
    openInventorSection = true
    contactEdit = false
    birthday = ''
    peopleData = {};
    recordData = {
        fields: {
            CountryOfCitizenship__pc: {
                displayValue: null,
                value: null
            },
            FirstName: {
                displayValue: null,
                value: null
            },
            Government_Agency_Name__pc: {
                displayValue: null,
                value: null
            },
            GovernmentEmployeeStatus__pc: {
                displayValue: null,
                value: null
            },
            HHMI_Current__pc: {
                displayValue: null,
                value: null
            },
            HHMI_Current_Date_From__pc: {
                displayValue: null,
                value: null
            },
            Institution__pc: {
                displayValue: null,
                value: null
            },
            LastName: {
                displayValue: null,
                value: null
            },
            MiddleName: {
                displayValue: null,
                value: null
            },
            Name: {
                displayValue: null,
                value: null
            },
            PersonBirthdate: {
                displayValue: null,
                value: null
            },
            PreferredName__pc: {
                displayValue: null,
                value: null
            },
            VaAppointment__pc: {
                displayValue: null,
                value: null
            },
            VaAppointmentDetails__pc: {
                displayValue: null,
                value: null
            }
        }
    }

    // Parameters for Institution search
    editInstitution = false
    updateableInstitution = false
    searchTimer
    contactInstitution
    contactInstitutionCode
    institutionResults = null
    selectedInstitutionResult = null
    contactFields = []

    get canEditInstitution() {
        return this.editInstitution && this.updateableInstitution
    }
    // Contact Fields
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    async handleGetRecord({ error, data }) {
        if (data && !this.contactEdit) {
            this.recordData = data

            // Update DoB from People Search
            await this.updateDoB()
            await this.getPeopleDataWithSource();

            this.contactInstitution =
                this.recordData.fields.Institution__pc?.value
            this.contactInstitutionCode =
                this.recordData.fields.InstitutionCode__pc?.value
            this.selectedInstitutionResult = {
                name: this.contactInstitution,
                id: this.contactInstitutionCode
            }

            if (this.birthday === '') {
                this.birthday = data.fields.PersonBirthdate?.value
            }

            // Only allow editing of Institution for Inactive Moira Status
            this.editInstitution =
                determineActiveStatus(
                    this.recordData.fields.MoiraStatus__pc?.value
                ) === 'Inactive'

            this.loading = false
        }
        if (error) {
            console.error(error)
        }
    }

    // TLO Contact Fields
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.contactFields = data.fields
            console.log(this.contactFields)
            this.updateableInstitution = this.contactFields.Institution__pc?.updateable === true
            console.log(`updateableInstitution: ${this.updateableInstitution}`)
            this.fields = this.getPrefixedPropertyNames(data.fields, 'Account.')
            console.log(this.fields)
        } else if (error) {
            this.errors.push(error)
        }
    }

    getPrefixedPropertyNames(obj, prefix) {
        // Get the property names of the object
        const propertyNames = Object.keys(obj)

        // Prefix each property name and return the new array
        return propertyNames.map((propertyName) => prefix + propertyName)
    }

    async getPeopleDataWithSource() {
        if (this.recordData?.id && this.recordData?.fields?.MitId__pc?.value) {
            let { searchResults, error } =await peopleSearchWithSource(
                this.recordData.fields.MitId__pc.value
            )

            if (searchResults && searchResults.length > 0) {
                this.peopleData = searchResults[0];
            }

            if (error) {
                console.error(error)
            }
        } else {
            // Contact doesn't have an MIT Id, use Salesforce data 
            this.peopleData.name = this.recordData?.fields.Name?.value;
            this.peopleData.legalFirstName = this.recordData?.fields.FirstName?.value;
            this.peopleData.legalMiddleName = this.recordData?.fields.MiddleName?.value;
            this.peopleData.legalLastName = this.recordData?.fields.LastName?.value;
            this.peopleData.preferredName = this.recordData?.fields.PreferredName__pc?.value;
            this.peopleData.dateOfBirthValue = this.recordData?.fields.PersonBirthdate?.value;
        }
    }

    async updateDoB() {
        if (this.recordData?.id && this.recordData?.fields?.MitId__pc?.value) {
            let { searchResults, error } = await peopleSearch(
                this.recordData.fields.MitId__pc.value
            )

            if (searchResults && searchResults.length > 0) {
                try {
                    const dob = getBirthdate(
                        searchResults[0].dobMonth,
                        searchResults[0].dobDay
                    )

                    updateContactDoB({
                        id: this.recordData.id,
                        dateOfBirth: dob
                    })
                    this.birthday = dob?.substring(0, 10) // discard time info
                } catch (e) {
                    console.error(e)
                }
            }

            if (error) {
                console.error(error)
            }
        }
    }

    get formattedDateOfBirth() {
        return getFormattedBirthdate(
            this.recordData.fields.PersonBirthdate?.value
        )
    }

    handleEditInstitution() {
        this.contactEdit = true
    }

    debounce(fn, wait) {
        clearTimeout(this.searchTimer)
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimer = setTimeout(fn, wait)
    }

    handleSearchInstitution(event) {
        this.debounce(async () => {
            await this.searchInstitution(event)
        }, WAIT_TIME)
    }

    handleBlurInstitution(event) {
        console.log(JSON.stringify(event))
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.clearInstitutionSearchResults()
        }, WAIT_TIME)
    }

    /**
     * Institution search
     * @param {*} event Institution search field change event
     */
    async searchInstitution(event) {
        const input = event.detail.value.toLowerCase()
        const response = await forresterOrganizationSearch(input)
        console.log('🏛 Organizations', response)
        if (response.results) {
            this.institutionResults = response.results
        }
    }

    /**
     * Select an institution
     * @param {*} event Institution combobox option selection
     */
    selectInstitution(event) {
        const selectedValue = event.currentTarget.dataset.value
        this.selectedInstitutionResult = this.institutionResults.find(
            (picklistOption) => picklistOption.id === selectedValue
        )
        this.contactInstitution = this.selectedInstitutionResult.name
        this.contactInstitutionCode = this.selectedInstitutionResult.id

        // Reset the search results
        this.clearInstitutionSearchResults()
    }

    clearInstitutionSearchResults() {
        this.institutionResults = null
    }

    showInstitutionList() {
        if (!this.institutionResults) {
            forresterOrganizationSearch(null)
        }
    }

    get selectedInstitution() {
        return this.selectedInstitutionResult
            ? this.selectedInstitutionResult.name
            : null
    }

    /**
     * ⚙️ Section and Form functions
     */

    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section'
    }

    get inventorSectionClass() {
        return this.openInventorSection ? 'slds-section slds-is-open' : 'slds-section'
    }

    handleSectionClick() {
        this.open = !this.open
    }

    handleInventorSectionClick(){
        this.openInventorSection = !this.openInventorSection
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        )
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset()
            })
        }
        this.clearInstitutionSearchResults()
        this.contactEdit = false
    }

    /**
     * Handle Contact form submission
     * @param {*} event Contact form submit event
     */
    handleContactSubmit(event) {
        event.preventDefault()
        // Check Institution validity
        if (
            this.template
                .querySelector('lightning-input[data-form-input="institution"]')
                .reportValidity()
        ) {
            const fields = event.detail.fields
            fields.Institution__pc = this.contactInstitution
            fields.InstitutionCode__pc = this.contactInstitutionCode
            console.log('📄 Contact Submit', JSON.stringify(event.detail))
            this.template
                .querySelector(
                    'lightning-record-edit-form[data-form="contactForm"]'
                )
                .submit(fields)
        }
    }

    async handleContactSuccess(event) {
        const payload = event.detail
        console.log('✅ Contact Updated', JSON.stringify(payload))

        // Reset the Edit Form fields
        this.handleReset()

        // Update the record to refresh the View Form
        await updateRecord({ fields: { Id: this.recordId } })
    }
}