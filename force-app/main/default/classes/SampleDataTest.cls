@IsTest
public class SampleDataTest {
    public final static String INTEGRATION_PROFILE = 'Salesforce Integration User';
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    public static User getNativeAppUploadUser() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Native App Upload Access'
        ];
        User uploadUser = new User(
            Alias = 'standt',
            Email = 'upload_user_native_app@mit.edu',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'upload_user_native_app@mit.edu'
        );

        insert uploadUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Native_App_Upload_User'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = ps.Id,
                AssigneeId = uploadUser.Id
            );
        }
        return uploadUser;
    }

    public static User getGuestAdministrationUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :INTEGRATION_PROFILE];
        User guestUser = new User(
            Alias = 'standt',
            Email = 'uguest_test@mit.edu.dev.nativeapp',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'uguest_test@mit.edu.dev.nativeapp'
        );

        insert guestUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Guest_Administrator_User'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = ps.Id,
                AssigneeId = guestUser.Id
            );
            PermissionSet psApi = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'Guest_Administrator_User_API'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = psApi.Id,
                AssigneeId = guestUser.Id
            );
        }
        return guestUser;
    }

    public static User getIpiaAcknowledgmentUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :INTEGRATION_PROFILE];
        User guestUser = new User(
            Alias = 'standt',
            Email = 'uipia_test@mit.edu.dev.nativeapp',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'uipia_test@mit.edu.dev.nativeapp'
        );

        insert guestUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'IPIA_Acknowledgement'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = ps.Id,
                AssigneeId = guestUser.Id
            );
        }
        return guestUser;
    }

    public static User getPeopleSearchUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :INTEGRATION_PROFILE];
        User guestUser = new User(
            Alias = 'standt',
            Email = 'upeople_test@mit.edu.dev.nativeapp',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'upeople_test@mit.edu.dev.nativeapp'
        );

        insert guestUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'People_Search_Query_API'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = ps.Id,
                AssigneeId = guestUser.Id
            );
        }
        return guestUser;
    }

    public static User getDocuSignUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = :INTEGRATION_PROFILE];
        User docuSignUser = new User(
            Alias = 'standt',
            Email = 'docusign_app@mit.edu',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'docusing_app@mit.edu'
        );

        insert docuSignUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'DocuSign_App_User_API'
            ];
            insert new PermissionSetAssignment(
                PermissionSetId = ps.Id,
                AssigneeId = docuSignUser.Id
            );
        }
        return docuSignUser;
    }
    public static User getOfficeAdminUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TLO User'];
        User officeAdmin = new User(
            Alias = 'standt',
            Email = 'office_admin1@mit.edu',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'office_admin1@mit.edu'
        );

        insert officeAdmin;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSetGroup psg = [
                SELECT Id, Status
                FROM PermissionSetGroup
                WHERE DeveloperName = 'TLO_Office_Admin'
            ];
            insert new PermissionSetAssignment(
                PermissionSetGroupId = psg.Id,
                AssigneeId = officeAdmin.Id
            );
        }
        return officeAdmin;
    }
    public static User getAdminUser() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ];
        User admin = new User(
            Alias = 'admin',
            Email = 'admin1@mit.edu',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AdminUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'admin1@mit.edu'
        );
        insert admin;
        return admin;
    }
    public static User getLicenseUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'TLO License User'];
        User licenseUser = new User(
            Alias = 'standt',
            Email = 'tlo_licensing_user@mit.edu',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'tlo_licensing_user@mit.edu'
        );

        insert licenseUser;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSetGroup psg = [
                SELECT Id, Status
                FROM PermissionSetGroup
                WHERE DeveloperName = 'TLO_Licensing_User'
            ];
            insert new PermissionSetAssignment(
                PermissionSetGroupId = psg.Id,
                AssigneeId = licenseUser.Id
            );
        }
        return licenseUser;
    }
    public static User getDepartmentHeadUser() {
        return getJitUser();
    }

    public static User getJitUser() {
        User user;
        System.runAs(getAdminUser()) {
            user = JitContactTest.getJitUser();
        }
        return user;
    }

    public static User getJitUser(Account jitContact) {
        User user;
        System.runAs(getAdminUser()) {
            user = JitContactTest.getJitUser(jitContact);
        }
        return user;
    }

    @IsTest
    public static void copyrightDisclosureDepartmentApprovalSampleTest() {
        Test.startTest();
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c copyrightDisclosure = CopyrightDisclosuresSampleFactory.createDisclosure(
            'Sample Inventor Submitted Disclosure for Copyright',
            true
        );
        System.assert(
            copyrightDisclosure.Status__c == 'Pending Department Approval',
            'Initial Status of Disclosure should be Pending Department Approval'
        );
        Test.stopTest();
    }

    // //The Sample data import can not use System.runAs to impersonate the TLO User. Validate permission set within test method.
    // @IsTest
    // public static void copyrightDisclosureRejectedByTloSampleTest() {
    //     Test.startTest();
    //     User officeAdmin = getOfficeAdminUser();
    //     ContactSampleDataFactory.createSampleContacts();
    //     System.runAs(officeAdmin) {
    //         Disclosure__c tloRejectedCopyrightDisclosure =  CopyrightDisclosuresSampleFactory.createDisclosure('Sample TLO Rejected Disclosure for Copyright', true);
    //         System.assert(tloRejectedCopyrightDisclosure.Status__c == 'Pending Department Approval', 'Initial Status of Disclosure should be Pending Department Approval');
    //         tloRejectedCopyrightDisclosure.Status__c = 'Inventor Submitted';
    //         update tloRejectedCopyrightDisclosure;
    //         tloRejectedCopyrightDisclosure.Rejected_By__c = 'TLO Admin';
    //         tloRejectedCopyrightDisclosure.Status__c = 'Rejected';
    //         tloRejectedCopyrightDisclosure.Rejection_Reason__c = 'Sample Rejection Reason';
    //         update tloRejectedCopyrightDisclosure;

    //     }
    //     Test.stopTest();
    // }

    //The Sample data import can not use System.runAs to impersonate the TLO User. Validate permission set within test method.
    @IsTest
    public static void copyrightDisclosureRejectedByDeptHeadSampleTest() {
        Test.startTest();
        User deptHead = getDepartmentHeadUser();
        ContactSampleDataFactory.createSampleContacts();

        Disclosure__c tloRejectedCopyrightDisclosure = CopyrightDisclosuresSampleFactory.createDisclosure(
            'Sample TLO Rejected Disclosure for Copyright',
            false
        );
        System.assert(
            tloRejectedCopyrightDisclosure.Status__c ==
            'Pending Department Approval',
            'Initial Status of Disclosure should be Pending Department Approval'
        );
        System.runAs(deptHead) {
            tloRejectedCopyrightDisclosure.Rejected_By__c = 'Department Head';
            tloRejectedCopyrightDisclosure.Status__c = 'Rejected';
            tloRejectedCopyrightDisclosure.Rejection_Reason__c = 'Sample Rejection Reason';
            update tloRejectedCopyrightDisclosure;
        }
        Test.stopTest();
    }

    @IsTest
    public static void softwareDisclosureDepartmentApprovalSampleTest() {
        Test.startTest();
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c softwareDisclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            'Sample Inventor Submitted Disclosure for Software',
            true
        );
        System.assert(
            softwareDisclosure.Status__c == 'Pending Department Approval',
            'Initial Status of Disclosure should be Pending Department Approval'
        );
        Test.stopTest();
    }

    // //The Sample data import can not use System.runAs to impersonate the TLO User. Validate permission set within test method.
    // @IsTest
    // public static void softwareDisclosureRejectedByTloSampleTest() {
    //     Test.startTest();
    //     User officeAdmin = getOfficeAdminUser();
    //     ContactSampleDataFactory.createSampleContacts();
    //     System.runAs(officeAdmin) {
    //         Disclosure__c tloRejectedSoftwareDisclosure =  SoftwareDisclosuresSampleFactory.createDisclosure('Sample TLO Rejected Disclosure for Software', true);
    //         System.assert(tloRejectedSoftwareDisclosure.Status__c == 'Pending Department Approval', 'Initial Status of Disclosure should be Pending Department Approval');
    //         tloRejectedSoftwareDisclosure.Status__c = 'Inventor Submitted';
    //         update tloRejectedSoftwareDisclosure;
    //         tloRejectedSoftwareDisclosure.Rejected_By__c = 'TLO Admin';
    //         tloRejectedSoftwareDisclosure.Status__c = 'Rejected';
    //         tloRejectedSoftwareDisclosure.Rejection_Reason__c = 'Sample Rejection Reason';
    //         update tloRejectedSoftwareDisclosure;

    //     }
    //     Test.stopTest();
    // }

    // The Sample data import can not use System.runAs to impersonate the DocuSign User. Validate permission set within test method.
    @IsTest
    public static void softwareDisclosureSignedByDocuSignTest() {
        User nativeAppUploadUser = getNativeAppUploadUser();
        User docuSignUser = getDocuSignUser();
        ContactSampleDataFactory.createSampleContacts();

        Disclosure__c approvedSoftwareDisclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            'Sample Approved Disclosure for Software',
            false
        );
        approvedSoftwareDisclosure.Status__c = 'Inventor Submitted';
        update approvedSoftwareDisclosure;
        approvedSoftwareDisclosure.Status__c = 'Approved';
        approvedSoftwareDisclosure.Case_Number__c = '123425J';
        update approvedSoftwareDisclosure;

        Test.startTest();

        System.runAs(docuSignUser) {
            // Test reading Disclosure__c Object
            Disclosure__c soqlDisclosure = [
                SELECT Id
                FROM Disclosure__c
                WHERE Id = :approvedSoftwareDisclosure.Id
            ];
            Id castedId = Id.valueOf(soqlDisclosure.Id);

            // Test reading DisclosureInventor__c Object
            Disclosure__c disclosure = [
                SELECT
                    Id,
                    Name,
                    (
                        SELECT
                            Id,
                            Name,
                            Signed_Status__c,
                            Signed_Disclosure_Date__c,
                            DocuSign_Recipient_StatusCode__c,
                            Disclosure__c
                        FROM Inventors__r
                    )
                FROM Disclosure__c
                WHERE Id = :castedId
            ];

            List<DisclosureInventor__c> result = disclosure.Inventors__r;
            System.assert(
                result.size() > 0,
                'Unable to find Disclosure Inventors'
            );

            List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>();
            for (DisclosureInventor__c inventor : result) {
                System.assert(
                    inventor.Signed_Status__c == 'Pending',
                    'Expecting Inventor to still sign disclosure'
                );
                inventor.Signed_Disclosure_Date__c = Date.newInstance(
                    2023,
                    2,
                    17
                );
                inventor.DocuSign_Recipient_StatusCode__c = 'Completed';
                disclosureInventors.add(inventor);
            }
            try {
                update disclosureInventors;
            } catch (Exception error) {
                System.assert(
                    false,
                    'Writing to DisclosureInventor__c failed: ' +
                    error.getMessage()
                );
            }

            // upload document
            SampleDataFactory.insertFile(
                ContentVersionClassification.SIGNED_DISCLOSURE,
                'signedFileName.pdf',
                'pdf',
                approvedSoftwareDisclosure.Id
            );
        }

        // Test trigger permission
        List<DisclosureInventor__c> testInventor = DisclosureRecordFetch.getDisclosureInventorByDisclosureId(
            String.valueOf(approvedSoftwareDisclosure.Id)
        );
        for (DisclosureInventor__c inventor : testInventor) {
            System.assertEquals(
                'Yes',
                inventor.Signed_Status__c,
                'SignedDisclosure should be Yes'
            );
            System.assert(
                inventor.Signed_Disclosure_Date__c != null,
                'Signed_Disclosure_Date should be set'
            );
        }

        List<Third_Party_Code__c> thirdPartyCodes = DisclosureRecordFetch.getThirdPartyCodeByDisclosureId(
            approvedSoftwareDisclosure.Id
        );

        System.runAs(nativeAppUploadUser) {
            for (Third_Party_Code__c thirdPartyCode : thirdPartyCodes) {
                SampleDataFactory.insertFile(
                    ContentVersionClassification.THIRD_PARTY_CODE,
                    'thirdPartyCode.pdf',
                    'pdf',
                    thirdPartyCode.Id
                );
            }
        }

        Test.stopTest();

        List<Notification__c> opsNotifications = [
            SELECT Id, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
        ];
        System.assertEquals(
            1,
            opsNotifications.size(),
            'There should be one notification for ops that all have signed'
        );
    }

    @IsTest
    public static void getAndUpdateContactTest() {
        Test.startTest();
        User guestAdmin = getGuestAdministrationUser();
        Account contact1 = SampleDataFactory.createContact(
            'Contact1',
            true,
            '900000008'
        );

        System.runAs(guestAdmin) {
            Account contact = DisclosureRecordFetch.getContactById(contact1.Id);
            System.assert(contact.MitId__pc == '900000008', 'MitId error');
            Account contactToUpdate = new Account(
                Id = contact.Id,
                MitId__pc = '900000009'
            );
            update contactToUpdate;
            Account contactUpdated = DisclosureRecordFetch.getContactById(
                contact1.Id
            );
            System.assert(
                contactUpdated.MitId__pc == '900000009',
                'MitId error'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void ipiaAcknowledgeTest() {
        Test.startTest();
        User user = getIpiaAcknowledgmentUser();
        System.runAs(user) {
            IPIA_Acknowledgement__c ipia = new IPIA_Acknowledgement__c(
                Name = 'John X Johnson',
                MIT_ID__c = '12345678',
                Acknowledged__c = true,
                Date_Acknowledged__c = Date.newInstance(2023, 3, 13)
            );
            insert ipia;

            List<IPIA_Acknowledgement__c> ipiaAcknowledgements = [
                SELECT
                    Id,
                    OwnerId,
                    IsDeleted,
                    Name,
                    CreatedDate,
                    CreatedById,
                    LastModifiedDate,
                    LastModifiedById,
                    SystemModstamp,
                    LastViewedDate,
                    LastReferencedDate,
                    Acknowledged__c,
                    Date_Acknowledged__c,
                    MIT_Id__c
                FROM IPIA_Acknowledgement__c
            ];
            System.debug(
                'ipiaAcknowledgements: ' +
                JSON.serializePretty(ipiaAcknowledgements)
            );

            System.assert(
                !ipiaAcknowledgements.isEmpty(),
                'IPIA_Acknowledgement__c not created'
            );
        }
        Test.stopTest();
    }
    @IsTest
    static void peopleSearchTest() {
        ContactSampleDataFactory.createSampleContacts();
        Test.startTest();
        User user = getPeopleSearchUser();
        System.runAs(user) {
            List<Account> contacts = [
                SELECT Id, MitId__pc, Institution__pc, LastModifiedDate
                FROM Account
                WHERE
                    MitId__pc != NULL
                    AND LastModifiedDate >= :DateTime.now().addDays(-1)
            ];
            System.debug(
                'getPeopleSearchUser: ' + JSON.serializePretty(contacts)
            );

            System.assert(!contacts.isEmpty(), ' not created');
        }
        Test.stopTest();
    }
}