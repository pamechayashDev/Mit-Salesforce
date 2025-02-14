@IsTest
public with sharing class DisclosureInitiateSigningProcessAPI2Test {
    @TestSetup
    static void setup(){
        TestSetup.defaultConfiguration();
        TestSetup.defaultDocTemplatesConfiguration();
    }
    static void setupTestData(String name) {
        ContactSampleDataFactory.createSampleContacts();
        DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(name, false);
    }

   
    @IsTest
    static void testInitiatedSigningProcess() {
        String name = 'Name testInitiatedSigningProcess';
        DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

        Disclosure__c disclosure = [SELECT Id
                                        FROM Disclosure__c 
                                        WHERE Name__c = :name LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
        req.httpMethod = 'GET';        
        req.params.put('disclosureId', disclosure.Id);

        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new DocGenApiMock());
            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();
        Test.stopTest();
        
        System.assert(result != null, 'result cannot be null');
        System.assert(res.statusCode == 202, 'HTTP Status Code should be 202');

        Disclosure__c disclosureToCheck = [SELECT Id, Status__c, Signing_Envelop_Id__c, Signing_Init_Job_Id__c,
                                                    Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate

                                        FROM Disclosure__c 
                                        WHERE Id = :disclosure.Id];

        System.assert(disclosureToCheck.Signing_Envelop_Id__c != null, 'Signing_Envelop_Id__c should have been created');
        System.assert(disclosureToCheck.Signing_Init_Job_Id__c != null, 'Signing_Init_Job_Id__c should have been created');
    }

    @IsTest
    static void testInitiatedSigningProcessStillInProgress() {
        System.debug('testInitiatedSigningProcessStillInProgress');

        String name = 'Name testInitiatedSigningProcessStillInProgress';
        DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

        Disclosure__c disclosure = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c 
                                    WHERE Name__c = :name LIMIT 1];

        Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req.httpMethod = 'GET';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response= res;

            Test.setMock(HttpCalloutMock.class, new DocGenApiMock()
                        .setRaiseDocuSignException(false));
            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();
        

            System.assert(result != null, 'result cannot be null');
            System.assert(res.statusCode == 202, 'HTTP Status Code should be 202');
        Test.stopTest();

        //Fake a delay before updating the check
        
        //update the disclosure (this should force the LastModifiedDate to be different from when we initiated the process ie: Last_Modified_at_time_of_Signing_Request__c)
        Disclosure__c disclosureToUpdate = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                        FROM Disclosure__c
                                        WHERE Id = :disclosure.Id];

        disclosureToUpdate.Name__c = 'I\'ve Been Updated';
        disclosureToUpdate.Last_Modified_at_time_of_Signing_Request__c = DateTime.now().addSeconds(-5);
        update disclosureToUpdate;

        Disclosure__c disclosureToCheck = [SELECT Id, Status__c, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                        FROM Disclosure__c
                                        WHERE Id = :disclosure.Id];


        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();

        req2.requestURI = '/api/initiate-signing-process/v2?disclosureId';
        req2.httpMethod = 'GET';
        req2.params.put('disclosureId', disclosure.Id);

        RestContext.request = req2;
        RestContext.response = res2;

        // Call initiateDisclosureSigningProcess for 2nd time on this Unit Test
        // after an update has been made to disclosure BUT no Async Job completed .. process should still be in pgrogress
        String result2 = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

        System.assert(result2 != null, 'result cannot be null');
        System.assertEquals(202, res2.statusCode, 'HTTP Status Code should be 202');

    }

    @IsTest
    static void testInitiatedSigningProcessUpdateEnvelopeStepsNeeded() {
        System.debug('testInitiatedSigningProcessUpdateEnvelopeStepsNeeded');

        String name = 'Name testInitiatedSigningProcessUpdateEnvelopeStepsNeeded';
        DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

        Disclosure__c disclosure = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c 
                                    WHERE Name__c = :name LIMIT 1];

        Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req.httpMethod = 'GET';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response= res;

            Test.setMock(HttpCalloutMock.class, new DocGenApiMock());
            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

            disclosure.Signing_Envelop_Id__c = '123456789';
            disclosure.Last_Modified_at_time_of_Signing_Request__c = DateTime.now().addSeconds(-5);
            update disclosure;
        

            System.assert(result != null, 'result cannot be null');
            System.assert(res.statusCode == 202, 'HTTP Status Code should be 202');

            //Fake a delay before updating the check

            //update the disclosure (this should force the LastModifiedDate to be different from when we initiated the process ie: Last_Modified_at_time_of_Signing_Request__c)
            Disclosure__c disclosureToUpdate = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                            FROM Disclosure__c 
                                            WHERE Id = :disclosure.Id];
            
            disclosureToUpdate.Name__c = 'I\'ve Been Updated';
            disclosureToUpdate.Last_Modified_at_time_of_Signing_Request__c = DateTime.now().addSeconds(-5);
            update disclosureToUpdate;  
            
            Disclosure__c disclosureToCheck = [SELECT Id, Status__c, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                            FROM Disclosure__c 
                                            WHERE Id = :disclosure.Id];


            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();  
            
            req2.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req2.httpMethod = 'GET';        
            req2.params.put('disclosureId', disclosure.Id);

            RestContext.request = req2;
            RestContext.response = res2;

            // Call initiateDisclosureSigningProcess for 2nd time on this Unit Test
            // after an update has been made to disclosure BUT no Async Job completed .. process should still be in pgrogress
            String result2 = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

            System.assert(result2 != null, 'result cannot be null');
            System.assert(res2.statusCode == 202, 'HTTP Status Code should be 202');
        Test.stopTest();   
        

    }

    @IsTest
    static void testInitiatedSigningProcessComplete() {
        System.debug('testInitiatedSigningProcessComplete');
        Test.startTest();

            Test.setMock(HttpCalloutMock.class, new DocGenApiMock());

            String name = 'Name testInitiatedSigningProcessComplete';
            DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

            Disclosure__c disclosure = [SELECT Id, Signing_Init_Job_Id__c
                                            FROM Disclosure__c
                                            WHERE Name__c = :name LIMIT 1];

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req.httpMethod = 'GET';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response= res;

            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

            //fake successfull call to DocuSign to set Async task as done and assigne envelopeId to Disclosure
            disclosure = [SELECT Id, Signing_Init_Job_Id__c
                                                        FROM Disclosure__c
                                                        WHERE Name__c = :name LIMIT 1];
        Test.stopTest();

        disclosure.Signing_Envelop_Id__c = '123456789';
        disclosure.Last_Modified_at_time_of_Signing_Request__c = DateTime.now();
        update disclosure;
    

        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();  
        
        req2.requestURI = '/api/initiate-signing-process/v2?disclosureId';
        req2.httpMethod = 'GET';        
        req2.params.put('disclosureId', disclosure.Id);

        RestContext.request = req2;
        RestContext.response = res2;

        // Call initiateDisclosureSigningProcess for 2nd time on this Unit Test
        // as we've faked the Async job and setting of envelopeId on Disclosure this could be ready to proceed now. 
        String result2 = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

        System.assert(result2 != null, 'result cannot be null');
        System.assertEquals(200, res2.statusCode, 'HTTP Status Code should be 200 -> \'Disclosure DocuSign Envelope Ready for Inventors to start signing\' result2: ' + result2);

        
    }

    @IsTest
    static void testInitiatedSigningProcessFailedThrowsException() {
        System.debug('testInitiatedSigningProcessFailedThrowsException');

        String name = 'Name testInitiatedSigningProcessFailedThrowsException';
        DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

        Disclosure__c disclosure = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c 
                                    WHERE Name__c = :name LIMIT 1];
        DocGenApiMock docGenApiMock = new DocGenApiMock()
                    .setRaiseDocuSignException(true);
        Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req.httpMethod = 'GET';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response= res;


            Test.setMock(HttpCalloutMock.class, docGenApiMock);
            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

            System.assert(result != null, 'result cannot be null');
            System.assert(res.statusCode == 202, 'HTTP Status Code should be 202');

        try{
            Test.stopTest();
            System.assert(false, 'Exception not thrown');
        } catch(CalloutException ex) {
            System.assert(true, 'Exception thrown');
        }
        docGenApiMock.setRaiseDocuSignException(false);
        Disclosure__c disclosureToCheck = [SELECT Id, Status__c, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate, Signing_Envelop_Id__c,
                                            Signing_Init_Job_Id__c
                                        FROM Disclosure__c
                                        WHERE Id = :disclosure.Id];
        System.assert(disclosureToCheck.Signing_Envelop_Id__c == null, 'Signing_Envelop_Id__c should be null');
        System.assert(disclosureToCheck.Signing_Init_Job_Id__c != null, 'Signing_Init_Job_Id__c should not be null');

        AsyncApexJob jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id = :disclosureToCheck.Signing_Init_Job_Id__c];
        System.assert(jobInfo.Status != 'Completed' , 'A new retry Job should be queued');


        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();

        req2.requestURI = '/api/initiate-signing-process/v2?disclosureId';
        req2.httpMethod = 'GET';
        req2.params.put('disclosureId', disclosure.Id);

        RestContext.request = req2;
        RestContext.response = res2;

        // Call initiateDisclosureSigningProcess after a failed InitiateDocuSignEnvelopeJob job
        String result2 = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

        System.assert(result2 != null, 'result cannot be null');
        System.assertEquals(202, res2.statusCode, 'HTTP Status Code should be 202');

        // Cannot trigger more than one Job in Unit test
        // The next job status should be 500 if the queued job also returns 'Failed'

    }

    @IsTest
    static void testInitiatedSigningProcess500() {
        System.debug('testInitiatedSigningProcessFailedThrowsException');
        Configurations__c config = Configurations__c.getInstance('initSigningJobMaxNumberOfRetry') ;
        config.Value__c = '0';
        update config;

        String name = 'Name testInitiatedSigningProcessFailedThrowsException';
        DisclosureInitiateSigningProcessAPI2Test.setupTestData(name);

        Disclosure__c disclosure = [SELECT Id, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate
                                    FROM Disclosure__c
                                    WHERE Name__c = :name LIMIT 1];
        DocGenApiMock docGenApiMock = new DocGenApiMock()
                    .setRaiseDocuSignException(true);
        Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/initiate-signing-process/v2?disclosureId';
            req.httpMethod = 'GET';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response= res;


            Test.setMock(HttpCalloutMock.class, docGenApiMock);
            String result = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

            System.assert(result != null, 'result cannot be null');
            System.assert(res.statusCode == 202, 'HTTP Status Code should be 202');

        try{
            Test.stopTest();
            System.assert(false, 'Exception not thrown');
        } catch(CalloutException ex) {
            System.assert(true, 'Exception thrown');
        }

        Disclosure__c disclosureToCheck = [SELECT Id, Status__c, Name__c, Last_Modified_at_time_of_Signing_Request__c, LastModifiedDate, Signing_Envelop_Id__c,
                                            Signing_Init_Job_Id__c
                                        FROM Disclosure__c
                                        WHERE Id = :disclosure.Id];
        System.assert(disclosureToCheck.Signing_Envelop_Id__c == null, 'Signing_Envelop_Id__c should be null');
        System.assert(disclosureToCheck.Signing_Init_Job_Id__c != null, 'Signing_Init_Job_Id__c should not be null');

        // Workaround: The exception did not change the status, Failed and Aborted handled the same in Service
        System.abortJob(Id.valueOf(disclosureToCheck.Signing_Init_Job_Id__c));

        AsyncApexJob jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id = :disclosureToCheck.Signing_Init_Job_Id__c];
        System.assertEquals('Aborted', jobInfo.Status, 'AsyncApexJob should be in \'Failed\' state');


        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();

        req2.requestURI = '/api/initiate-signing-process/v2?disclosureId';
        req2.httpMethod = 'GET';
        req2.params.put('disclosureId', disclosure.Id);

        RestContext.request = req2;
        RestContext.response = res2;

        // Call initiateDisclosureSigningProcess after a failed InitiateDocuSignEnvelopeJob job
        String result2 = DisclosureInitiateSigningProcessAPIV2.initiateDisclosureSigningProcess();

        System.assert(result2 != null, 'result cannot be null');
        System.assertEquals(500, res2.statusCode, 'HTTP Status Code should be 500');


    }



}