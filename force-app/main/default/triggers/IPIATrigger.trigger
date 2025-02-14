/**
 * Created by Andreas du Preez on 2024/07/30.
 */

trigger IPIATrigger on IPIA_Record__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    String ipiaTriggerEnabledStr = 'true';
    Configurations__c ipiaTriggerEnabledConfig = Configurations__c.getInstance('ipiaTriggerEnabled');
    if (ipiaTriggerEnabledConfig != null) {
        ipiaTriggerEnabledStr = ipiaTriggerEnabledConfig.Value__c;
    }     
    Boolean ipiaTriggerEnabled = Boolean.valueOf(ipiaTriggerEnabledStr);

    if(Trigger.isBefore && Trigger.isInsert && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onAfterUpdate(Trigger.old, Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isDelete && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onBeforeDelete(Trigger.old);
    }

    if(Trigger.isAfter && Trigger.isDelete && ipiaTriggerEnabled) {
        IPIARecordTriggerHandler.onAfterDelete(Trigger.old);
    }
}