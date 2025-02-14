public class DisclosuresTriggerHandler {
    public static final string INITIATOR_ERROR_MSG = 'A disclosure can only be deleted by the Initiator (ie: the person who submitted the disclosure)';
    public static final string DRAFT_ERROR_MSG = 'Only Draft disclosures can be deleted.';
    private static Id recordTypeIdCompleteDraft = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Complete_Draft_Disclosure')
        .getRecordTypeId();
    private static Id recordTypeIdEndorseOrDelegate = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName()
        .get('Endorse_or_Delegate_Disclosure')
        .getRecordTypeId();

    public static void onBeforeInsert(List<Disclosure__c> disList) {
        validateDisclosureSubmittedBy(disList);
        onBeforeInsertValidation(disList);

        if (disList != null && !disList.isEmpty()) {
            for (Disclosure__c disinv : disList) {
                if (disinv.Status__c == 'Draft') {
                    disinv.Draft_Date__c = Util.today();
                }
            }
        }
    }

    public static void onAfterInsert(List<Disclosure__c> newDisList) {
        if (newDisList != null && !newDisList.isEmpty()) {
            Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();

            try {
                for (Disclosure__c disinv : newDisList) {
                    if (disinv.Submitting_Contact__c != null) {
                        Account contact = new Account(
                            Id = disinv.Submitting_Contact__c
                        );
                        contactDisclosureMap.put(contact, disinv.Id);
                    }
                }
            } catch (Exception e) {
                System.debug('An error occured trying to create new Contact');
                System.debug(e);
            }

            if (
                contactDisclosureMap != null &&
                contactDisclosureMap.size() > 0
            ) {
                ContactActionHandler.initDisclosureContactAction(
                    contactDisclosureMap,
                    recordTypeIdCompleteDraft
                );
            }

            DisclosureCreateAuditEvent.createAuditEvents(
                newDisList,
                new Map<Id, Disclosure__c>()
            );
        }
    }

    public static void onBeforeUpdate(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDis
    ) {
        Set<String> disclosureIds = new Set<String>();
        List<Id> approvedDisclosureIds = new List<Id>();

        List<Disclosure__c> draftDisclosures = new List<Disclosure__c>();
        for (Disclosure__c d : disList) {
            disclosureIds.add(d.Id);
            if (
                d.Status__c == 'Draft' &&
                d.Status__c != oldDis.get(d.Id).Status__c
            ) {
                d.Draft_Date__c = Util.today();
            }
            if (
                d.Status__c == 'Approved' &&
                d.Status__c != oldDis.get(d.Id).Status__c
            ) {
                approvedDisclosureIds.add(d.Id);
            }
            // Code Need to Bulkify : Please do not review
            // Should be able to Archive a Disclosure without validation
            if (
                d.Status__c != null &&
                oldDis.get(d.id).Status__c == 'Draft' &&
                d.Status__c != 'Draft' &&
                d.Status__c != 'Archived'
            ) {
                draftDisclosures.add(d);
            }
            // Code Need to Bulkify : Please do not review
        }
        if (!draftDisclosures.isEmpty()) {
            DisclosureValidation.onDraftStatusChange(draftDisclosures);
        }
        // Start Validation
        DisclosureTransitionValidation.statusTransitionValidation(disList, oldDis);
        onBeforeUpdateValidation(disList, oldDis);
        onBeforeTloContactUpdateRequestValidation(
            disList,
            approvedDisclosureIds
        );
    }

    public static void onAfterUpdate(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDis
    ) {
        Set<String> disclosureIds = new Set<String>();
        for (Disclosure__c d : disList) {
            disclosureIds.add(d.Id);
        }
        List<Disclosure__c> queryDisclosures = new List<Disclosure__c>();
        List<DisclosureInventor__c> disInventor = DisclosureRecordFetch.getDisclosureInventorsByDisclosureIds(
            disclosureIds
        );
        List<Department_Head__c> deptHeads = DisclosureRecordFetch.getDepartmentHeadByDisclosureIds(
            disclosureIds
        );

        Map<Id, Disclosure__c> uniqueDisclosures = new Map<Id, Disclosure__c>();
        for (DisclosureInventor__c inv : disInventor) {
            if (uniqueDisclosures.get(inv.Disclosure__r.Id) == null) {
                uniqueDisclosures.put(inv.Disclosure__r.Id, inv.Disclosure__r);
                queryDisclosures.add(inv.Disclosure__r);
            }
        }
        if (queryDisclosures.size() != disList.size()) {
            //Not all the Disclosures have inventors.
            queryDisclosures = DisclosureRecordFetch.getDisclosuresByIds(
                disclosureIds
            );
        }

        //Create Contact Action for Complete Draft Disclosures when disclosure moves from Archive back to Draft
        //Build the list of Submitting TLO Contact and the Disclosure they are assigned to
        Map<Account, Id> contactDisclosureMap = new Map<Account, Id>();
        for (Disclosure__c disinv : queryDisclosures) {
            if (
                disinv.Submitting_Contact__c != null &
                disinv.Status__c == 'Draft' &&
                oldDis.get(disinv.Id).Status__c == 'Archived'
            ) {
                Account contact = new Account(
                    Id = disinv.Submitting_Contact__c
                );
                contactDisclosureMap.put(contact, disinv.Id);
            }
        }
        //Check if there are any disclosures that need the Contact action created
        //If there are, create the Contact Action
        if (contactDisclosureMap != null && contactDisclosureMap.size() > 0) {
            ContactActionHandler.initDisclosureContactAction(
                contactDisclosureMap,
                recordTypeIdCompleteDraft
            );
        }

        DisclosureCreateAuditEvent.createAuditEvents(disList, oldDis);

        DisclosureAfterHandler.updateDisclosure(disList, oldDis);

        // Start Notification on Disclosure Level
        DisclosureOpsNotification.scheduleNotificationsForOps(
            queryDisclosures,
            oldDis,
            deptHeads
        );

        DisclosureInventorNotification.scheduleNotifications(
            queryDisclosures,
            oldDis,
            disInventor,
            deptHeads
        );

        DepartmentHeadNotification.scheduleNotifications(
            queryDisclosures,
            oldDis,
            deptHeads
        );

        // 2460 - Notification
        if (disclosureIds != null && !disclosureIds.isEmpty()) {
            DisclosureOpsNotification.sendNotificationForSigned(
                queryDisclosures,
                oldDis
            );

            // OnApprove add DocuSignSummaryInfo Document
            DocuSignSummaryInfoJob.onDisclosureApprove(
                queryDisclosures,
                oldDis
            );
        }
    }

    public static void onBeforeDelete(List<Disclosure__c> disList) {
        String softwareCodeRecordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        String copyrightRecordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();

        // Only allow the "Disclosure Management Deleter" role to delete Disclosures
        if (
            UserInfo.getUserRoleId() !=
            ShirleyConstants.DISCLOSURE_DELETE_ROLE_ID
        ) {
            for (Disclosure__c d : disList) {
                if (d.Status__c != null && d.Status__c != 'Draft') {
                    d.addError(DRAFT_ERROR_MSG);
                }
            }
        }

        if (disList != null && !disList.isEmpty() && disList.size() == 1) {
            if (disList[0].RecordTypeId == softwareCodeRecordTypeId) {
                List<Software_Code_Disclosure__c> software = DisclosureRecordFetch.getSoftwareCodeByDisclosureId(
                    disList[0].Id
                );
                if (software != null && !software.isEmpty()) {
                    List<Open_Source__c> openSource = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
                        software[0].Id
                    );
                    delete openSource;
                }
            } else if (disList[0].RecordTypeId == copyrightRecordTypeId) {
                List<Copyright_Disclosure__c> copyright = DisclosureRecordFetch.getCopyrightByDisclosureId(
                    disList[0].Id
                );
                if (copyright != null && !copyright.isEmpty()) {
                    List<Open_Source__c> openSource = DisclosureRecordFetch.getOpenSourceByCopyrightId(
                        copyright[0].Id
                    );
                    delete openSource;
                }
            }
        }
        if (disList != null && !disList.isEmpty()) {
            DisclosureInventorNotification.onDeleteDisclosureNotification(
                disList
            );
        }
    }

    public static void onAfterDelete(List<Disclosure__c> disList) {
        DisclosureAfterHandler.deleteDisclosure(disList);
    }

    public static void validateDisclosureSubmittedBy(
        List<Disclosure__c> disList
    ) {
        try {
            string contactId = AccountUtils.getAccountIdFromCurrentUser();

            for (Disclosure__c disclosure : disList) {
                if (disclosure.Submitting_Contact__c == null) {
                    disclosure.Submitting_Contact__c = contactId;
                }
            }
        } catch (System.QueryException e) {
            for (Disclosure__c disclosure : disList) {
                if (disclosure.Submitting_Contact__c == null) {
                    disclosure.addError(
                        'Cannot find Contact for logged in User'
                    );
                }
            }
        }
    }

    public static void onBeforeInsertValidation(List<Disclosure__c> disList) {
        for (Disclosure__c disclosure : disList) {
            if (disclosure.Status__c == null) {
                disclosure.Status__c = 'Draft';
            }
            if (disclosure.Status__c == 'Approved') {
                disclosure.addError(label.Disclosure_Error_Initial_Approved);
            }
        }
    }

    public static void onBeforeTloContactUpdateRequestValidation(
        List<Disclosure__c> disList,
        List<Id> approvedDisclosureIds
    ) {
        Map<Id, Disclosure__c> lookup = new Map<Id, Disclosure__c>();
        lookup.putAll(disList);
        if (!approvedDisclosureIds.isEmpty()) {
            DisclosureValidation.onBeforeApproveValidationByDisclosureId(
                lookup,
                approvedDisclosureIds
            );
        }
    }
    public static void onBeforeUpdateValidation(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosure
    ) {
        for (Disclosure__c disclosure : disList) {
            if (disclosure.Status__c == 'Rejected') {
                if (
                    String.isEmpty(disclosure.Rejection_Reason__c) ||
                    disclosure.Rejection_Reason__c == 'N/A'
                ) {
                    disclosure.addError(
                        label.Disclosure_Error_Rejection_Reason
                    );
                    return;
                }
                if (
                    String.isEmpty(disclosure.Rejected_By__c) ||
                    disclosure.Rejected_By__c == 'N/A'
                ) {
                    disclosure.addError(
                        label.Disclosure_Error_Rejection_Rejected_By
                    );
                    return;
                }
            }
            if (
                !PersonAccountMigrationHelpers.isPersonAccountMigrationInProgress() && // TODO: Refactor - Remove post AC migration
                disclosure.Status__c != null &&
                oldDisclosure.get(disclosure.Id).Status__c == 'Rejected'
            ) {
                Disclosure__c old = oldDisclosure.get(disclosure.Id);
                disclosure.addError(label.Disclosure_Error_Editable_State);
            }
            if (
                disclosure.Status__c == 'Inventor Submitted' &&
                oldDisclosure.get(disclosure.Id).Status__c !=
                'Inventor Submitted'
            ) {
                disclosure.Submitted_Date__c = Date.today();
            }
        }
    }
}