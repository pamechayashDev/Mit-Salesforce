import getBioTangByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getBioTangByDisclosureId'
import getCopyrightByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getCopyrightByDisclosureId'
import getInventionByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getInventionByDisclosureId'
import getSoftwareCodeByDisclosureId from '@salesforce/apex/DisclosureRecordFetch.getSoftwareCodeByDisclosureId'
import getUserInformationbyId from '@salesforce/apex/DisclosureRecordFetch.getUserInformationbyId'
import getContactByMitId from '@salesforce/apex/DisclosureRecordFetch.getContactByMitId'
import restGet from '@salesforce/apex/AwsApiCall.restGet'
import getPeopleDataWithSource from '@salesforce/apex/PeopleSearchApi.getPeopleDataWithSource'
import orgLocale from "@salesforce/i18n/locale";
import orgCurrencyCode from "@salesforce/i18n/currency";

import Disclosure_Documents_Header_PublicationsManuscripts from '@salesforce/label/c.Disclosure_Documents_Header_PublicationsManuscripts'
import Disclosure_Documents_Header_TechnicalDescription from '@salesforce/label/c.Disclosure_Documents_Header_TechnicalDescription'

import { createRecord, updateRecord } from 'lightning/uiRecordApi'
import LightningConfirm from 'lightning/confirm';


/**
 * Helper function to determine the sort primer for a given value type
 * Can add other types as needed, e.g. dates.
 * @param valueType The type of value to be sorted defined by the `SORT_BY_TYPE_ENUMS` enum
 * @param x The value to be sorted
 */
export function determineSortPrimer(valueType, x) {
    switch (valueType) {
        case SORT_BY_TYPE_ENUMS.STRING:
            return asString(x)
        case SORT_BY_TYPE_ENUMS.STRING_IGNORE_CASE:
            return asStringIgnoreCase(x)
        case SORT_BY_TYPE_ENUMS.NUMBER:
            return asNumber(x)
        default:
            return defaultPrimer(x)
    }
}

/**
 * Helper function to be used in conjunction with the `sortBy` function. Primes the input
 * to be treated as a string
 * @param {object} x input object to be turned into a string
 */
export function asString(x) {
    return x === undefined || x === null ? '' : x + ''
}

/**
 * Helper function to be used in conjunction with the `sortBy` function. Primes the input
 * to be treated as a number
 * @param {object} x input object to be turned into a number
 */
export function asNumber(x) {
    return x === undefined || x === null ? 0 : x
}

/**
 * Helper function to be used in conjunction with the `sortBy` function. Primes the input
 * to be treated as a string, ignoring case
 * @param {object} x input object to be turned into a string, ignoring case
 */
export function asStringIgnoreCase(x) {
    return asString(x).toLowerCase()
}

/**
 * Helper function to be used in conjunction with the `sortBy` function. Primes the input
 * to be treated as a string, ignoring case
 * @param {object} x input object to be turned into a string, ignoring case
 */
export function defaultPrimer(x) {
    return isNullOrEmpty(x) ? '' : x
}

/**
 * Helper function to generate an Active or Inactive status for the UI
 * @param {string} mitMoiraStatus string in the form of a number that determines the status
 * @returns a string that displays the status
 */
export function determineActiveStatus(mitMoiraStatus) {
    //the moira status comes in as a string
    let parsed = parseInt(mitMoiraStatus, 10)
    if (parsed === 1 || parsed === 9) {
        return 'Active'
    }
    return 'Inactive'
}

/**
 * Helper function to generate email address from kerb
 * @param {string} krbName string for a person's Kerb Name
 * @returns a string for email
 */
export function emailFromKrbName(krbName) {
    return `${krbName}@mit.edu`
}

export function getFullName(legalFirstName, legalMiddleName, legalLastName) {
    let nameArray = [
        legalFirstName ?? '',
        legalMiddleName ?? '',
        legalLastName ?? ''
    ]
    let fullName = nameArray
        .filter(function (e) {
            return e
        })
        .join(' ')

    return fullName
}

/**
 * Helper function to generate the partial Date of Birth field
 * @param {*} dobMonth The birth month
 * @param {*} dobDay The birth day
 * @returns A date of birth for the year 1900, or null if the supplied
 *          parameters are invalid inputs
 */
export function getBirthdate(dobMonth, dobDay) {
    if (dobMonth && dobDay) {
        const birthdate = Date.parse('1900-' + dobMonth + '-' + dobDay)
        return birthdate ? new Date(birthdate).toISOString() : null
    }
    return null
}

export function getFormattedBirthdate(birthday) {
    if (birthday) {
        const dateOfBirth = new Date(Date.parse(birthday + 'T00:00:00')) // Add time info to automatically convert to local timezone
        if (dateOfBirth instanceof Date && !isNaN(dateOfBirth.valueOf())) {
            return (dateOfBirth.getMonth() + 1) + '/' + dateOfBirth.getDate()
        }
    }
    return null
}

export function getDisplayName(
    preferredFirstName,
    legalFirstName,
    legalMiddleName,
    legalLastName
) {
    let nameArray = []

    if (
        preferredFirstName !== undefined &&
        preferredFirstName !== null &&
        preferredFirstName !== ''
    ) {
        nameArray = [preferredFirstName ?? '', legalLastName ?? '']
    } else {
        nameArray = [
            legalFirstName ?? '',
            legalMiddleName ?? '',
            legalLastName ?? ''
        ]
    }
    let name = nameArray
        .filter(function (e) {
            return e
        })
        .join(' ')

    return name
}

export function getEmail(
    kerbStatus,
    mitPreferredEmail,
    mitEmail,
    alumni,
    alumniEmail,
    nonMitEmail
) {
    let email

    if (kerbStatus === 'Active') {
        email = mitPreferredEmail ? mitPreferredEmail : mitEmail
    } else {
        if (alumni) {
            email = alumniEmail
        } else {
            email = nonMitEmail
        }
    }
    // If email is blank, set fallback email
    if (email === null || email === undefined || email.trim?.() === '') {
        email = mitEmail
    }
    
    return email
}

