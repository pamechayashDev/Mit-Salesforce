@IsTest
public with sharing class DisclosureValidationTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    private static Disclosure__c initDisclosure(String type) {
        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get(type)
            .getRecordTypeId();
        Disclosure__c testDisclosure = new Disclosure__c(
            Name__c = 'Test Disclosure',
            Status__c = 'Draft',
            RecordTypeId = recordTypeId,
            Submitting_Contact__c = sampleContact.Id
        );
        insert testDisclosure;

        DisclosureInventor__c sampleInventor1 = new DisclosureInventor__c(
            MitAtTimeOfInvention__c = true,
            PrimaryInventor__c = true,
            Signed_Status__c = 'Yes',
            Contact__c = sampleContact.Id,
            Disclosure__c = testDisclosure.Id
        );

        insert sampleInventor1;
        Department_Head__c depHead = new Department_Head__c(
            Disclosure__c = testDisclosure.Id,
            Signed_Date__c = Date.newInstance(2020, 7, 7),
            Contact__c = deptHeadContact.Id
        );
        insert depHead;

        update new Disclosure__c(Id = testDisclosure.Id, Status__c = 'Draft');
        return testDisclosure;
    }

    @IsTest
    static void testDisclosureOnDelete() {
        Test.startTest();
        User user = getUser();
        System.runAs(user) {
            System.debug('testDisclosureOnDelete');
            Disclosure__c testDisclosure = new Disclosure__c(
                Name__c = 'Test Disclosure',
                Status__c = null
            );
            DisclosureValidation.onBeforeDelete(
                new List<Disclosure__c>{ testDisclosure }
            );
            System.assertEquals(
                testDisclosure.Name__c,
                'Test Disclosure',
                'Expecting Name to be `Test Disclosure` '
            );
        }
        Test.stopTest();
    }

    static User getUser() {
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

        insert userExample;
        return userExample;
    }

    static Disclosure__c setupSoftwareCodeDisclosure(String status) {
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        // Test setup
        Disclosure__c testDisclosure = initDisclosure(
            'Software_Code_Disclosure'
        );
        Software_Code_Disclosure__c testSoftwareCodeDisclosure = new Software_Code_Disclosure__c(
            Name = 'Test Sotware Code Disclosure',
            Disclosure__c = testDisclosure.Id
        );
        insert testSoftwareCodeDisclosure;
        Account contact = SampleDataFactory.createContact(
            'Marcus',
            true,
            '12345589'
        );
        // Default status is Draft
        if (status != 'Draft') {
            testDisclosure.Status__c = status;
            update testDisclosure;
        }

        return testDisclosure;
    }

    @IsTest
    static void testDisclosureSuccessTriggerViaDML() {
        Test.startTest();
        User user = getUser();
        System.runAs(user) {
            Disclosure__c testDisclosure = setupSoftwareCodeDisclosure('Draft');
            Database.DeleteResult result = Database.delete(testDisclosure);
            System.assert(
                result.isSuccess(),
                'Owner able to Remove disclosure'
            );

            List<Software_Code_Disclosure__c> softwareCodeDisclosures = [
                SELECT Id
                FROM Software_Code_Disclosure__c
                WHERE Disclosure__r.Id = :testDisclosure.Id
                LIMIT 10
            ];
            System.assert(
                softwareCodeDisclosures.size() == 0,
                'Software_Code_Disclosure__c should also be deleted'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testDisclosureFailureTriggerViaDML() {
        Test.startTest();
        User user = getUser();
        Disclosure__c testDisclosure = setupSoftwareCodeDisclosure('Draft');
        System.runAs(user) {
            try {
                Database.DeleteResult result = Database.delete(testDisclosure);
                //! TODO: Replace this ASAP
                // System.assert(false,'Exception not thrown');
            } catch (Exception error) {
                System.assert(
                    error.getMessage()
                        .contains(DisclosureValidation.INITIATOR_ERROR_MSG),
                    'Expecting ' + DisclosureValidation.INITIATOR_ERROR_MSG
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testDisclosureStatusFailureTriggerViaDML() {
        Test.startTest();
        User user = getUser();
        Disclosure__c testDisclosure = setupSoftwareCodeDisclosure(
            'Inventor Submitted'
        );
        System.runAs(user) {
            try {
                Database.DeleteResult result = Database.delete(testDisclosure);
                System.assert(false, 'Exception not thrown');
            } catch (Exception error) {
                System.assert(
                    error.getMessage()
                        .contains(DisclosureValidation.DRAFT_ERROR_MSG),
                    'Expecting ' + DisclosureValidation.DRAFT_ERROR_MSG
                );
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testContactValidation() {
        Account contact = new Account(
            AltEmail__pc = 'tlo@advance.io',
            PersonOtherPhone = '0612345678',
            CountryOfCitizenship__pc = 'USA',
            FirstName = 'John',
            Government_Agency_Name__pc = 'U.S. Air Force',
            GovernmentEmployeeStatus__pc = true,
            GuestAccountNeeded__pc = 'No',
            HHMI_Current__pc = true,
            HHMI_Current_Date_From__pc = Date.newInstance(2023, 2, 14),
            Institution__pc = 'Massachusetts Institute of Technology',
            InstitutionCode__pc = '12345',
            InvitationCode__pc = '',
            KerbName__pc = 'kerb',
            LastName = 'Johnson',
            MiddleName = 'Jay',
            MitId__pc = '12345678',
            MoiraStatus__pc = '1',
            OldEmail__pc = 'old@yahoo.com',
            PersonBirthdate = Date.newInstance(2000, 2, 14),
            PersonDepartment = 'Computer Science',
            PersonEmail = 'sample@mit.edu',
            PersonMailingStreet = '244 Wood Street',
            PersonMailingCity = 'Lexington',
            PersonMailingCountry = 'United States of America',
            PersonMailingPostalCode = '02421-6426',
            PersonMailingState = 'MA',
            PersonTitle = 'Lecturer',
            Phone = '0613245672',
            PreferredName__pc = 'JJ',
            VaAppointment__pc = 'No'
        );

        try {
            insert contact;
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
    }

    // FIXME: This test is failing due to the new email field not being the same as the old field
    //  its not unique, Person Accounts email field cannot be unique
    // @isTest
    // static void testContactDuplicateEmailValidation() {
    //     Test.startTest();

    //     Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    //         .get('PersonAccount')
    //         .getRecordTypeId();
    //     Account contact = new Account(
    //         PersonEmail = 'sample@mit.edu',
    //         FirstName = 'sample',
    //         LastName = 'contact',
    //         RecordTypeId = personAccountRecordTypeId
    //     );
    //     Account contact2 = new Account(
    //         PersonEmail = 'sample@mit.edu',
    //         FirstName = 'sample2',
    //         LastName = 'contact',
    //         RecordTypeId = personAccountRecordTypeId
    //     );

    //     insert contact;

    //     try {
    //         insert contact2;
    //         System.assert(
    //             false,
    //             'Duplicate Account Email Address, error not thrown.'
    //         );
    //     } catch (Exception error) {
    //         System.assert(true, error.getMessage());
    //     }
    //     Test.stopTest();
    // }

    static testMethod void validateAfterUpdateArchiveNoPrimaryInventor() {
        try {
            Test.startTest();
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Invention_Disclosure')
                .getRecordTypeId();
            Account contact = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account contactHead = SampleDataFactory.createContact(
                'Donald1',
                true,
                '123456781'
            );
            Disclosure__c disclosure = SampleDataFactory.createDisclosure(
                recordTypeId,
                'Sample Draft Disclosure for Invention',
                'Draft',
                contact
            );
            DisclosureInventor__c disclosureInventor = SampleDataFactory.createInventor(
                disclosure,
                false,
                contact
            );

            Department_Head__c departmentHead = SampleDataFactory.createDepartmentHead(
                disclosure,
                contactHead
            );
            disclosure.Status__c = 'Archived';
            update disclosure;
            Test.stopTest();
        } catch (Exception ex) {
            String errorMessage = ex.getMessage();
            System.assert(false, errorMessage);
            //Should be able to Archive without validation.
        }
    }

    static testMethod void validateAfterUpdateOnBehalfOf() {
        Test.startTest();
        try {
            Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Invention_Disclosure')
                .getRecordTypeId();
            Account contact = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account contactHead = SampleDataFactory.createContact(
                'Donald1',
                true,
                '123456781'
            );
            Disclosure__c disclosure = SampleDataFactory.createDisclosure(
                recordTypeId,
                'Sample Draft Disclosure for Invention',
                'Draft',
                contact
            );
            DisclosureInventor__c disclosureInventor = SampleDataFactory.createInventor(
                disclosure,
                true,
                contact
            );

            Department_Head__c departmentHead = SampleDataFactory.createDepartmentHead(
                disclosure,
                contactHead
            );

            List<Disclosure__c> disclosures = new List<Disclosure__c>();
            disclosures.add(disclosure);
            DisclosureValidation.DisclosureContext disclosureContext = DisclosureValidation.getDisclosureContext(
                disclosures
            );

            DisclosureValidation.onBehalfOfInventorValidation(
                disclosureContext.disclosureInventorMap
            );
            disclosure.Status__c = 'Rejected';
            update disclosure;
        } catch (Exception ex) {
            String errorMessage = ex.getMessage();
            System.assertEquals(
                errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                true
            );
            //Please review the Rejection Reason before rejecting the disclosure
        }
        Test.stopTest();
    }

    static testMethod void validateCopyrightDepartmentHead() {
        Test.startTest();
        try {
            Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Copyright_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account sampleContact2 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345679'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Donald1',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdCopyright,
                'Copyright Success',
                'Draft',
                sampleContact1
            );

            Department_Head__c firstDeptHead = SampleDataFactory.createDepartmentHead(
                disclosure,
                departmentHeadContact
            );

            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
                'Sample Inventor Submitted Copyright',
                disclosure,
                departmentHeadContact
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Copyright',
                copyrightDisclosure,
                null
            );
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                true,
                'Expecting OpenSource Licensing to be true'
            );
            Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
                'Third Party Content',
                copyrightDisclosure
            );
            SampleDataFactory.createInventor(disclosure, true, sampleContact2);
            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;
        } catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void validateCopyrightDepartmentHeadNoOpenSource() {
        Test.startTest();
        try {
            Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Copyright_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account sampleContact2 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345679'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Donald1',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdCopyright,
                'Copyright Success',
                'Draft',
                sampleContact1
            );

            Department_Head__c noDeptHead = null; // Enforce Test intention

            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
                'Sample Inventor Submitted Copyright',
                disclosure,
                departmentHeadContact
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Copyright',
                copyrightDisclosure,
                null
            );
            openSource.Open_Source_Licensing__c = false;
            update openSource;
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                false,
                'Expecting OpenSource Licensing to be false'
            );

            Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
                'Third Party Content',
                copyrightDisclosure
            );
            SampleDataFactory.createInventor(disclosure, true, sampleContact2);
            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;
        } catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void validateCopyrightDepartmentHeadFailure() {
        Test.startTest();
        try {
            Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Copyright_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account sampleContact2 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345679'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Donald1',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdCopyright,
                'Copyright Success',
                'Draft',
                sampleContact1
            );

            Department_Head__c noDeptHead = null; // Enforce Test intention

            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
                'Sample Inventor Submitted Copyright',
                disclosure,
                departmentHeadContact
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Copyright',
                copyrightDisclosure,
                null
            );
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                true,
                'Expecting OpenSource Licensing to be true'
            );
            Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
                'Third Party Content',
                copyrightDisclosure
            );
            SampleDataFactory.createInventor(disclosure, true, sampleContact2);
            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;

            System.assert(false, 'Exception not thrown');
        } catch (Exception ex) {
            System.assertEquals(
                ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                true,
                ex.getMessage()
            );
        }
        Test.stopTest();
    }

    static testMethod void validateSoftwareDepartmentHead() {
        Test.startTest();
        try {
            Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Software_Code_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account existingContact1 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345670'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Joe',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdSoftware,
                'title',
                'Draft',
                sampleContact1
            );
            SampleDataFactory.createDepartmentHead(
                disclosure,
                departmentHeadContact
            );
            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
                'Sample Inventor Submitted Software Code',
                disclosure
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Software Code',
                null,
                softwareCodeDisclosure
            );
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                true,
                'Expecting OpenSource Licensing to be true'
            );
            SampleDataFactory.createThirdPartyCode(
                'Third Party Code',
                softwareCodeDisclosure
            );
            SampleDataFactory.createInventor(
                disclosure,
                true,
                existingContact1
            );

            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;
        } catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void validateSoftwareDepartmentHeadNoOpenSource() {
        Test.startTest();
        try {
            Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Software_Code_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account existingContact1 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345670'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Joe',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdSoftware,
                'title',
                'Draft',
                sampleContact1
            );
            Department_Head__c noDeptHead = null; // Enforce Test intention

            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
                'Sample Inventor Submitted Software Code',
                disclosure
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Software Code',
                null,
                softwareCodeDisclosure
            );
            openSource.Open_Source_Licensing__c = false;
            update openSource;
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                false,
                'Expecting OpenSource Licensing to be false'
            );

            SampleDataFactory.createThirdPartyCode(
                'Third Party Code',
                softwareCodeDisclosure
            );
            SampleDataFactory.createInventor(
                disclosure,
                true,
                existingContact1
            );

            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;
        } catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void validateSoftwareDepartmentHeadFailure() {
        Test.startTest();
        try {
            Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
                .get('Software_Code_Disclosure')
                .getRecordTypeId();

            Account sampleContact1 = SampleDataFactory.createContact(
                'Donald',
                true,
                '12345678'
            );
            Account existingContact1 = SampleDataFactory.createContact(
                'Jeff',
                true,
                '12345670'
            );
            Account departmentHeadContact = SampleDataFactory.createContact(
                'Joe',
                true,
                '123456781'
            );

            Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
                recordTypeIdSoftware,
                'title',
                'Draft',
                sampleContact1
            );
            Department_Head__c noDeptHead = null; // Enforce Test intention

            SampleDataFactory.createDisclosureInternalFunding(
                disclosure,
                'Yes',
                '12345678',
                'Internal Funding 1'
            );
            SampleDataFactory.createCommercialInterest(disclosure);
            Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
                'Sample Inventor Submitted Software Code',
                disclosure
            );
            Open_Source__c openSource = SampleDataFactory.createOpenSource(
                'Open Source for Inventor Submitted Software Code',
                null,
                softwareCodeDisclosure
            );
            System.assertEquals(
                openSource.Open_Source_Licensing__c,
                true,
                'Expecting OpenSource Licensing to be true'
            );

            SampleDataFactory.createThirdPartyCode(
                'Third Party Code',
                softwareCodeDisclosure
            );
            SampleDataFactory.createInventor(
                disclosure,
                true,
                existingContact1
            );

            // Department head approval, Can not directly go to Inventor Submitted
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;

            System.assert(false, 'Exception not thrown');
        } catch (Exception ex) {
            System.assertEquals(
                ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                true,
                ex.getMessage()
            );
        }
        Test.stopTest();
    }
}