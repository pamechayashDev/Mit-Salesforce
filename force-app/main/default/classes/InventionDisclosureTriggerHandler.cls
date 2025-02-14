public class InventionDisclosureTriggerHandler {

    public static void onBeforeInsert(List<Invention_Disclosure__c> inventionDisclosureListList) {
        Map<Id, Disclosure__c> parents = new Map<Id, Disclosure__c>();
        for(Invention_Disclosure__c inventionDisclosure: inventionDisclosureListList) {
            parents.put(inventionDisclosure.disclosure__c, null);
        }
        if(parents != null && parents.size() > 0) {
            parents.putAll([SELECT Status__c FROM Disclosure__c WHERE Id = :parents.keySet()]);
            for(Invention_Disclosure__c inventionDisclosure:inventionDisclosureListList) {
                Disclosure__c disclosure = parents.get(inventionDisclosure.disclosure__c);
                if(disclosure.Status__c != 'Draft') {
                    InventionDisclosureFieldValidation.validateInventionDisclosureFields(inventionDisclosure);
                }
            }
        }
    }
    
    public static void onBeforeUpdate(List<Invention_Disclosure__c> inventionDisclosureList, Map<Id, Invention_Disclosure__c> oldinv) {
        for(Invention_Disclosure__c inventionDisclosure:inventionDisclosureList) {
            InventionDisclosureFieldValidation.validateInventionDisclosureFieldsDisclosureUpdate(inventionDisclosure);
        }
    }
    
    public static void onAfterInsert(List<Invention_Disclosure__c> invDis) {
        
    }
    
    public static void onAfterUpdate(List<Invention_Disclosure__c> invDis, Map<Id, Invention_Disclosure__c> oldinv) { 
    
    }
}