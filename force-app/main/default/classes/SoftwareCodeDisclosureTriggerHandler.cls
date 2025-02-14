public class SoftwareCodeDisclosureTriggerHandler {
    public static void onAfterUpdate(List<Software_Code_Disclosure__c> softwareCodeList, Map<Id, Software_Code_Disclosure__c> oldSoftwareCodeMap) {
        // If the Is_Open_Source_YN__c field is No, delete the related Open_Source__c object
        List<Open_Source__c> openSourceDeleteList = new List<Open_Source__c>();
        for(Software_Code_Disclosure__c softwareCode : softwareCodeList) {
            if(
                softwareCode.Is_Open_Source_YN__c == 'No' &&
                oldSoftwareCodeMap.get(softwareCode.Id).Is_Open_Source_YN__c == 'Yes'
            ) {
                openSourceDeleteList.addAll(DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(softwareCode.Id));
            }
        }

        if(!openSourceDeleteList.isEmpty()) {
            delete openSourceDeleteList;
        }
    }
}