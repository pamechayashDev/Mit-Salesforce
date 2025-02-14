@isTest
private class IPIAForresterSyncTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
        ExternalQueryMock.getInstance().clearCache();
    }

    @IsTest
    static void testExistingForresterContactSync() {
        // Add mock data
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345671', SignDatetime__c = Date.today().addDays(-2));
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1 };

        insert ipiaRecords;

        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        Forrester_CONTACT__x mockForresterContact = new Forrester_CONTACT__x(
            MIT_ID__c = '912345671',
            CONTACT_RECID__c = '12345',
            IPIA_SIGNED_FLAG__c = 'N'
        );
        mockForresterContacts.add(mockForresterContact);

        mock.setDataStore('Forrester_CONTACT__x:ids', mockForresterContacts);
        Id jobId;
        Test.startTest();
        try {
            Integer delayInMinutes = 0;
            IPIARecordUpsertJob upsertContactJob = new IPIARecordUpsertJob(
                new Set<Id>{ ipiaRecord1.Id }
            );
            jobId = System.enqueueJob(upsertContactJob, delayInMinutes);
        } catch (Exception e) {
            System.assert(false, 'An exception was thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

  
}