@IsTest
public with sharing class NotificationBuilderTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @IsTest
    static void testNotificationBuilder() {
        Map<String, String> variables = new Map<String, String>();
        variables.put('inventor_email', 'test@mit.edu');

        String sample = NotificationBuilder.notifyVariableMapToString(
            variables
        );
        System.assert(
            sample == '{"inventor_email":"test@mit.edu"}',
            'Map to Notification message error, found ' + sample
        );

        variables.put('title', 'SampleTitle');
        sample = NotificationBuilder.notifyVariableMapToString(variables);
        System.assert(
            sample == '{"title":"SampleTitle","inventor_email":"test@mit.edu"}',
            'Map to Notification message error, found ' + sample
        );

        Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
            'to@mit.edu',
            NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
            variables
        );
        System.assert(
            newEmail.Variables__c ==
            '{"title":"SampleTitle","inventor_email":"test@mit.edu"}',
            'Notification Variables error, found ' + newEmail.Variables__c
        );
        System.assert(
            newEmail.To__c == 'to@mit.edu',
            'Notification TO Address error'
        );
        System.assert(
            newEmail.Template__c ==
            NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
            'Notification Template name error'
        );
        System.assert(
            newEmail.Status__c == 'Pending',
            'Notification status not Pending error'
        );
    }

    @IsTest
    static void testEmptyNotificationVariables() {
        Map<String, String> variables = new Map<String, String>();

        String sample = NotificationBuilder.notifyVariableMapToString(
            variables
        );
        System.assert(sample == '{}', 'Expecting Empty Map , found ' + sample);

        Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
            'to@mit.edu',
            NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
            variables
        );
        System.assert(
            newEmail.Variables__c == '{}',
            'Notification Variables__c not Empty'
        );
    }

    @IsTest
    static void testSerializeNullVariables() {
        Map<String, String> variables = null;

        String sample = NotificationBuilder.notifyVariableMapToString(
            variables
        );
        System.assert(
            sample == null,
            'Null Variable Map expected, found ' + sample
        );

        Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
            'to@mit.edu',
            NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
            variables
        );
        System.assert(
            newEmail.Variables__c == null,
            'Expected Variable__c to be null'
        );
    }

    @IsTest
    static void testDeserializeNullVariables() {
        String jsonMap = null;
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            jsonMap
        );
        System.assert(variableMap == null, 'Map to Notification message error');
    }
    @IsTest
    static void testDeserializeVariables() {
        Map<String, String> variables = new Map<String, String>();
        variables.put('inventor_email', 'test@mit.edu');
        String jsonMap = NotificationBuilder.notifyVariableMapToString(
            variables
        );

        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            jsonMap
        );
        System.assert(
            !variableMap.isEmpty(),
            'Deserialized Map should not be empty'
        );
    }

    @IsTest
    static void testDeserializeSObject() {
        Account sampleContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Disclosure__c testDisclosure = new Disclosure__c(
            Name__c = 'Test Disclosure',
            Status__c = 'Draft',
            RecordTypeId = recordTypeId,
            Submitting_Contact__c = sampleContact.Id
        );
        insert testDisclosure;

        Disclosure__c soqlDisclosure = [
            SELECT Id, Name__c, Status__c, Submitting_Contact__r.PersonEmail
            FROM Disclosure__c
            WHERE Id = :testDisclosure.Id
        ];

        Notification__c notification = NotificationBuilder.buildNotificationEmail(
            'test@mit.edu',
            NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
            soqlDisclosure
        );

        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notification.Variables__c
        );
        System.debug(variableMap);

        System.assert(
            !variableMap.isEmpty(),
            'Deserialized Map should not be empty'
        );

        System.assert(
            variableMap.get('Status__c') == testDisclosure.Status__c,
            'Deserialized Map should contain SObject fields'
        );

        Map<String, Object> contact = (Map<String, Object>) variableMap.get(
            'Submitting_Contact__r'
        );
        System.assert(
            contact.get('PersonEmail') ==
            soqlDisclosure.Submitting_Contact__r.PersonEmail,
            'Deserialized Map should contain SObject Child fields'
        );
    }

    // Ensure Variable__c will be able to hold large rejection reason and title.
    @IsTest
    static void testLargeRejectReasonNotification() {
        Test.startTest();

        String largeDescription = 'a'.repeat(3000); // Disclosure Description can be 3000 chars
        String largeReason = 'b'.repeat(1024); // The Reason can be 1024 chars
        String largeTitle = 'c'.repeat(200); // The Title can be 250 chars

        ContactSampleDataFactory.createSampleContacts();

        Disclosure__c disclosure = SoftwareDisclosuresSampleFactory.createDisclosure(
            largeTitle,
            false
        );
        disclosure.Description__c = largeDescription;

        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        disclosure.Rejected_By__c = 'Department Head';
        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = largeReason;
        update disclosure;

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
                Template__c = :NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD
        ];
        System.Assert(
            testAllNotificationsCreated.size() == 1,
            'One reject notifications should have been created, one for TLO Ops'
        );

        Test.stopTest();
    }
}