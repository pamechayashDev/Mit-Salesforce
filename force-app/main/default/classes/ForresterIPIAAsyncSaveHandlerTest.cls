@isTest
private class ForresterIPIAAsyncSaveHandlerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    static void processSaveTest() {
        // Insert Account without rec id
        IPIA_Record__c ipiaRecord = new IPIA_Record__c(MitId__c = '912345101' , FormName__c = 'Test_IPIA_FormName_1', SignDatetime__c = Date.Today().addDays(-30));
        insert ipiaRecord;

        Async_Request__c asyncReq = AsyncRequestHelper.prepareAsyncRequest(
            ipiaRecord.Id,
            'IPIA_Record__c',
            'IPIASignedToForresterJob'
        );
        insert asyncReq;

        Boolean isSuccess = true;
        Database.SaveResult saveResult = (Database.SaveResult) JSON.deserialize(
            JSON.serialize(
                new Map<String, Object>{
                    'id' => ipiaRecord.Id,
                    'success' => isSuccess,
                    'errors' => new List<String>()
                }
            ),
            Database.SaveResult.class
        );

        // Create mock database instance for external data
        ExternalQueryMock mock = ExternalQueryMock.getInstance();

        // Mock Forrester Contact data
        List<Forrester_CONTACT__x> mockForresterContacts = new List<Forrester_CONTACT__x>();
        Forrester_CONTACT__x mockForresterContact = new Forrester_CONTACT__x(
            MIT_ID__c = '912345101' ,
            CONTACT_RECID__c = '12345'
        );
        mockForresterContacts.add(mockForresterContact);

        mock.setDataStore('Forrester_CONTACT__x:Ids', mockForresterContacts);

        Test.startTest();
        // Create an instance of the callback handler
        ForresterIPIAAsyncSaveHandler forresterIPIACallbackHandler = new ForresterIPIAAsyncSaveHandler(
            asyncReq.Id
        );
        forresterIPIACallbackHandler.processSave(saveResult);
        Test.stopTest();

    }


}