import getSoftwareCodeByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getSoftwareCodeByDisclosureId"
import getOpenSourceBySoftwareCodeId from "@salesforce/apex/DisclosureRecordFetch.getOpenSourceBySoftwareCodeId"
import getThirdPartyCodeBySoftwareCodeId from "@salesforce/apex/DisclosureRecordFetch.getThirdPartyCodeBySoftwareCodeId"


import { getDisclosureBody, getDepartmentHeads } from 'c/disclosureBodyRest';
import { jsonPropertyFromValue, booleanFromYNU } from "c/forresterUtils"

const populateSoftwareCodeData = (async (disclosure, user) => {
    let bodyData = await getDisclosureBody(disclosure, user)
    console.log('🅰️ Starting populateSoftwareCodeData')
    let invention = getSoftwareCodeByDisclosureId({disclosureId: disclosure.id}).then((result) => {
        console.log('results', result)
        console.log('results[0]', result[0])
        return result[0]
    }).catch((error) => {
        console.log('Error fetching Software Code Disclosure', error)
    })

    const departmentHeadsPromise = getDepartmentHeads(disclosure)

    const departmentHeads = await departmentHeadsPromise

    return invention.then((fields) => {
        console.log('Populating Software Code')
        if (fields == null || fields === undefined) {
            console.log('🔴 Error: NO Software Code exist, for Disclosure: ' + disclosure.id)
            throw new Error('NO Software Code exist, for Disclosure: ' + disclosure.id)
        }


        bodyData.disclosureBody = {
            disclosureType: 'Software',
            isOpenSourceFlag: booleanFromYNU(fields.Is_Open_Source_YN__c),
            yearsCodeFirstCreated: jsonPropertyFromValue(fields.Years_Code_First_Created__c),
            yearsCodeFirstPublished: jsonPropertyFromValue(fields.Years_Code_First_Published__c),
            softwareDescription: jsonPropertyFromValue(disclosure.fields.Description__c.value), // need value
            departmentHead: (departmentHeads && departmentHeads.length > 0 ) ? departmentHeads[0] : undefined ,
            openSource: undefined,
            thirdPartiesCode: undefined
        }

        return getThirdPartyCodeBySoftwareCodeId({softwareDisclosureId: fields.Id}).then((third) => {
            for (let i = 0; i < third.length; i++) {
                if (i === 0 ){
                    bodyData.disclosureBody.thirdPartiesCode = []
                }
                bodyData.disclosureBody.thirdPartiesCode.push(  {
                    "isCodeAvailableOnWebFlag": jsonPropertyFromValue(third[i].Is_Code_Available_On_Web__c),
                    "codeName": jsonPropertyFromValue(third[i].Name),
                    "licenseType": jsonPropertyFromValue(third[i].License_Type__c),
                    "openSourceOtherComments": jsonPropertyFromValue(third[i].Open_Source_Other_Comments__c),
                    "webPageToDownloadCode": jsonPropertyFromValue(third[i].Web_Page_To_Download_Code__c),
                    "webPage3rdPartyLicense": jsonPropertyFromValue(third[i].Web_Page_Third_Party_License__c),
                })
            }

            return getOpenSourceBySoftwareCodeId({softwareDisclosureId: fields.Id}).then((openSource) => {
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

export {populateSoftwareCodeData}