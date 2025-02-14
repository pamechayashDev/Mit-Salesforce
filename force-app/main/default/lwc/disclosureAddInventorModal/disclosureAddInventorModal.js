import { api, wire, track } from 'lwc'
import LightningModal from 'lightning/modal'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import { createRecord, getRecord } from 'lightning/uiRecordApi'
import {
    jitGetCreateContact,
    peopleSearch,
    reduceErrors,
    CONTACT_SEARCH_COLUMNS,
    createContactManual,
    updateContactManual,
    sortBy,
    determineActiveStatus,
    getFormattedBirthdate,
    forresterOrganizationSearch
} from 'c/utils'
import restGet from '@salesforce/apex/AwsApiCall.restGet'
import restPost from '@salesforce/apex/AwsApiCall.restPost'
import getContactByMitId from '@salesforce/apex/DisclosureRecordFetch.getContactByMitId'
import logLwcError from '@salesforce/apex/LogUtil.logLwcError'
import sandboxEmailValidation from '@salesforce/apex/GuestAccount.sandboxEmailValidation'

// Contact Fields
import ACCOUNT_OBJECT from '@salesforce/schema/Account'
import DISCLOSURE_INVENTOR_OBJECT from '@salesforce/schema/DisclosureInventor__c'

const WAIT_TIME = 750

export default class DisclosureAddInventorModal extends LightningModal {
    @api recordId

    createDisabled = false

    errors = []
    errorMessage = 'Error creating Inventor'

    // Parameters for search
    loading = false
    haveSearched = false
    searchQuery = ''
    searchColumns = CONTACT_SEARCH_COLUMNS
    searchResults
    searchError
    searchTimer
    defaultSortDirection = 'asc'
    sortDirection = 'asc'
    sortedBy
    minCharacterLength = 3

    // Parameters for Institution search
    @track institutionResults = []
    @track selectedInstitutionResult = undefined
    isSelectingInstitution = false
    // @track shouldShowResults = false

    // Parameters for creating new Contact
    selectedRow = null
    contactFields = []
    discInventorFields = []
    contactId
    contactInstitution
    contactInstitutionCode
    contactFirstName = ''
    contactLastName = ''
    contactMiddleName = ''
    guestAccountNeeded = 'Yes'

    // Parameters for updating Contact
    @track isEditingContact = false
    @track editingContact = null
    @track formConfiguration = null
    existingContact = null
    peopleSearchContact = null
    validEmail = false
    editContactResetState = null

    // Parameters for creating new Inventor
    inventorId = null

    /**
     * Current page:
     * 1: Search Page
     * 2: Update Contact Page
     * 3: New Contact Page
     * 4: Add Inventor Page
     */
    page = 1

