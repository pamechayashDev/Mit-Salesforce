@IsTest
public with sharing class JitContactTest {
    @TestSetup
    static void setupTestData() {
        TestSetup.defaultConfiguration();
    }

    public static UserResponseWrapper createUser(UserWrapper user) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/jit/v1/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueof(System.JSON.serialize(user));
        RestContext.response = res;
        UserResponseWrapper wrapper = JitApi.createUser();
        return wrapper;
    }

    public static UserWrapper createUserWrapper(
        String firstName,
        String lastName,
        String emailAddress,
        String mitId
    ) {
        UserWrapper userRequest = new UserWrapper();
        userRequest.firstName = firstName;
        userRequest.lastName = lastName;
        userRequest.email = emailAddress;
        userRequest.mitId = mitId;
        userRequest.salesforceEnvUsernameSuffix = '.unit.test';
        return userRequest;
    }

    static User getUser(UserRole role) {
        Id systemAdminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ]
        .Id;

        User userExample = new User();
        userExample.Username =
            'emailtest' +
            '_' +
            DateTime.now().format('MM-dd-yyyy-HH-mm-ss') +
            '@mit.edu.' +
            UserInfo.getOrganizationId().toLowerCase();
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest1@mit.edu';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.UserRoleId = role.Id;
        insert userExample;
        return userExample;
    }

    public static UserRole getUserRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        insert r;
        return r;
    }

    public static User getJitUser() {
        UserRole role = getUserRole();
        User user = getUser(role);
        UserWrapper userRequest = createUserWrapper(
            'Bob',
            'Tiger',
            'Bob_sample@mit.edu',
            '02345678'
        );
        System.runAs(user) {
            UserResponseWrapper response = createUser(userRequest);
        }
        User jitUser = [
            SELECT Id
            FROM User
            WHERE Email = 'Bob_sample@mit.edu'
            LIMIT 1
        ];
        return jitUser;
    }

    public static User getJitUser(Account jitContact) {
        UserRole role = getUserRole();
        User user = getUser(role);
        UserWrapper userRequest = createUserWrapper(
            jitContact.FirstName,
            jitContact.LastName,
            jitContact.PersonEmail,
            jitContact.MitId__pc
        );
        System.runAs(user) {
            UserResponseWrapper response = createUser(userRequest);
        }
        User jitUser = [
            SELECT Id
            FROM User
            WHERE Email = :jitContact.PersonEmail
            LIMIT 1
        ];
        return jitUser;
    }

    @isTest
    public static void jitOnMitInventorTest() {
        Test.startTest();
        UserRole role = getUserRole();
        User user = getUser(role);
        UserWrapper userRequest = createUserWrapper(
            'Donald',
            'Tiger',
            'Donald_sample@external.com',
            '12345678'
        );
        System.runAs(user) {
            // 1) Contact created before Contact logs in with JIT, for example added as a PiContact on a Disclosure
            // Email is not required but need to be unique
            Account piContact = SampleDataFactory.createContact(
                'Donald',
                false,
                '12345678'
            );

            // 2) The PiContact - Contact logs in for the First time, JIT Create the new User
            UserResponseWrapper response = createUser(userRequest);
            System.assert(true, System.JSON.serialize(response));
        }

        User jitUser = [
            SELECT Id
            FROM User
            WHERE Email = 'Donald_sample@external.com'
            LIMIT 1
        ];

        System.runAs(jitUser) {
            // 3) Contact is logged in
            Account piContactTest = [
                SELECT
                    Id,
                    FirstName,
                    LastName,
                    PersonEmail,
                    MitId__pc,
                    Name,
                    MoiraStatus__pc
                FROM Account
                WHERE MitId__pc = '12345678' AND IsPersonAccount = TRUE
                LIMIT 1
            ];

            System.assert(
                piContactTest.FirstName == userRequest.firstName,
                'JIT did not update empty FirstName'
            );
            System.assert(
                piContactTest.LastName == userRequest.lastName,
                'JIT did not update empty LastName'
            );
            System.assert(
                piContactTest.PersonEmail == userRequest.email,
                'JIT did not update empty Email address'
            );
            System.assert(
                piContactTest.MitId__pc == userRequest.mitId,
                'JIT did not update empty MitID address'
            );
            System.assert(
                String.isNotBlank(piContactTest.MoiraStatus__pc),
                'JIT did not update MitInventor to true'
            );
        }
        Test.stopTest();
    }
}