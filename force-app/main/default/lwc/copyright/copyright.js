import getCopyrightByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getCopyrightByDisclosureId"
import getOpenSourceByCopyrightId from "@salesforce/apex/DisclosureRecordFetch.getOpenSourceByCopyrightId"
import getThirdPartyContentByCopyrightId from "@salesforce/apex/DisclosureRecordFetch.getThirdPartyContentByCopyrightId";
import { getDisclosureBody, getDepartmentHeads } from 'c/disclosureBodyRest';
import { jsonPropertyFromValue, booleanFromYNU } from "c/forresterUtils"

const populateCopyrightData = (async (disclosure, user) => {
    let bodyData = await getDisclosureBody(disclosure, user)
    console.log('🅰️ Starting populateCopyrightData')
    let invention = getCopyrightByDisclosureId({disclosureId: disclosure.id}).then((result) => {
        console.log('results', result)
        console.log('results[0]', result[0])
        return result[0]
    }).catch((error) => {
        console.log('Error fetching Copyright Disclosure', error)
    })

    const departmentHeadsPromise = getDepartmentHeads(disclosure)

    const departmentHeads = await departmentHeadsPromise

    return invention.then((fields) => {
        console.log('Populating Copyright')
        if (fields == null || fields === undefined) {
            console.log('🔴 Error: NO Copyright exist, for Disclosure: ' + disclosure.id)
            throw new Error('NO Copyright exist, for Disclosure: ' + disclosure.id)
        }


        bodyData.disclosureBody = {
            "disclosureType": 'Copyright',
            "creatorsRequestDistributeOpenSourceFlag": booleanFromYNU(fields.Creators_Request_Distrib_Open_Source_YN__c),
            "yearsCodeFirstCreated": jsonPropertyFromValue(fields.Years_Code_First_Created__c),
            "yearsCodeFirstPublished": jsonPropertyFromValue(fields.Years_Code_First_Published__c),
            "partOfEmploymentFlag": booleanFromYNU(fields.Part_Of_Employment_YN__c),
            "copyrightDescription": jsonPropertyFromValue(disclosure.fields.Description__c.value),
            "departmentHead": (departmentHeads && departmentHeads.length > 0 ) ? departmentHeads[0] : undefined ,
            "openSource": undefined,
            "thirdPartiesContent": undefined

        }
        return getThirdPartyContentByCopyrightId({copyrightId: fields.Id}).then((third) => {
            for (let i = 0; i < third.length; i++) {
                if (i === 0 ){
                    bodyData.disclosureBody.thirdPartiesContent = []
                }
                bodyData.disclosureBody.thirdPartiesContent.push({
                    "name": jsonPropertyFromValue(third[i].Name),
                    "source": jsonPropertyFromValue(third[i].Source__c),
                    "comments": jsonPropertyFromValue(third[i].Attachment_Comment__c),
                    "agreementFlag": jsonPropertyFromValue(third[i].Agreement__c) //checkbox
                })
            }
            return getOpenSourceByCopyrightId({disclosureId: fields.Id}).then((openSource) => {
                for (let i = 0; i < openSource.length; i++) {
                    bodyData.disclosureBody.openSource = {
                        "openSourceLicensingFlag": jsonPropertyFromValue(openSource[i].Open_Source_Licensing__c),
                        "openSourceLicensingType": jsonPropertyFromValue(openSource[i].Open_Source_Licensing_Type__c),
                        "openSourceOtherComments": jsonPropertyFromValue(openSource[i].Open_Source_Other_Comments__c),
                    }
                }
                return bodyData;
            })
        })
    })

})

export {populateCopyrightData}