public with sharing class DepartmentHeadValidation {
    public static void validateDepartmentHead(
        List<Department_Head__c> departmentHeads
    ) {
        //Before Insert new map is null

        Map<ID, Set<ID>> disclosureContacts = new Map<ID, Set<ID>>();
        Set<ID> disclosureSet = new Set<Id>();

        for (Department_Head__c departmentHead : departmentHeads) {
            disclosureSet.add(departmentHead.Disclosure__c);
            if (
                disclosureContacts.containsKey(departmentHead.Disclosure__c) ==
                false
            ) {
                Set<ID> contactList = new Set<ID>();
                disclosureContacts.put(
                    departmentHead.Disclosure__c,
                    contactList
                );
            }
            disclosureContacts.get(departmentHead.Disclosure__c)
                .add(departmentHead.Contact__c);
        }

        List<Department_Head__c> existingDepartmentHead = [
            SELECT
                Id,
                Contact__r.Id,
                Contact__r.MoiraStatus__pc,
                Delegated_To__r.Contact__r.Id,
                Disclosure__r.Id
            FROM Department_Head__c
            WHERE Disclosure__c IN :disclosureSet
        ];

        List<DisclosureInventor__c> existingInventors = [
            SELECT
                Id,
                PrimaryInventor__c,
                Contact__c,
                Contact__r.Id,
                Contact__r.MoiraStatus__pc,
                Disclosure__r.Id
            FROM DisclosureInventor__c
            WHERE Disclosure__c IN :disclosureSet
        ];

        for (DisclosureInventor__c existingInventor : existingInventors) {
            if (
                disclosureContacts.containsKey(
                    existingInventor.Disclosure__r.Id
                )
            ) {
                Set<Id> contactSet = disclosureContacts.get(
                    existingInventor.Disclosure__r.Id
                );
                if (contactSet.contains(existingInventor.Contact__r.Id)) {
                    findDepartmentHead(
                            departmentHeads,
                            existingInventor.Disclosure__r.Id,
                            existingInventor.Contact__r.Id
                        )
                        .addError(label.Disclosure_Error_Unique_TLO_Contact);
                }
            }
        }
    }

    private static Department_Head__c findDepartmentHead(
        List<Department_Head__c> newDeptHead,
        ID disclosureId,
        ID contact
    ) {
        for (Department_Head__c deptHead : newDeptHead) {
            if (
                deptHead.Disclosure__c == disclosureId &&
                deptHead.Contact__c == contact
            ) {
                return deptHead;
            }
        }
        return null;
    }
}