@IsTest
public with sharing class JitApiTest {
    private static User createExistingUser() {        
        String profileName =  'System Administrator'; // ShirleyConstants.COMMUNITY_PROFILE_NAME;
        Id communityProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'emailtest' + '_' + DateTime.now().format('MM-dd-yyyy-HH-mm-ss') + '@test.com.unit.test.' + UserInfo.getOrganizationId().toLowerCase();
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest1@mit.edu';
        userExample.TimeZoneSidKey = JitApi.defaultCommunityUserTimeZone();
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = communityProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        //userExample.ContactId = con.Id;

        insert userExample;
        return userExample;
    }

    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
        User user = createExistingUser();

    }

    // @IsTest  TODO this is failing test data not being used between test cases 
    // static void test_canCreateUser_ExistingUser()
    // {   
    //     UserWrapper userRequest = new UserWrapper(); 
    //     userRequest.firstName =  'First';
    //     userRequest.lastName = 'Last';
    //     userRequest.email =  'emailtest' + '_' + DateTime.now().format('MM-dd-yyyy-HH-mm-ss') + '@tlo.edu';
    //     userRequest.mitId =  '123654';
    //     userRequest.krbName =  'emailtest1';
    //     userRequest.salesforceEnvUsernameSuffix =  '.unit.test';

    //     Id communityProfileId = [SELECT Id FROM User WHERE FirstName = 'createExistingUser';
            
    //     Test.startTest();    
    //         boolean canCreateUser = JitApi.canCreateUser(userRequest);
    //     Test.stopTest();
        
    //     System.assertEquals(canCreateUser, false);    
    // }

    @IsTest
    static void test_canCreateUser_NoUser_Exists()
    {
        UserWrapper userRequest = new UserWrapper(); 
        userRequest.firstName =  'unit test first name';
        userRequest.lastName = 'unit test last name';
        userRequest.email =  'nouser@mit.edu';
        userRequest.mitId =  '9632587';
        userRequest.salesforceEnvUsernameSuffix =  '_unit.test';

        Test.startTest();    
            boolean canCreateUser = JitApi.canCreateUser(userRequest);
        Test.stopTest();
        
        System.assertEquals(canCreateUser, true);    
    }

    @IsTest
    static void test_createUser_UserDoesExists() {
        UserWrapper userRequest = new UserWrapper(); 
        userRequest.firstName =  'First';
        userRequest.lastName = 'Last';
        userRequest.email =  'emailtest1@mit.edu';
        userRequest.mitId =  '123654';
        userRequest.salesforceEnvUsernameSuffix =  '.unit.test';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/api/jit/v1/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(userRequest));

        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        User user = getUserWithRole();
            System.runAs(user) {
                UserResponseWrapper result = JitApi.createUser();
                System.assertEquals(result.username, userRequest.mitId + '@tlo.edu' + userRequest.salesforceEnvUsernameSuffix);
            }
        Test.stopTest();
        

    }

    @IsTest
    static void test_createUser_NoUserExists() {
        UserWrapper userRequest = new UserWrapper(); 
        userRequest.firstName =  'unit test first name';
        userRequest.lastName = 'unit test last name';
        userRequest.email =  'nouser@mit.edu';
        userRequest.mitId =  '9632587';
        userRequest.salesforceEnvUsernameSuffix =  '.unit.test';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/api/jit/v1/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(userRequest));

        RestContext.request = req;
        RestContext.response= res;
        
        UserResponseWrapper result = null;
        Test.startTest();
            User user = getUserWithRole();
            System.runAs(user) {
                result = JitApi.createUser();
            }
        Test.stopTest();
        

        /* Verify the result is correct */
        System.assertEquals(result.username, userRequest.mitId + '@tlo.edu' + userRequest.salesforceEnvUsernameSuffix);
    }    

    static User getUserWithRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        insert r;
        
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'emailtest' + '_' + DateTime.now().format('MM-dd-yyyy-HH-mm-ss') + '@mit.edu.' + UserInfo.getOrganizationId().toLowerCase();
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest1@mit.edu';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.UserRoleId = r.Id;
                
        insert userExample;
        return userExample;

    }
}