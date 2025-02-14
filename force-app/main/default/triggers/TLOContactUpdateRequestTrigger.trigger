trigger TLOContactUpdateRequestTrigger on TLO_Contact_Update_Request__c (before update) {

    if(Trigger.isUpdate && Trigger.isBefore) {
        TLOContactUpdateRequestTriggerHandler.onBeforeUpdate(Trigger.new);
    }

}