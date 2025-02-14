@IsTest
public with sharing class AsyncRequestHelperTest {
    @IsTest
    public static void prepareAsyncRequestTest() {
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );

        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Antibody Disclosure for BioTang',
            'Draft',
            inventorContact
        );

        Async_Request__c asyncRequest = AsyncRequestHelper.prepareAsyncRequest(
            disclosure.Id,
            'Disclosure__c',
            'JobName'
        );

        System.assert(asyncRequest != null, 'asyncRequest should not be null');
        System.assert(
            asyncRequest.Has_Processed__c == false,
            'asyncRequest.Has_Processed__c  should be false'
        );
        System.assert(
            asyncRequest.Retry_Count__c == 0,
            'asyncRequest.Retry_Count__c  should be 0'
        );
        System.assert(
            asyncRequest.Record_Id__c == disclosure.Id,
            'asyncRequest.Record_Id__c  should be ' + disclosure.Id
        );
        System.assert(
            asyncRequest.sObject_Name__c == 'Disclosure__c',
            'asyncRequest.Record_Id__c  should be Disclosure__c'
        );
        System.assert(
            asyncRequest.Job_Name__c == 'JobName',
            'asyncRequest.Job_Name__c  should be JobName'
        );
    }
}