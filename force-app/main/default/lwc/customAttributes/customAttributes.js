import getDisclosureInventorByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getDisclosureInventorByDisclosureId"
import getContactById from "@salesforce/apex/DisclosureRecordFetch.getContactById"
import { arrayPushKeyValue, ynuFromBoolean } from "c/forresterUtils"
import getCopyrightByDisclosureId from "@salesforce/apex/DisclosureRecordFetch.getCopyrightByDisclosureId";

const getCustomAttributes = (async (disclosure) => {

    const inventorList = await getDisclosureInventorByDisclosureId({ disclosureId: disclosure.id })

    // eslint-disable-next-line consistent-return
    let response = await Promise.all(inventorList.map(async (inventor) => {
        console.log("Inventor Custom Attributes", inventor)

        const contact = await getContactById({ id: inventor.Contact__c })
        console.log('tlo', contact)

        //Clarification from T&M. No field in Forrester, need to Use Custom attributes to store as comment?
        //The comment text should be: This inventor, [Name of Inventor], is a US Government employee and works in [Government Agency].
        if (contact.GovernmentEmployeeStatus__pc === true) {
            return {
                entityContext: 'CASE_ADMIN',
                key: 'Government Agency',
                value: `This inventor, ${contact.Name}, is a US Government employee and works in ${contact.Government_Agency_Name__pc}`
            }
        }
    }))

    if (response === undefined || response === null) {
        response = [];
    }

    if (disclosure.fields.SubmittedOnBehalf__c.value === true) {
        const contact = await getContactById({ id: disclosure.fields.Submitting_Contact__r.value.fields.Id.value })
        const comments = [];
        //Add the Submitting TLO Contact as Admin comments.
        const submittedKey = 'Submitted By';
        arrayPushKeyValue(comments, '\nName', contact.Name);
        arrayPushKeyValue(comments, 'Email', contact.PersonEmail);
        arrayPushKeyValue(comments, 'MIT-Id', contact.MitId__pc);
        arrayPushKeyValue(comments, 'Submitted On Behalf Of', ynuFromBoolean(disclosure.fields.SubmittedOnBehalf__c.value));

        const submittedValue = comments.join('\n');
        const submittedBy = {
            entityContext: 'CASE_ADMIN',
            key: submittedKey,
            value: submittedValue
        }
        response.push(submittedBy);
    }

    if (disclosure != null && disclosure.fields.RecordType.value.fields.DeveloperName.value === 'Copyright_Disclosure') {
        let copyright = getCopyrightByDisclosureId({ disclosureId: disclosure.id }).then((result) => {
            return result[0]
        }).catch((error) => {
            console.log('Error fetching Copyright Disclosure', error)
        })
        await copyright.then((fields) => {

            const comments = [];
            //Add the MIT Point Of Contact as Admin comments.
            const submittedKey = 'MIT Point of Contact';
            arrayPushKeyValue(comments, '\nName', fields.MIT_Point_of_Contact_Acc__r?.Name);
            arrayPushKeyValue(comments, 'Email', fields.MIT_Point_of_Contact_Acc__r?.PersonEmail);
            arrayPushKeyValue(comments, 'MIT-Id', fields.MIT_Point_of_Contact_Acc__r?.MitId__pc);
            const submittedValue = comments.join('\n');
            const submittedBy = {
                entityContext: 'CASE_ADMIN',
                key: submittedKey,
                value: submittedValue
            }
            response.push(submittedBy);
        })
    }

    const filtered = response ? response.filter(att => att !== null && att !== undefined) : undefined;
    return filtered !== undefined && filtered.length > 0 ? filtered : undefined;
})


export { getCustomAttributes }