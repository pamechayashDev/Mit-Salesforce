@isTest
public class CheckAccountByMITIDTest {
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"people":[{ "student":null,"staff":true,"scopedUserId":"ebj@mit.edu","preferredName":"Eran","OdlcName":null,"nonMitEmail":null,"mitIdObsolete":"N","mitIdCreationDate":"Fri Jun 07 2024 14:24:59 GMT+0000 (Coordinated Universal Time)","mitId":"900047159","mitHrOrgUnitId":"10000273","mitEmail":"ebj@mit.edu","legalMiddleName":null,"legalLastName":"Ben-Joseph","legalFirstName":"Eran","krbName":"ebj","kerbCreationDate":"2011-03-28T21:19:33.000Z","jobTitle":"Professor","institution":null,"homeAddressZip":null,"homeAddressStreet1":null,"homeAddressStateCode":null,"homeAddressCity":null,"gradStudent":null,"dobMonth":"08","dobDay":"10","deceased":false,"alumniRecordTypeName":null,"alumniRecordTypeCode":null,"affiliate":false}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    
    @testSetup
    static void setupTestData() {
     ApiConfigurations__c config = new ApiConfigurations__c();
   //     config.Api_Base__c = 'peopleSearchApi';
      //  config.Api_Path__c = 'peopleSearchApi';
        config.Name = 'peopleSearchApi';
        insert config;
        Account personAccount = new Account(
            FirstName = 'Test',
            LastName = 'User',
            MitId__pc = 'MIT12345',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id
        );
        insert personAccount;
    }

    @isTest
    static void testCheckByMITID_AccountFound() {

        Account personAccount = [SELECT Id, MitId__pc FROM Account WHERE MitId__pc = 'MIT12345' LIMIT 1];
        system.debug('personAcc---'+personAccount);
        Test.startTest();
  
        Map<String, Object> result = CheckAccountByMITID.checkByMITID(personAccount.MitId__pc);
        Test.stopTest();
           system.debug('res--'+result);

        System.assertEquals('Account Found', result.get('Status'), 'The status should indicate the account was found');
        System.assert(result.get('Account')!=null, 'The account should be included in the response');
        System.assertEquals('', result.get('responseToCreateAccount'), 'responseToCreateAccount should be empty for found accounts');
    }

    @isTest
    static void testCheckByMITID_AccountNotFound() {
                Test.startTest();
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());


        Map<String, Object> result = CheckAccountByMITID.checkByMITID('900047159');
        Test.stopTest();
     system.debug('result of not found'+result);
        // Assert the response
        System.assertEquals('Account Not Found', result.get('Status '), 'The status should indicate the account was not found');
        System.assert(result.get('Account')=='', 'The account should be null for accounts not found');
        System.assert(result.get('responseToCreateAccount')!=null, 'responseToCreateAccount should contain data when account not found');
    }  
}