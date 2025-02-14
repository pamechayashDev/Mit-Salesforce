import getCommercialInterestsByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getCommercialInterestsByDisclosureId"
import { jsonPropertyFromValue } from "c/forresterUtils"
const getCommercialInterest = (async (disclosure) => {

    const commercialInterestList = await getCommercialInterestsByDisclosureId({ disclosureId: disclosure.id })

    const response = await Promise.all(commercialInterestList.map(async (commercial) => {
        console.log("commercialInterest", commercial)
            return {
                companyName: jsonPropertyFromValue(commercial?.Company_Name__c),
                contactName: jsonPropertyFromValue(commercial?.Contact_Name__c),
                contactEmail: jsonPropertyFromValue(commercial?.Contact_Email__c)
            }
    }))
    const filtered = response ? response.filter(att => att !== null && att !== undefined ) : undefined;
    return filtered !== undefined && filtered.length > 0 ? filtered : undefined;
})


export {getCommercialInterest}