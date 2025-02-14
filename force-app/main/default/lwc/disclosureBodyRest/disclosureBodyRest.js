import getDisclosureInternalFundingByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getDisclosureInternalFundingByDisclosureId"
import getDisclosureExternalFundingByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getDisclosureExternalFundingByDisclosureId"
import getDepartmentHeadByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getDepartmentHeadByDisclosureId";
import { getInventors } from "c/inventors"
import { jsonPropertyFromValue } from "c/forresterUtils"
import { getCustomAttributes } from "c/customAttributes"
import { getCommercialInterest } from "c/commercialInterest"

const getDisclosureBody = (async (disclosure, user) => {
    const customAttributesPromise = getCustomAttributes(disclosure)
    const commercialInterestPromise = getCommercialInterest(disclosure)
    const inventorsPromise = getInventors(disclosure)
    const internalFundingPromise = getDisclosureInternalFundingByDisclosureId({ disclosureId: disclosure.id });
    const externalFundingPromise = getDisclosureExternalFundingByDisclosureId({ disclosureId: disclosure.id });

    const customAttributes = await customAttributesPromise
    const commercialInterest = await commercialInterestPromise
    const inventors = await inventorsPromise
    const internalFunding = await internalFundingPromise
    const externalFunding = await externalFundingPromise

    const internalSponsors = internalFunding.map((sponsor) => {
        console.log("Sponsor", sponsor)
        return {
            "externalFunding": false,
            "fundingBody": {
                "costObjectKnown": sponsor ? jsonPropertyFromValue(sponsor.CostObjectKnown__c) : undefined, // api support y_n_u
                "costObjectNumber": sponsor ? jsonPropertyFromValue(sponsor.CostObjectNumber__c) : undefined,
                "internalFundingDetail": sponsor ? jsonPropertyFromValue(sponsor.FundingDetails__c) : undefined
            }
        }
    });

    const externalSponsors = externalFunding.map((sponsor) => {
        console.log("Sponsor", sponsor)
        return {
            "externalFunding": true,
            "fundingBody": {
                "ospProjectNumber": sponsor ? jsonPropertyFromValue(sponsor.Award_Id__c) : undefined,
                "grantContactNumber": sponsor ? jsonPropertyFromValue(sponsor.GrantOrContactNumber__c) : undefined,
                "sponsorName": sponsor ? jsonPropertyFromValue(sponsor.Sponsor_Name__c) : undefined,
                "principalInvestigator": sponsor?.PI_Acc__r ? jsonPropertyFromValue(sponsor.PI_Acc__r.Name) : undefined,
            }
        }
    });
    // Using disclosure.fields.Submitting_Contact__r.value.fields.Name.value for submittedBy will show in Forrester as Approved By user.
    const bodyData = {
        "externalReferenceId": jsonPropertyFromValue(disclosure.fields.External_ID__c.value),
        "title": jsonPropertyFromValue(disclosure.fields.Name__c.value),
        "user": jsonPropertyFromValue(user.fields.Name.value),
        "submittedBy": jsonPropertyFromValue(user.fields.Name.value), // This is the TLO user that Approved the Disclosure
        "description": jsonPropertyFromValue(disclosure.fields.Description__c.value),
        "funding": {
            "fundingDetails": jsonPropertyFromValue(disclosure.fields.Funding_Details__c.value),
            "internalSponsors": (internalSponsors && internalSponsors.length > 0) ? internalSponsors : undefined,
            "externalSponsors": (externalSponsors && externalSponsors.length > 0) ? externalSponsors : undefined
        },
        "commercialInterests": commercialInterest,
        "customAttributes": customAttributes,
        "inventors": inventors,
        "disclosureBody": undefined
    }

    return bodyData;
});


const getDepartmentHeads = (async (disclosure) => {
    const deptPromise = getDepartmentHeadByDisclosureId({ disclosureId: disclosure.id }).then((departmentHead) => {
        console.log("DepartmentHead", departmentHead);
        let deptHeadList;
        for (let i_1 = 0; i_1 < departmentHead.length; i_1++) {
            if (i_1 === 0) {
                deptHeadList = []
            }
            let deptHead = departmentHead[i_1];
            const departmentHeadJson = {
                'deptHeadName': jsonPropertyFromValue(deptHead.Contact__r.Name),
                'deptHeadTitle': jsonPropertyFromValue(deptHead.Title__c),
                'deptHeadDept': jsonPropertyFromValue(deptHead.Contact__r.PersonDepartment),
                'deptHeadMitId': jsonPropertyFromValue(deptHead.Contact__r.MitId__pc),
                'deptHeadDateSigned': jsonPropertyFromValue(deptHead.Signed_Date__c)
            };
            deptHeadList.push(departmentHeadJson)
        }
        return deptHeadList;
    });
    return await deptPromise;
})



export { getDisclosureBody, getDepartmentHeads }