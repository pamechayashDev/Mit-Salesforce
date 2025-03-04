public with sharing class UPPNotificationController {
    @AuraEnabled
    public static List<UPP_Notification__c> getUserNotifications(  
    Date dateFrom,
    Date dateTo,
    Boolean showArchived
    ) {
        Id currentUserId = UserInfo.getUserId();
      String recordTypeFilter = showArchived ? 'Archived' : 'Active';
 
       String baseQuery = 'SELECT Id, Business_Area__c, Subject__c, Sent__c, Conversation__c, User__c ,User__r.Name FROM UPP_Notification__c WHERE RecordType.Name = :recordTypeFilter And User__c = :currentUserId';

        List<String> conditions = new List<String>();

  
            if (dateFrom != null) {
                conditions.add('Sent__c >= :dateFrom');
            }
            if (dateTo != null) {
                conditions.add('Sent__c <= :dateTo');
            }
        
        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }
        return Database.query(baseQuery);
    }
}