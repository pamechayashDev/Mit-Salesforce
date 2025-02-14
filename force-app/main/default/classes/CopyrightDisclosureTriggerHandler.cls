public class CopyrightDisclosureTriggerHandler {
    public static void onAfterUpdate(List<Copyright_Disclosure__c> copyrightList, Map<Id, Copyright_Disclosure__c> oldCopyrightMap) {
        // If the Creators_Request_Distrib_Open_Source_YN__c field is No, delete the related Open_Source__c object
        List<Open_Source__c> openSourceDeleteList = new List<Open_Source__c>();
        for(Copyright_Disclosure__c copyright : copyrightList) {
            if(
                copyright.Creators_Request_Distrib_Open_Source_YN__c == 'No' &&
                oldCopyrightMap.get(copyright.Id).Creators_Request_Distrib_Open_Source_YN__c == 'Yes'
            ) {
                openSourceDeleteList.addAll(DisclosureRecordFetch.getOpenSourceByCopyrightId(copyright.Id));
            }
        }

        if(!openSourceDeleteList.isEmpty()) {
            delete openSourceDeleteList;
        }
    }
}