export function getInstitution(kerbStatus, institution) {
    return kerbStatus === 'Active' ? 'MIT' : institution ?? ''
}

export function determineAffiiation(affiliate, student, staff, alumni, guest) {
    let affiliationBoolArray = [affiliate, student, staff, alumni, guest]
    let affiliationArray = ['Affiliate', 'Student', 'Staff', 'Alumni', 'Guest']
    let result = []
    for (let i = 0; i < affiliationBoolArray.length; i++) {
        if (affiliationBoolArray[i]) {
            result.push(affiliationArray[i])
        }
    }
    return result.join('/')
}

export function determineStudentType(
    gradStudent,
    undergradStudent,
    visitingStudent
) {
    if (gradStudent) {
        return 'Graduate'
    } else if (undergradStudent) {
        return 'Undergraduate'
    } else if (visitingStudent) {
        return 'Visiting'
    }
    return ''
}

export function YesNoFromBoolean(value) {
    return value ? 'Yes' : 'No'
}

/**
 * Helper function that filters an array with elements that include a date range by a date range.
 * ie: X date range is between Y date range.
 * ensure date ranges overlap
 *
 * @param {string} startDateFilter start date of filter selected by user in string format '1996-11-22'
 * @param {string} endDateFilter end date of filter selected by user in string format, '1996-11-22'
 * @param {array} arrayToFilter array of objects to be filtered
 * @returns  Filtered Results contains all items contained in a range.
 */
export function filterDateRangeBetweenDateRange(
    startDateFilter,
    endDateFilter,
    arrayToFilter
) {
    //early return if date range is invalid
    if (startDateFilter.length === 0 || endDateFilter.length === 0) {
        return arrayToFilter
    }
    let filteredArray = []
    for (let i = 0; i < arrayToFilter.length; i++) {
        if (
            endDateFilter >= arrayToFilter[i].startDate &&
            startDateFilter <= arrayToFilter[i].endDate
        ) {
            filteredArray.push(arrayToFilter[i])
        }
    }
    return filteredArray
}

/**
 * Helper function that filters an array and returns all objects in the array that have a start date that is equal to or older than the date passed in.
 * ie: X date range is older than Y date starting point.
 * @param {string} startDateFilter start date of filter selected by user in string format '1996-11-22'
 * @param {array} arrayToFilter array of objects to be filtered
 * @returns  Filtered Results contain all objects that have a date older than the start date.
 */
export function filterDateAsOf(startDateFilter, arrayToFilter) {
    if (startDateFilter.length === 0) {
        return arrayToFilter
    }
    let filteredArray = []
    for (let i = 0; i < arrayToFilter.length; i++) {
        if (
            startDateFilter >= arrayToFilter[i].startDate &&
            startDateFilter <= arrayToFilter[i].endDate
        ) {
            filteredArray.push(arrayToFilter[i])
        }
    }
    return filteredArray
}

/**
 *
 * @param {string} userDefinedText text that a user entered to filter the results by
 * @param {array} arrayToFilter array of objects to be filtered
 * @param {key} keyInObject the key in the object you want to target
 * @returns array of objects that contain the user defined text in the key of the object
 */
export function filterArrayWithUserText(
    userDefinedText,
    arrayToFilter,
    keyInObject
) {
    //early return for if there is no text to filter by
    if (userDefinedText === '') {
        return arrayToFilter
    }
    let filteredArray = []
    //loop through the array of objects
    for (let i = 0; i < arrayToFilter.length; i++) {
        //if the value is null/empty, skip it
        if (
            arrayToFilter[i][keyInObject] === null ||
            arrayToFilter[i][keyInObject] === undefined
        ) {
            continue
        }
        //check the key in the object and then check if the value of that key contains the user defined text
        if (
            arrayToFilter[i][keyInObject]
                .toLowerCase()
                .includes(userDefinedText.toLowerCase())
        ) {
            filteredArray.push(arrayToFilter[i])
        }
    }
    return filteredArray
}

/**
 * [ALERT] SalesForce doesn't properly parse most boolean values that come from combobox inputs/selections. Please make sure you JSON.parse your value before using it. TypeScript would be so good for this...
 * @param {string} userDefinedBoolean boolean that a user entered to filter the results by
 * @param {array} arrayToFilter array of objects to be filtered
 * @param {key} keyInObject the key in the object you want to target
 * @returns array of objects where the key has the same boolean value as the user defined boolean
 */
export function filterArrayByUserBoolean(
    userDefinedBoolean,
    arrayToFilter,
    keyInObject
) {
    //early return for if there is no text to filter by
    //a failsafe if a developer passes a string instead of a boolean value
    if (userDefinedBoolean === null || typeof userDefinedBoolean === 'string') {
        console.error(
            '[filterArrayByUserBoolean]',
            'Please make sure you pass a proper boolean value to filter by.'
        )
        return arrayToFilter
    }
    let filteredArray = []
    //loop through the array of objects
    for (let i = 0; i < arrayToFilter.length; i++) {
        //check the key in the object and then check if the value of that key contains the user defined text
        if (arrayToFilter[i][keyInObject] === userDefinedBoolean) {
            filteredArray.push(arrayToFilter[i])
        }
    }
    return filteredArray
}

/**
 * Helper function to generate a list of items from an array of text and seperate them with a comma
 * This is better than using a .join method since it doesn't add a comma after the last item and catches for empty arrays/strings
 * @param {array} textArray an array that contains strings that you want to seperate by a comma
 * @returns a string that contains the strings in the array separated by a comma
 */
export function generateCommaSeparatedString(textArray) {
    let commaSeparatedString = ''
    //early return if there is no text in the array
    if (textArray.length === 0) {
        return commaSeparatedString
    }
    textArray.forEach(function (text, index) {
        //if the item is empty, don't add a comma or add it to the string
        if (text !== '') {
            commaSeparatedString = `${commaSeparatedString} ${text}`
            //add a comma if it's not the last item
            if (index !== textArray.length - 1) {
                commaSeparatedString = `${commaSeparatedString}, `
            }
        }
    })
    return commaSeparatedString
}

