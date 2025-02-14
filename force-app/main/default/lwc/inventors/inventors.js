import getDisclosureInventorByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getDisclosureInventorByDisclosureId"
import getContactById from "@salesforce/apex/DisclosureRecordFetch.getContactById"
import getDisclosureInventorAffiliatedPicklist from "@salesforce/apex/DisclosureRecordFetch.getDisclosureInventorAffiliatedPicklist"
import getDisclosureInventorFundingDlcPicklist from "@salesforce/apex/DisclosureRecordFetch.getDisclosureInventorFundingDlcPicklist"
import { jsonPropertyFromValue, birthDayFromValue } from "c/forresterUtils"
const getInventors = (async (disclosure) => {

    const inventorList = await getDisclosureInventorByDisclosureId({ disclosureId: disclosure.id })
    const affiliatedMap = await getDisclosureInventorAffiliatedPicklist();
    const fundingDlcMap = await getDisclosureInventorFundingDlcPicklist();


    const response = await Promise.all(inventorList.map(async (inventor) => {
        console.log("Inventor", inventor)

        const contact = await getContactById({ id: inventor.Contact__c })
        console.log('contact', contact)

        let extraQuestions;

        if (inventor) {

            extraQuestions = {
                'salaryOrWages': jsonPropertyFromValue(inventor.SalaryWages__c), // API support y_n_u, and can be used with out converting
                'salaryOrWagesDetail': jsonPropertyFromValue(inventor.SalaryWagesDetails__c),
                'workAtMit': jsonPropertyFromValue(inventor.WorkDoneAtMIT__c),
                'workAtOtherInstitution': jsonPropertyFromValue(inventor.WorkDoneOutsideMIT__c),
                'workAtOtherInstitutionMoreDetail': jsonPropertyFromValue(inventor.WorkDoneOutsideMITDetails__c),
                'wasResearchAsPartOfCollaboration': jsonPropertyFromValue(inventor.Collaboration__c),
                'wasResearchAsPartOfCollaborationMoreDetail': jsonPropertyFromValue(inventor.CollaborationDetails__c),
                'wasResearchAsPerformedByConsultant': jsonPropertyFromValue(inventor.ConsultantOrContract__c),
                'wasResearchAsPerformedByConsultantMoreDetail': jsonPropertyFromValue(inventor.ConsultantOrContractDetails__c),
                'fundingDlc': inventor.FundingThroughDlc__c ? inventor.FundingThroughDlc__c.split(';').map(x => fundingDlcMap[x.trim()]) : undefined,
                'affiliationOptions': inventor.AffiliatedWithOrgsDlcs__c ? inventor.AffiliatedWithOrgsDlcs__c.split(';').map(x => affiliatedMap[x.trim()]) : undefined,
                'additionalSponsoredResearchOrFundingSources': jsonPropertyFromValue(inventor.AdditionalSponsorsOrFunding__c),
                'conceivedDuringCourseWork': jsonPropertyFromValue(inventor.PartOfClass__c),
                'conceivedDuringCourseWorkMoreDetail': jsonPropertyFromValue(inventor.PartOfClassDetails__c),
                'thirdPartyMaterialsOrDatasets': jsonPropertyFromValue(inventor.ThirdPartyMaterials__c),
                'additionalComments': jsonPropertyFromValue(inventor.AdditionalComments__c)
            }
            const extraQuestionsAsJson = JSON.stringify(extraQuestions);
            if (extraQuestionsAsJson === '{}') {
                //object is empty
                extraQuestions = undefined
            }
        }
        /*using disclosure.fields.SubmittedOnBehalf__c.value will result in NO Inventor being added, default to false */
        return {
            "mitId": jsonPropertyFromValue(contact.MitId__pc),
            "inventorName": jsonPropertyFromValue(contact.Name),
            'legalGivenName': jsonPropertyFromValue(contact.FirstName),
            'legalMiddleName': jsonPropertyFromValue(contact.MiddleName),
            'legalLastName': jsonPropertyFromValue(contact.LastName),
            "email": jsonPropertyFromValue(contact.PersonEmail),
            'oldEmail': jsonPropertyFromValue(contact.OldEmail__pc),
            "hhmi": jsonPropertyFromValue(contact.HHMI_Current__pc), //checkbox
            "hhmiCurrentDateOfTenure": jsonPropertyFromValue(contact.HHMI_Current_Date_From__pc),
            "signedDisclosureFlag": jsonPropertyFromValue(inventor.Signed_Status__c === 'Yes' ? true : false), //checkbox
            "govEmployeeStatusFlag": contact.GovernmentEmployeeStatus__pc, // checkbox
            "atMitAtTheTimeOfInvention": jsonPropertyFromValue(inventor.MitAtTimeOfInvention__c), //checkbox
            "alternatePhone": jsonPropertyFromValue(contact.PersonMobilePhone),
            "alternateEmail": jsonPropertyFromValue(contact.AltEmail__pc),
            "alternateAddress": jsonPropertyFromValue(contact.PersonMailingStreet),
            "alternateAddressCity": jsonPropertyFromValue(contact.PersonMailingCity),
            "alternateAddressState": jsonPropertyFromValue(contact.PersonMailingState),
            "alternateAddressZipcode": jsonPropertyFromValue(contact.PersonMailingPostalCode),
            "alternateAddressCountry": jsonPropertyFromValue(contact.PersonMailingCountry),
            "countryCitizenship": jsonPropertyFromValue(contact.CountryOfCitizenship__pc),
            "submitOnBehalfOf": jsonPropertyFromValue(false), //checkbox SOB does not automatically get added as inventor and cannot add themselves as an inventor either
            "additionalInformation": extraQuestions,
            "primaryContact": jsonPropertyFromValue(inventor.PrimaryInventor__c),
            'institution': jsonPropertyFromValue(contact.Institution__pc),
            'institutionCode': jsonPropertyFromValue(contact.InstitutionCode__pc),
            'birthday': birthDayFromValue(contact.PersonBirthdate),
            'position': jsonPropertyFromValue(contact.PersonTitle),// Position__c deprecated
            'department': jsonPropertyFromValue(contact.Department__pc)
        }
    }))

    return response
})


export { getInventors }