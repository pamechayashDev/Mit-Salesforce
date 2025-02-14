@IsTest
public with sharing class DepartmentHeadNotificationTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    private static Disclosure__c getDisclosureToTest(String title) {
        Disclosure__c disclosureToTest = [
            SELECT
                Id,
                Status__c,
                Name__c,
                Name,
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

    @IsTest
    static void testDeptHeadOnOpenSourceEndorsementNotification() {
        Test.startTest();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];

        Account deptHeadContactDelegated = SampleDataFactory.createContact(
            'Tiger',
            true,
            '103456780'
        );
        Account departmentHeadContact = SampleDataFactory.createContact(
            'Scott',
            true,
            '123456780'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'Bob',
            true,
            '123456781'
        );
        Account nonMitInventorContact = SampleDataFactory.createContact(
            'Donald',
            false,
            null
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Jeff',
            true,
            '11345678'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            'Title Of',
            'Draft',
            submittingContact
        );
        Department_Head__c deptHeadFirst = SampleDataFactory.createDepartmentHead(
            disclosure,
            departmentHeadContact
        );

        Department_Head__c deptHeadEndorse = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContactDelegated
        );
        deptHeadFirst.Delegated_To__c = deptHeadEndorse.Id;
        update deptHeadFirst;

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
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContact
        );

        System.assertEquals(
            'Pending',
            inventor.Signed_Status__c,
            'Inventor Signed Disclosure Flag need to be Pending'
        );

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        List<Notification__c> notificationsForTigerOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'tiger_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST
        ];
        System.assert(
            notificationsForTigerOnly.size() == 1,
            'DLC Opensource Notifications not Created for Tiger.'
        );

        Notification__c delegatedNotification = notificationsForTigerOnly.get(
            0
        );
        Map<String, Object> variableMapDlc = NotificationBuilder.deserializeVariables(
            delegatedNotification.Variables__c
        );
        System.assert(
            String.valueOf(variableMapDlc.get('submitter_name')).length() > 0,
            'Submitter Name missing'
        );
        System.assert(
            String.valueOf(variableMapDlc.get('disclosure_type')).length() > 0,
            'disclosure_type missing'
        );
        System.assertEquals(
            swRecordType.Name,
            String.valueOf(variableMapDlc.get('disclosure_type')),
            'disclosure_type1 should be the Name of Software_Code_Disclosure'
        );
        System.assert(
            String.valueOf(variableMapDlc.get('disclosure_name')).length() > 0,
            'disclosure_name Name missing'
        );

        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notificationsForTigerOnly.get(0).Variables__c
        );
        System.assert(
            String.valueOf(variableMap.get('submitter_name')).length() > 0,
            'Submitter Name missing'
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'Only one notifications should have been created, one for DeptHead on the Disclosure'
        );

        Test.stopTest();
    }

    /**
     * Test Delegated Department Head after Status is Pending Department Approval.
     */
    @IsTest
    static void testDeptHeadOnDelegatedEndorsementAfterStatusNotification() {
        String disclosureTitle = 'testDeptHeadOnDelegatedEndorsementAfterStatusNotification';
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account deptHeadContactDelegatedTo = SampleDataFactory.createContact(
            'deptHead2nd',
            true,
            '103456780'
        );
        Account deptHeadFirstContact = SampleDataFactory.createContact(
            'deptHead1st',
            true,
            '123456780'
        );
        Account inventorContact = SampleDataFactory.createContact(
            'mitInventor',
            true,
            '123456781'
        );
        Account nonMitInventorContact = SampleDataFactory.createContact(
            'nonMitInventor',
            false,
            null
        );
        Account submittingContact = SampleDataFactory.createContact(
            'Submitter',
            true,
            '11345678'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            disclosureTitle,
            'Draft',
            submittingContact
        );
        Department_Head__c deptHeadFirst = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadFirstContact
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
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );
        DisclosureInventor__c inventor = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact
        );
        SampleDataFactory.createInventor(
            disclosure,
            false,
            nonMitInventorContact
        );

        System.assertEquals(
            'Pending',
            inventor.Signed_Status__c,
            'Inventor Signed Disclosure Flag need to be Pending'
        );

        // Only watchers will get notified
        DisclosureEnableWatchers.enableDraftWatchers(disclosure.Id);

        Test.startTest();
        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        Disclosure__c disclosureToTest = getDisclosureToTest(disclosureTitle);
        RecordType swRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdSoftware
            LIMIT 1
        ];

        //=========== email to 1st Dept Head telling them that they've been assigned as a Dept Head on a Disclosure
        List<Notification__c> firstDeptHeadEndorsementRequestNotification = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'deptHead1st_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST
        ];
        System.assert(
            firstDeptHeadEndorsementRequestNotification.size() == 1,
            'DeptHead Opensource Notifications not Created for First Dept Head.'
        );
        Notification__c firstDeptHeadNotification = firstDeptHeadEndorsementRequestNotification.get(
            0
        );
        Map<String, Object> firstDeptHeadVariableMap = NotificationBuilder.deserializeVariables(
            firstDeptHeadNotification.Variables__c
        );
        System.assert(
            String.valueOf(firstDeptHeadVariableMap.get('dlc_email')) ==
            deptHeadFirstContact.PersonEmail,
            'dlc_email email not set'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                submittingContact.FirstName,
                submittingContact.MiddleName,
                submittingContact.LastName,
                true
            ),
            String.valueOf(firstDeptHeadVariableMap.get('submitter_name')),
            'submitter_name not correct'
        );
        //===========

        //=========== DeptHead delegates to someone else.
        Department_Head__c deptHeadDelegatedTo = SampleDataFactory.createDepartmentHead(
            disclosure,
            deptHeadContactDelegatedTo
        );
        deptHeadFirst.Delegated_To__c = deptHeadDelegatedTo.Id;
        deptHeadFirst.Comment__c = 'Comment';
        update deptHeadFirst;

        //=========== 1st dept head delegated to someone else .. email sent to them telling them this delegation was successful
        List<Notification__c> firstDeptHeadDelegatedToSomeoneElseNotifications = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'deptHead1st_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_PROXIED
        ];
        System.assert(
            firstDeptHeadDelegatedToSomeoneElseNotifications.size() == 1,
            'DeptHead Proxied Notifications should be Created for Scott.'
        );
        Notification__c firstDeptHeadDelegatedToSomeoneElseNotification = firstDeptHeadDelegatedToSomeoneElseNotifications.get(
            0
        );
        Map<String, Object> firstDeptHeadDelegatedToSomeoneElseNotificationVariableMap = NotificationBuilder.deserializeVariables(
            firstDeptHeadDelegatedToSomeoneElseNotification.Variables__c
        );
        System.assert(
            String.valueOf(
                firstDeptHeadDelegatedToSomeoneElseNotificationVariableMap.get(
                    'dlc_email'
                )
            ) == deptHeadFirstContact.PersonEmail,
            'Proxied DeptHead email not set'
        );
        System.assert(
            String.valueOf(
                firstDeptHeadDelegatedToSomeoneElseNotificationVariableMap.get(
                    'dlc_delegated_email'
                )
            ) == deptHeadContactDelegatedTo.PersonEmail,
            'Delegated DeptHead email not set'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                submittingContact.FirstName,
                submittingContact.MiddleName,
                submittingContact.LastName,
                true
            ),
            String.valueOf(
                firstDeptHeadDelegatedToSomeoneElseNotificationVariableMap.get(
                    'submitter_name'
                )
            ),
            'submitter_name not correct'
        );
        //===========

        //=========== 1st dept head delegated to someone else .. 2nd dept head does not get initial email like 1st one (telling them that they've been assigned as a Dept Head on a Disclosure)
        List<Notification__c> secondDeptHeadNoEndorseNotifications = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'deptHead2nd_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST
        ];
        System.assert(
            secondDeptHeadNoEndorseNotifications.size() == 0,
            'DeptHead Opensource Notifications should not be Created for Tiger.'
        );

        // ================== they get email telling them that 1st dept. had delegated the endorsement request to them
        List<Notification__c> secondDeptHeadNotificationsOnly = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                To__c = 'deptHead2nd_sample@mit.edu'
                AND Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST_DELEGATED
        ];
        System.assert(
            secondDeptHeadNotificationsOnly.size() == 1,
            'DeptHead Opensource Delegated Notifications should not be Created for Tiger.'
        );
        Notification__c delegatedToNotification = secondDeptHeadNotificationsOnly.get(
            0
        );
        Map<String, Object> delegatedToVariableMap = NotificationBuilder.deserializeVariables(
            delegatedToNotification.Variables__c
        );

        System.debug(
            '\n\nndelegatedToVariableMap:- \n\n' +
            delegatedToVariableMap +
            '\n\n'
        );
        System.assert(
            String.valueOf(delegatedToVariableMap.get('comments')).length() > 0,
            'Delegated To Comments missing'
        );
        System.assert(
            String.valueOf(delegatedToVariableMap.get('submitter_name'))
                .length() > 0,
            'Submitter Name missing'
        );
        System.assert(
            String.valueOf(delegatedToVariableMap.get('disclosure_type'))
                .length() > 0,
            'disclosure_type missing'
        );
        System.assertEquals(
            swRecordType.Name,
            String.valueOf(delegatedToVariableMap.get('disclosure_type')),
            'disclosure_type1 should be the Name of Software_Code_Disclosure'
        );
        System.assertEquals(
            deptHeadFirst.Comment__c,
            String.valueOf(delegatedToVariableMap.get('comments')),
            'comments not correct'
        );

        System.assertEquals(
            deptHeadFirstContact.PersonEmail.toLowerCase(),
            String.valueOf(delegatedToVariableMap.get('dlc_email')),
            'dlc_email not correct'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                deptHeadFirstContact.FirstName,
                deptHeadFirstContact.MiddleName,
                deptHeadFirstContact.LastName,
                true
            ),
            String.valueOf(delegatedToVariableMap.get('dlc_name')),
            'dlc_name not correct'
        );

        System.assertEquals(
            deptHeadContactDelegatedTo.PersonEmail.toLowerCase(),
            String.valueOf(delegatedToVariableMap.get('dlc_delegated_email')),
            'dlc_email not correct'
        );
        System.assertEquals(
            ContactNameUtil.toFullName(
                deptHeadContactDelegatedTo.FirstName,
                deptHeadContactDelegatedTo.MiddleName,
                deptHeadContactDelegatedTo.LastName,
                true
            ),
            String.valueOf(delegatedToVariableMap.get('dlc_delegated_name')),
            'dlc_name not correct'
        );

        System.assertEquals(
            disclosureToTest.Name__c,
            String.valueOf(delegatedToVariableMap.get('disclosure_title')),
            'disclosure_title not correct'
        );
        System.assertEquals(
            disclosureToTest.Name,
            String.valueOf(delegatedToVariableMap.get('disclosure_name')),
            'disclosure_name not correct'
        );

        List<Notification__c> testAllNotificationsCreated = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'Only one notifications should have been created, one for DeptHead on the Disclosure and not one for Delegated DeptHead'
        );

        // ============================
        // TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED (disclosure-primary_inventors_and_submitter-endorsement_request_delegated)
        // ============================
        List<Notification__c> testAllInventorDelegatedEndorsementRequest = [
            SELECT
                Id,
                Name,
                BCC__c,
                CC__c,
                Failure_Count__c,
                Status__c,
                Template__c,
                To__c,
                Variables__c
            FROM Notification__c
            WHERE
                Template__c = :NotificationBuilder.TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED
        ];
        System.Assert(
            testAllInventorDelegatedEndorsementRequest.size() == 2,
            'Only two notifications should have been created, one for Primary inventor and one for Submitter on the Disclosure, notified that Endorsement request was delegated'
        );

        for (Notification__c n : testAllInventorDelegatedEndorsementRequest) {
            //submitter tests
            if (n.To__c == submittingContact.PersonEmail) {
                Map<String, Object> nVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug('\n\nnVariableMap:- \n\n' + nVariableMap + '\n\n');

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        submittingContact.FirstName,
                        submittingContact.MiddleName,
                        submittingContact.LastName,
                        true
                    ),
                    String.valueOf(nVariableMap.get('inventor_name')),
                    'inventor_name not correct'
                );

                //Dept Head delegated to
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        deptHeadContactDelegatedTo.FirstName,
                        deptHeadContactDelegatedTo.MiddleName,
                        deptHeadContactDelegatedTo.LastName,
                        true
                    ),
                    String.valueOf(nVariableMap.get('dlc_name')),
                    'dlc_name not correct'
                );
                System.assertEquals(
                    deptHeadContactDelegatedTo.PersonEmail.toLowerCase(),
                    String.valueOf(nVariableMap.get('dlc_email')),
                    'dlc_email not correct'
                );

                //Dept Head
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        deptHeadFirstContact.FirstName,
                        deptHeadFirstContact.MiddleName,
                        deptHeadFirstContact.LastName,
                        true
                    ),
                    String.valueOf(nVariableMap.get('dlc_from_name')),
                    'dlc_from_name not correct'
                );
                System.assertEquals(
                    deptHeadFirstContact.PersonEmail.toLowerCase(),
                    String.valueOf(nVariableMap.get('dlc_from_email')),
                    'dlc_from_email not correct'
                );
            }

            //inventor tests
            if (n.To__c == inventorContact.PersonEmail) {
                Map<String, Object> nnVariableMap = NotificationBuilder.deserializeVariables(
                    n.Variables__c
                );
                System.debug(
                    '\n\nnnVariableMap:- \n\n' +
                    nnVariableMap +
                    '\n\n'
                );

                System.assertEquals(
                    swRecordType.Name,
                    String.valueOf(nnVariableMap.get('disclosure_type')),
                    'disclosure_type should be the Name of Software_Code_Disclosure'
                );
                System.assertEquals(
                    disclosureToTest.Name__c,
                    String.valueOf(nnVariableMap.get('disclosure_title')),
                    'disclosure_title not correct'
                );
                System.assertEquals(
                    disclosureToTest.Name,
                    String.valueOf(nnVariableMap.get('disclosure_name')),
                    'disclosure_name not correct'
                );

                //Submitted/Inventor
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        inventorContact.FirstName,
                        inventorContact.MiddleName,
                        inventorContact.LastName,
                        true
                    ),
                    String.valueOf(nnVariableMap.get('inventor_name')),
                    'inventor_name not correct'
                );

                //Dept Head delegated to
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        deptHeadContactDelegatedTo.FirstName,
                        deptHeadContactDelegatedTo.MiddleName,
                        deptHeadContactDelegatedTo.LastName,
                        true
                    ),
                    String.valueOf(nnVariableMap.get('dlc_name')),
                    'dlc_name not correct'
                );
                System.assertEquals(
                    deptHeadContactDelegatedTo.PersonEmail.toLowerCase(),
                    String.valueOf(nnVariableMap.get('dlc_email')),
                    'dlc_email not correct'
                );

                //Dept Head
                System.assertEquals(
                    ContactNameUtil.toFullName(
                        deptHeadFirstContact.FirstName,
                        deptHeadFirstContact.MiddleName,
                        deptHeadFirstContact.LastName,
                        true
                    ),
                    String.valueOf(nnVariableMap.get('dlc_from_name')),
                    'dlc_from_name not correct'
                );
                System.assertEquals(
                    deptHeadFirstContact.PersonEmail.toLowerCase(),
                    String.valueOf(nnVariableMap.get('dlc_from_email')),
                    'dlc_from_email not correct'
                );
            }
        }
        Test.stopTest();
    }
}