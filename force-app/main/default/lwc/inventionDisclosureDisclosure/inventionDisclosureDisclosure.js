import { LightningElement, api, wire } from 'lwc'
import { getRecord } from 'lightning/uiRecordApi'
import { getInventionData, DISCLOSURE_FIELDS } from 'c/utils'

import getThesisDetailsByInventionId from '@salesforce/apex/DisclosureRecordFetch.getThesisDetailsByInventionId'

export default class InventionDisclosureDisclosure extends LightningElement {
    @api recordId

    disclosureData
    recordData
    thesisData = {}

    loading = true

    get allAccordionSections() {
        return [
            'publicationDates',
            'thesisInformation',
            'reductionToPractice',
            'additionalDisclosureInformation'
        ]
    }

    @wire(getRecord, { recordId: '$recordId', fields: DISCLOSURE_FIELDS })
    async handleDisclosure({ error, data }) {
        this.loading = true
        if (data) {
            this.disclosureData = data
            this.recordData = await getInventionData(this.recordId)

            let thesisRes = await getThesisDetailsByInventionId({
                inventionId: this.recordData.Id
            })
            if (thesisRes[0] !== null) {
                this.thesisData = thesisRes[0]
            }
        } else if (error) {
            console.log(error)
            console.log(error.body.message)
        }

        this.loading = false
    }

    //Getter helpers for returning data from the record to the HTML template
    get dateOfConceptionOfInvention() {
        return this.recordData?.Conception_Date__c ?? ''
    }

    get whereDateHasBeenDocumented() {
        return this.recordData?.Conception_Comment__c ?? ''
    }

    get inventionFirstPublicationDate() {
        return this.recordData?.Publication_Date__c ?? ''
    }

    get inventionFirstPublicationComment() {
        return this.recordData?.First_Publication_Comment__c ?? ''
    }

    get anticipatedDate() {
        return this.recordData?.Anticipated_Publication_Disclosure_Date__c ?? ''
    }

    get anticipatedDateKnown() {
        return this.recordData?.Disclosure_Anticipated_Publication__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get anticipatedSpecifiedPublication() {
        return this.recordData?.Anticipated_Publication_Comment__c ?? ''
    }

    get anticipatedPresentationTypes() {
        if (!this.recordData?.Type_Of_Presentation__c) {
            return [' ']
        }
        return this.recordData?.Type_Of_Presentation__c.split(';')
    }

    get renderAnticipatedPresentationTypes() {
        if (this.recordData?.Type_Of_Presentation__c) {
            return this.recordData?.Type_Of_Presentation__c.split(';').length >
                0
                ? true
                : false
        }
        return false
    }

    get inventionsPubliclyPresented() {
        return this.recordData?.Disclosure_Oral_Presentation__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get inventionPubliclyPresentedDate() {
        return this.recordData?.Oral_Disclosure_Date__c ?? ''
    }

    get inventionPubliclyPresentedComment() {
        return this.recordData?.First_Oral_Disclosure_Comment__c ?? ''
    }

    get thesisType() {
        return this.thesisData?.Thesis_Type__c ?? ''
    }

    get nameOfStudent() {
        return this.thesisData?.Name_of_Student__c ?? ''
    }

    get partOfThesis() {
        return this.recordData?.Disclosure_Part_Of_Thesis__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get publishedOrDisclosed() {
        return this.recordData?.Disclosure_Published_Or_Disclosed__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get thesisComment() {
        return this.thesisData?.Thesis_Comment__c ?? ''
    }

    get thesisDefenseDate() {
        return this.thesisData?.Thesis_Defense_Date__c ?? ''
    }

    get thesisHold() {
        return this.recordData?.Disclosure_Thesis_Hold__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get thesisSubmittedDate() {
        return this.thesisData?.Thesis_Submitted_Date__c ?? ''
    }

    get thesisDegreeDate() {
        return this.thesisData?.Thesis_Degree_Date__c ?? ''
    }

    get reducedToPractice() {
        return this.recordData?.Disclosure_Reduced_To_Practice__c === 'Yes'
            ? 'Yes'
            : 'No'
    }

    get reductionToPracticeDate() {
        return this.recordData?.Reduced_To_Practice_Date__c ?? ''
    }

    get reductionToPracticeComment() {
        return this.recordData?.Reduced_To_Practice_Comment__c ?? ''
    }

    // Getter helpers that assist with the conditional rendering of the elements on HTML templates, specifically for the icons and fields
    get isPublishedOrDisclosed() {
        return this.recordData?.Disclosure_Published_Or_Disclosed__c === 'Yes'
            ? true
            : false
    }

    get isAnticipatedDateKnown() {
        return this.recordData?.Disclosure_Anticipated_Publication__c === 'Yes'
            ? true
            : false
    }

    get isInventionsPubliclyPresented() {
        return this.recordData?.Disclosure_Oral_Presentation__c === 'Yes'
            ? true
            : false
    }

    get isPartOfThesis() {
        return this.recordData?.Disclosure_Part_Of_Thesis__c === 'Yes'
            ? true
            : false
    }

    get thesisMustBeOnHold() {
        return this.recordData?.Disclosure_Thesis_Hold__c === 'Yes'
            ? true
            : false
    }

    get isReducedToPractice() {
        return this.recordData?.Disclosure_Reduced_To_Practice__c === 'Yes'
            ? true
            : false
    }
}