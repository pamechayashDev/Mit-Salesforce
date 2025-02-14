/**
 * Handler class for Disclosure__c after triggers
 */
public with sharing class DisclosureAfterHandler {
    private static Id recordTypeIdCompleteDraft = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Complete_Draft_Disclosure')
        .getRecordTypeId();
    private static Id recordTypeIdEndorseOrDelegate = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Endorse_or_Delegate_Disclosure')
        .getRecordTypeId();
    private static Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Sign_Disclosure')
        .getRecordTypeId();

    /**
     * Handler method for Disclosure after update operations
     * @param disclosures List of Disclosure__c objects that were updated
     */
    public static void updateDisclosure(
        List<Disclosure__c> disclosures,
        Map<Id, Disclosure__c> oldDisclosures
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        if (disclosures != null) {
            contactActions.addAll(updateDepartmentHeadActions(disclosures));
            contactActions.addAll(updateDraftCompletionActions(disclosures));

            // For disclosures that have moved to "Inventor Submitted" stage
            List<Disclosure__c> inventorSubmittedDisclosures = new List<Disclosure__c>();
            for (Disclosure__c disc : disclosures) {
                if (
                    disc.Status__c == 'Approved' &&
                    oldDisclosures != null &&
                    oldDisclosures.get(disc.Id).Status__c != disc.Status__c
                ) {
                    inventorSubmittedDisclosures.add(disc);
                }
            }
            initSignDisclosureActions(inventorSubmittedDisclosures);
            contactActions.addAll(cancelRedundantContactActions(disclosures));
        }

        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Handler method for Disclosure after delete operations
     * @param disclosures List of Disclosure__c objects that were deleted
     */
    public static void deleteDisclosure(List<Disclosure__c> disclosures) {
        if (disclosures != null) {
            cancelDraftCompletionActions(disclosures);
        }
    }
    /**
     * Cancel any "Pending" Contact Actions for Disclosures that have been deleted
     * @param disclosures List of Disclosure__c objects that need to be cancelled
     */
    private static void cancelDraftCompletionActions(
        List<Disclosure__c> disclosures
    ) {
        ContactActionHandler.markDisclosureActionsAsCancelled(disclosures);
    }

    /**
     * Create "Sign Disclosure" Actions
     * @param disclosures List of Disclosure__c objects that need Actions created
     */
    private static void initSignDisclosureActions(
        List<Disclosure__c> disclosures
    ) {
        Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();

        // Get list of inventors who have not signed
        List<DisclosureInventor__c> unsignedInventors = [
            SELECT Id, Contact__r.Id, Disclosure__c, Signed_Status__c
            FROM DisclosureInventor__c
            WHERE Disclosure__c IN :disclosures AND Signed_Status__c = 'Pending'
        ];

        for (DisclosureInventor__c inv : unsignedInventors) {
            contactDisclosureMap.put(inv.Contact__r, inv.Disclosure__c); // override old one
        }

        ContactActionHandler.initDisclosureContactAction(
            contactDisclosureMap,
            recordTypeIdSignDisclosure
        );
    }

    /**
     * Update or create any "Endorse or Delegate" Actions for Disclosures that
     * have been submitted for review
     * @param disclosures List of Disclosure__c objects that need to be checked
     * for updates
     */
    public static List<Contact_Action__c> updateDepartmentHeadActions(
        List<Disclosure__c> disclosures
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        Set<String> pendingDisclosureIds = new Set<String>();
        Set<String> inventorDisclosureIds = new Set<String>();
        Set<String> rejectedDisclosureIds = new Set<String>();
        Set<String> contactId = new Set<String>();
        for (Disclosure__c disclosure : disclosures) {
            if (disclosure.Status__c == 'Pending Department Approval') {
                pendingDisclosureIds.add(disclosure.Id);
            }
            if (disclosure.Status__c == 'Inventor Submitted') {
                inventorDisclosureIds.add(disclosure.Id);
            }
            if (disclosure.Status__c == 'Rejected') {
                rejectedDisclosureIds.add(disclosure.Id);
            }
        }
        if (pendingDisclosureIds != null && !pendingDisclosureIds.isEmpty()) {
            Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();

            List<Department_Head__c> deptHeads = DisclosureRecordFetch.getDepartmentHeadByDisclosureIds(
                pendingDisclosureIds
            );
            for (Department_Head__c deptHead : deptHeads) {
                // Check if "Endorse or Delegate" action exists for current Dept Head
                contactId.add(deptHead.Contact__c);
            }
            Disclosure_Action__c[] disclosureActions = [
                SELECT Id, Contact_Action__r.Id
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c = :contactId
                    AND Disclosure__c IN :pendingDisclosureIds
                    AND RecordTypeId = :recordTypeIdEndorseOrDelegate
            ];
            if (disclosureActions.size() == 0) {
                for (Department_Head__c deptHead : deptHeads) {
                    Account contact = new Account(Id = deptHead.Contact__c);

                    contactDisclosureMap.put(contact, deptHead.Disclosure__c);
                }

                ContactActionHandler.initDisclosureContactAction(
                    contactDisclosureMap,
                    recordTypeIdEndorseOrDelegate
                );
            }
        }
        if (inventorDisclosureIds != null && !inventorDisclosureIds.isEmpty()) {
            List<Disclosure_Action__c> disclosureActions1 = [
                SELECT Id, Contact_Action__r.Id
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Status__c = 'Pending'
                    AND Disclosure__c IN :inventorDisclosureIds
                    AND RecordTypeId = :recordTypeIdEndorseOrDelegate
            ];
            contactActions.addAll(
                ContactActionHandler.getUpdatedDisclosureActionStatus(
                    disclosureActions1,
                    ContactActionHandler.Status.Completed
                )
            );
        }
        // If Disclosure has been Rejected...
        if (rejectedDisclosureIds != null && !rejectedDisclosureIds.isEmpty()) {
            // Cancel all Pending Contact Actions
            List<Disclosure_Action__c> pendingToCanceledActions = [
                SELECT Id, Contact_Action__r.Id
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Status__c = 'Pending'
                    AND Disclosure__c IN :rejectedDisclosureIds
            ];

            contactActions.addAll(
                ContactActionHandler.getUpdatedDisclosureActionStatus(
                    pendingToCanceledActions,
                    ContactActionHandler.Status.Canceled
                )
            );
        }
        return contactActions;
    }

    private static List<Contact_Action__c> updateDraftCompletionActions(
        List<Disclosure__c> disclosures
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        Map<String, String> discontactMap = new Map<String, String>();
        for (Disclosure__c disclosure : disclosures) {
            if (
                disclosure.Status__c == 'Inventor Submitted' ||
                disclosure.Status__c == 'Pending Department Approval'
            ) {
                if (disclosure.Submitting_Contact__c != null) {
                    discontactMap.put(
                        disclosure.Id,
                        disclosure.Submitting_Contact__c
                    );
                }
            }
        }
        if (discontactMap != null && discontactMap.KeySet() != null) {
            List<Disclosure_Action__c> disclosureActions = [
                SELECT Id, Contact_Action__r.Id
                FROM Disclosure_Action__c
                WHERE
                    Contact_Action__r.Contact__c IN :discontactMap.values()
                    AND Contact_Action__r.Status__c = 'Pending'
                    AND Disclosure__c = :discontactMap.keySet()
                    AND RecordTypeId = :recordTypeIdCompleteDraft
            ];

            contactActions.addAll(
                ContactActionHandler.getUpdatedDisclosureActionStatus(
                    disclosureActions,
                    ContactActionHandler.Status.Completed
                )
            );
        }
        return contactActions;
    }

    private static List<Contact_Action__c> cancelRedundantContactActions(
        List<Disclosure__c> disclosures
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        Set<String> disclosureIds = new Set<String>();

        for (Disclosure__c disclosure : disclosures) {
            if (
                disclosure.Status__c == 'Approved' ||
                disclosure.Status__c == 'Rejected' ||
                disclosure.Status__c == 'Archived'
            ) {
                disclosureIds.add(disclosure.Id);
            }
        }

        if (disclosureIds != null && !disclosureIds.isEmpty()) {
            List<Disclosure_Action__c> pendingDisclosureActionsFromDisclosure = getPendingDisclosureActionsFromDisclosures(
                disclosureIds
            ); // HV TODO ?

            List<Disclosure_Action__c> filteredPendingDisclosureActionsFromDisclosure = new List<Disclosure_Action__c>();
            // TODO is there a better way/place to do this
            // remove an pending (Sign_Disclosure) as those should not be cleared with Disclosure is Approved
            for (
                Disclosure_Action__c action : pendingDisclosureActionsFromDisclosure
            ) {
                if (
                    action.Disclosure__r.Status__c == 'Approved' &&
                    action.RecordTypeId != recordTypeIdSignDisclosure
                ) {
                    // pending (Sign_Disclosure) must stay
                    filteredPendingDisclosureActionsFromDisclosure.add(action);
                }
            }

            List<Contact_Action__c> contactActionsChangedToCanceled = ContactActionHandler.getUpdatedDisclosureActionStatus(
                filteredPendingDisclosureActionsFromDisclosure,
                ContactActionHandler.Status.Canceled
            );

            contactActions.addAll(contactActionsChangedToCanceled);
        }

        return contactActions;
    }

    public static List<Disclosure_Action__c> getPendingDisclosureActionsFromDisclosures(
        Set<String> disclosureIds
    ) {
        return [
            SELECT
                Id,
                Contact_Action__r.Id,
                Disclosure__r.Id,
                Disclosure__r.Status__c,
                RecordTypeId
            FROM Disclosure_Action__c
            WHERE
                Contact_Action__r.Status__c = 'Pending'
                AND Disclosure__c = :disclosureIds
        ];
    }
}