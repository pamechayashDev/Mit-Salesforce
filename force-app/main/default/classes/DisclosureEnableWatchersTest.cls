@IsTest
public with sharing class DisclosureEnableWatchersTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    static void setupTestData(String name) {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdCellLine = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('cellLine')
            .getRecordTypeId();

        Account inventorContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account inventorContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            name,
            'Draft',
            inventorContact1
        );

        DisclosureInventor__c inventorSubmitting = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact1
        );
        DisclosureInventor__c inventorAntibody = SampleDataFactory.createInventor(
            disclosure,
            true,
            inventorContact2
        );
    }

    @IsTest
    static void testEnableWatcherProcess() {
        String name = 'Name testEnableWatcherProcess';
        DisclosureEnableWatchersTest.setupTestData(name);
        Test.startTest();
        System.runAs(SampleDataTest.getJitUser()) {
            Disclosure__c disclosure = [
                SELECT Id
                FROM Disclosure__c
                WHERE Name__c = :name
                LIMIT 1
            ];

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/api/disclosure-enable-watchers/v1?disclosureId';
            req.httpMethod = 'POST';
            req.params.put('disclosureId', disclosure.Id);

            RestContext.request = req;
            RestContext.response = res;

            String result = DisclosureEnableWatchers.enableWatchersRest();
            System.debug(result);
            System.assert(result != null, 'result cannot be null');
            System.assert(
                res.statusCode == 200,
                'HTTP Status Code should be 200'
            );
        }
        Test.stopTest();

        List<Notification__c> notificationsForAll = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW
        ];

        System.assert(
            notificationsForAll.size() == 1,
            'Primary Inventor to Review Draft Notifications not Created.'
        ); // Submitting Contact should not get Notified

        Notification__c notification = notificationsForAll.get(0);
        Map<String, Object> variableMap = NotificationBuilder.deserializeVariables(
            notification.Variables__c
        );
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        RecordType bioRecordType = [
            SELECT Name
            FROM RecordType
            WHERE ID = :recordTypeIdBioTang
            LIMIT 1
        ];
        System.assertEquals(
            bioRecordType.Name,
            String.valueOf(variableMap.get('disclosure_type')),
            'disclosure_type1 should be the Name of BioTang_Disclosure'
        );

        // ====================================
        // Remove Inventor
        // ====================================
        DisclosureInventor__c inventor = [
            SELECT Id
            FROM DisclosureInventor__c
            WHERE Contact__r.PersonEmail = 'john_sample@external.com'
        ];
        inventor.PrimaryInventor__c = false;
        update inventor;

        List<Notification__c> notificationsForRemoved = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_REMOVED
        ];

        System.assert(
            notificationsForRemoved.size() == 1,
            'Named Primary Inventor not removed.'
        ); // Submitting Contact should not get Notified

        // ====================================
        // Delete Inventor
        // ====================================
        delete inventor;
        List<Notification__c> notificationsForDeletion = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DELETED
        ];

        System.assert(
            notificationsForDeletion.size() == 1,
            'Named Watcher not notified.'
        );
    }
}