public class DepartmentHeadTriggerHandler {
    // RecordType Id
    private static Id recordTypeIdDelegate = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Endorse_or_Delegate_Disclosure')
        .getRecordTypeId();
    private static Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Sign_Disclosure')
        .getRecordTypeId();
    // Status type
    public enum Status {
        Pending,
        Completed,
        Canceled
    }

    public static void onBeforeInsert(
        List<Department_Head__c> departmentHeadList
    ) {
        DepartmentHeadValidation.validateDepartmentHead(departmentHeadList);
    }

    public static void onBeforeUpdate(
        List<Department_Head__c> departmentHeadList,
        Map<Id, Department_Head__c> olddepartmentHeadList
    ) {
        Set<String> departmentHeadIds = new Set<String>();
        for (Department_Head__c disinv : departmentHeadList) {
            departmentHeadIds.add(disinv.Id);
        }
        if (departmentHeadIds != null && !departmentHeadIds.isEmpty()) {
            List<Department_Head__c> depHeadList = DisclosureRecordFetch.getDepartmentHeadsByIds(
                departmentHeadIds
            );
            Map<String, String> idStatusMap = new Map<String, String>();
            for (Department_Head__c dep : depHeadList) {
                idStatusMap.put(dep.Id, dep.Disclosure__r.Status__c);
            }

            for (Department_Head__c disinv : departmentHeadList) {
                // TODO: Refactor - Remove post AC migration
                if (
                    !PersonAccountMigrationHelpers.isPersonAccountMigrationInProgress()
                ) {
                    if (
                        idStatusMap.get(disinv.Id) == 'Approved' ||
                        idStatusMap.get(disinv.Id) == 'Rejected'
                    ) {
                        disinv.addError(Label.Disclosure_Error_Editable_State);
                    }
                }
            }
        }
    }

    public static void onAfterInsert(
        List<Department_Head__c> departmentHeadList
    ) {
        List<Id> departmentHeadIds = new List<Id>();
        for (Department_Head__c disinv : departmentHeadList) {
            departmentHeadIds.add(disinv.Id);
        }

        DisclosureCreateAuditEvent.createDelegatedToAuditEventChange(
            departmentHeadList,
            null
        );

        insertDepartmentHead(departmentHeadList);
    }

    public static void onAfterUpdate(
        List<Department_Head__c> departmentHeadList,
        Map<Id, Department_Head__c> olddepartmentHeadList
    ) {
        List<Id> departmentHeadIds = new List<Id>();
        Set<String> contact = new Set<String>();
        Set<String> disclosure = new Set<String>();
        for (Department_Head__c disinv : departmentHeadList) {
            departmentHeadIds.add(disinv.Id);
            if (disinv.Contact__c != null) {
                contact.add(disinv.Contact__c);
            }
            if (disinv.Disclosure__c != null) {
                disclosure.add(disinv.Disclosure__c);
            }
        }

        DisclosureCreateAuditEvent.createDelegatedToAuditEventChange(
            departmentHeadList,
            olddepartmentHeadList
        );
        updateDepartmentHead(departmentHeadList, contact, disclosure);
    }

    public static void onAfterDelete(
        List<Department_Head__c> departmentHeadList
    ) {
        Set<String> departmentHeadIds = new Set<String>();
        Set<String> contact = new Set<String>();
        Set<String> disclosure = new Set<String>();
        for (Department_Head__c disinv : departmentHeadList) {
            departmentHeadIds.add(disinv.Id);
            if (disinv.Contact__c != null) {
                contact.add(disinv.Contact__c);
            }
            if (disinv.Disclosure__c != null) {
                disclosure.add(disinv.Disclosure__c);
            }
        }
        deleteDepartmentHead(departmentHeadList, contact, disclosure);
    }

    public static void insertDepartmentHead(
        List<Department_Head__c> deptHeads
    ) {
        if (deptHeads != null) {
            Set<String> depHeadIds = new Set<String>();
            for (Department_Head__c d : deptHeads) {
                depHeadIds.add(d.Id);
            }
            if (depHeadIds != null && !depHeadIds.isEmpty()) {
                List<Department_Head__c> departmentHeadList = DisclosureRecordFetch.getDepartmentHeadsByIds(
                    depHeadIds
                );
                initContactActions(departmentHeadList);
            }
        }
    }

    public static void updateDepartmentHead(
        List<Department_Head__c> deptHeads,
        Set<String> contact,
        Set<String> disclosure
    ) {
        if (deptHeads != null) {
            List<Contact_Action__c> updateConAction = new List<Contact_Action__c>();
            List<Disclosure_Action__c> disaction = [
                SELECT
                    Id,
                    Contact_Action__r.Id,
                    Disclosure__c,
                    Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :contact
                    AND Contact_Action__r.Status__c = 'Pending'
                    AND Disclosure__c = :disclosure
                    AND RecordTypeId = :recordTypeIdDelegate
            ];
            for (Disclosure_Action__c dis : disaction) {
                Contact_Action__c conac = new Contact_Action__c(
                    Id = dis.Contact_Action__c
                );
                conac.Status__c = 'Completed';
                updateConAction.add(conac);
            }
            if (updateConAction != null && !updateConAction.isEmpty()) {
                update updateConAction;
            }
        }
    }

