/**
 * Handler for Department_Head__c after triggers
 */

public with sharing class DepartmentHeadAfterHandler {
    private static Id recordTypeIdDelegate = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Endorse_or_Delegate_Disclosure')
        .getRecordTypeId();

    /**
     * Handler method for Department_Head__c after insert operations
     * @param deptHeads List of Department_Head__c objects that were inserted
     */
    public static void insertDepartmentHead(
        List<Department_Head__c> deptHeads
    ) {
        // Create Contact Actions
        if (deptHeads != null) {
            initContactActions(deptHeads);
        }
    }

    /**
     * Handler method for Department_Head__c after update operations
     * @param deptHeads List of Department_Head__c objects that were updated
     */
    public static void updateDepartmentHead(
        List<Department_Head__c> deptHeads
    ) {
        if (deptHeads != null) {
            ContactActionHandler.completeDelegatedPendingContactActions(
                deptHeads
            );
        }
    }

    /**
     * Handler method for Department_Head__c after delete operations
     * @param deptHeads List of Department_Head__c objects that were deleted
     */
    public static void deleteDepartmentHead(
        List<Department_Head__c> deptHeads
    ) {
        if (deptHeads != null) {
            ContactActionHandler.cancelDeletedDeptHeadPendingContactActions(
                deptHeads
            );
        }
    }

    /**
     * Initialize Contact_Actions__c for Department Heads if the Dislcosure
     * Status is 'Pending Department Approval', normally when delegated
     * @param deptHeads List of Department_Head__c objects that need Contact_Actions__c created
     */
    private static void initContactActions(List<Department_Head__c> deptHeads) {
        Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();

        for (Department_Head__c deptHead : deptHeads) {
            Disclosure__c disc = DisclosureRecordFetch.getDisclosureById(
                deptHead.Disclosure__c
            );
            if (disc.Status__c == 'Pending Department Approval') {
                contactDisclosureMap.put(
                    DisclosureRecordFetch.getContactById(deptHead.Contact__c),
                    deptHead.Disclosure__c
                );
            }
        }
        ContactActionHandler.initDisclosureContactAction(
            contactDisclosureMap,
            recordTypeIdDelegate
        );
    }
}