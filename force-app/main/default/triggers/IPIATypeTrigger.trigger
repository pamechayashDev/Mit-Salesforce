/**
 * Created by Andreas du Preez on 2024/08/23.
 */

trigger IPIATypeTrigger on IPIA_Type__c (before insert, before update, after insert, after update, before delete) {
    String ipiaTriggerEnabledStr = 'true';
    Configurations__c ipiaTriggerEnabledConfig = Configurations__c.getInstance('ipiaTriggerEnabled');
    if (ipiaTriggerEnabledConfig != null) {
        ipiaTriggerEnabledStr = ipiaTriggerEnabledConfig.Value__c;
    }     
    Boolean ipiaTriggerEnabled = Boolean.valueOf(ipiaTriggerEnabledStr);

    if(Trigger.isBefore && Trigger.isInsert && ipiaTriggerEnabled) {
        IPIATypeTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate && ipiaTriggerEnabled) {
        IPIATypeTriggerHandler.onBeforeUpdate(Trigger.old, Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert && ipiaTriggerEnabled) {
        IPIATypeTriggerHandler.onAfterInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isDelete && ipiaTriggerEnabled) {
        IPIATypeTriggerHandler.onBeforeDelete(Trigger.old);
    }
}