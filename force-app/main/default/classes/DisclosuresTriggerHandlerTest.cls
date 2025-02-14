@isTest
public class DisclosuresTriggerHandlerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    /**
     * If an Open Source object is deleted, but the parent Copyright/Software Code
     * has the corresponding "Is Open Source" flag set to true, the Department
     * Head should not be deleted
     */
    @isTest
    public static void testOpenSourceDeleteDeptHead() {
        // Set up data
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c copyrightDisc = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            'Open Source Delete Copyright',
            false
        );
        Disclosure__c softwareDisc = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            'Open Source Delete Software',
            false
        );

        Test.startTest();
        try {
            // Test Copyright
            // Check that Department Head exists
            List<Department_Head__c> copyrightDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                copyrightDisc.Id
            );
            System.assert(
                copyrightDeptHeadList.isEmpty() == false,
                'Department Head was not created for Copyright'
            );

            // Check that Open Source exists
            Copyright_Disclosure__c copyright = DisclosureRecordFetch.getCopyrightByDisclosureId(
                copyrightDisc.Id
            )[0];
            List<Open_Source__c> copyrightOpenSourceList = DisclosureRecordFetch.getOpenSourceByCopyrightId(
                copyright.Id
            );
            System.assert(
                copyrightOpenSourceList.isEmpty() == false,
                'Open Source was not created for Copyright'
            );

            // Delete Open Source from Disclosure
            Open_Source__c copyrightOpenSource = copyrightOpenSourceList[0];
            delete copyrightOpenSource;

            // Check that Department Head was not deleted
            copyrightDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                copyrightDisc.Id
            );
            System.assert(
                copyrightDeptHeadList.isEmpty() == false,
                'Department Head was not expected to be deleted for Copyright, but it was'
            );

            // Test Software Code
            // Check that Department Head exists
            List<Department_Head__c> softwareCodeDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                softwareDisc.Id
            );
            System.assert(
                softwareCodeDeptHeadList.isEmpty() == false,
                'Department Head was not created for Software Code'
            );

            // Check that Open Source exists
            Software_Code_Disclosure__c softwareCode = DisclosureRecordFetch.getSoftwareCodeByDisclosureId(
                softwareDisc.Id
            )[0];
            List<Open_Source__c> openSourceList = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
                softwareCode.Id
            );
            System.assert(
                openSourceList.isEmpty() == false,
                'Open Source was not created for Software Code'
            );

            // Delete Open Source from Disclosure
            Open_Source__c openSource = openSourceList[0];
            delete openSource;

            // Check that Department Head was deleted
            softwareCodeDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                softwareDisc.Id
            );
            System.assert(
                softwareCodeDeptHeadList.isEmpty() == false,
                'Department Head was not expected to be deleted for Software Code, but it was'
            );
        } catch (Exception e) {
            System.assert(false, 'Exception was thrown: ' + e.getMessage());
        }

        Test.stopTest();
    }

    /**
     * If a Software Code or Copyright Disclosure has the corresponding "Is Open
     * Source" flag set to false, then any related Open Source and Department
     * Head objects should be deleted
     */
    @isTest
    public static void testOpenSourceUncheck() {
        // Set up Data
        ContactSampleDataFactory.createSampleContacts();
        Disclosure__c copyrightDisc = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            'Open Source Delete Copyright',
            false
        );
        Disclosure__c softwareDisc = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            'Open Source Delete Software',
            false
        );

        Test.startTest();
        try {
            // Test Copyright
            // Check that Department Head exists
            List<Department_Head__c> copyrightDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                copyrightDisc.Id
            );
            System.assert(
                copyrightDeptHeadList.isEmpty() == false,
                'Department Head was not created for Copyright'
            );

            // Check that Open Source exists
            Copyright_Disclosure__c copyright = DisclosureRecordFetch.getCopyrightByDisclosureId(
                copyrightDisc.Id
            )[0];
            List<Open_Source__c> copyrightOpenSourceList = DisclosureRecordFetch.getOpenSourceByCopyrightId(
                copyright.Id
            );
            System.assert(
                copyrightOpenSourceList.isEmpty() == false,
                'Open Source was not created for Copyright'
            );

            // Uncheck Open Source from Copyright
            copyright.Creators_Request_Distrib_Open_Source_YN__c = 'No';
            update copyright;

            // Check that Open Source was deleted
            copyrightOpenSourceList = DisclosureRecordFetch.getOpenSourceByCopyrightId(
                copyright.Id
            );
            System.assert(
                copyrightOpenSourceList.isEmpty() == true,
                'Open Source was expected deleted for Copyright, but was not'
            );

            // Check that Department Head was deleted
            copyrightDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                copyrightDisc.Id
            );
            System.assert(
                copyrightDeptHeadList.isEmpty() == true,
                'Department Head was expected to be deleted for Copyright, but was not'
            );

            // Test Software Code
            // Check that Department Head exists
            List<Department_Head__c> softwareCodeDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                softwareDisc.Id
            );
            System.assert(
                softwareCodeDeptHeadList.isEmpty() == false,
                'Department Head was not created for Software Code'
            );

            // Check that Open Source exists
            Software_Code_Disclosure__c softwareCode = DisclosureRecordFetch.getSoftwareCodeByDisclosureId(
                softwareDisc.Id
            )[0];
            List<Open_Source__c> openSourceList = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
                softwareCode.Id
            );
            System.assert(
                openSourceList.isEmpty() == false,
                'Open Source was not created for Software Code'
            );

            // Uncheck Open Source from Software
            softwareCode.Is_Open_Source_YN__c = 'No';
            softwareCode.Open_Source_Comment__c = 'GitHub';
            update softwareCode;

            // Check that Open Source was deleted
            openSourceList = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
                softwareCode.Id
            );
            System.assert(
                openSourceList.isEmpty() == true,
                'Open Source was expected deleted for Software, but was not'
            );

            // Check that Department Head was deleted
            softwareCodeDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                softwareDisc.Id
            );
            System.assert(
                softwareCodeDeptHeadList.isEmpty() == true,
                'Department Head was expected to be deleted, but was not'
            );
        } catch (Exception e) {
            System.assert(false, 'Exception was thrown: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    public static void validateOnBeforeDelete() {
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Account contact = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345678'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeId,
            'Sample Draft Disclosure for Copyright',
            'Draft',
            contact
        );
        Account pointOfContact = null;
        Copyright_Disclosure__c copyright = SampleDataFactory.createCopyright(
            'TestCopy',
            disclosure,
            pointOfContact
        );
        delete disclosure;

        Id recordTypeId1 = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account contact1 = SampleDataFactory.createContact(
            'Donald2',
            true,
            '12345671'
        );
        Disclosure__c disclosure1 = SampleDataFactory.createDisclosure(
            recordTypeId1,
            'Sample Draft Disclosure for SoftwareCode1',
            'Draft',
            contact1
        );
        Software_Code_Disclosure__c software = SampleDataFactory.createSoftwareCode(
            'TestSoft',
            disclosure1
        );
        SampleDataFactory.createOpenSource('name', null, software);
        delete disclosure1;
    }

    @isTest
    public static void validateBeforeUpdate() {
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
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeId,
            'Sample Draft Disclosure for Invention',
            'Draft',
            submittingContact
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

        disclosure.Status__c = 'Draft';
        update disclosure;

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;
    }

    @isTest
    public static void validateAfterUpdate() {
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
            disclosure.Status__c = 'Rejected';
            update disclosure;
            System.assert(false, 'Exception not thrown');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage();
            System.assertEquals(
                errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                true
            );
            //Please review the Rejection Reason before rejecting the disclosure
        }
    }
    @isTest
    public static void validateUnarchivedContactActionCreation() {
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
            disclosure.Status__c = 'Archived';
            update disclosure;

            disclosure.Status__c = 'Draft';
            update disclosure;

            List<Disclosure_Action__c> disclosureActions = [
                SELECT Id, Name, Disclosure__c, RecordTypeId
                FROM Disclosure_Action__c
                WHERE Disclosure__c = :disclosure.Id
            ];

            System.assertEquals(disclosureActions.size(), 2);
        } catch (Exception ex) {
            String errorMessage = ex.getMessage();
            System.assertEquals(
                errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                true
            );
            //Please review the Rejection Reason before rejecting the disclosure
        }
    }

    @isTest
    public static void validateAfterUpdatev1() {
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
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeId,
            'Sample Draft Disclosure for Invention',
            'Draft',
            submittingContact
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

        disclosure.Status__c = 'Inventor Submitted';
        update disclosure;

        disclosure.Status__c = 'Approved';
        update disclosure;
        system.assertEquals('Approved', disclosure.Status__c);
    }

    @IsTest
    public static void validateAllInventorSignedNotifications() {
        String disclosureTitle = 'Sample Draft Disclosure for Invention to be signed 1';

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();
        Account contactInventor1 = SampleDataFactory.createContact(
            'James',
            true,
            '12345678'
        );
        Account contactInventor2 = SampleDataFactory.createContact(
            'Henry',
            true,
            '123456781'
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeId,
            disclosureTitle,
            'Draft',
            submittingContact
        );

        DisclosureInventor__c disclosureInventor1 = SampleDataFactory.createInventor(
            disclosure,
            true,
            contactInventor1
        );
        DisclosureInventor__c disclosureInventor2 = SampleDataFactory.createInventor(
            disclosure,
            true,
            contactInventor2
        );

        disclosure.Case_Number__c = '1234';
        update disclosure;

        disclosureInventor1.Signed_Status__c = 'Yes';
        update disclosureInventor1;

        List<Notification__c> notifications = [
            SELECT Id, Template__c, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
        ];
        System.assertEquals(
            0,
            notifications.size(),
            'There should be no notifications for TEMPLATE_DISCLOSURE_ALL_SIGNED yet, not all inventors have signed.'
        );

        disclosureInventor2.Signed_Status__c = 'Yes';
        update disclosureInventor2;

        // get data to run checks against
        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
        Notification__c notification = [
            SELECT Id, Template__c, Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED
            LIMIT 1
        ];
        Map<String, Object> jsonVal = (Map<String, Object>) JSON.deserializeUntyped(
            notification.Variables__c
        );
        RecordType inventionRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeId
            LIMIT 1
        ];

        // ASSERT
        System.assertEquals(
            NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED,
            notification.Template__c,
            'Template name should be for TEMPLATE_DISCLOSURE_ALL_SIGNED'
        );
        System.assertEquals(
            disclosureToTest.Submitting_Contact__r.Name,
            String.valueOf(jsonVal.get('submitter_name')),
            'submitter_name variables should match that of the Submitted By person on disclosure'
        );
        System.assertEquals(
            inventionRecordType.Name,
            String.valueOf(jsonVal.get('disclosure_type')),
            'disclosure_type should be the Name of Invention_Disclosure'
        );
        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(jsonVal.get('disclosure_title')),
            'disclosure_title should be the Name__c of Disclosure'
        );
        System.assertEquals(
            disclosureToTest.Case_Number__c,
            String.valueOf(jsonVal.get('case_number')),
            'case_number should be the Case_Number__c of Disclosure'
        );
        System.assertEquals(
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/lightning/r/Disclosure__c/' +
            disclosureToTest.Id +
            '/view',
            String.valueOf(jsonVal.get('link')),
            'link to be to disclosure view by id'
        );
    }

    @isTest
    public static void validateBeforeUpdateContactUpdateRequest() {
        ContactSampleDataFactory.createSampleContacts();
        String disclosureTitle = 'ContactUpdateRequest';
        Disclosure__c d = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            disclosureTitle,
            true
        );

        Account contact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '900047497'
        ];

        TLO_Contact_Update_Request__c cur = new TLO_Contact_Update_Request__c(
            Disclosure__c = d.Id,
            Contact__c = contact.Id,
            Email__c = 'test@gmail.com'
        );
        insert (cur);

        Disclosure__c disclosure = [
            SELECT Id, Name__c
            FROM Disclosure__c
            WHERE Name__c = :disclosureTitle
            LIMIT 1
        ];

        Test.startTest();
        try {
            disclosure.Status__c = 'Approved';
            update disclosure;
            System.assert(
                false,
                'Pending Contact Update request exist not thrown'
            );
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        Test.stopTest();
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
                Name__c,
                Case_Number__c,
                SubmittedOnBehalf__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Id,
                Submitting_Contact__r.Name,
                Submitting_Contact__r.PersonEmail,
                Submitting_Contact__r.AltEmail__pc
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        return disclosureToTest;
    }
}