/**
 * Helper function to determine whether or not a value is null or empty
 *
 * @param {*} val value to be examined
 * @returns {boolean} true if the value is null or empty, false if it has a value
 */
export function isNullOrEmpty(val) {
    if (
        val === undefined ||
        val === null ||
        (typeof val.trim === 'function' ? val.trim() : 'Not a String') === ''
    ) {
        return true
    }
    return false
}

/**
 * Searches to see if a Contact exists and, if it does, returns that record.
 * If one does not exist, it will create one using the supplied fields
 * @param {*} fields List of fields to find/create the record
 * @returns {*} The found/created Contact
 */
export async function jitGetCreateContact(fields) {
    console.log(fields)
    let contact = await getContactByMitId({
        mitId: fields.mitId
    })
    console.log(contact);

    let error
    if (!contact) {
        try {
            const contactToSubmit = formatContactSubmitted(fields)
            const response = await createContactManual(contactToSubmit) // If Contact does not exist, create it
            contact = response.data
            error = response.error
        } catch (e) {
            error = e
        }
    }
    return { data: contact, error: error }
}

/**
 * Update people search contact to  contact schema
 * @param {Object} sourceObject Source object to extract properties from (people search row)
 * @returns {Object} contact schema object
 */
export function formatContactSubmitted(sourceObject) {
    return {
        apiName: 'Account',
        fields: {
            AltEmail__pc: sourceObject.nonMitEmail,
            AlumniEmail__pc: sourceObject.alumniEmail,
            FirstName: sourceObject.legalFirstName,
            GuestAccountNeeded__pc: (sourceObject.kerbStatus === 'Active' || sourceObject.alumni === true) ? 'No' : 'Yes',
            Institution__pc: sourceObject.institution,
            InstitutionCode__pc: null, // People search data has no institution code
            IsAlumni__pc: sourceObject.alumni,
            KerbName__pc: sourceObject.krbName,
            LastName: sourceObject.legalLastName,
            MiddleName: sourceObject.legalMiddleName,
            MitId__pc: sourceObject.mitId,
            MoiraStatus__pc: sourceObject.moiraStatus,
            PersonBirthdate: sourceObject.birthDate ?? null,
            PersonDepartment: sourceObject.dlcName,
            PersonEmail: sourceObject.email,
            PersonOtherPhone: sourceObject.phone,
            PreferredName__pc: sourceObject.preferredName
        }
    }
}

/**
 * Format a float value to a string according to the current Org's locale settings.
 * @param value Float value to convert to string.
 * @param accountingFormat Determine if a negative amount should be in parentheses or minus sign.
 * @returns {string}
 */
export function formatCurrency(value, accountingFormat = false){
    return new Intl.NumberFormat(orgLocale, {
        style: "currency",
        currency: orgCurrencyCode,
        currencyDisplay: "symbol",
        currencySign: accountingFormat ? 'accounting' : 'standard',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(value ?? 0);
}

/**
 * Manually create a Contact
 * @param {*} submittedContact The submitted contact object
 * @returns {*} The created Contact record
 */
export async function createContactManual(submittedContact) {
    let createdContact = null
    let error = null

    // Create Record
    await createRecord(submittedContact)
        .then((contact) => {
            createdContact = contact
        })
        .catch((e) => {
            error = e
        })
    if (createdContact) {
        createdContact = { Id: createdContact.id, ...createdContact.fields }
    }
    return { data: createdContact, error: error }
}

/**
 * Manually update a Contact
 * @param {*} submittedContact The submitted contact object
 * @returns {*} The updated Contact record
 */
export async function updateContactManual(submittedContact) {
    let updatedContact = null
    let error = null

    // Update Record
    await updateRecord(submittedContact)
        .then((contact) => {
            updatedContact = contact
        })
        .catch((e) => {
            error = e
        })
    if (updatedContact) {
        updatedContact = { Id: updatedContact.id, ...updatedContact.fields }
    }
    return { data: updatedContact, error: error }
}

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors]
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message)
                }
                // Page level errors
                else if (
                    error?.body?.pageErrors &&
                    error.body.pageErrors.length > 0
                ) {
                    return error.body.pageErrors.map((e) => e.message)
                }
                // Field level errors
                else if (
                    error?.body?.fieldErrors &&
                    Object.keys(error.body.fieldErrors).length > 0
                ) {
                    const fieldErrors = []
                    Object.values(error.body.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            )
                        }
                    )
                    return fieldErrors
                }
                // UI API DML page level errors
                else if (
                    error?.body?.output?.errors &&
                    error.body.output.errors.length > 0
                ) {
                    return error.body.output.errors.map((e) => e.message)
                }
                // UI API DML field level errors
                else if (
                    error?.body?.output?.fieldErrors &&
                    Object.keys(error.body.output.fieldErrors).length > 0
                ) {
                    const fieldErrors = []
                    Object.values(error.body.output.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            )
                        }
                    )
                    return fieldErrors
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message
                }
                // Unknown error shape so try HTTP status text
                return error.statusText
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    )
}

/**
 * Helper comparison function that is to be used in conjunction with the JavaScript `sort`
 * function. Compares two Objects by a specified field
 *
 * @param {string} field field of objects to be compared
 * @param {int} reverse order in which the values should be compared; 1 if in ascending
 * order, -1 if order needs to be revesed
 * @param {function} primer function that can be called on each of the fields before comparing
 */
export function sortBy(field, reverse, primer) {
    const key = primer
        ? function (x) {
            return primer(x[field])
        }
        : function (x) {
            return defaultPrimer(x[field])
        }

    return function (a, b) {
        a = key(a) ?? ''
        b = key(b) ?? ''

        // Ensure that nulls are always at the bottom
        if (isNullOrEmpty(a)) return 1
        if (isNullOrEmpty(b)) return -1

        return reverse * ((a > b) - (b > a))
    }
}

/**
 * Helper function that generates a dropdown list metadata based on values that are in an array of objects
 * @param {array} arrayToFilter array of objects to be filtered
 * @param {key} keyInObject a key that is in an object in the array
 * @returns a unique array that consists of the values in the array of objects
 */
