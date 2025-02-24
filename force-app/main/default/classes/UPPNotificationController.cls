public with sharing class UPPNotificationController {
    @AuraEnabled
    public static List<UPP_Notification__c> getUserNotifications() {
        Id currentUserId = UserInfo.getUserId();
        return [
            SELECT Id, Business_Area__c, Subject__c, Sent__c, Conversation__c, User__c ,User__r.Name
            FROM UPP_Notification__c
            WHERE User__c = :currentUserId
            ORDER BY Sent__c DESC
        ];
    }
}