@isTest
public with sharing class DisclosureInventorSignedToForresterTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    static void testPrepareJSONRequestBody() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account nonMitInventorContact = SampleDataFactory.createContact(
            'Donald',
            false,
            null
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'DeptHead1',
            true,
            '123456782'
        );
        Account piContact = SampleDataFactory.createContact(
            'PI',
            true,
            '123456784'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            inventorContact
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Test',
            disclosure
        );
        Department_Head__c deptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContact
        );

        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        DisclosureInventor__c nonMitInventor = SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContact
        );

        inventor.Signed_Status__c = 'Yes';
        inventor.Signed_Disclosure_Date__c = Date.newInstance(2023, 3, 13);
        update inventor;

        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Case_Number__c = '12345J';
        disclosure.Status__c = 'Approved';
        update disclosure;

        List<Async_Request__c> asyncJobs = [
            SELECT
                Id,
                Has_Processed__c,
                Retry_Count__c,
                Record_Id__c,
                sObject_Name__c
            FROM Async_Request__c
            WHERE
                Has_Processed__c = FALSE
                AND Retry_Count__c < 3
                AND sObject_Name__c = 'DisclosureInventor__c'
                AND Job_Name__c = 'InventorSignedDisclosureToForresterJob'
        ];
        System.assert(
            asyncJobs.size() == 0,
            'Expecting 0 DisclosureInventor__c SignedDisclosure job entry'
        );

        DisclosureInventor__c disinv = DisclosureInventorSignedToForrester.getDisclosureInventorById(
            inventor.Id
        );
        System.assert(disinv != null, 'Unable to find Disclosure Inventor');
        System.assert(
            disinv.Disclosure__r.Case_Number__c != null,
            'Case Number required for call out'
        );

        Account tloContact = DisclosureRecordFetch.getContactById(
            disinv.Contact__c
        );
        String jsonBody = DisclosureInventorSignedToForrester.prepareJSONRequestBody(
            disinv,
            tloContact,
            true
        );
        System.debug(jsonBody);

        nonMitInventor.Signed_Status__c = 'Yes';
        nonMitInventor.Signed_Disclosure_Date__c = Date.newInstance(
            2023,
            3,
            13
        );
        update nonMitInventor;

        // User complete additional questions
        nonMitInventor.WorkDoneOutsideMIT__c = 'Yes';
        nonMitInventor.WorkDoneOutsideMITDetails__c = 'Details of work done';
        nonMitInventor.AdditionalComments__c = 'Test Comments';
        update nonMitInventor;

        DisclosureInventor__c disNonMitInv = DisclosureInventorSignedToForrester.getDisclosureInventorById(
            nonMitInventor.Id
        );
        System.assert(
            disNonMitInv != null,
            'Unable to find Disclosure Non-MIT Inventor'
        );
        Account tloNonMitContact = DisclosureRecordFetch.getContactById(
            disNonMitInv.Contact__c
        );
        String jsonNonMitBody = DisclosureInventorSignedToForrester.prepareJSONRequestBody(
            disNonMitInv,
            tloNonMitContact,
            true
        );
        System.debug(jsonNonMitBody);
        System.assert(
            jsonNonMitBody != null,
            'Failed to Prepare JSON for Non-MIT Inventor'
        );

        PatchDisclosureDto dto = (PatchDisclosureDto) System.JSON.deserialize(
            jsonNonMitBody,
            PatchDisclosureDto.class
        );
        System.assertEquals(
            dto.inventors[0].additionalInformation.additionalComments,
            'Test Comments',
            'additionalComments on JSON should be same as inventor.AdditionalComments__c'
        );

        List<Async_Request__c> asyncJobsNonMit = [
            SELECT
                Id,
                Has_Processed__c,
                Retry_Count__c,
                Record_Id__c,
                sObject_Name__c
            FROM Async_Request__c
            WHERE
                Has_Processed__c = FALSE
                AND Retry_Count__c < 3
                AND sObject_Name__c = 'DisclosureInventor__c'
                AND Job_Name__c = 'InventorSignedDisclosureToForresterJob'
        ];
        System.assert(
            asyncJobsNonMit.size() == 1,
            'Expecting 1 DisclosureInventor__c SignedDisclosure job entry'
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ForresterMock());
        String jobId = Database.executeBatch(
            new DisclosureInventorSignedToForrester(),
            1
        );
        System.Assert(
            jobId != null,
            'DisclosureInventorSignedToForrester jobId can not be null'
        );
        Test.stopTest();
    }

    @isTest
    static void testNoQuestionForSubmittingInventor() {
        Test.setMock(HttpCalloutMock.class, new ForresterMock());
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account inventorContact = SampleDataFactory.createContact(
            'Inventor',
            true,
            '123456781'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Delegate Action',
            'Draft',
            inventorContact
        );
        disclosure.SubmittedOnBehalf__c = false;
        update disclosure;

        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );

        inventor.WorkDoneOutsideMIT__c = 'Yes';
        inventor.WorkDoneOutsideMITDetails__c = 'Details of work done';
        inventor.AdditionalComments__c = 'Test Comments';
        inventor.DocuSign_Recipient_StatusCode__c = 'Completed'; //additional questions only sent to Forrester when Disclosure signed
        update inventor;

        List<Async_Request__c> asyncJobs = [
            SELECT
                Id,
                Has_Processed__c,
                Retry_Count__c,
                Record_Id__c,
                sObject_Name__c
            FROM Async_Request__c
            WHERE
                Has_Processed__c = FALSE
                AND Retry_Count__c < 3
                AND sObject_Name__c = 'DisclosureInventor__c'
                AND Job_Name__c = 'InventorSignedDisclosureToForresterJob'
        ];
        System.assertEquals(
            asyncJobs.size(),
            0,
            'No InventorSignedDisclosureToForresterJob should be created for the Submitting Inventor'
        );
    }

    public class ForresterMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            String apiPath = ApiConfigurationBuilder.getApiPathToString(
                'forresterApi'
            );
            if (
                req.getEndpoint().containsignorecase(apiPath + '/disclosures/')
            ) {
                String responsebody = '{"status": "SUCCESS"}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }

            return null;
        }
    }

    public class Forrester400Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            System.debug(req.getEndpoint());
            String apiPath = ApiConfigurationBuilder.getApiPathToString(
                'forresterApi'
            );
            if (
                req.getEndpoint().containsignorecase(apiPath + '/disclosures/')
            ) {
                String responsebody = '{"message": "failed"}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(400);
                return res;
            }

            return null;
        }
    }
}