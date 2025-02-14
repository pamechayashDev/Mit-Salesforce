@isTest
private class CustomLookupControllerTest {

    @isTest
    static void testSearchLookupRecords() {
        
        String searchTerm = 'Testing';
        List<String> selectedIds = new List<String>();
        String sObjectName = 'User';
        String field = 'Name';
        String subField = '';
        Integer maxResults = 5;
        String iconName = 'standard:account';

        Profile prof = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@playgroundorg.com');
        insert usr;
        
        String recordId = usr.id;
        
        Group queue = new Group(Name='Testing', Type='Queue');
        insert queue;
        
        Test.startTest();
        List<customLookupController.LookupSearchResult> results = customLookupController.searchLookupRecords(searchTerm, selectedIds, sObjectName, field, subField, maxResults, iconName);
        customLookupController.LookupSearchResult result = customLookupController.getRecentlyCreatedRecord(sObjectName, recordId, field, subField);
        Test.stopTest();

    }

}