    // Disclosure Fields
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            'Disclosure__c.Id',
            'Disclosure__c.Name',
            'Disclosure__c.Name__c'
        ]
    })
    disclosure

    // TLO Contact Fields
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.contactFields = data.fields
        } else if (error) {
            this.errors.push(error)
        }
    }

    // Disclosure Inventor Fields
    @wire(getObjectInfo, { objectApiName: DISCLOSURE_INVENTOR_OBJECT })
    discInventorInfo({ data, error }) {
        if (data) {
            this.discInventorFields = data.fields
        } else if (error) {
            this.errors.push(error)
        }
    }

    page2Rendered = false
    renderedCallback() {
        // Page 2: Initial load
        // =================================================
        if (this.page !== 2 && !this.page2Rendered) {
            return
        }
        // Only run validation if form opened in edit mode
        if (this.isEditingContact) {
            const updateContactForm = this.template.querySelector(
                'div[data-id="updateContact"]'
            )
            this.validateForm(updateContactForm)
        }

        this.page2Rendered = true
        // =================================================
    }

    /**
     * Getters for page navigation
     */
    get isSearch() {
        return this.page === 1
    }

    get isUpdateContact() {
        return this.page === 2
    }

    get isNewContact() {
        return this.page === 3
    }

    get isNewInventor() {
        // upsertContact()
        return this.page === 4
    }

    /**
     * Getters for labels
     */
    get header() {
        switch (this.page) {
            case 1:
                return 'Search Contact'
            case 2:
                if (this.isEditingContact) {
                    return 'Updating ' + this.contactName
                }
                return this.contactName
            case 3:
                return 'New Contact'
            case 4:
                return 'Add ' + this.contactName + ' As Inventor'
            default:
                return ''
        }
    }

    onContactFirstNameChange(event) {
        this.contactFirstName = event.detail.value
    }

    onContactMiddleNameChange(event) {
        this.contactMiddleName = event.detail.value
    }

    onContactLastNameChange(event) {
        this.contactLastName = event.detail.value
    }

    get contactName() {
        let names = [
            this.contactFirstName,
            this.contactMiddleName,
            this.contactLastName
        ]
        if (this.editingContact) {
            names = [
                this.editingContact.FirstName,
                this.editingContact.MiddleName,
                this.editingContact.LastName
            ]
        }
        return names
            .filter(function (el) {
                return el
            })
            .join(' ')
    }

    get disablePrimaryContactChk() {
        let hasActiveKerb =
            determineActiveStatus(this.editingContact?.MoiraStatus__pc) ===
            'Active'
        return !hasActiveKerb ? true : false
    }

    get contactEdit() {
        return !this.contactId
    }

    get showErrors() {
        return this.errors.length > 0
    }

    /**
     * Getters for update contact
     */

    get isFormReadOnly() {
        return !this.isEditingContact
    }

    get formattedDateOfBirth() {
        const DateOfBirth = getFormattedBirthdate(
            this.editingContact.PersonBirthdate
        )
        return DateOfBirth
    }

    /**
     * Getters for institution search
     */

    get selectedInstitution() {
        const institution = this.selectedInstitutionResult
            ? this.selectedInstitutionResult.name
            : null
        return institution
    }

    get hasInstitutionResults() {
        return !!this.institutionResults.length
    }

    /**
     * 📍 Nav Functions
     */

    navUpdateContact() {
        this.page = 2
        this.size = 'small'
    }

    navNewContact() {
        this.page = 3
        this.size = 'small'
    }

    /**
     * Create Contact from row selection
     */
    async navAddInventor() {
        if (!this.selectedRow) {
            document.body.dispatchEvent(
                new ShowToastEvent({
                    title: 'Selection Error',
                    message: 'Please select a Contact first',
                    variant: 'error'
                })
            )
        } else {
            this.loading = true

            // Get Contact
            this.contact = await getContactByMitId({
                mitId: this.selectedRow.mitId
            })

            try {
                // Format people search contact to tlo contact
                this.peopleSearchContact = await this.formatPeopleSearchContact(
                    this.selectedRow
                )
                console.log(
                    'Formatted people search contact',
                    this.peopleSearchContact
                )

                if (this.contact) {
                    console.log('Existing TLO contact found', this.contact)
                    this.contactId = this.contact.Id
                    // TLO contact property values take preference
                    // Except GuestAccountNeeded__pc, it will be determined by lookup
                    this.editingContact = this.updateContact(
                        this.peopleSearchContact,
                        this.contact,
                        [
                            'AltEmail__pc',
                            'AlumniEmail__pc',
                            'FirstName',
                            'Institution__pc',
                            'InstitutionCode__pc',
                            'IsAlumni__pc',
                            'KerbName__pc',
                            'LastName',
                            'MiddleName',
                            'MitId__pc',
                            'MoiraStatus__pc',
                            'Name',
                            'PersonDepartment',
                            'PersonEmail',
                            'PersonMobilePhone',
                            'PersonOtherPhone',
                            'PreferredName__pc'
                        ]
                    )
                } else {
                    this.editingContact = this.peopleSearchContact
                }
                console.log(
                    '🧍✏️ source contact',
                    JSON.parse(JSON.stringify(this.editingContact))
                )

                // Determine if contact has all required fields
                if (!this.isContactComplete(this.editingContact)) {
                    // Take snapshot of state of contact. Reset to this state.
                    this.editContactResetState = { ...this.editingContact }
                    // If contact is incomplete open in edit mode
                    this.toggleEditMode(true)
                } else {
                    // If contact is complete open in read only mode
                    this.toggleEditMode(false)
                }

                this.loading = false
                this.navUpdateContact()
            } catch (error) {
                document.body.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Creating Inventor',
                        message: error?.message,
                        variant: 'error'
                    })
                )
                this.loading = false
            }
        }
    }

    /**
     * Update tlo contact from source
     * @param {Object} target Contact object to be updated
     * @param {Object} source Contact object to update from
     * @param {List} fieldList Optional List of fields
     * @returns {Object} Updated object
     */
    updateContact(target, source, fieldList) {
        // Create a new object to prevent mutation of the original object
        const merged = { ...target }

        Object.keys(source).forEach((key) => {
            // Check if fieldList is provided and if it includes the current key
            const shouldUpdate =
                !fieldList || (fieldList && fieldList.includes(key))

            // Only overwrite properties if the source property has a value and should be updated
            if (
                shouldUpdate &&
                source[key] !== null &&
                source[key] !== undefined &&
                source[key] !== ''
            ) {
                merged[key] = source[key]
            }
        })

        return merged
    }

    /**
     * Update people search contact to tlo contact schema
     * @param {Object} sourceObject Source object to extract properties from (people search row)
     * @returns {Object} TLO contact schema object
     */
    async formatPeopleSearchContact(sourceObject) {
        const dob =
            sourceObject.dobMonth && sourceObject.dobDay
                ? `2000-${sourceObject.dobMonth}-${sourceObject.dobDay}`
                : null

        // Lookup guest account status
        const guestAccountNeeded = await this.checkGuestAccountNeeded(
            sourceObject
        )
        if (guestAccountNeeded instanceof Error) {
            // Throw error if lookup produced an error
            throw guestAccountNeeded
        }

        // Map people search contact to contact schema
        const contact = {
            AltEmail__pc:
                sourceObject.nonMitEmail === sourceObject.email
                    ? null
                    : sourceObject.nonMitEmail,
            AlumniEmail__pc: sourceObject.alumniEmail,
            PersonBirthdate: dob,
            PersonDepartment: sourceObject.dlcName,
            PersonEmail: sourceObject.email,
            GuestAccountNeeded__pc: guestAccountNeeded,
            Institution__pc: undefined,
            InstitutionCode__pc: undefined,
            IsAlumni__pc: sourceObject.alumni,
            KerbName__pc: sourceObject.krbName,
            FirstName: sourceObject.legalFirstName,
            LastName: sourceObject.legalLastName,
            MiddleName: sourceObject.legalMiddleName,
            MitId__pc: sourceObject.mitId,
            MoiraStatus__pc: sourceObject.moiraStatus,
            Name: sourceObject.name,
            PersonMobilePhone: sourceObject.phone,
            PreferredName__pc: sourceObject.preferredName
        }

        // Search for institution
        if (!contact?.Institution__pc && sourceObject.institution) {
            const { Institution__pc, InstitutionCode__pc } = await this.lookupInstitutionCode(sourceObject.institution)
            contact.Institution__pc = Institution__pc
            contact.InstitutionCode__pc = InstitutionCode__pc
        }

        return contact
    }

    async checkGuestAccountNeeded(sourceObject) {
        // Lookup guest account status
        try {
            //Only lookup guest account status for inActive and Non Alumni People
            if (
                sourceObject.kerbStatus === 'Active' ||
                sourceObject.alumni === true
            ) {
                return 'No'
            }

            const guestAccountStatus = await this.getAccountStatus(
                sourceObject.mitId
            )
            console.log('guestAccountStatus', guestAccountStatus)

            switch (guestAccountStatus) {
                case 'NOTFOUND':
                    return 'Yes'
                case 'INVITED':
                case 'ACTIVE':
                    return 'No'
                case 'DISABLED':
                    console.error(
                        `Email ${sourceObject.email} was marked as 'Disabled' and the Guest User would not be able to Activate their account.`
                    )
                    logLwcError({
                        exceptionDetails: `MIT ID ${sourceObject.mitId}, Email ${sourceObject.email} was marked as 'Disabled' and the Guest User would not be able to Activate their account.`
                    })
                    return 'No'
                case 'FAILED':
                    console.error(
                        `Guest account lookup failed for MIT ID ${sourceObject.mitId}`
                    )
                    throw new Error(
                        `Guest account lookup failed for MIT ID ${sourceObject.mitId}`
                    )
                case 'EMPTY':
                    console.error(
                        `Guest account lookup failed for MIT ID ${sourceObject.mitId}, response was empty`
                    )
                    throw new Error(
                        `Guest account lookup failed for MIT ID ${sourceObject.mitId}`
                    )
                case 'MULTIPLE':
                    console.error(
                        `Guest account lookup found multiple accounts for MIT ID ${sourceObject.mitId}`
                    )
                    logLwcError({
                        exceptionDetails: `Guest account lookup found multiple accounts for MIT ID ${sourceObject.mitId}`
                    })
                    return 'No'
                case undefined:
                    return sourceObject.kerbStatus === 'Active' || sourceObject.alumni === true ? 'No' : 'Yes'
                default:
                    console.error(
                        `Guest account lookup for MIT ID ${sourceObject.mitId} status unknown: ${guestAccountStatus}`
                    )
                    logLwcError({
                        exceptionDetails: `Guest account lookup for MIT ID ${sourceObject.mitId} status unknown: ${guestAccountStatus}`
                    })
                    return 'No'
            }
        } catch (error) {
            logLwcError({ exceptionDetails: error.message })
            return error
        }
    }

    async lookupInstitutionCode(institution) {
        const response = await forresterOrganizationSearch(institution)
        if (response?.results?.length === 1) {
            return {
                InstitutionCode__pc: response.results[0].id,
                Institution__pc: institution
            }
        }
        console.error('Could not lookup institution code.')
        // If lookup fails just set institution, leave code undefined
        return {
            InstitutionCode__pc: undefined,
            Institution__pc: institution
        }
    }

    /**
     * Checks if contact has all required fields
     * @param {Object} contact Contact to check required fields
     * @returns {Boolean} Passed or failed complete check
     */
    isContactComplete(contact) {
        let hasActiveKerb =
            determineActiveStatus(contact.MoiraStatus__pc) === 'Active'

        let isAlumni = contact.IsAlumni__pc ? contact.IsAlumni__pc : false
        let isComplete = true

        // Check if contact has all required fields
        if (hasActiveKerb) {
            isComplete = true
        } else if (!hasActiveKerb && !isAlumni) {
            isComplete =
                !!contact.PersonEmail &&
                !!contact.Institution__pc &&
                !contact.PersonEmail?.endsWith('mit.edu') &&
                !contact.AltEmail__pc?.endsWith('mit.edu')
        } else if (!hasActiveKerb && isAlumni) {
            isComplete = !!contact.Institution__pc
        }

        return isComplete
    }

    /**
     * Pre-configure update form fields requirements
     */
    setFormConfiguration() {
        let hasActiveKerb =
            determineActiveStatus(this.editingContact.MoiraStatus__pc) ===
            'Active'
        let isAlumni = this.editingContact.IsAlumni__pc
            ? this.editingContact.IsAlumni__pc
            : false

        this.formConfiguration = {
            // Non-editable field
            FirstName: {
                disabled: this.isEditingContact,
                showEditIcon: false,
                required: false
            },
            // Non-editable field
            MiddleName: {
                disabled: this.isEditingContact,
                showEditIcon: false,
                required: false
            },
            // Non-editable field
            LastName: {
                disabled: this.isEditingContact,
                showEditIcon: false,
                required: false
            },
            // Non-editable field
            PreferredName__pc: {
                disabled: this.isEditingContact,
                showEditIcon: false,
                required: false
            },
            // Optionally editable field
            PersonEmail: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : false,
                required: false
            },
            // Optionally editable field
            AltEmail__pc: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : false,
                required: false
            },
            // Optionally editable field
            PersonMobilePhone: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : true,
                required: false
            },
            // Optionally editable field
            PersonOtherPhone: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : true,
                required: false
            },
            // Optionally editable field
            Institution__pc: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : false,
                required: false
            },
            // Optionally editable field
            InstitutionCode__pc: {
                disabled: true,
                showEditIcon: false,
                required: false
            },
            // Optionally editable field
            PersonBirthdate: {
                disabled: this.isEditingContact,
                showEditIcon: this.isEditingContact ? false : false,
                required: false
            },
            // Non-editable field
            Name: {
                disabled: this.isEditingContact,
                showEditIcon: false,
                required: false
            }
        }

        // Set disabled and required fields
        // This allows single form to function as edit/view
        if (hasActiveKerb) {
            // PersonMobilePhone
            this.formConfiguration.PersonMobilePhone.disabled = false

            // PersonOtherPhone
            this.formConfiguration.PersonOtherPhone.disabled = false
        } else if (!hasActiveKerb && !isAlumni) {
            // PersonEmail
            this.formConfiguration.PersonEmail.disabled = false
            this.formConfiguration.PersonEmail.showEditIcon = this.isEditingContact ? false : true
            this.formConfiguration.PersonEmail.required = true
            this.formConfiguration.PersonEmail.customValidation = {
                validate: (value) => value.endsWith('mit.edu'),
                message: 'Guest email address cannot end in mit.edu'
            }

            // AltEmail__pc
            this.formConfiguration.AltEmail__pc.disabled = false
            this.formConfiguration.AltEmail__pc.showEditIcon = this.isEditingContact ? false : true
            this.formConfiguration.AltEmail__pc.customValidation = {
                validate: (value) => value.endsWith('mit.edu'),
                message: 'Guest email address cannot end in mit.edu'
            }

            // Phone
            this.formConfiguration.PersonMobilePhone.disabled = false

            // PersonOtherPhone
            this.formConfiguration.PersonOtherPhone.disabled = false

            // Institution__pc
            this.formConfiguration.Institution__pc.disabled = false
            this.formConfiguration.Institution__pc.required = true
            this.formConfiguration.Institution__pc.showEditIcon = this.isEditingContact ? false : true
        } else if (!hasActiveKerb && isAlumni) {
            // Phone
            this.formConfiguration.PersonMobilePhone.disabled = false

            // PersonOtherPhone
            this.formConfiguration.PersonOtherPhone.disabled = false

            // Institution__pc
            this.formConfiguration.Institution__pc.disabled = false
            this.formConfiguration.Institution__pc.required = true
            this.formConfiguration.Institution__pc.showEditIcon = this.isEditingContact ? false : true
        }
    }

    /**
     * 🔍 Search Screen Functions
     */

    handleSearchPerson(event) {
        this.searchQuery = event.detail.value
        const inputField = event.target
        // Do not send request if characters not 3 or more
        if (this.searchQuery?.length >= this.minCharacterLength) {
            inputField.setCustomValidity('')
            inputField.reportValidity()
            this.debounce(async () => {
                await this.searchPerson(event)

                // Refocus search field after search
                const searchField = this.template.querySelector(
                    "lightning-input[data-field-id='searchPerson']"
                )
                if (searchField) searchField.focus()
            }, WAIT_TIME)
        } else {
            // show field validation error
            if (inputField) {
                inputField.setCustomValidity(
                    `Please enter at least ${this.minCharacterLength} characters.`
                )
                inputField.reportValidity()
            }
        }
    }

    async searchPerson() {
        this.loading = true
        try {
            console.log('🔎 Searching for ' + this.searchQuery)
            let { searchResults, searchError } = await peopleSearch(
                this.searchQuery
            )
            console.log(searchResults)
            if (searchError) {
                console.error(searchError)
            }

            this.searchResults = searchResults
            this.searchError = searchError
        } catch (e) {
            this.searchError = e
        } finally {
            this.loading = false
            this.haveSearched = true
        }
    }

    handleSelectPerson(event) {
        this.selectedRow = event.detail.selectedRows[0]
        console.log('🚣‍♂️', this.selectedRow)
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail
        const cloneData = [...this.searchResults]

        cloneData.sort(sortBy(sortedBy, sortDirection === 'desc' ? 1 : -1))
        this.searchResults = cloneData
        this.sortDirection = sortDirection
        this.sortedBy = sortedBy
    }

    debounce(fn, wait) {
        clearTimeout(this.searchTimer)
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimer = setTimeout(fn, wait)
    }

    /**
     * 🧍✏️ Update Contact
     * ================================================================================
     *  Page: 2
     */

    /**
     * Form handlers
     */

    handleEditClick() {
        // Take snapshot of state of contact. Reset to this state.
        this.editContactResetState = { ...this.editingContact }
        // Toggle edit mode on
        this.toggleEditMode(true)

        // Run validation
        const updateContactForm = this.template.querySelector(
            'div[data-id="updateContact"]'
        )
        this.validateForm(updateContactForm)
    }

    handleInputChange(event) {
        // Update edit contact values
        const fieldName = event.currentTarget.name
        const fieldValue = event.detail.value
        this.editingContact[fieldName] = fieldValue
        // Clear custom validation if present
        if (event.currentTarget.validity.customError) {
            event.currentTarget.setCustomValidity('')
            event.currentTarget.reportValidity()
        }
    }

    handleCancelClick() {
        if (this.isEditingContact) {
            // Reset form unsaved changes
            this.editingContact = { ...this.editContactResetState }
            // Clear validation messages
            const updateContactForm = this.template.querySelector(
                'div[data-id="updateContact"]'
            )
            this.clearCustomValidity(updateContactForm)
            // Toggle edit mode off
            this.toggleEditMode(false, true)
        } else {
            this.close()
        }
    }

    /**
     * Update Contact Save Button Wrapper
     */
    async handleUpdateContactSave() {
        this.errors = []
        const updateContactForm = this.template.querySelector(
            'div[data-id="updateContact"]'
        )
        if (this.isEditingContact) {
            this.loading = true

            // Check email for duplicate
            await this.validateEmail(updateContactForm)

            // Validate form
            const hasPassedFormValidation = this.validateForm(updateContactForm)
            if (hasPassedFormValidation) {
                // Take snapshot of state of contact before save. Reset to this state.
                this.editContactResetState = { ...this.editingContact }
                // Toggle edit mode off
                this.toggleEditMode(false)
            }
            this.loading = false
        } else {
            // Check email for duplicate
            await this.validateEmail(updateContactForm)

            // Check if all required fields are completed
            if (
                this.isContactComplete(this.editingContact) &&
                this.validEmail
            ) {
                // Create TLO contact
                await this.handleUpdateContactSubmit(updateContactForm)
                // Only if submit produced no errors toggle edit mode off
                if (this.errors.length === 0) {
                    // Toggle edit mode off
                    this.toggleEditMode(false)
                    // Nav to add inventor
                    this.handleAddInventor(null)
                }
            } else {
                // Toggle edit mode on and validate form
                this.toggleEditMode(true)
                this.validateForm(updateContactForm)
            }
            this.loading = false
        }
    }

    /**
     * Trigger email forrester validation if email is valid and sets custom validation message
     * @param {*} form Form to get field from
     */
    async validateEmail(form) {
        const emailInput = this.getFieldFromForm(form, 'PersonEmail')
        if (emailInput.validity.valid) {
            // Validate email against forrester, guest account and set validity of field
            this.validEmail = await this.forresterAndGuestAccountEmailValidation(
                {
                    Name: this.editingContact?.Name,
                    PersonEmail: emailInput.value,
                    MitId__pc: this.editingContact?.MitId__pc,
                    GuestAccountNeeded__pc: this.editingContact?.GuestAccountNeeded__pc
                },
                emailInput
            )
        }
    }

    /**
     * Get specific field from form
     * @param {*} form Form to get field from
     * @param {String} fieldName Field name to return
     * @returns Form input field
     */
    getFieldFromForm(form, fieldName) {
        // Get all the input fields inside the form
        const inputs = [...form.querySelectorAll('lightning-input')]
        return inputs.filter((input) => input.name === fieldName)[0]
    }

    /**
     * Toggle form edit mode
     * @param {Boolean} isEditing Should the form toggle into edit mode
     * @param {Boolean} isCancel Is the form mode toggled by cancel
     */
    toggleEditMode(isEditing, isCancel = false) {
        // Update editing state
        this.isEditingContact = isEditing

        // Setting of institution as there are two separate input fields for edit/view mode
        if (isEditing === true) {
            this.shouldShowResults = false
            // Add contact institution value to search field
            if (this.editingContact.Institution__pc) {
                this.selectedInstitutionResult = {
                    name: this.editingContact.Institution__pc ?? ''
                }
            }
        }
        // If canceled don't carry over institution value
        if (isEditing === false) {
            if (isCancel) {
                this.selectedInstitutionResult = undefined
            } else {
                // Grab institution value from search and add to read only field
                if (this.selectedInstitution) {
                    this.editingContact.Institution__pc =
                        this.selectedInstitution
                }
            }
        }

        this.setFormConfiguration()
    }

    /**
     * Run validation on form
     * @param {*} form The form containing the input fields
     * @returns {Boolean} Form validation failed
     */
    validateForm(form) {
        // Get all the input fields inside the form
        const inputs = [...form.querySelectorAll('lightning-input')]

        // Check and report validity of form
        const formValidityResults = inputs.map((input) => {
            // Trigger input validation
            const inputValidity = input.checkValidity()
            // Trigger custom validation if field custom validation is set
            if (this.formConfiguration[input.name]?.customValidation) {
                // Custom validation
                const hasFailedValidation = this.formConfiguration[
                    input.name
                ].customValidation.validate(input.value)
                if (hasFailedValidation) {
                    input.setCustomValidity(
                        this.formConfiguration[input.name].customValidation
                            .message
                    )
                }
            }

            // Display validation message
            input.reportValidity()

            return inputValidity
        })
        const failedValidation = formValidityResults.some(
            (valid) => valid === false
        )
        return !failedValidation
    }

    /**
     * Clear custom validity message on form
     * @param {*} form The form containing the input fields
     */
    clearCustomValidity(form) {
        // Get all the input fields inside the form
        const inputs = [...form.querySelectorAll('lightning-input')]

        inputs.forEach((input) => {
            const isRequiredInput = input.required
            // Clear custom validity
            input.setCustomValidity('')
            // Clear built in validation
            // Toggle required of before checking validity
            if (isRequiredInput) input.required = false
            input.reportValidity()
            // Toggle required back after checking validity (Clears required message)
            if (isRequiredInput) input.required = true
        })
    }

    async handleUpdateContactSubmit(form) {
        let fieldValues = this.getUpdateContactFormFields(form)
        if (fieldValues) {
            let results = null
            // List of fields to save
            const fieldList = [
                'AltEmail__pc',
                'AlumniEmail__pc',
                'FirstName',
                'GuestAccountNeeded__pc',
                'Institution__pc',
                'InstitutionCode__pc',
                'IsAlumni__pc',
                'KerbName__pc',
                'LastName',
                'MiddleName',
                'MitId__pc',
                'MoiraStatus__pc',
                'PersonDepartment',
                'PersonEmail',
                'PersonMobilePhone',
                'PersonOtherPhone',
                'PreferredName__pc'
            ]

            // Updating contact with field values
            fieldValues = this.updateContact(
                this.editingContact,
                fieldValues,
                fieldList
            )
            // Account Name field cannot be created/updated (Concatenated field)
            delete fieldValues.Name

            const submittedContact = {
                fields: fieldValues
            }

            try {
                if (this.contactId) {
                    // Attach record id to fields (required for update)
                    submittedContact.fields.Id = this.contactId
                    // Update record
                    console.log(
                        '🧍✏️ updating contact',
                        JSON.parse(JSON.stringify(submittedContact))
                    )
                    results = await updateContactManual(submittedContact)
                } else {
                    // Attach api name to submitted contact (required for create)
                    submittedContact.apiName = 'Account'
                    // Create record
                    console.log(
                        '🧍✏️ creating contact',
                        JSON.parse(JSON.stringify(submittedContact))
                    )
                    results = await createContactManual(submittedContact)
                    const newContact = results.data
                    if (newContact) {
                        this.contactId = newContact.Id
                    }
                }

                // Check results for errors and map to field validation
                if (results?.error) {
                    throw results.error
                }
            } catch (error) {
                // Map errors to field validity
                const fieldErrors = results.error?.body?.output?.fieldErrors
                if (fieldErrors && Object.keys(fieldErrors).length) {
                    this.displayFieldErrors(fieldErrors)
                } else {
                    console.error(error)
                    this.errors.push(error)

                    let reducedError = reduceErrors(error)
                    console.log(reducedError)
                    this.errorMessage = 'Error Saving Record'
                    this.errors.push(reducedError)
                }
            } finally {
                this.loading = false
            }
        }
    }

    displayFieldErrors(fieldErrors) {
        // Toggle form into edit mode to display field level errors
        this.toggleEditMode(true)
        // Get form inputs
        const form = this.template.querySelector('div[data-id="updateContact"]')
        const inputs = [...form.querySelectorAll('lightning-input')]

        // Map field errors to field custom validity
        inputs.forEach((input) => {
            const inputFieldErrors = fieldErrors[input.name]
            if (inputFieldErrors !== undefined) {
                // Join messages into one string
                const message = fieldErrors[input.name]
                    .map((fieldError) => fieldError.message)
                    .join('\n')
                input.setCustomValidity(message)
                input.reportValidity()
            }
        })
    }

    /**
     * Collect input fields values
     * @param {*} form The form containing the input fields
     * @returns {Object} Field values object (contact object)
     */
    getUpdateContactFormFields(form) {
        // Get all the input fields inside the form
        const inputs = [...form.querySelectorAll('lightning-input')]
        // Create an object to hold the field values
        let fieldValues = {}

        // Loop through each input and collect the values
        inputs.forEach((input) => {
            let inputValue = input.value || null

            // Field value is formatted, save unformatted date
            if (input.name === 'PersonBirthdate') {
                inputValue = this.editingContact.PersonBirthdate || null
            }

            // Use the field's API name or another identifier as the key
            fieldValues[input.name] = inputValue
        })

        return fieldValues
    }

    /**
     * 👤 Contact Add
     * ================================================================================
     *  Page: 3
     */

    /**
     * Manually create a Contact
     * @param {*} row The row with the details for the Contact
     */
    async createContact(row) {
        // Create Record
        await jitGetCreateContact(row)
            .then(({ data, error }) => {
                if (data) {
                    this.contactId = data.Id
                    console.log(this.contactId)
                    this.navAddInventor()
                }
                if (error) {
                    console.error(error)
                    this.errors.push(error)

                    let reducedError = reduceErrors(error)
                    console.log(reducedError)
                    this.errorMessage = 'Error Creating Record'
                    this.errors.push(reducedError)
                }
            })
            .catch((error) => {
                console.error(error)
                this.errors.push(error)

                let reducedError = reduceErrors(error)
                console.log(reducedError)
                this.errorMessage = 'Error Creating Record'
                this.errors.push(reducedError)
            })
            .finally(() => {
                this.loading = false
            })
    }

    /**
     * Contact Save Button Wrapper
     */
    async handleContactSave() {
        // Clear custom validation error massages
        this.clearValidationErrors(['email'])
        if (this.contactEdit) {
            this.validateInputFields(['email', 'institution'])
            this.template
                .querySelector(
                    'lightning-button[data-formbutton="createTloContactSubmit"]'
                )
                .click()
        } else {
            await this.handleAddInventor()
        }
    }

    /**
     * Handle Contact form submission
     * @param {*} event Contact form submit event
     */
    async handleContactSubmit(event) {
        event.preventDefault()
        const hasInputValidationErrors = this.validateInputFields([
            'email',
            'institution'
        ])

        // Prevent submission, if input fields has validation errors
        if (!hasInputValidationErrors) {
            this.loading = true
            console.log('Contact Submit event', event)
            const fields = event.detail.fields

            // Validate email against forrester
            let emailInput = this.getValidationFields(['email'])[0]
            fields.PersonEmail = emailInput.value
            await this.forresterAndGuestAccountEmailValidation(fields, emailInput)

            // Prevent submission, If a duplicate forrester contact was found
            const hasForresterEmailValidationErrors = this.validateInputFields([
                'email'
            ])

            if (!hasForresterEmailValidationErrors) {
                // Account Name field cannot be created/updated (Concatenated field)
                delete fields.Name
                this.template
                    .querySelector(
                        'lightning-record-edit-form[data-form="createContactForm"]'
                    )
                    .submit(fields)
            }
            this.loading = false
        }
    }

    /**
     * Check validity of input fields.
     * @param {Array} fieldNamesToValidate List of data-formfield strings
     * @returns {Boolean} Validation passed
     */
    validateInputFields(fieldNames) {
        const inputValidationFields = this.getValidationFields(fieldNames)
        const inputValidatedFields = inputValidationFields.map((field) =>
            field.checkValidity()
        )
        const hasValidationErrors = inputValidatedFields.some(
            (fieldValidity) => fieldValidity === false
        )
        if (hasValidationErrors) {
            inputValidationFields.map((field) => field.reportValidity())
        }
        return hasValidationErrors
    }

    /**
     * Get input fields by data-formfield
     * @param {Array} fieldNamesToValidate List of data-formfield strings
     * @returns {Array} List of elements
     */
    getValidationFields(fieldNamesToValidate) {
        return fieldNamesToValidate.map((fieldName) =>
            this.template.querySelector(
                `lightning-input[data-formfield="${fieldName}"]`
            )
        )
    }

    /**
     * Clear custom validation errors
     * @param {Array} fieldNamesToClear List of data-formfield strings
     * @returns {Array} List of elements
     */
    clearValidationErrors(fieldNamesToClear) {
        fieldNamesToClear.forEach((fieldName) => {
            this.template
                .querySelector(`lightning-input[data-formfield="${fieldName}"]`)
                ?.setCustomValidity('')
            this.template
                .querySelector(`lightning-input[data-formfield="${fieldName}"]`)
                ?.reportValidity()
        })
    }

    proxyShowToast(title, variant, message) {
        const toast = this.template.querySelector('c-toast-message');
        toast.showToast({
            title : title,
            variant : variant,
            message : message
        });
    }
    showEmailToast(msg ,emailInput){
        console.log('showEmailToast', emailInput)
        if(emailInput?.attributes.disabled){
         this.proxyShowToast('Error saving', 'error', msg)
        }
    }
    /**
     * Handle Contact form email field validation
     * @param {*} event Contact form submit event
     */
    async forresterAndGuestAccountEmailValidation(fields, emailInput) {
        if (fields.GuestAccountNeeded__pc !== 'No') {
            const oktaCheckSandboxEmail =
                await this.sandboxCheckEmail(fields)
            if (oktaCheckSandboxEmail) {
                emailInput.setCustomValidity(oktaCheckSandboxEmail)
                this.showEmailToast(oktaCheckSandboxEmail, emailInput);
                return false
            }
        }

        const duplicateForresterContact =
            await this.forresterCheckDuplicateEmail(fields)

        if (duplicateForresterContact) {
            emailInput.setCustomValidity(duplicateForresterContact)
            this.showEmailToast(duplicateForresterContact, emailInput);
            return false
        }
        // Reset validation message
        emailInput.setCustomValidity('')

        return true
    }


    async sandboxCheckEmail(inventor) {
        const params = {
                email: inventor.PersonEmail
        }

        const validationResponse = await sandboxEmailValidation(params)

        if (!validationResponse.includes('Success')) {
            console.log(validationResponse)
            return validationResponse
        }
        return undefined
    }

    /**
     * Handle Contact form success
     * @param {*} event Contact form success event
     */
    async handleContactSuccess(event) {
        console.log('Contact Success', event)
        this.contactId = event.detail.id
        await this.handleAddInventor()
    }

    /**
     * 💡 Inventor Add
     * ================================================================================
     *  Page: 4
     */

    /**
     * Handle Inventor form submit
     * @param {*} event Inventor form submit event
     */
    async handleAddInventor(event) {
        try {
            console.log(event)

            // Remove all errors
            this.errors = []

            if (!this.contactId) {
                document.body.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Creating Record',
                        message: 'Please select a Contact first',
                        variant: 'error'
                    })
                )
                this.loading = false
            } else if (!this.recordId) {
                document.body.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Creating Record',
                        message: 'Error: cannot find Disclosure',
                        variant: 'error'
                    })
                )
                this.loading = false
            } else {
                // Retrieve all of the fields from inputs
                let submittedInventor = {
                    apiName: 'DisclosureInventor__c',
                    fields: {
                        Disclosure__c: this.recordId,
                        Contact__c: this.contactId,
                        PrimaryInventor__c: this.template.querySelector(
                            'lightning-input[data-formfield="primaryInventor"]'
                        ).checked,
                        MitAtTimeOfInvention__c: this.template.querySelector(
                            'lightning-input[data-formfield="mitAtTimeOfInvention"]'
                        ).checked,
                        Submitter_Marked_Inventor_As_HHMI__c:
                            this.template.querySelector(
                                'lightning-input[data-formfield="hhmiAtTimeOfInvention"'
                            ).checked
                    }
                }

                // Create Record
                await createRecord(submittedInventor)
                    .then((inventor) => {
                        this.inventorId = inventor.id
                        console.log(this.inventorId)
                        this.close('Success')
                    })
                    .catch((error) => {
                        console.error(error)
                        this.errorMessage = error.message ?? error.body.message
                        this.errors.push(reduceErrors(error))
                        this.loading = false
                    })
            }
        } catch (e) {
            console.log(e)
            this.errors.push(reduceErrors(e))
            this.loading = false
        } finally {
            if (!this.errors) {
                this.close()
            }
        }
    }

    /**
     * Duplicate contact validation
     */
    async forresterCheckDuplicateContact(inventor) {
        const apiName = 'forresterApi'
        const params = {
            api: apiName,
            resource: '/inventors/inventor/validate-duplicate',
            headers: {
                'Content-Type': 'application/json;charset=UTF-8'
            },
            body: JSON.stringify({
                inventorName: inventor.Name,
                email: inventor.PersonEmail,
                mitId: inventor?.mitId ?? inventor.MitId__pc
            })
        }

        return JSON.parse(await restPost(params))
    }

    /**
     * Account status lookup
     * @param {*} mitId mit id to lookup
     * @return {string} Account status
     */
    async getAccountStatus(mitId) {
        const apiName = 'guestAccountApi'
        const params = {
            api: apiName,
            resource: `/guest-accounts?mitid=${mitId}`
        }
        const response = JSON.parse(await restGet(params))
        console.log('Call to GuestAccount /guest-accounts response ', response)

        if (!response || response?.length === 0) {
            console.error(
                'Call to GuestAccount /guest-accounts failed, response is empty'
            )
            logLwcError({
                exceptionDetails: `Call to GuestAccount /guest-accounts failed, response is empty`
            })
            return 'EMPTY'
        }

        if (
            response?.message &&
            response?.message === 'Internal Server Error'
        ) {
            console.error('Request failed, Internal Server Error')
            logLwcError({
                exceptionDetails: `Request failed, Internal Server Error, response ${JSON.stringify(
                    response
                )}`
            })
            return 'FAILED'
        }

        if (response?.message && response?.message === 'Not Found') {
            console.log('Call to GuestAccount /guest-accounts, not found')
            return 'NOTFOUND'
        }

        if (response?.length > 1) {
            console.error(
                'Call to GuestAccount /guest-accounts response returned multiple accounts'
            )
            logLwcError({
                exceptionDetails: `Call to GuestAccount /guest-accounts response returned multiple accounts, response ${JSON.stringify(
                    response
                )}`
            })
            return 'MULTIPLE'
        }

        return response?.status
    }

    /**
     * Validate inventor email forrester
     * @param {*} inventor Inventor added
     */
    async forresterCheckDuplicateEmail(inventor) {
        const validationResponse = await this.forresterCheckDuplicateContact(
            inventor
        )
        if (!validationResponse.message.includes('Success')) {
            console.log('Forrester contact found with same email address')
            return validationResponse.message
        }
        return undefined
    }

    /**
     * Institution search
     * @param {*} event Institution search field change event
     */
    async searchInstitution(event) {
        console.log('searchInstitution')
        const input = event.detail.value

        // If input is blank, clear institution code field
        if (input === '') {
            this.contactInstitutionCode = null
        }

        // If re-selecting of same value, update selectedInstitutionResult
        if (this.selectedInstitutionResult) {
            this.selectedInstitutionResult = { name: event.detail.value }
        }

        const searchText = input.toLowerCase().trim()
        const response = await forresterOrganizationSearch(searchText)
        console.log('🏛 Organizations', response)
        if (response.results) {
            this.institutionResults = response.results
        }
    }

    async showInstitutionList(event) {
        const input = event.target?.value
        console.log(input)

        // Search for institution
        await this.searchInstitution({ detail: { value: input } })
    }

    hideInstitutionList() {
        console.log('hideInstitutionList')
        // Clear institution
        this.debounce(() => this.resetInstitutionSearch(), 200)
    }

    resetInstitutionSearch() {
        console.log('resetInstitutionSearch')
        // Hide search list
        this.institutionResults = []
        const input = this.template.querySelector(
            `lightning-input[data-formfield="institution"]`
        )
        const value = input?.value
        // Update contact
        if (
            value &&
            this.editingContact &&
            value !== this.editingContact.Institution__pc &&
            !this.isSelectingInstitution
        ) {
            // Reset institution
            this.selectedInstitutionResult = {
                name: this.editContactResetState.Institution__pc ?? '',
                id: this.editContactResetState.InstitutionCode__pc
            }
        }

        //New contact
        if (value && !this.editingContact) {
            // Validation not cleared when user selects a institution, manually check validation
            input.reportValidity()
        }

        this.isSelectingInstitution = false
    }

    /**
     * Select an institution
     * @param {*} event Institution combobox option selection
     */
    selectInstitution(event) {
        console.log('selectInstitution')
        this.isSelectingInstitution = true
        const selectedValue = event.currentTarget.dataset.value
        this.selectedInstitutionResult = this.institutionResults.find(
            (picklistOption) => picklistOption.id === selectedValue
        )
        this.contactInstitution = this.selectedInstitutionResult.name
        this.contactInstitutionCode = this.selectedInstitutionResult.id
        if (this.isEditingContact) {
            this.editingContact.Institution__pc =
                this.selectedInstitutionResult.name
            this.editingContact.InstitutionCode__pc =
                this.selectedInstitutionResult.id
        }
        this.clearInstitutionSearchResults()
    }

    clearInstitutionSearchResults() {
        this.institutionResults = []
    }

    /**
     * ⚠️ Error handling
     */

    /**
     * Form error handling
     * @param {*} event
     */
    handleFormError(event) {
        console.log(event)
        // Form handles the error via toast
        this.loading = false
    }

    /**
     * Handle error box closing
     */
    handleErrorClose() {
        this.errors = []
    }
}