@isTest
public with sharing class DisclosureInventorSignedHandlerTest {
    // @TestSetup
    // static void setup() {
    //     TestSetup.defaultConfiguration();
    // }

    // @isTest
    // public static void testSignDisclosureCreatesAsyncJobForDocRetrieval() {
    //     // Setup variables
    //     ContactSampleDataFactory.createSampleContacts();

    //     String title = 'testSignDisclosureCreatesAsyncJobForDocRetrieval';
    //     Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureNoDeptHead(
    //         title,
    //         true
    //     );

    //     List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
    //         disclosure.Id
    //     );
    //     DisclosureInventor__c inventor = inventors[0];

    //     inventor.DocuSign_Recipient_StatusCode__c = 'Completed';
    //     update inventor;

    //     List<DisclosureInventor__c> inventorsToTest = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureIdInventorId(
    //         disclosure.Id,
    //         inventor.Id
    //     );
    //     DisclosureInventor__c inventorToTest = inventorsToTest[0];
    //     System.assertEquals(
    //         'Yes',
    //         inventorToTest.Signed_Status__c,
    //         'Should be true?'
    //     );

    //     List<Async_Request__c> asyncRequests = [
    //         SELECT
    //             Id,
    //             Has_Processed__c,
    //             Retry_Count__c,
    //             Record_Id__c,
    //             sObject_Name__c
    //         FROM Async_Request__c
    //         WHERE
    //             Has_Processed__c = FALSE
    //             AND Retry_Count__c = 0
    //             AND sObject_Name__c = 'DisclosureInventor__c'
    //             AND Job_Name__c = 'FetchInventorSignedDocJob'
    //             AND Record_Id__c = :inventorToTest.Id
    //     ];

    //     System.assertEquals(
    //         1,
    //         asyncRequests.size(),
    //         'asyncRequest for this Inventor Should Exist'
    //     );
    // }
}