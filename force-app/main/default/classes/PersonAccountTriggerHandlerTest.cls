@isTest
public class PersonAccountTriggerHandlerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testOnBeforeInsert() {
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );
        cont1.GovernmentEmployeeStatus__pc = true;
        try {
            update cont1;
        } catch (Exception ex) {
            String msg = ex.getMessage();
            system.assert(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }

    @isTest
    public static void testOnBefore() {
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        cont.VaAppointment__pc = 'No';
        cont.GovernmentEmployeeStatus__pc = false;
        update cont;

        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );

        Account cont2 = [
            SELECT Id, VaAppointmentDetails__pc, Government_Agency_Name__pc
            FROM Account
            WHERE Id = :cont.Id
        ];

        system.assertEquals(cont2.VaAppointmentDetails__pc, null);
        system.assertEquals(
            cont2.Government_Agency_Name__pc,
            'Federal Bureau of Investigation'
        );

        // Update Contact name
        cont.PreferredName__pc = 'JJ';
        update cont;
        Account contact = [
            SELECT Name
            FROM Account
            WHERE Id = :cont.Id
        ];
        System.assertEquals(
            contact.Name,
            'Donald Donald Donald',
            'Expected name to be "Preferred Name + Last Name"'
        );

        cont.PreferredName__pc = null;
        cont.FirstName = 'John';
        cont.LastName = 'James';
        update cont;
        contact = [
            SELECT Name
            FROM Account
            WHERE Id = :cont.Id
        ];
        System.assertEquals(
            contact.Name,
            'John Donald James',
            'Expected name to be "First Name + Middle Name + Last Name"'
        );
    }

    @isTest
    public static void testOnAfterUpdate() {
        Test.startTest();
        User user = getUserWithRole();
        System.runAs(user) {
            Test.setMock(
                HttpCalloutMock.class,
                new GuestAccountTest.GuestAccountMock()
            );
            Contact sampleContact1 = createExistingContact(
                'this1@must.change',
                '968581554'
            );
            createExistingUser('this1@must.change', sampleContact1.Id);
            Contact sampleContact2 = createExistingContact(
                'this2@must.change',
                '968581555'
            );
            createExistingUser('this2@must.change', sampleContact2.Id);

            Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Software_Code_Disclosure')
                .getRecordTypeId();
            Account cont1 = SampleDataFactory.createContact(
                'Donald1',
                false,
                '968581544'
            );
            Id cont1ContactId = [
                SELECT PersonContactId
                FROM Account
                WHERE Id = :cont1.Id
            ].PersonContactId;
            createExistingUser(
                'Donald1_sample@external.com',
                cont1ContactId
            );
            cont1.PersonEmail = 'cr_d1@guest.test';
            Account cont2 = SampleDataFactory.createContact(
                'Donald2',
                false,
                '968581545'
            );
            Id cont2ContactId = [
                SELECT PersonContactId
                FROM Account
                WHERE Id = :cont2.Id
            ].PersonContactId;
            createExistingUser(
                'Donald2_sample@external.com',
                cont2ContactId
            );
            cont2.PersonEmail = 'cr_d2@guest.test';
            List<Account> contactChangedList = new List<Account>();
            contactChangedList.add(cont1);
            contactChangedList.add(cont2);
            update contactChangedList;
        }
        Test.stopTest();

        Account resultCon1 = [
            SELECT Id, PersonEmail, FirstName, MiddleName, LastName, MitId__pc
            FROM Account
            WHERE MitId__pc = '968581544'
            LIMIT 1
        ];
        Account resultCon2 = [
            SELECT Id, PersonEmail, FirstName, MiddleName, LastName, MitId__pc
            FROM Account
            WHERE MitId__pc = '968581545'
            LIMIT 1
        ];

        User resultUser1 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, AccountId
            FROM User
            WHERE AccountId = :resultCon1.Id
            LIMIT 1
        ];

        User resultUser2 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, AccountId
            FROM User
            WHERE AccountId = :resultCon2.Id
            LIMIT 1
        ];

        System.assertEquals(
            'cr_d1@guest.test',
            resultCon1.PersonEmail,
            'Contact object Email should be cr_d1@guest.test'
        );
        System.assertEquals(
            'cr_d1@guest.test',
            resultUser1.Email,
            'User object Email should be cr_d1@guest.test'
        );
        System.assertEquals(
            'cr_d2@guest.test',
            resultCon2.PersonEmail,
            'Contact object Email should be cr_d2@guest.test'
        );
        System.assertEquals(
            'cr_d2@guest.test',
            resultUser2.Email,
            'User object Email should be cr_d2@guest.test'
        );
    }

    static User getUserWithRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        insert r;

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
        userExample.UserRoleId = r.Id;

        insert userExample;
        return userExample;
    }

    static Contact createExistingContact(String email, string mitId) {
        Id mitInventorAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('MIT_Inventor')
            .getRecordTypeId();
        Account acc = new Account(
            Name = mitId,
            RecordTypeId = mitInventorAccRecTypeId
        );

        insert acc;

        Contact contactExample = new Contact();
        contactExample.FirstName = 'First';
        contactExample.LastName = 'Last';
        contactExample.AccountId = acc.Id;
        contactExample.MitId__c = mitId;
        contactExample.Email = email;

        insert contactExample;
        return contactExample;
    }

    static void createExistingUser(String email, Id contactId) {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String profileName = ShirleyConstants.COMMUNITY_PROFILE_NAME;
        Profile p = [SELECT Id FROM profile WHERE name = :profileName];

        User userExample = new User();
        userExample.Username =
            'emailtest' +
            '_' +
            DateTime.now().format('MM-dd-yyyy-HH-mm-ss') +
            email +
            UserInfo.getOrganizationId().toLowerCase();
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = email;
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = p.Id;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.ContactId = contactId;

        insert userExample;
    }
}