export function dropdownListGenerator(arrayToFilter, keyInObject) {
    //early return for if there is no data passed through
    if (arrayToFilter.length === 0) return []

    let dropdownListValues = []
    for (let i = 0; i < arrayToFilter.length; i++) {
        if (
            arrayToFilter[i][keyInObject] !== null &&
            arrayToFilter[i][keyInObject] !== undefined &&
            arrayToFilter[i][keyInObject] !== '' &&
            dropdownListValues.indexOf(arrayToFilter[i][keyInObject]) === -1
        ) {
            dropdownListValues.push(arrayToFilter[i][keyInObject])
        }
    }
    return dropdownListValues.map(function (value) {
        return { label: value, value: value }
    })
}

/**
 * This function is used to generate the size of a file in it's respective byte size
 * @param {number} fileInBytes
 * @returns a string that contains the size of the file in it's respective byte size
 */
export function getFileSize(fileInBytes) {
    if (!fileInBytes) return 'undefined size'

    let bytes = fileInBytes
    let sizes = ['bytes', 'KB', 'MB', 'GB', 'TB']
    if (bytes === 0) return '0 bytes'
    let i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)), 10)
    return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i]
}

/**
 * This function is used to generate the icon of a file based on the file extension
 * @param {string} fileExtension
 * @returns a string that contains the icon of the file to be used in a lightning file icon component
 */
export function fileIcon(fileExtension) {
    const FILE_ICON_ENUMS = this.FILE_ICON_ENUMS
    if (!fileExtension) return 'doctype:attachment'

    switch (fileExtension) {
        case FILE_ICON_ENUMS.pdf:
            return 'doctype:pdf'
        case FILE_ICON_ENUMS.docx:
            return 'doctype:word'
        case FILE_ICON_ENUMS.doc:
            return 'doctype:word'
        case FILE_ICON_ENUMS.zip:
            return 'doctype:zip'
        case FILE_ICON_ENUMS.gz:
            return 'doctype:zip'
        case FILE_ICON_ENUMS.ppt:
            return 'doctype:ppt'
        case FILE_ICON_ENUMS.pptx:
            return 'doctype:ppt'
        case FILE_ICON_ENUMS.pptm:
            return 'doctype:ppt'
        case FILE_ICON_ENUMS.txt:
            return 'doctype:txt'
        case FILE_ICON_ENUMS.tex:
            return 'doctype:txt'
        case FILE_ICON_ENUMS.latex:
            return 'doctype:txt'
        case FILE_ICON_ENUMS.xls:
            return 'doctype:excel'
        case FILE_ICON_ENUMS.xlsm:
            return 'doctype:excel'
        case FILE_ICON_ENUMS.xlsx:
            return 'doctype:excel'
        case FILE_ICON_ENUMS.mp3:
            return 'doctype:audio'
        case FILE_ICON_ENUMS.mp4:
            return 'doctype:mp4'
        case FILE_ICON_ENUMS.wav:
            return 'doctype:audio'
        case FILE_ICON_ENUMS.svg:
            return 'doctype:image'
        case FILE_ICON_ENUMS.csv:
            return 'doctype:csv'
        case FILE_ICON_ENUMS.html:
            return 'doctype:html'
        case FILE_ICON_ENUMS.htm:
            return 'doctype:html'
        case FILE_ICON_ENUMS.bsv:
            return 'doctype:image'
        case FILE_ICON_ENUMS.py:
            return 'doctype:html'
        case FILE_ICON_ENUMS.c:
            return 'doctype:html'
        case FILE_ICON_ENUMS.link:
            return 'doctype:link'
        default:
            return 'doctype:attachment'
    }
}

/**
 * This function is used to generate the icon of a file based on the MIME types
 * @param {string} MIME type
 * @returns a string that contains the icon of the file to be used in a lightning file icon component
 */
export function fileMimeTypeIcon(fileType) {
    
    if (fileType.startsWith('image/')) {
        return 'doctype:image';
    } else if (fileType === 'application/pdf') {
        return 'doctype:pdf';
    } else if (fileType === 'application/msword' || fileType === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
        return 'doctype:word';
    } else if (fileType === 'application/vnd.ms-excel' || fileType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
        return 'doctype:excel';
    } else if (fileType.startsWith('audio/')) {
        return 'doctype:audio';
    } else if (fileType.startsWith('video/')) {
        return 'doctype:video';
    } else if (fileType === 'text/csv') {
        return 'doctype:csv';
    } else if (fileType === 'text/plain') {
        return 'doctype:txt';
    } else if (fileType === 'application/zip' || fileType === 'application/gzip') {
        return 'doctype:zip';
    } else if (fileType === 'application/vnd.ms-powerpoint' || fileType === 'application/vnd.openxmlformats-officedocument.presentationml.presentation') {
        return 'doctype:ppt';
    } else if (fileType === 'text/html') {
        return 'doctype:html';
    } else if (fileType === 'text/x-python') {
        return 'doctype:code';
    } else if (fileType === 'text/x-c' || fileType === 'text/x-csrc' || fileType === 'text/x-chdr') {
        return 'doctype:code';
    } else if (fileType === 'text/uri-list') {
        return 'doctype:link';
    } else {
        return 'utility:file';
    }
}

/**
 * This function returns the record data for a given BioTang object using the
 * related Disclosure object as an Id
 * @param disclosureRecordId The related Disclosure__c object that will be used
 * to retrieve the BioTangDisclosure__c object
 */
export async function getBioTangData(disclosureRecordId) {
    let recordData = null
    let resDiscData = await getBioTangByDisclosureId({
        disclosureId: disclosureRecordId
    })

    if (resDiscData && resDiscData[0] !== null) {
        console.log(`%c [RECORD DATA]`, `color: green`, resDiscData[0])
        recordData = resDiscData[0]
    }

    return recordData
}

/**
 * This function returns the record data for a given Copyright object using the
 * related Disclosure object as an Id
 * @param disclosureRecordId The related Disclosure__c object that will be used
 * to retrieve the Copyright_Disclosure__c object
 */
