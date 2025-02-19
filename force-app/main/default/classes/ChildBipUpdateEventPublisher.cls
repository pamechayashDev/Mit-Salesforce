public with sharing class ChildBipUpdateEventPublisher {
    @AuraEnabled
    public static void publishChildBipUpdateEvent(String recordId) {
        childBipComponent_Update__e event = new childBipComponent_Update__e(
            RecordId__c = recordId
        );
        Database.SaveResult result = EventBus.publish(event);
        System.debug('Platform Event Published: ' + result);
    }
}
