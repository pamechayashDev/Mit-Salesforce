/**
 * Handler class for Contact Action operations
 */
public with sharing class ContactActionHandler {
    // Record Type Ids
    public static Id recordTypeIdDelegate = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Endorse_or_Delegate_Disclosure')
        .getRecordTypeId();
    public static Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Sign_Disclosure')
        .getRecordTypeId();

    // Status types
    public enum Status {
        Pending,
        Completed,
        Canceled
    }

    public static void initDisclosureContactAction(
        List<DisclosureInventor__c> inventors,
        Id disclosureActionRecordTypeId
    ) {
        initDisclosureContactAction(
            DisclosureRecordFetch.getContactDisclosureMapByInventors(inventors),
            disclosureActionRecordTypeId
        );
    }

    /**
     * Initialize Disclosure_Action__c objects using a list of Account objects and a Record Type
     * @param disclosureContactMap A list of Disclosure__c Ids and associated Account objects
     * @param disclosureActionRecordTypeId The Id of the Disclosure_Action__c Record Type to be used
     */
    public static void initDisclosureContactAction(
        Map<Account, Id> contactDisclosureMap,
        Id disclosureActionRecordTypeId
    ) {
        System.debug(contactDisclosureMap.toString());
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
        List<Disclosure_Action__c> disclosureActions = new List<Disclosure_Action__c>();
        Map<Account, Contact_Action__c> contactActionMap = new Map<Account, Contact_Action__c>();

        // Create the Contact Actions
        System.debug('Creating Contact Actions');

        for (Account key : contactDisclosureMap.keySet()) {
            Contact_Action__c contactAction = new Contact_Action__c(
                Contact__c = key.Id,
                Status__c = 'Pending'
            );
            contactActions.add(contactAction);
            contactActionMap.put(key, contactAction);
        }

        if (!contactActions.isEmpty()) {
            insert contactActions;

            // Create the corresponding Disclosure Actions
            System.debug('Creating Disclosure Actions');

            for (Account contact : contactActionMap.keySet()) {
                Contact_Action__c contactAction = contactActionMap.get(contact);
                Id disclosure = contactDisclosureMap.get(contact);

                System.debug('Contact Action');
                System.debug(contactAction);

                Disclosure_Action__c disclosureAction = new Disclosure_Action__c(
                    Contact_Action__c = contactAction.Id,
                    RecordTypeId = disclosureActionRecordTypeId,
                    Disclosure__c = disclosure
                );
                disclosureActions.add(disclosureAction);

                System.debug('Disclosure Action');
                System.debug(disclosureAction);
            }

            if (!disclosureActions.isEmpty()) {
                insert disclosureActions;
            }
        }
    }

    /**
     * Mark pending Contact Actions as complete if the Department Head has delegated
     * @param deptHeads List of Department_Head__c objects that need to be cleansed
     */
    public static void completeDelegatedPendingContactActions(
        List<Department_Head__c> deptHeads
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        for (Department_Head__c deptHead : deptHeads) {
            // Check if the Department Head has delegated to someone else, but still has a pending Actions
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

    /**
     * Mark pending Contact Actions as cancelled if the Department Head has been deleted
     * @param deptHeads List of Department_Head__c objects that need to be cleansed
     */
    public static void cancelDeletedDeptHeadPendingContactActions(
        List<Department_Head__c> deptHeads
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        for (Department_Head__c deptHead : deptHeads) {
            // Check if the Department Head has pending Actions
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
                    Status.Canceled
                )
            );
        }

        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Mark pending Contact Actions as complete if the Inventor has Signed
     * @param inventors List of DisclosureInventor__c objects that need to be checked
     */
    public static void completeSignDisclosureActions(
        List<DisclosureInventor__c> inventors
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        // TODO this is not a bulkified query for the Disclosure_Action__c :-(
        for (DisclosureInventor__c inv : inventors) {
            Boolean inventorMadeSigningDecision = (inv.Signed_Status__c ==
            'Yes' ||
            inv.Signed_Status__c == 'Opted Out');

            // Check if the Inventor has signed the disclosure, but still has pending Actions
            if (inventorMadeSigningDecision) {
                List<Disclosure_Action__c> signActions = [
                    SELECT Id, Contact_Action__r.Id
                    FROM Disclosure_Action__c
                    WHERE
                        Contact_Action__r.Contact__c = :inv.Contact__c
                        AND Contact_Action__r.Status__c = 'Pending'
                        AND Disclosure__c = :inv.Disclosure__c
                        AND RecordTypeId = :recordTypeIdSignDisclosure
                ];

                // Opted Out: is a legitimate decisions for this action and is thus Completed (not Cancelled)
                contactActions.addAll(
                    getUpdatedDisclosureActionStatus(
                        signActions,
                        Status.Completed
                    )
                );
            }
        }

        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Mark all "Pending" Contact Actions related to the given Disclosures as "Completed"
     * @param disclosures List of Disclousres to be processed
     */
    public static void markDisclosureActionsAsCompleted(
        List<Disclosure__c> disclosures
    ) {
        List<Contact_Action__c> contactActions = getUpdatedDisclosureActionStatus(
            getPendingDisclosureActionsFromDisclosures(disclosures),
            Status.Completed
        );
        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Mark all "Pending" Contact Actions related to the given Disclosures as "Cancelled"
     * @param disclosures The list of Disclousres to be processed
     */
    public static void markDisclosureActionsAsCancelled(
        List<Disclosure__c> disclosures
    ) {
        List<Contact_Action__c> contactActions = getUpdatedDisclosureActionStatus(
            getPendingDisclosureActionsFromDisclosures(disclosures),
            Status.Canceled
        );
        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Mark all "Pending" Contact Actions related to the given Disclosure as "Cancelled"
     * @param disclosure The Disclousre to be processed
     */
    public static void markDisclosureActionsAsCancelled(
        Disclosure__c disclosure
    ) {
        List<Contact_Action__c> contactActions = getUpdatedDisclosureActionStatus(
            getPendingDisclosureActionsFromDisclosure(disclosure),
            Status.Canceled
        );
        if (!contactActions.isEmpty()) {
            update contactActions;
        }
    }

    /**
     * Return the list of associated Contact Actions with a new status
     * @param disclosureActions List of Disclosure Actions that need their associated Contact Actions updated
     * @param status The new status to be used for the Contact Actions
     */
    public static List<Contact_Action__c> getUpdatedDisclosureActionStatus(
        List<Disclosure_Action__c> disclosureActions,
        Status status
    ) {
        List<Contact_Action__c> contactActions = new List<Contact_Action__c>();

        for (Disclosure_Action__c disclosureAction : disclosureActions) {
            // Update all Contact Actions with new status
            Contact_Action__c contactAction = disclosureAction.Contact_Action__r;
            contactAction.Status__c = status.name();
            contactActions.add(contactAction);
            System.debug(
                'Contact Actions to be updated: ' + contactActions.toString()
            );
        }

        return contactActions;
    }

    /**
     * Get all "Pending" Disclosure Actions for a given list of Disclosures
     * @param disclosures The list of Disclosures to be processed
     */
    public static List<Disclosure_Action__c> getPendingDisclosureActionsFromDisclosures(
        List<Disclosure__c> disclosures
    ) {
        List<Id> disclosureIds = new List<Id>();

        for (Disclosure__c disclosure : disclosures) {
            disclosureIds.add(disclosure.Id);
        }

        List<Disclosure_Action__c> disclosureActions = [
            SELECT Id, Contact_Action__r.Id
            FROM Disclosure_Action__c
            WHERE
                Contact_Action__r.Status__c = 'Pending'
                AND Disclosure__c IN :disclosureIds
                AND RecordTypeId != :recordTypeIdSignDisclosure // TODO: This needs to be updated when we get new disclosure status!!!!
        ];

        return disclosureActions;
    }

    /**
     * Get all "Pending" Disclosure Actions for a given list of Disclosures
     * @param disclosure The list of Disclosures to be processed
     */
    public static List<Disclosure_Action__c> getPendingDisclosureActionsFromDisclosure(
        Disclosure__c disclosure
    ) {
        List<Disclosure__c> disclosures = new List<Disclosure__c>();
        disclosures.add(disclosure);
        List<Disclosure_Action__c> disclosureActions = getPendingDisclosureActionsFromDisclosures(
            disclosures
        );
        return disclosureActions;
    }
}