export async function getCopyrightData(disclosureRecordId) {
    let recordData = null
    let resDiscData = await getCopyrightByDisclosureId({
        disclosureId: disclosureRecordId
    })

    if (resDiscData && resDiscData[0] !== null) {
        console.log(`%c [RECORD DATA]`, `color: green`, resDiscData[0])
        recordData = resDiscData[0]
    }

    return recordData
}

/**
 * This function returns the record data for a given Invention object using the
 * related Disclosure object as an Id
 * @param disclosureRecordId The related Disclosure__c object that will be used
 * to retrieve the Invention_Disclosure__c object
 */
export async function getInventionData(disclosureRecordId) {
    let recordData = null
    let resDiscData = await getInventionByDisclosureId({
        disclosureId: disclosureRecordId
    })

    if (resDiscData && resDiscData[0] !== null) {
        console.log(`%c [RECORD DATA]`, `color: green`, resDiscData[0])
        recordData = resDiscData[0]
    }

    return recordData
}

/**
 * This function returns the record data for a given Software_Code__c object
 * using the related Disclosure object as an Id
 * @param disclosureRecordId The related Disclosure__c object that will be used
 * to retrieve the Software_Code_Disclosure__c object
 */
export async function getSoftwareCodeData(disclosureRecordId) {
    let recordData = null
    let resDiscData = await getSoftwareCodeByDisclosureId({
        disclosureId: disclosureRecordId
    })

    if (resDiscData && resDiscData[0] !== null) {
        console.log(`%c [RECORD DATA]`, `color: green`, resDiscData[0])
        recordData = resDiscData[0]
    }

    return recordData
}

/**
 * This function returns the user data for a given user Id
 * @param userId The Id of the user that is to be retrieved
 */
export async function getUserData(userId) {
    let userData = await getUserInformationbyId({ userId: userId })

    if (this.userData !== null) {
        console.log(`%c [USER DATA]`, `color: green`, this.userData)
    }

    return userData
}

/**
 * Search for a person using the MIT `people-search` API
 *
 * @param personSearchParam Search query to be used
 * @param deepSearch Auto use of wildcards, defaulted to `false`
 * @returns {searchResults, error} Search results and, if applicable, resulting error
 */
export async function peopleSearch(personSearchParam) {
    let searchResults, error

    // Replace multiple spaces with just one space
    personSearchParam = `${personSearchParam.replace(/[ ]{2,}/, ' ')}`

    // Remove any wildcards from search string
    personSearchParam = personSearchParam.startsWith('*')
        ? personSearchParam.substring(1, personSearchParam.length)
        : personSearchParam
    personSearchParam = `${personSearchParam.replace('*', ' ')}`

    if (personSearchParam.length === 0) {
        error = 'Please search for a person'
        return { searchResults, error }
    }
    if (personSearchParam.length < 3) {
        error = 'Please enter at least 3 characters'
        return { searchResults, error }
    }

    // Search using API
    try {
        const apiName = 'peopleSearchApi'
        let result = await restGet({
            api: apiName,
            resource: `/search?query=${encodeURIComponent(
                personSearchParam
            )}&krbStatus=any&pageFrom=0&pageSize=100&onlyResultsWithEmail=true`
        })
        // Unauthorized or Forbidden error checks
        if (
            result.includes('Forbidden') ||
            result.includes('Unauthorized') ||
            result.includes('status code 401')
        ) {
            error = 'You are not authorized to access this resource'
            return { searchResults, error }
        }
        if (result.includes('timed out')) {
            error = 'The requested resource has timed out. Please try again'
            return { searchResults, error }
        }

        // Get `people` list from returned result
        searchResults = JSON.parse(result).people

        // Loop through the data and replace the moira status with a text variant
        for (let i = 0; i < searchResults.length; i++) {
            searchResults[i].kerbStatus = determineActiveStatus(
                searchResults[i].moiraStatus
            )
            searchResults[i].email = getEmail(
                searchResults[i].kerbStatus,
                searchResults[i].mitPreferredEmail,
                searchResults[i].mitEmail,
                searchResults[i].alumni,
                searchResults[i].alumniEmail,
                searchResults[i].nonMitEmail
            )
            searchResults[i].name = getDisplayName(
                searchResults[i].preferredName,
                searchResults[i].legalFirstName,
                searchResults[i].legalMiddleName,
                searchResults[i].legalLastName
            )
            searchResults[i].affiliation = determineAffiiation(
                searchResults[i].affiliate,
                searchResults[i].student,
                searchResults[i].staff,
                searchResults[i].alumni,
                searchResults[i].guest
            )
            searchResults[i].finalInstitution = getInstitution(
                searchResults[i].kerbStatus,
                searchResults[i].institution
            )
            searchResults[i].studentType = determineStudentType(
                searchResults[i].gradStudent,
                searchResults[i].undergradStudent,
                searchResults[i].visitingStudent
            )
            searchResults[i].mitIdCreationDate = searchResults[i]
                .mitIdCreationDate
                ? new Date(
                    searchResults[i].mitIdCreationDate
                ).toLocaleDateString('en-US')
                : null
        }
    } catch (e) {
        console.error(e)
        error =
            'Failed to search for a person, please try again. If this problem persits please contact your administrator'
    }

    return { searchResults, error }
}

/**
 * Search for a person using the MIT `people-search` API
 *
 * @param personSearchParam Search query to be used
 * @param deepSearch Auto use of wildcards, defaulted to `false`
 * @returns {searchResults, error} Search results and, if applicable, resulting error
 */