    public static void deleteDepartmentHead(
        List<Department_Head__c> deptHeads,
        Set<String> contact,
        Set<String> disclosure
    ) {
        if (deptHeads != null) {
            List<Contact_Action__c> updateConAction = new List<Contact_Action__c>();
            List<Disclosure_Action__c> disaction = [
                SELECT
                    Id,
                    Contact_Action__r.Id,
                    Disclosure__c,
                    Contact_Action__r.Status__c
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :contact
                    AND Contact_Action__r.Status__c = 'Pending'
                    AND Disclosure__c = :disclosure
                    AND RecordTypeId = :recordTypeIdDelegate
            ];
            for (Disclosure_Action__c dis : disaction) {
                Contact_Action__c conac = new Contact_Action__c(
                    Id = dis.Contact_Action__c
                );
                conac.Status__c = 'Canceled';
                updateConAction.add(conac);
            }
            if (updateConAction != null && !updateConAction.isEmpty()) {
                update updateConAction;
            }
        }
    }

    private static void initContactActions(List<Department_Head__c> deptHeads) {
        Map<String, String> contactDisclosureMap = new Map<String, String>();

        for (Department_Head__c deptHead : deptHeads) {
            if (
                deptHead.Disclosure__r.Status__c ==
                'Pending Department Approval'
            ) {
                contactDisclosureMap.put(
                    deptHead.Contact__c,
                    deptHead.Disclosure__c
                );
            }
        }
        if (contactDisclosureMap != null && contactDisclosureMap.size() > 0) {
            DisclosureInventorNotification.onDeptHeadEndorsementRequestDelegation(
                deptHeads
            );
            initDisclosureContactAction(
                recordTypeIdDelegate,
                contactDisclosureMap
            );
        }
    }

    public static void initDisclosureContactAction(
        Id disclosureActionRecordTypeId,
        Map<String, String> contactDisclosureMap
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        Map<Id, Contact_Action__c> contactActionMap = new Map<Id, Contact_Action__c>();
        for (String key : contactDisclosureMap.keySet()) {
            Contact_Action__c contactAction = new Contact_Action__c(
                Contact__c = key
            );
            contactActions.add(contactAction);
        }
        if (contactActions != null && !contactActions.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(
                contactActions,
                false
            );
            set<String> contactActionId = new Set<String>();
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    contactActionId.add(sr.getId());
                }
            }
            if (contactActionId != null && !contactActionId.isEmpty()) {
                insertdisclosureAction(
                    contactActionId,
                    contactDisclosureMap,
                    disclosureActionRecordTypeId
                );
            }
        }
    }

    public static void insertdisclosureAction(
        set<String> contactActionId,
        Map<String, String> contactDisclosureMap,
        String disclosureActionRecordTypeId
    ) {
        List<Disclosure_Action__c> disclosureActions = new List<Disclosure_Action__c>();
        for (Contact_Action__c contactAction : [
            SELECT Id, Contact__c
            FROM Contact_Action__c
            WHERE Id IN :(contactActionId)
        ]) {
            Disclosure_Action__c disclosureAction = new Disclosure_Action__c(
                Contact_Action__c = contactAction.Id,
                RecordTypeId = disclosureActionRecordTypeId,
                Disclosure__c = contactDisclosureMap.get(
                    contactAction.Contact__c
                )
            );
            disclosureActions.add(disclosureAction);
        }
        if (!disclosureActions.isEmpty()) {
            insert disclosureActions;
        }
    }

    public static void completeDelegatedPendingContactActions(
        List<Department_Head__c> deptHeads
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        for (Department_Head__c deptHead : deptHeads) {
            if (deptHead.Delegated_To__c != null) {
                List<Disclosure_Action__c> deptHeadActions = [
                    SELECT Id, Contact_Action__r.Id
                    FROM Disclosure_Action__c
                    WHERE
                        Contact_Action__r.Contact__c = :deptHead.Contact__c
                        AND Contact_Action__r.Status__c = 'Pending'
                        AND Disclosure__c = :deptHead.Disclosure__c
                        AND RecordTypeId = :recordTypeIdDelegate
                ];
                contactActions.addAll(
                    getUpdatedDisclosureActionStatus(
                        deptHeadActions,
                        Status.Completed
                    )
                );
            }
        }
        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    public static List<Contact_Action__c> getUpdatedDisclosureActionStatus(
        List<Disclosure_Action__c> disclosureActions,
        Status status
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        for (Disclosure_Action__c disclosureAction : disclosureActions) {
            Contact_Action__c contactAction = disclosureAction.Contact_Action__r;
            contactAction.Status__c = status.name();
            contactActions.add(contactAction);
        }

        return contactActions;
    }
}