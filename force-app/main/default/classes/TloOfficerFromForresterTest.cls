@isTest
public with sharing class TloOfficerFromForresterTest {

    @TestSetup
    static void setup(){
       TestSetup.defaultConfiguration();
    }

    static Disclosure__c setupTestDisclosure() {

        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c approvedSoftwareDisclosure =  SoftwareDisclosuresSampleFactory.createDisclosure('UnitTestTloOfficerForrester1', true);
        approvedSoftwareDisclosure.Status__c = 'Inventor Submitted';
        update approvedSoftwareDisclosure;
        approvedSoftwareDisclosure.Status__c = 'Approved';
        approvedSoftwareDisclosure.Case_Number__c = '123425';
        update approvedSoftwareDisclosure;
 
        Disclosure__c disclosure = DisclosureDao.getDisclosureWithAllFields(approvedSoftwareDisclosure.Id);
        System.assert(disclosure.External_ID__c != null, 'Expecting External Id to be defined');
        return disclosure;
    }

   
    @isTest
    static void forresterRestTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        System.assert(disclosure.TLO_License_Officer__c == null, 'TloOfficer should be empty');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ForresterMock(disclosure.External_ID__c));
        String jobId = Database.executeBatch(new TloOfficerFromForrester(), 1);
        System.assert(jobId != null, 'TloOfficer From Forrester jobId can not be null');
        Test.stopTest();


        Set<String> disclosureIds = new Set<String>();
        disclosureIds.add(disclosure.Id);
        Disclosure__c disclosureUpdated = DisclosureRecordFetch.getDisclosuresByIds(disclosureIds)[0];
        System.assert(disclosureUpdated.TLO_License_Officer__c != null, 'TloOfficer should not be empty');

        TLO_Officer__c officer = disclosureUpdated.TLO_License_Officer__r;
        System.assert(officer.Name != String.valueOf(officer.Id), 'TloOfficer name not set ');

        
        Configurations__c config = Configurations__c.getInstance(TloOfficerFromForrester.LAST_SYNC_DATE_CONFIG);
        System.assert(config.Value__c == Helpers.formatDate(DateTime.now()), 'Last Successful Sync Date should be set');
        

    }

 
    @isTest
    static void forresterRestNoDataTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        System.assert(disclosure.TLO_License_Officer__c == null, 'TloOfficer should be empty');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ForresterNoDataMock());
        String jobId = Database.executeBatch(new TloOfficerFromForrester(), 1);
        System.assert(jobId != null, 'TloOfficer From Forrester jobId can not be null');
        Test.stopTest();

        Disclosure__c disclosureUpdated = DisclosureDao.getDisclosureWithAllFields(disclosure.Id);
        System.assert(disclosureUpdated.TLO_License_Officer__c == null, 'TloOfficer should be empty');

        List<Log_Exception__c> errors = [SELECT Id FROM Log_Exception__c];
        System.assert(errors.isEmpty(), 'No Errors should exist');
        
        Configurations__c config = Configurations__c.getInstance(TloOfficerFromForrester.LAST_SYNC_DATE_CONFIG);
        System.assert(config.Value__c == Helpers.formatDate(DateTime.now()), 'Last Successful Sync Date should be set');
        

    }

    @isTest
    static void forresterRestNullDataTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        System.assert(disclosure.TLO_License_Officer__c == null, 'TloOfficer should be empty');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ForresterNullDataMock());
        String jobId = Database.executeBatch(new TloOfficerFromForrester(), 1);
        System.assert(jobId != null, 'TloOfficer From Forrester jobId can not be null');
        Test.stopTest();

        Disclosure__c disclosureUpdated = DisclosureDao.getDisclosureWithAllFields(disclosure.Id);
        System.assert(disclosureUpdated.TLO_License_Officer__c == null, 'TloOfficer should be empty');

        List<Log_Exception__c> errors = [SELECT Id FROM Log_Exception__c];
        System.assert(errors.isEmpty(), 'No Errors should exist');
        
        Configurations__c config = Configurations__c.getInstance(TloOfficerFromForrester.LAST_SYNC_DATE_CONFIG);
        System.assert(config.Value__c == Helpers.formatDate(DateTime.now()), 'Last Successful Sync Date should be set');
        

    }

    



   public class ForresterMock implements HttpCalloutMock {
        String externalId;
        public ForresterMock(String externalId) {
            this.externalId = externalId;
        }
        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            if (req.getEndpoint().containsignorecase('licensing-officer/updated?page=1&')) {
                String responsebody='{"totalItems": 3, "totalPages": 3, "currentPage": 1, "results": [{"externalId": ' + externalId + ', "caseNumber": "123425", "caseSuffix": "J", "caseStatus": "ACTIVE", "caseOfficer": {"officerId": "CORD", "mitId": "903728169", "name": "Cordellia Sita", "email": "csita@mit.edu"}}]}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }
            if (req.getEndpoint().containsignorecase('licensing-officer/updated?page=2&')) {
                String responsebody='{"totalItems": 3, "totalPages": 3, "currentPage": 2, "results": [{"externalId": -2, "caseNumber": "24356", "caseSuffix": null, "caseStatus": "ACTIVE", "caseOfficer": {"officerId": "MB", "mitId": "903728170", "name": "Mary Baker", "email": "mbaker@mit.edu"}}]}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }

            if (req.getEndpoint().containsignorecase('licensing-officer/updated?page=3&')) {
                String responsebody='{"totalItems": 3, "totalPages": 3, "currentPage": 3, "results": [{"externalId": 6069, "caseNumber": "24357", "caseSuffix": null, "caseStatus": "ACTIVE", "caseOfficer": {"officerId": "DP", "name": "Deirdre Patel", "email": "tlo-tech@mit.edu"}}]}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }

            return null;
        }
    }

    public class ForresterNoDataMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            if (req.getEndpoint().containsignorecase('licensing-officer/updated?page=1&')) {
                String responsebody='{"totalItems": 0, "totalPages": 0, "currentPage": 1, "results": []}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }
           
            return null;
        }
    }

    public class ForresterNullDataMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            if (req.getEndpoint().containsignorecase('licensing-officer/updated?page=1&')) {
                String responsebody='{"totalItems": 0, "totalPages": 0, "currentPage": 1}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(200);
                return res;
            }
           
            return null;
        }
    }


}