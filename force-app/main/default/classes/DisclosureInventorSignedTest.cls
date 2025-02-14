@isTest
public with sharing class DisclosureInventorSignedTest {
    @isTest
    static void testAuditTrailCreatedForInventorSigned() {
        TestSetup.defaultConfiguration();
        // String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsement_thenAuditForEndorseRequestExists';
        // Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(title , false);

        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        // Contacts
        Account contact1 = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account contact2 = SampleDataFactory.createContact(
            'Donald',
            true,
            '123654'
        );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Inventor Actions on Signing',
            'Draft',
            contact1
        );

        // Inventors On Disclosure
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(
            disclosure,
            true,
            contact1
        );
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(
            disclosure,
            true,
            contact2
        );

        //testing
        inventor1.DocuSign_Recipient_StatusCode__c = 'Completed';
        inventor1.Signed_Disclosure_Date__c = Date.newInstance(2023, 3, 13);
        update inventor1;

        DisclosureInventor__c disInv = [
            SELECT
                Id,
                DocuSign_Recipient_StatusCode__c,
                Signed_Status__c,
                Signed_Disclosure_Date__c,
                Contact__r.Name,
                Disclosure__r.Name,
                Contact__r.PersonEmail,
                Disclosure__r.Name__c,
                Disclosure__c
            FROM DisclosureInventor__c
            WHERE Id = :inventor1.Id
        ];

        System.assert(disInv != null, 'Unable to find Disclosure Inventor');
        System.assert(
            disInv.DocuSign_Recipient_StatusCode__c == 'Completed',
            'disInv.DocuSign_Recipient_StatusCode__c should have been \'Completed\''
        );
        System.assert(
            disInv.Signed_Status__c == 'Yes',
            'disInv.Signed_Status__c should have been \'Yes\''
        );
        System.assert(
            disInv.Signed_Disclosure_Date__c != null,
            'disInv.Signed_Disclosure_Date__c should have been set'
        );

        Disclosure__c disclosureToTest = [
            SELECT Id
            FROM Disclosure__c
            WHERE Name__c = 'Test Inventor Actions on Signing'
            LIMIT 1
        ];
        List<Disclosure_Audit_Event__c> inventorAuditTrail = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureToTest.Id
        ];

        System.assertEquals(
            2,
            inventorAuditTrail.size(),
            'inventorAuditTrail.size() should be 2 at this point'
        );

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[1];
        String expected =
            '<a href="/lightning/r/Account/' +
            disInv.Contact__r.Id +
            '/view" target="_self">' +
            disInv.Contact__r.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Signed;
        Id recordTypeSignedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Signing')
            .getRecordTypeId();
        System.assertEquals(
            expected,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_Signed,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_Signed'
        );
        System.assertEquals(
            recordTypeSignedId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for PendingDepartmentApproval'
        );
    }

    @isTest
    static void testEachInventorSigned() {
        TestSetup.defaultConfiguration();
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        // Contacts
        Account submittingContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account coInventorContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '1236541'
        );
        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Test Inventor Actions on Signing',
            'Draft',
            submittingContact
        );
        // Inventors On Disclosure
        DisclosureInventor__c submittingInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            submittingContact
        );
        DisclosureInventor__c coInventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            coInventorContact
        );

        Test.startTest();
        submittingInventor.Signed_Status__c = 'Yes';
        submittingInventor.DocuSign_Recipient_StatusCode__c = 'Completed';
        submittingInventor.Signed_Disclosure_Date__c = Date.newInstance(
            2023,
            3,
            13
        );
        update submittingInventor;

        List<Notification__c> notification = [
            SELECT Id, Template__c, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];
        System.Assert(
            notification.size() == 0,
            'The Ops team does not need to get a “Signature Received” email  when the inventor signs upon Submission. \n' +
            'They already get an email telling them a case has been submitted'
        );

        coInventor.Signed_Status__c = 'Yes';
        coInventor.DocuSign_Recipient_StatusCode__c = 'Completed';
        coInventor.Signed_Disclosure_Date__c = Date.newInstance(2023, 3, 13);
        update coInventor;

        List<Notification__c> coInventorNotifcations = [
            SELECT Id, Template__c, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
        ];
        System.Assert(
            coInventorNotifcations.size() == 1,
            'coInventor “Signature Received” email  should have been created'
        );

        Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(
            coInventorNotifcations[0].Variables__c
        );
        System.assertEquals(
            'Test Inventor Actions on Signing',
            String.valueOf(jsonVal.get('disclosure_title')),
            'Should match the name for disclosure created above'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                submittingContact.FirstName,
                submittingContact.MiddleName,
                submittingContact.LastName,
                true
            ),
            String.valueOf(jsonVal.get('submitter_name')),
            'Should be the name for submittingContact above'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                coInventorContact.FirstName,
                coInventorContact.MiddleName,
                coInventorContact.LastName,
                true
            ),
            String.valueOf(jsonVal.get('inventor_name')),
            'Should be the name for coInventorContact above'
        );
        Test.stopTest();
    }
}