export async function peopleSearchWithSource(personSearchParam) {
    let searchResults, error

    // Replace multiple spaces with just one space
    personSearchParam = `${personSearchParam.replace(/[ ]{2,}/, ' ')}`

    // Remove any wildcards from search string
    personSearchParam = personSearchParam.startsWith('*')
        ? personSearchParam.substring(1, personSearchParam.length)
        : personSearchParam
    personSearchParam = `${personSearchParam.replace('*', ' ')}`

    if (personSearchParam.length === 0) {
        error = 'Please search for a person'
        return { searchResults, error }
    }
    if (personSearchParam.length < 3) {
        error = 'Please enter at least 3 characters'
        return { searchResults, error }
    }

    // Search using API
    try {
        const apiName = 'peopleSearchApi'
        let result = await getPeopleDataWithSource({
            api: apiName,
            resource: `/search?query=${encodeURIComponent(
                personSearchParam
            )}&showSource=1`
        })
        // Unauthorized or Forbidden error checks
        if (
            result.includes('Forbidden') ||
            result.includes('Unauthorized') ||
            result.includes('status code 401')
        ) {
            error = 'You are not authorized to access this resource'
            return { searchResults, error }
        }
        if (result.includes('timed out')) {
            error = 'The requested resource has timed out. Please try again'
            return { searchResults, error }
        }

        // Check if result is an object and convert it to a JSON string if necessary
        if (typeof result === 'object') {
            result = JSON.stringify(result)
        }
        searchResults = JSON.parse(result)

        // Loop through the data and replace the moira status with a text variant
        for (let i = 0; i < searchResults.length; i++) {
            searchResults[i].kerbStatus = determineActiveStatus(
                searchResults[i].moiraStatus
            )
            searchResults[i].email = getEmail(
                searchResults[i].kerbStatus,
                searchResults[i].mitPreferredEmail,
                searchResults[i].mitEmail,
                searchResults[i].alumni,
                searchResults[i].alumniEmail,
                searchResults[i].nonMitEmail
            )
            searchResults[i].name = getDisplayName(
                searchResults[i].preferredName,
                searchResults[i].legalFirstName,
                searchResults[i].legalMiddleName,
                searchResults[i].legalLastName
            )
            searchResults[i].affiliation = determineAffiiation(
                searchResults[i].affiliate,
                searchResults[i].student,
                searchResults[i].staff,
                searchResults[i].alumni,
                searchResults[i].guest
            )
            searchResults[i].finalInstitution = getInstitution(
                searchResults[i].kerbStatus,
                searchResults[i].institution
            )
            searchResults[i].studentType = determineStudentType(
                searchResults[i].gradStudent,
                searchResults[i].undergradStudent,
                searchResults[i].visitingStudent
            )
            searchResults[i].mitIdCreationDate = searchResults[i]
                .mitIdCreationDate
                ? new Date(
                    searchResults[i].mitIdCreationDate
                ).toLocaleDateString('en-US')
                : null
        }
    } catch (e) {
        console.error(e)
        error =
            'Failed to search for a person, please try again. If this problem persits please contact your administrator'
    }

    return { searchResults, error }
}



/**
 * ENUMS
 */
export const DOCUMENT_FOR_RECORDTYPE = {
    BIO_TANG: 'BioTang_Disclosure',
    INVENTION: 'Invention_Disclosure',
    SOFTWARE_CODE: 'Software_Code_Disclosure',
    COPYRIGHT: 'Copyright_Disclosure'
}

export const DOCUMENT_TYPES = {
    DISCLOSURE: 'Disclosure',
    CASE: 'Case',
    AGREEMENT: 'Agreement',
}

export const DOCUMENT_CLASSIFICATIONS = {
    SIGNED_DISCLOSURE: 'Signed Disclosure',
    TECHNICAL_DESCRIPTION: 'Technical Description',
    PUBLICATION_MANUSCRIPTS: 'Publication/Manuscripts',
    SOFTWARE_CODE: 'Software Code',
    THIRD_PARTY_AGREEMENTS: 'Third Party Agreements',
    THIRD_PARTY_CODE: 'Third Party Code',
    FINALISED_CRDR: 'Finalised_CRDR',
    DRAFT_CRDR: 'Draft_CRDR',
    CRDR: 'CRDR',
    ORIGINAL_DOCUMENT: 'ORIGINAL_DOCUMENT',
    LICENSE: 'License'

}

export const FILTER_FILES_ENUMS = {
    ALL: 'all',
    SIGNED_DISCLOSURE: 'signedDisclosure',
    TECHNICAL_DESCRIPTION: 'technicalDescription',
    PUBLICATION_MANUSCRIPTS: 'publicationsManuscripts',
    SOFTWARE_CODE: 'software',
    THIRD_PARTY_AGREEMENTS: 'thirdParty',
    THIRD_PARTY_CODE: 'thirdPartyCode',
    FINALISED_CRDR: 'Finalised_CRDR',
    DRAFT_CRDR: 'Draft_CRDR',
    LICENSE: 'license'
}

export function determineFilterTypeByDocQueryType(documentQueryType) {
    switch (documentQueryType) {
        case DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE:
            return FILTER_FILES_ENUMS.SIGNED_DISCLOSURE
        case DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION:
            return FILTER_FILES_ENUMS.TECHNICAL_DESCRIPTION
        case DOCUMENT_CLASSIFICATIONS.PUBLICATION_MANUSCRIPTS:
            return FILTER_FILES_ENUMS.PUBLICATION_MANUSCRIPTS
        case DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE:
            return FILTER_FILES_ENUMS.SOFTWARE_CODE
        case DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS:
            return FILTER_FILES_ENUMS.THIRD_PARTY_AGREEMENTS
        case DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE:
            return FILTER_FILES_ENUMS.THIRD_PARTY_CODE
        case DOCUMENT_CLASSIFICATIONS.FINALISED_CRDR:
            return FILTER_FILES_ENUMS.FINALISED_CRDR
        case DOCUMENT_CLASSIFICATIONS.DRAFT_CRDR:
            return FILTER_FILES_ENUMS.DRAFT_CRDR
        case DOCUMENT_CLASSIFICATIONS.LICENSE:
            return FILTER_FILES_ENUMS.LICENSE
        default:
            return FILTER_FILES_ENUMS.ALL
    }
}

