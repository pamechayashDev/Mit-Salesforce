@isTest
public class TLOContactTriggerHandlerTest {
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
            TLO_Contact__c cont1 = SampleDataFactory.createTLOContact(
                'Donald1',
                false,
                '968581554'
            );
            cont1.Email__c = 'cr_d1@guest.test';
            TLO_Contact__c cont2 = SampleDataFactory.createTLOContact(
                'Donald2',
                false,
                '968581555'
            );
            cont2.Email__c = 'cr_d2@guest.test';
            List<TLO_Contact__c> tloContactChangedList = new List<TLO_Contact__c>();
            tloContactChangedList.add(cont1);
            tloContactChangedList.add(cont2);
            update tloContactChangedList;
        }
        Test.stopTest();

        Contact resultCon1 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, MitId__c
            FROM Contact
            WHERE MitId__c = '968581554'
            LIMIT 1
        ];
        Contact resultCon2 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, MitId__c
            FROM Contact
            WHERE MitId__c = '968581555'
            LIMIT 1
        ];

        User resultUser1 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, ContactId
            FROM User
            WHERE ContactId = :resultCon1.Id
            LIMIT 1
        ];

        User resultUser2 = [
            SELECT Id, Email, FirstName, MiddleName, LastName, ContactId
            FROM User
            WHERE ContactId = :resultCon2.Id
            LIMIT 1
        ];

        System.assert(
            resultCon1.Email == 'cr_d1@guest.test',
            'Contact object Email should be cr_d1@guest.test'
        );
        System.assert(
            resultUser1.Email == 'cr_d1@guest.test',
            'User object Email should be cr_d1@guest.test'
        );
        System.assert(
            resultCon2.Email == 'cr_d2@guest.test',
            'Contact object Email should be cr_d2@guest.test'
        );
        System.assert(
            resultUser2.Email == 'cr_d2@guest.test',
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