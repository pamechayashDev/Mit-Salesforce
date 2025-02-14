@isTest
public class ArchiveDraftDisclosuresTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }
    @isTest
    public static void createDraftDisclosure() {
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

        Disclosure__c disclosureWithNoInventors = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Draft Disclosure with no Inventors',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;

        insert dh;

        DisclosureInventor__c di = new DisclosureInventor__c();
        di.Disclosure__c = d.Id;
        di.PrimaryInventor__c = false;
        di.Contact__c = cont.Id;
        insert di;

        Integer draftDateOlderThan =
            Integer.valueOf(
                ConfigurationBuilder.getConfigurationToString(
                    'archiveDraftOlderThan'
                )
            ) + 1;
        DateTime dt = DateTime.now().addDays(-draftDateOlderThan);
        Date theDate = Date.newInstance(dt.year(), dt.month(), dt.day());
        d.Draft_Date__c = theDate;
        disclosureWithNoInventors.Draft_Date__c = theDate;
        update d;
        update disclosureWithNoInventors;

        Test.startTest();
        Id batchprocessid = Database.executeBatch(
            new ArchiveDraftDisclosures(),
            2
        );

        AsyncApexJob aaj = [
            SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob
            WHERE ID = :batchprocessid
        ];
        System.assert(aaj != null);
        Test.stopTest();

        List<Notification__c> testSubmittingNotificationsCreated = [
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
                Template__c = :NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED
        ];
        System.Assert(
            testSubmittingNotificationsCreated.size() == 2,
            'All Submitters should get notified that Draft was Archived'
        );
    }
}