export function determineFileClassifactionName(classification) {
    switch (classification) {
        case DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE:
            return DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE
        case DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION:
            return Disclosure_Documents_Header_TechnicalDescription
        case DOCUMENT_CLASSIFICATIONS.PUBLICATION_MANUSCRIPTS:
            return Disclosure_Documents_Header_PublicationsManuscripts
        case DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE:
            return DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE
        case DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS:
            return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS
        case DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE:
            return DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE
        case DOCUMENT_CLASSIFICATIONS.FINALISED_CRDR:
            return DOCUMENT_CLASSIFICATIONS.FINALISED_CRDR
        case DOCUMENT_CLASSIFICATIONS.DRAFT_CRDR:
            return DOCUMENT_CLASSIFICATIONS.DRAFT_CRDR
        case DOCUMENT_CLASSIFICATIONS.LICENSE:
            return DOCUMENT_CLASSIFICATIONS.LICENSE
        default:
            return classification
    }
}

export const FILE_ICON_ENUMS = {
    pdf: 'pdf',
    docx: 'docx',
    doc: 'doc',
    zip: 'zip',
    gz: 'gz',
    ppt: 'ppt',
    pptx: 'pptx',
    pptm: 'pptm',
    txt: 'txt',
    tex: 'tex',
    latex: 'latex',
    xls: 'xls',
    xlsm: 'xlsm',
    xlsx: 'xlsx',
    mp3: 'mp3',
    mp4: 'mp4',
    wav: 'wav',
    svg: 'svg',
    csv: 'csv',
    html: 'html',
    htm: 'htm',
    bsv: 'bsv',
    py: 'py',
    link: 'link',
    c: 'c'
}

export const SORT_BY_TYPE_ENUMS = {
    STRING: 'string',
    STRING_IGNORE_CASE: 'stringIgnoreCase',
    DATE: 'date',
    NUMBER: 'number'
}

/**
 * VALUE LISTS
 */

export const DISCLOSURE_FIELDS = [
    'Disclosure__c.External_ID__c',
    'Disclosure__c.CreatedById',
    'Disclosure__c.Case_Number__c',
    'Disclosure__c.Status__c',
    'Disclosure__c.Stage__c',
    'Disclosure__c.Name',
    'Disclosure__c.Name__c',
    'Disclosure__c.Description__c',
    'Disclosure__c.Funding_Details__c',
    'Disclosure__c.RecordType.DeveloperName',
    'Disclosure__c.SubmittedOnBehalf__c',
    'Disclosure__c.Disclosure_Reason__c',
    'Disclosure__c.Disclosure_Reason_Comment__c',
    'Disclosure__c.TLO_License_Officer__c',
    'Disclosure__c.CreatedDate',
    'Disclosure__c.LastModifiedDate'
]

export const ACCOUNT_FIELDS = [
    'Account.CountryOfCitizenship__pc',
    'Account.DisplayName__pc',
    'Account.FirstName',
    'Account.Government_Agency_Name__pc',
    'Account.GovernmentEmployeeStatus__pc',
    'Account.HHMI_Current__pc',
    'Account.HHMI_Current_Date_From__pc',
    'Account.Institution__pc',
    'Account.InstitutionCode__pc',
    'Account.LastName',
    'Account.MiddleName',
    'Account.MitId__pc',
    'Account.Name',
    'Account.PersonBirthdate',
    'Account.PersonEmail',
    'Account.PersonMobilePhone',
    'Account.PreferredName__pc',
    'Account.VaAppointment__pc',
    'Account.VaAppointmentDetails__pc',
    'Account.Contact_Recid__pc'
]

export const HISTORY_ACCOUNT_FIELDS = [
    'Account.Name',
    'Account.MitId__pc'
]

export const DOCUMENT_DISCLOSURE_FIELDS = [
    'Disclosure__c.Name__c',
    'Disclosure__c.RecordType.DeveloperName'
]

export const DOCUMENT_FORRESTER_CASE_FIELDS = [
    'Forrester_Case__x.CASE_RECID__c'
]

export const DOCUMENT_FORRESTER_CASE_CRDR_FIELDS = [
    'Forrester_SHIR_CRDR_VIEW__x.CASE_CRDR_RECID__c',
    'Forrester_SHIR_CRDR_VIEW__x.CASE_RECID__c',
    'Forrester_SHIR_CRDR_VIEW__x.FY__c'
]
export const DOCUMENT_FORRESTER_AGREEMENT_FIELDS = [
    'Forrester_SHIR_AGREEMENT_VIEW__x.AGREEMENT_RECID__c'
]

const documentStructure = {
    Case: [{
        classification: DOCUMENT_CLASSIFICATIONS.ORIGINAL_DOCUMENT,
        fields: DOCUMENT_FORRESTER_CASE_FIELDS,
        entityIdField: 'CASE_RECID__c'
    }],
    Other_Agreement: [{
        classification: DOCUMENT_CLASSIFICATIONS.ORIGINAL_DOCUMENT,
        fields: DOCUMENT_FORRESTER_CASE_FIELDS,
        entityIdField: 'CASE_RECID__c'
    }],
    Sponsor_Agreement: [{
        classification: DOCUMENT_CLASSIFICATIONS.ORIGINAL_DOCUMENT,
        fields: DOCUMENT_FORRESTER_CASE_FIELDS,
        entityIdField: 'CASE_RECID__c'
    }],
    CRDR: [{
        classification: DOCUMENT_CLASSIFICATIONS.CRDR,
        fields: DOCUMENT_FORRESTER_CASE_CRDR_FIELDS,
        entityIdField: 'CASE_CRDR_RECID__c'
        },
        {
        classification: DOCUMENT_CLASSIFICATIONS.FINALISED_CRDR,
        fields: DOCUMENT_FORRESTER_CASE_CRDR_FIELDS,
        entityIdField: 'CASE_CRDR_RECID__c'
        },
        {
        classification: DOCUMENT_CLASSIFICATIONS.DRAFT_CRDR,
        fields: DOCUMENT_FORRESTER_CASE_CRDR_FIELDS,
        entityIdField: 'CASE_CRDR_RECID__c'
    }],
    TLO_Agreement: [{
        classification: DOCUMENT_CLASSIFICATIONS.ORIGINAL_DOCUMENT,
        fields: DOCUMENT_FORRESTER_AGREEMENT_FIELDS,
        entityIdField: 'AGREEMENT_RECID__c'
    }],
    Disclosure: [{
        classification: DOCUMENT_CLASSIFICATIONS.SIGNED_DISCLOSURE,
        fields: DOCUMENT_DISCLOSURE_FIELDS,
        entityIdField: 'Id'
        },
        {
            classification: DOCUMENT_CLASSIFICATIONS.TECHNICAL_DESCRIPTION,
            fields: DOCUMENT_DISCLOSURE_FIELDS,
            entityIdField: 'Id'
        },
        {
            classification: DOCUMENT_CLASSIFICATIONS.PUBLICATION_MANUSCRIPTS,
            fields: DOCUMENT_DISCLOSURE_FIELDS,
            entityIdField: 'Id'
        },
        {
            classification: DOCUMENT_CLASSIFICATIONS.SOFTWARE_CODE,
            fields: DOCUMENT_DISCLOSURE_FIELDS,
            entityIdField: 'Id'
        },
        {
            classification: DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_AGREEMENTS,
            fields: DOCUMENT_DISCLOSURE_FIELDS,
            entityIdField: 'Id'
        },
        {
            classification: DOCUMENT_CLASSIFICATIONS.THIRD_PARTY_CODE,
            fields: DOCUMENT_DISCLOSURE_FIELDS,
            entityIdField: 'Id'
        }
    ]
}


