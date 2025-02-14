@isTest
public with sharing class GuestAccountTest {
    public static Integer uniqueCounter = 0;
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    static Disclosure__c setupTestDisclosure() {
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c disclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            'UnitTestTloOfficerForrester1',
            true
        );
        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;
        disclosure.Status__c = 'Approved';
        disclosure.Case_Number__c = '123425';
        update disclosure;

        return disclosure;
    }

    static Account getContactByEmail(String email) {
        return [
            SELECT
                Id,
                MitId__pc,
                InvitationCode__pc,
                GuestAccountNeeded__pc,
                FirstName,
                MiddleName,
                LastName,
                PersonEmail,
                AltEmail__pc,
                PersonMobilePhone,
                Institution__pc,
                InstitutionCode__pc
            FROM Account
            WHERE PersonEmail = :email
        ];
    }

    @isTest
    static void invitationCodeRestTest() {
        Disclosure__c disclosure = setupTestDisclosure();

        Account sampleNonMitContact = getContactByEmail(
            'cr11@guest.test'
        );
        System.assert(
            sampleNonMitContact.MitId__pc == null,
            'Guest Account mitId should be null'
        );
        System.assert(
            sampleNonMitContact.InvitationCode__pc == null,
            'Guest Account invitation code should be null'
        );
        sampleNonMitContact.GuestAccountNeeded__pc = 'Yes';
        update sampleNonMitContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GuestAccountMock());
        GuestAccount.createGuestAccounts(disclosure.Id);
        Test.stopTest();

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            disclosure.Id
        );
        System.assert(!inventors.isEmpty(), 'Disclosure inventors is empty');
        for (DisclosureInventor__c inventor : inventors) {
            // GuestAccountNeeded__c was 'Yes' and now set to 'No'
            if (inventor.Contact__r.Id == sampleNonMitContact.Id) {
                System.assert(
                    inventor.Contact__r.GuestAccountNeeded__pc == 'No',
                    'Guest Account Needed should be No'
                );
                System.assert(
                    inventor.Contact__r.MitId__pc != null,
                    'Guest Account Missing mitId'
                );
                System.assert(
                    inventor.Contact__r.InvitationCode__pc != null,
                    'Guest Account Missing invitation code'
                );
            } else {
                System.assert(
                    inventor.Contact__r.InvitationCode__pc == null,
                    'Guest Account invitation code should not be set'
                );
            }
        }
    }

    @isTest
    static void accountMitIdNotFound404RestTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        Account sampleNonMitContact = getContactByEmail(
            'cr11@guest.test'
        );
        sampleNonMitContact.GuestAccountNeeded__pc = 'Yes';
        update sampleNonMitContact;
        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GuestAccountMock(404));
            GuestAccount.createGuestAccounts(disclosure.Id);
            Test.stopTest();
            System.assert(
                false,
                'Provided MitId not found exception not thrown'
            );
        } catch (CalloutException ex) {
            System.assert(true, 'Exception thrown');
        }
    }

    @isTest
    static void accountEmailExist409RestTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        Account sampleNonMitContact = getContactByEmail(
            'cr11@guest.test'
        );
        sampleNonMitContact.GuestAccountNeeded__pc = 'Yes';
        update sampleNonMitContact;

        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new GuestAccountMock(409));
            GuestAccount.createGuestAccounts(disclosure.Id);
            Test.stopTest();
            System.assert(
                false,
                'Account with Email already exist exception not thrown'
            );
        } catch (CalloutException ex) {
            System.assert(true, 'Exception thrown');
        }
    }

    @isTest
    static void updateGuestAccountRestTest() {
        Disclosure__c disclosure = setupTestDisclosure();
        Account sampleNonMitContactwihMitId = getContactByEmail(
            'cr13@guest.test'
        );
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GuestAccountMock());
        GuestAccount.updateGuestAccount(sampleNonMitContactwihMitId);
        Test.stopTest();
    }

    public class GuestAccountMock implements HttpCalloutMock {
        Integer statusCode;
        public GuestAccountMock() {
            this.statusCode = 201;
        }
        public GuestAccountMock(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            System.debug(req.getEndpoint());
            uniqueCounter++;
            String apiPath = ApiConfigurationBuilder.getApiPathToString('guestAccountApi');
            if (
                req.getEndpoint()
                    .containsIgnoreCase(apiPath + '/invite-codes')
            ) {
                Date validUntil = Date.today().addDays(3);
                GuestApiDto.InviteCodeRequest request = (GuestApiDto.InviteCodeRequest) JSON.deserialize(
                    req.getBody(),
                    GuestApiDto.InviteCodeRequest.class
                );
                GuestApiDto.InviteCodeResponse response = new GuestApiDto.InviteCodeResponse();
                response.inviteCode = 'QTK0DE' + uniqueCounter;
                response.systemName = 'TLO';
                response.validUntil =
                    Helpers.formatDate(validUntil) + 'T23:59:59Z';
                response.email = request.email;

                if (request.mitId == null) {
                    Integer randomMitNumber = Integer.valueof(
                        (Math.random() * 10000)
                    );
                    response.mitId = '9' + uniqueCounter + randomMitNumber;
                } else {
                    response.mitId = request.mitId;
                }

                String responseBody = JSON.serialize(response, true);
                HTTPResponse res = new HTTPResponse();
                res.setBody(responseBody);
                res.setStatusCode(statusCode);
                return res;
            }

            if (
                req.getEndpoint()
                    .containsIgnoreCase(apiPath + '/guest-accounts')
            ) {
                if (req.getMethod() == 'GET') {
                    GuestApiDto.GuestAccountInfoWithMitIdResponse respObj = new GuestApiDto.GuestAccountInfoWithMitIdResponse();
                    respObj.scopedUserId = 'scopedUserId';
                    respObj.status = 'ACTIVE';
                    String responseStr = JSON.serializePretty(respObj);
                    HTTPResponse res = new HTTPResponse();
                    res.setBody(responseStr);
                    res.setStatusCode(200);

                    return res;
                }

                if (req.getMethod() == 'PUT') {
                    GuestApiDto.GuestAccountUpdateRequest request = (GuestApiDto.GuestAccountUpdateRequest) JSON.deserialize(
                        req.getBody(),
                        GuestApiDto.GuestAccountUpdateRequest.class
                    );
                    GuestApiDto.GuestAccountInfoWithMitIdResponse response = new GuestApiDto.GuestAccountInfoWithMitIdResponse();
                    response.firstName = request.firstName;
                    response.middleName = request.middleName;
                    response.lastName = request.lastName;
                    response.email = request.email;
                    response.telephone = request.telephone;
                    response.status = request.status;
                    Integer randomMitNumber = Integer.valueof(
                        (Math.random() * 10000)
                    );
                    response.mitId = '9' + uniqueCounter + randomMitNumber;

                    String responseBody = JSON.serialize(response, true);
                    HTTPResponse res = new HTTPResponse();
                    res.setBody(responseBody);
                    res.setStatusCode(201);
                    return res;
                }
            }

            return null;
        }
    }
    @isTest
    static void sandboxGuestAccountDEVTest() {
        // Mock Prod
        System.assert(GuestAccount.isValidEmail('gtest@gmail.com'), 'Email should be valid');
        System.assert(GuestAccount.orgEnvironment == 'PROD', 'Need to mock PROD Org Environment');

        String prodJitEmail = GuestAccount.getSandboxJITEmail('fox@gmail.com');
        System.assertEquals('fox@gmail.com', prodJitEmail, 'PROD Org Environment JIT Email should not change');

        GuestAccount.orgEnvironment = 'DEV';
        System.assert(GuestAccount.orgEnvironment == 'DEV', 'Need to mock DEV Org Environment');
        List<String> invalidList = new List<String>{
            'gtest@gmail.com',
            'g+test@gmail.com',
            'gdev@gmail.com',
            'jack+test@gmail.com',
            'jack@gmail+dev.com',
            'jack+DEV@gmail.com',
            '+devjack@gmail.com',
            'mjfox@mit.edu'

        };
        for (String email : invalidList) {
            System.assert(!GuestAccount.isValidEmail(email), 'Email should be invalid ' + email);    
        }

        List<String> validList = new List<String>{
            'jack+dev@gmail.com',
            'jack+dev.1@gmail.com',
            '+dev.jack@gmail.com',
            'fen+dev.1jack@gmail.com',
            '+dev.1jack@gmail.com'

        };
        for (String email : validList) {
            System.assert(GuestAccount.isValidEmail(email), 'Email should be valid ' + email);    
        }

        String mitEmail = GuestAccount.getSandboxJITEmail('fox@mit.edu');
        System.assertEquals('fox@mit.edu', mitEmail, 'Mit JIT Email conversion');

        String jitEmail = GuestAccount.getSandboxJITEmail('fox@gmail.com');
        System.assertEquals('fox+dev@gmail.com', jitEmail, 'JIT Email conversion');

        String validJitEmail = GuestAccount.getSandboxJITEmail('fox+dev@gmail.com');
        System.assertEquals('fox+dev@gmail.com', validJitEmail, 'JIT Email conversion');

        String nullJitEmail = GuestAccount.getSandboxJITEmail(null);
        System.assertEquals(null, nullJitEmail, 'null JIT Email');

        String blankJitEmail = GuestAccount.getSandboxJITEmail('');
        System.assertEquals('', blankJitEmail, 'Blank JIT Email');


    }

    @isTest
    static void sandboxGuestAccountQATest() {
        Configurations__c config = Configurations__c.getInstance('orgEnvironment');
        config.Value__c = 'QA';
        update config;
        System.assert(GuestAccount.orgEnvironment == 'QA', 'Need to mock QA Org Environment');
        System.assert(!GuestAccount.isValidEmail(''), 'Email should be invalid');
        System.assert(GuestAccount.isValidEmail(null), 'Email should be valid');
        List<String> invalidList = new List<String>{
            'gtest@gmail.com',
            'gTEST@gmail.com',
            'gTEST.1@gmail.com',
            'jeff+dev.1@gmail.com'

        };
        for (String email : invalidList) {
            System.assert(!GuestAccount.isValidEmail(email), 'Email should be invalid ' + email);    
        }

        List<String> validList = new List<String>{
            'jeff+test.1@gmail.com',
            'jeff+test.2@gmail.com',
            'jeff+test@gmail.com',
            'george+test.c@gmail.com'
        };
        for (String email : validList) {
            System.assert(GuestAccount.isValidEmail(email), 'Email should be valid ' + email);    
        }

        String jitEmail = GuestAccount.getSandboxJITEmail('fox@gmail.com');
        System.assertEquals('fox+test@gmail.com', jitEmail, 'JIT Email conversion');


        try{
            ContactSampleDataFactory.createSampleQAContacts();
        } catch(Exception e) {
            System.assert(false, 'Unexpected Exception thrown ' + e.getMessage());
        }

        try{
            ContactSampleDataFactory.createSampleContacts();
            System.assert(false, 'Exception not thrown');
        } catch(Exception e) {}
    }

     @isTest
     static void sandboxGuestAccountDEVNoConfigTest() {
        Configurations__c config = Configurations__c.getInstance('orgEnvironment');
        delete config;
        System.assert(GuestAccount.orgEnvironment == 'DEV', 'Need to mock DEV Org Environment');
        System.assert(GuestAccount.isValidEmail('jack+dev.1@gmail.com'), 'Email should be valid');
     }

     @isTest
     static void voidGuestAccountStatus() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGuestAccountStatus());
        GuestAccount.AccountDataWrapper wrapper = GuestAccount.getGuestAccountStatus('abc@test.com');
        System.assert(wrapper != null, 'Response not empty');
        Test.stopTest();
     }

     @isTest
     static void guestAccountNeededTest() {
        GuestAccount.orgEnvironment = 'PROD';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGuestAccount404Status());
        Account jitContact = ContactSampleDataFactory.createJITContactManual();
        System.assertEquals('ben@mit.edu', jitContact.PersonEmail, 'Mit email expected');
        System.assertEquals('No', jitContact.GuestAccountNeeded__pc, 'Guest Account Needed Flag not set');
        System.assertEquals(false, jitContact.IsAlumni__pc, 'Not Alumni');
        System.assertEquals(false, Helpers.isActiveKerb(jitContact.MoiraStatus__pc), 'Not Active');
        jitContact.PersonEmail = 'cr-ben@guest.test';
        update jitContact;
        System.debug('📩 Email Changed');

        List<String> futureJsonRecords = new List<String>();
        futureJsonRecords.add(JSON.serialize(new Tlo_Contact_Email_Event__e(
                                                                 Event_Name__c = 'onEmailUpdated',
                                                                 TloContactId__c = jitContact.Id,
                                                                 Email__c = jitContact.PersonEmail
                                                             )
                                            ));
        // Future method does not execute in Test
        TloContactEmailEventHandler.futureAfterUpdateEvent(futureJsonRecords);

        Test.stopTest();


        Account invitedUser = getContactByEmail(
            'cr-ben@guest.test'
        );
        System.assertEquals('Yes',invitedUser.GuestAccountNeeded__pc, 'Guest Account Needed Flag not Set');


     }



     private class MockHttpResponseGuestAccountStatus implements HttpCalloutMock {
         // Implement this interface method
         public HTTPResponse respond(HTTPRequest req) {

             String endPointAccountStatus = '/account-status?email';
             String endPointAccountSearch = '/guest-accounts';
             String endPointInviteCode = '/invite-codes?email';

             // Create a fake response
             HttpResponse res = new HttpResponse();
             res.setHeader('Content-Type', 'application/json');

             if (req.getEndpoint().containsIgnoreCase(endPointAccountStatus)) {
                res.setBody('{"status":""}');
             }

             if (req.getEndpoint().containsIgnoreCase(endPointAccountSearch)) {
                res.setBody('{"mitId": "971897526","firstName": "Alexa","lastName": "Bates","middleName": "Jaine","scopedUserId": "00uhdj3btfTNqmcv7697@guest.mit.edu","status": "ACTIVE","email": "alexa.bates+dev@testondev.com"}');
             }

             if (req.getEndpoint().containsIgnoreCase(endPointInviteCode)) {
                res.setBody('{"inviteCodes":[{"systemName":"","inviteCode":"","validUntil":"","email":""}]}');
             }
             res.setStatusCode(200);
             return res;
         }
     }

     private class MockHttpResponseGuestAccount404Status implements HttpCalloutMock {
      // Implement this interface method
      public HTTPResponse respond(HTTPRequest req) {

          String endPointAccountStatus = '/account-status?email';
          String endPointAccountSearch = '/guest-accounts';
          String endPointInviteCode = '/invite-codes?email';

          // Create a fake response
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/json');

          if (req.getMethod() == 'POST'  && req.getEndpoint().containsIgnoreCase('invite-codes')) {
            res.setBody('{"inviteCodes":[{"systemName":"","inviteCode":"AXC35","validUntil":"","email":""}]}');
            res.setStatusCode(200);
            return res;
          }

          if (req.getEndpoint().containsIgnoreCase(endPointAccountStatus) || req.getEndpoint().containsIgnoreCase(endPointInviteCode) || req.getEndpoint().containsIgnoreCase(endPointAccountSearch) ) {
            res.setBody('{"message":"Not Found"}');
          }
          res.setStatusCode(404);
          return res;
      }
  }

}