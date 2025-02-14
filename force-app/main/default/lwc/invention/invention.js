import getInventionByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getInventionByDisclosureId"
import getThesisDetailsByInventionId from "@salesforce/apex/DisclosureRecordFetch.getThesisDetailsByInventionId"

import { getDisclosureBody } from 'c/disclosureBodyRest';
import { jsonPropertyFromValue, booleanFromYNU } from "c/forresterUtils"

const populateInventionData = (async (disclosure, user) => {
    let bodyData = await getDisclosureBody(disclosure, user)
    console.log('🅰️ Starting populateInventionData')
    let invention = getInventionByDisclosureId({disclosureId: disclosure.id}).then((result) => {
        console.log('results', result)
        console.log('results[0]', result[0])
        return result[0]
    }).catch((error) => {
        console.log('Error fetching Invention Disclosure', error)
    })


    return invention.then((fields) => {
        console.log('Populating Invention')
        if (fields == null || fields === undefined) {
            console.log('🔴 Error: NO Invention exist, for Disclosure: ' + disclosure.id)
            throw new Error('NO Invention exist, for Disclosure: ' + disclosure.id)
        }


        bodyData.disclosureBody = {
            "disclosureType": 'Invention',
            "antPubDate": jsonPropertyFromValue(fields.Anticipated_Publication_Disclosure_Date__c),
            "antPubDiscFlag": booleanFromYNU(fields.Disclosure_Anticipated_Publication__c), // boolean
            "anticPubComment": jsonPropertyFromValue(fields.Anticipated_Publication_Comment__c),
            "conceptComment": jsonPropertyFromValue(fields.Conception_Comment__c),
            "conceptDate": jsonPropertyFromValue(fields.Conception_Date__c),
            "firstOralDiscComment": jsonPropertyFromValue(fields.First_Oral_Disclosure_Comment__c),
            "firstPubComment": jsonPropertyFromValue(fields.First_Publication_Comment__c),
            "oralDiscDate": jsonPropertyFromValue(fields.Oral_Disclosure_Date__c),
            "partOfThesisFlag": booleanFromYNU(fields.Disclosure_Part_Of_Thesis__c), //boolean
            "pubDate": jsonPropertyFromValue(fields.Publication_Date__c),
            "publishedOrDisclosedFlag": booleanFromYNU(fields.Disclosure_Published_Or_Disclosed__c), //boolean
            "reducedToPracticeComment": jsonPropertyFromValue(fields.Reduced_To_Practice_Comment__c),
            "reducedToPracticeDate": jsonPropertyFromValue(fields.Reduced_To_Practice_Date__c),
            "reducedToPracticeFlag": booleanFromYNU(fields.Disclosure_Reduced_To_Practice__c), //boolean
            "thesis": undefined,
            "thesisHoldFlag": booleanFromYNU(fields.Disclosure_Thesis_Hold__c), //boolean
            "typeOfPresentation": jsonPropertyFromValue(fields.Type_Of_Presentation__c),
            "inventorComment": jsonPropertyFromValue(disclosure.fields.Description__c.value) // no field for this property
        }
        return getThesisDetailsByInventionId({inventionId: fields.Id}).then((thesis) => {
            for (let i = 0; i < thesis.length; i++) {
                bodyData.disclosureBody.thesis = {
                    "thesisDefenseDate": jsonPropertyFromValue(thesis[i].Thesis_Defense_Date__c),
                    "thesisComment": jsonPropertyFromValue(thesis[i].Thesis_Comment__c),
                    "thesisSubmittedDate": jsonPropertyFromValue(thesis[i].Thesis_Submitted_Date__c),
                    "thesisDegreeDate": jsonPropertyFromValue(thesis[i].Thesis_Degree_Date__c),
                }
            }
            return bodyData;
        })

    })


})

export {populateInventionData}