export function getDocumentFieldsByRecordTypeAndClassification(recordType, classification) {
    const documentMetadata = documentStructure[recordType];
    if (documentMetadata) {
        const filtered = documentMetadata.filter(x => x.classification === classification);
        return (filtered.length > 0) ? filtered[0].fields : documentMetadata[0].fields
    }
    return DOCUMENT_DISCLOSURE_FIELDS;
}

export function getDocumentEntityIdFieldByRecordTypeAndClassification(recordType, classification, data) {
    let property = 'Id';
    const documentMetadata = documentStructure[recordType];
    if (documentMetadata) {
        const filtered = documentMetadata.filter(x => x.classification === classification);
        property = (filtered.length > 0) ? filtered[0].entityIdField : documentMetadata[0].entityIdField
    }

    const fields = data.fields;
    if (fields && fields[property] !== undefined) {
        return fields[property]?.value ?? ''
    } else {
        return data.fields?.Id?.value ?? '';
    }

}

export function isEntityIdDocumentByRecordType(recordType) {
    console.debug('isEntityIdDocumentByRecordType', recordType)
    if (recordType === DOCUMENT_TYPES.DISCLOSURE || !recordType) {
        return false
    } else {
        return true
    }
}

export const CONTACT_SEARCH_COLUMNS = [
    {
        fieldName: 'name',
        label: 'Name',
        sortable: true,
        type: 'text',
        hideDefaultActions: true
    },
    {
        fieldName: 'email',
        label: 'Email',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        initialWidth: 250
    },
    {
        fieldName: 'finalInstitution',
        label: 'Institution',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        wrapText: true
    },
    {
        fieldName: 'dlcName',
        label: 'Current Department',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        cellAttributes: {
            class: 'text-capitalize'
        },
        initialWidth: 160
    },
    {
        fieldName: 'affiliation',
        label: 'Current Affiliation',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        cellAttributes: {
            class: 'text-capitalize'
        },
        initialWidth: 160
    },
    {
        fieldName: 'mitId',
        label: 'MIT ID',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        fieldName: 'krbName',
        label: 'Kerberos',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        initialWidth: 110
    },
    {
        fieldName: 'kerbStatus',
        label: 'Kerberos Status',
        sortable: true,
        type: 'text',
        hideDefaultActions: true,
        initialWidth: 150
    }
]

/**
 * This function is used to iterate through the Key/Value pairs of the picklist received via Apex and return the long text fields that are selected in the field for the record.
 * @param {object} apiPicklist this is the key/value pairs of the picklist received via Apex
 * Example: DisclosureRecordFetch.getDisclosureReasonPicklist
 * @param {string} apiStringListOnObject the values that are selected in the field for the record
 * Example: Disclosure_Reason__c = "GroundbreakingOrRevolutionary;CommercialPotential"
 * @returns an array of the long text fields that are selected in the field for the record.
 */
export const longTextFieldsFromApiPicklist = (
    apiPicklist,
    apiStringListOnObject
) => {
    const optionsToCheck = apiStringListOnObject.split(';')
    const resultArray = []

    for (let i = 0; i < optionsToCheck.length; i++) {
        const option = optionsToCheck[i]
        if (option in apiPicklist) {
            resultArray.push(apiPicklist[option])
        }
    }

    return resultArray
}

/**
 * Escape apostrophe in string for oracle query
 * @param {string} inputString This is the organization string to escape.
 */
export const escapeApostrophe = (inputString) => {
    // Replace all occurrences of ' with ''
    // This is to escape ' in oracle db
    if (inputString) {
        return inputString.replace(/'/g, "''")
    }
    return ''
}


/**
 * 🔍🏛 Institution Search
 * @param {string} org This is the organization string to search.
 */
export const forresterOrganizationSearch = async (org) => {
    const escapedOrg = escapeApostrophe(org)
    const apiName = 'forresterApi'
    const params = {
        api: apiName,
        resource: `/organizations${org ? '?nameSearch=' + encodeURIComponent(escapedOrg) : ''}`
    }
    return JSON.parse(await restGet(params))
}

/**
 * 🔍🏛 Confirmation Dialog
 * @param label The Modal header label
 * @param message The Modal message
 * @param theme The Modal theme. Possible values are:
    default: white
    shade: gray
    inverse: dark blue
    alt-inverse: darker blue
    success: green
    info: gray-ish blue
    warning: yellow
    error: red
    offline: black
 * @param variant The Modal variant. Possible values are 'header', 'headerless'
 *
 * https://developer.salesforce.com/docs/component-library/bundle/lightning-confirm/documentation
 */
export const showConfirmationDialog = async (label, message, theme = 'default', variant = 'header') => {
    return LightningConfirm.open({
        message: message,
        theme: theme,
        label: label,
        variant: variant
    })
}