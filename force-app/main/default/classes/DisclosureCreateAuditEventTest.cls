@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public with sharing class DisclosureCreateAuditEventTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
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

    private static List<Disclosure_Audit_Event__c> getDisclosureAuditTrail(
        Id disclosureId
    ) {
        List<Disclosure_Audit_Event__c> inventorAuditTrail = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureId
        ];

        return inventorAuditTrail;
    }

    private static Department_Head__c getDeptHead(Id disclosureId) {
        List<Department_Head__c> discDeptHeadList = [
            SELECT
                Id,
                Comment__c,
                Contact__r.PersonDepartment,
                Disclosure__c,
                Signed_Date__c,
                Contact__r.Name,
                Contact__r.MitId__pc,
                Contact__r.PersonTitle,
                Contact__r.PersonEmail,
                // Newly Delegated Department Head
                Delegated_To__c,
                Delegated_To__r.Id,
                Delegated_To__r.Name,
                Delegated_To__r.Contact__c,
                Delegated_To__r.Contact__r.Name,
                Delegated_To__r.Contact__r.Id
            FROM Department_Head__c
            WHERE Disclosure__c = :disclosureId
        ];

        Department_Head__c discDeptHead = discDeptHeadList[0];

        return discDeptHead;
    }

    @isTest
    static void givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsement_thenAuditForEndorseRequestExists() {
        // SETUP TEST DATA
        ContactSampleDataFactory.createSampleContacts();
        String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsement_thenAuditForEndorseRequestExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);

        // GET DATA TO RUN THE TEST CHECKS AGAINST
        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;
        Department_Head__c deptHead = getDeptHead(disclosureToTest.Id);

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[1];

        String deptHeadId = deptHead.Contact__r.Id;
        String deptHeadName = deptHead.Contact__r.Name;
        String submittedByContactId = submittedByContact.Id;
        String submittedByContactName = submittedByContact.Name;

        Test.startTest();
        String expected =
            '<a href="/lightning/r/Account/' +
            deptHeadId +
            '/view" target="_self">' +
            deptHeadName +
            '</a> ' +
            label.Disclosure_DAE_Description_PendingDepartmentApproval +
            ' <a href="/lightning/r/Account/' +
            submittedByContactId +
            '/view" target="_self">' +
            submittedByContactName +
            '</a>';

        Id recordTypePendingDeptApprovalId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('PendingDepartmentApproval')
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
            Label.Disclosure_DAE_Subject_PendingDepartmentApproval,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_PendingDepartmentApproval'
        );
        System.assertEquals(
            recordTypePendingDeptApprovalId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for PendingDepartmentApproval'
        );
        Test.stopTest();
    }

    @isTest
    static void givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadEndorses_thenAuditForEndorsementExists() {
        //SETUP THE TEST DATA
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadEndorses_thenAuditForEndorsementExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);
        DisclosureSampleDataFactory.deptHeadEndorsesDisclosure(
            disclosure,
            'Test givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadEndorses_thenAuditForEndorsementExists'
        );

        // GET DATA TO RUN TEST CHECKS AGAINST
        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;
        Department_Head__c deptHead = getDeptHead(disclosureToTest.Id);

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[2];

        String deptHeadId = deptHead.Contact__r.Id;
        String deptHeadName = deptHead.Contact__r.Name;

        Test.startTest();
        String expected5 =
            '<a href="/lightning/r/Account/' +
            deptHeadId +
            '/view" target="_self">' +
            deptHeadName +
            '</a> ' +
            label.Disclosure_DAE_Description_Endorsed +
            ' with comment &quot;Test givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadEndorses_thenAuditForEndorsementExists&quot;';

        Id recordTypeEndorsedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('InventorSubmitted')
            .getRecordTypeId();
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_Endorsed,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_Endorsed'
        );
        System.assertEquals(
            recordTypeEndorsedId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for InventorSubmitted'
        );
        System.assertEquals(
            expected5,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        Test.stopTest();
    }

    @isTest
    static void givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadDelegates_thenAuditForDelegationExists() {
        //SETUP THE TEST DATA
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadDelegates_thenAuditForDelegationExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);

        Account secondDeptHeadContact = SampleDataFactory.createContact(
            'DeptHead2',
            true,
            '123456783'
        );
        Department_Head__c secondDeptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            secondDeptHeadContact
        );
        DisclosureSampleDataFactory.deptHeadDelegateDisclosure(
            disclosure,
            secondDeptHead,
            'Test delegation'
        );

        // GET DATA TO RUN TEST CHECKS AGAINST
        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;
        Department_Head__c deptHead = getDeptHead(disclosureToTest.Id);

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[2];

        System.debug('deptHead: \n\n' + deptHead + '\n\n');
        System.debug('inventorAuditTrail: \n\n' + inventorAuditTrail + '\n\n');

        String delegatedFromId = deptHead.Contact__r.Id;
        String delegatedFromName = deptHead.Contact__r.Name;
        String delegatedToId = deptHead.Delegated_To__r.Contact__r.Id;
        String delegatedToName = deptHead.Delegated_To__r.Contact__r.Name;

        Test.startTest();
        System.assertEquals(
            3,
            inventorAuditTrail.size(),
            'inventorAuditTrail should have 2 entries at this point'
        );
        String expected2 =
            '<a href="/lightning/r/Account/' +
            delegatedFromId +
            '/view" target="_self">' +
            delegatedFromName +
            '</a> ' +
            label.Disclosure_DAE_Description_Delegated +
            ' <a href="/lightning/r/Account/' +
            delegatedToId +
            '/view" target="_self">' +
            delegatedToName +
            '</a>' +
            ' with comment &quot;Test delegation&quot;';

        Id recordTypeDelegatedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Delegation')
            .getRecordTypeId();
        System.assertEquals(
            expected2,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_Delegated,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_Delegated'
        );
        System.assertEquals(
            recordTypeDelegatedId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for Delegation'
        );

        Test.stopTest();
    }

    @isTest
    static void givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadRejects_thenAuditForRejectionExists() {
        //SETUP THE TEST DATA
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndDeptHeadRejects_thenAuditForRejectionExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);
        DisclosureSampleDataFactory.deptHeadRejectsDisclosure(
            disclosure,
            'Reason for rejection by Dept Head'
        );

        // GET DATA TO RUN TEST CHECKS AGAINST
        User userDetails = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;
        Department_Head__c deptHead = getDeptHead(disclosureToTest.Id);

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[2];
        String deptHeadId = deptHead.Contact__r.Id;
        String deptHeadName = deptHead.Contact__r.Name;

        Test.startTest();
        System.assertEquals(
            3,
            inventorAuditTrail.size(),
            'inventorAuditTrail should have 2 entries at this point'
        );

        String expected2 =
            '<a href="/lightning/r/Account/' +
            deptHeadId +
            '/view" target="_self">' +
            deptHeadName +
            '</a> ' +
            label.Disclosure_DAE_Description_DeptHeadRejected;

        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Rejection')
            .getRecordTypeId();
        System.assertEquals(
            expected2,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_DeptHeadRejected,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_DeptHeadRejected'
        );
        System.assertEquals(
            recordTypeRejectionId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for Rejection'
        );

        Test.stopTest();
    }

    @isTest
    static void givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndTloRejects_thenAuditForRejectionExists() {
        //SETUP THE TEST DATA
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndTloRejects_thenAuditForRejectionExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);
        DisclosureSampleDataFactory.deptHeadEndorsesDisclosure(
            disclosure,
            'Test givenCopyrightAsInventor_whenSubmitteForDeptHeadEndorsementAndTloRejects_thenAuditForRejectionExists'
        );
        DisclosureSampleDataFactory.tloRejectsDisclosure(
            disclosure,
            'Reason for rejection by TLO'
        );

        // GET DATA TO RUN TEST CHECKS AGAINST
        User userDetails = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;
        Department_Head__c deptHead = getDeptHead(disclosureToTest.Id);

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[3];

        String deptHeadId = deptHead.Contact__r.Id;
        String deptHeadName = deptHead.Contact__r.Name;

        Test.startTest();
        System.assertEquals(
            4,
            inventorAuditTrail.size(),
            'inventorAuditTrail should have 4 entries at this point'
        );

        String expected2 =
            '<a href="/lightning/r/User/' +
            userDetails.Id +
            '/view" target="_self">' +
            userDetails.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_TloRejected;

        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Rejection')
            .getRecordTypeId();
        System.assertEquals(
            expected2,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_TloRejected,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_TloRejected'
        );
        System.assertEquals(
            recordTypeRejectionId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for Rejection'
        );

        Test.stopTest();
    }

    @isTest
    static void givenCopyrightAsInventor_whenDeptHeadEndorsesAndTloApproves_thenAuditForTloApprovalExists() {
        //SETUP THE TEST DATA
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenCopyrightAsInventor_whenDeptHeadEndorsesAndTloApproves_thenAuditForTloApprovalExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createCopyrightDisclosureWithDeptHeadAsInventor(
            title,
            false
        );
        DisclosureSampleDataFactory.submitForDeptHeadEndorsement(disclosure);
        DisclosureSampleDataFactory.deptHeadEndorsesDisclosure(
            disclosure,
            'Test givenCopyrightAsInventor_whenDeptHeadEndorsesAndTloApproves_thenAuditForTloApprovalExists'
        );
        DisclosureSampleDataFactory.tloApprovesDisclosure(disclosure);

        // GET DATA TO RUN TEST CHECKS AGAINST
        User userDetails = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        Disclosure__c disclosureToTest = getDisclosureToTest(title);
        List<Disclosure_Audit_Event__c> inventorAuditTrail = getDisclosureAuditTrail(
            disclosureToTest.Id
        );
        Account submittedByContact = disclosureToTest.Submitting_Contact__r;

        Disclosure_Audit_Event__c auditEntry = inventorAuditTrail[3];

        Test.startTest();
        System.assertEquals(
            4,
            inventorAuditTrail.size(),
            'inventorAuditTrail should have 4 entries at this point'
        );
        String expected2 =
            '<a href="/lightning/r/User/' +
            userDetails.Id +
            '/view" target="_self">' +
            userDetails.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Approved;

        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();
        System.assertEquals(
            expected2,
            auditEntry.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTest.Id,
            auditEntry.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_Approved,
            auditEntry.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_Approved'
        );
        System.assertEquals(
            recordTypeRejectionId,
            auditEntry.RecordTypeId,
            'RecordTypeId needs to be for Rejection'
        );

        Test.stopTest();
    }

    @isTest
    static void givenSoftwareAsInventorNoDeptHead_whenInventorSubmits_thenNoAuditExists() {
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenSoftwareAsInventorNoDeptHead_whenInventorSubmits_thenNoAuditExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureNoDeptHead(
            title,
            false
        );

        Disclosure__c disclosureToTest = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Name__c = :title
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

        disclosureToTest.Status__c = 'Inventor Submitted';
        update disclosureToTest;

        Disclosure__c disclosureToTestAgain = [
            SELECT Id, Status__c, Submitting_Contact__c
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        List<Disclosure_Audit_Event__c> inventorAuditTrail1 = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureToTestAgain.Id
        ];

        Test.startTest();
        System.assertEquals(
            2,
            inventorAuditTrail1.size(),
            'inventorAuditTrail.size() should only be 2 at this point'
        );

        List<Department_Head__c> discDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            disclosureToTestAgain.Id
        );
        System.assertEquals(
            0,
            discDeptHeadList.size(),
            'discDeptHeadList.size()'
        );

        Test.stopTest();
    }

    @isTest
    static void givenSoftwareAsInventorWithDeptHead_whenSentToDeptHeadAndDeptHeadEndorses_thenAuditExistsForEachStep() {
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenSoftwareAsInventorWithDeptHead_whenSentToDeptHeadAndDeptHeadEndorses_thenAuditExistsForEachStep';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureFullyPopulated(
            title,
            false
        );

        Disclosure__c disclosureToTest = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Name__c = :title
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
            1,
            inventorAuditTrail.size(),
            'inventorAuditTrail.size() should be 1 at this point, no audit trail for Draft Disclosures.'
        );

        disclosureToTest.Status__c = 'Pending Department Approval';
        update disclosureToTest;

        Disclosure__c disclosureToTestAgain = [
            SELECT Id, Status__c, Submitting_Contact__c
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        List<Disclosure_Audit_Event__c> inventorAuditTrail1 = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureToTestAgain.Id
        ];

        Test.startTest();
        System.assertEquals(
            2,
            inventorAuditTrail1.size(),
            'inventorAuditTrail.size() should only be 2 at this point'
        );
        Disclosure_Audit_Event__c a = inventorAuditTrail1[1];

        System.debug('a.Description__c: \n\n' + a.Description__c + '\n\n'); // Breakpoint here to look at each one
        System.debug('a.Subject__c: \n\n' + a.Subject__c + '\n\n'); // Breakpoint here to look at each one

        List<Department_Head__c> discDeptHeadList = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            disclosureToTestAgain.Id
        );
        Department_Head__c discDeptHead = discDeptHeadList[0];
        String deptHeadId = discDeptHead.Contact__r.Id;
        String deptHeadName = discDeptHead.Contact__r.Name;

        Account submittedByContact = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :disclosureToTestAgain.Submitting_Contact__c
        ];
        String submittedByContactId = submittedByContact.Id;
        String submittedByContactName = submittedByContact.Name;

        String expected =
            '<a href="/lightning/r/Account/' +
            deptHeadId +
            '/view" target="_self">' +
            deptHeadName +
            '</a> ' +
            label.Disclosure_DAE_Description_PendingDepartmentApproval +
            ' <a href="/lightning/r/Account/' +
            submittedByContactId +
            '/view" target="_self">' +
            submittedByContactName +
            '</a>';

        Id recordTypePendingDeptApprovalId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('PendingDepartmentApproval')
            .getRecordTypeId();
        System.assertEquals(
            a.Description__c,
            expected,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTestAgain.Id,
            a.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_PendingDepartmentApproval,
            a.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_PendingDepartmentApproval'
        );
        System.assertEquals(
            recordTypePendingDeptApprovalId,
            a.RecordTypeId,
            'RecordTypeId needs to be for PendingDepartmentApproval'
        );

        disclosureToTest.Status__c = 'Inventor Submitted';
        update disclosureToTest;

        // Dept. Head Endorsed
        Disclosure__c disclosureToTestAgain2 = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        List<Disclosure_Audit_Event__c> inventorAuditTraiwwl1 = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureToTestAgain2.Id
        ];

        System.assertEquals(
            3,
            inventorAuditTraiwwl1.size(),
            'inventorAuditTrail.size() should only be 3 at this point'
        );
        Disclosure_Audit_Event__c aa = inventorAuditTraiwwl1[2];

        String expected2 =
            '<a href="/lightning/r/Account/' +
            deptHeadId +
            '/view" target="_self">' +
            deptHeadName +
            '</a> ' +
            label.Disclosure_DAE_Description_Endorsed;

        Id recordTypeEndorsedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('InventorSubmitted')
            .getRecordTypeId();
        System.assertEquals(
            expected2,
            aa.Description__c,
            'Description__c not what was expected'
        );
        System.assertEquals(
            disclosureToTestAgain.Id,
            aa.Disclosure__c,
            'Disclosure__c should be equal to the Disclosure we currently testing'
        );
        System.assertEquals(
            Label.Disclosure_DAE_Subject_Endorsed,
            aa.Subject__c,
            'Subject__c should be value from label Disclosure_DAE_Subject_Endorsed'
        );
        System.assertEquals(
            recordTypeEndorsedId,
            aa.RecordTypeId,
            'RecordTypeId needs to be for InventorSubmitted'
        );

        Test.stopTest();
    }

    @isTest
    static void givenSoftwareAsInventorNoDeptHead_whenIventorSubmits_thenNoAuditExists() {
        ContactSampleDataFactory.createSampleContacts();

        String title = 'givenSoftwareAsInventorNoDeptHead_whenIventorSubmits_thenNoAuditExists';
        Disclosure__c disclosure = DisclosureSampleDataFactory.createDraftSoftwareDisclosureNoDeptHead(
            title,
            false
        );

        Disclosure__c disclosureToTest = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Name__c = :title
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
            1,
            inventorAuditTrail.size(),
            'inventorAuditTrail.size() should be 1 at this point, no audit trail for Draft Disclosures.'
        );

        disclosureToTest.Status__c = 'Inventor Submitted';
        update disclosureToTest;

        Disclosure__c disclosureToTestAgain = [
            SELECT Id, Status__c
            FROM Disclosure__c
            WHERE Name__c = :title
            LIMIT 1
        ];
        List<Disclosure_Audit_Event__c> inventorAuditTrail1 = [
            SELECT
                Id,
                Description__c,
                Disclosure__c,
                Event_Date__c,
                Subject__c,
                RecordTypeId
            FROM Disclosure_Audit_Event__c
            WHERE Disclosure__c = :disclosureToTestAgain.Id
        ];

        System.assertEquals(
            2,
            inventorAuditTrail1.size(),
            'inventorAuditTrail.size() should only be 2 at this point'
        );
    }
}