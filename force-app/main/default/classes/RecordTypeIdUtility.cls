public with sharing class RecordTypeIdUtility {


    public static final  Id DISCLOSURE_SOFTWARE = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();
    public static final  Id DISCLOSURE_COPYRIGHT = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Copyright_Disclosure').getRecordTypeId();

    public static Set<Id> getContentVersionRecordTypIds(List<String> recordTypes) {
       Set<Id> recordTypeIds = new Set<Id>();
       for(String recordTypeName : recordTypes) {
           Id agreementRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
           recordTypeIds.add(agreementRecordTypeId);
       }
       return recordTypeIds;
    }
}