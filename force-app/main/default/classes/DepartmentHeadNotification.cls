public with sharing class DepartmentHeadNotification {
    public static void scheduleNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<Department_Head__c> existingDepartmentHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        NotificationContext context = getNotificationContext(
            disList,
            oldDisclosures,
            existingDepartmentHeads
        );

        List<Notification__c> deptHeadEndorsementNotification = onDeptHeadEndorsementRequestNotification(
            context
        );
        if (!deptHeadEndorsementNotification.isEmpty()) {
            sendNotificationEmails.addAll(deptHeadEndorsementNotification);
        }

        if (!sendNotificationEmails.isEmpty()) {
            insert sendNotificationEmails;
        }
    }
    /**
        TLOS-1575, TLOS-793 Delegated Dept Head Notification - open source license request is in "Pending Department Approval". Endorsement Request
        This needs to be sent out when Disclosure reaches a status of “Pending Department Approval” for all those Disclosure Types that have Dept. Head associated with them. Namely: Copyright (non-software). NOTE: that Dept Head is not always mandatory on a Copyright (non-software) &/or Software Disclosure
    */
    private static List<Notification__c> onDeptHeadEndorsementRequestNotification(
        NotificationContext context
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();
        for (Disclosure__c disclosure : context.newDisclosures) {
            List<Department_Head__c> deptHeads = context.disclosureDeptHeadMap.get(
                disclosure.Id
            );

            //OpenSource Notification if in Pending Department Approval status
            String newStatus = disclosure.Status__c;
            String oldStatus = context.oldDisclosures.get(disclosure.id)
                .Status__c;
            Boolean statusChanged = (newStatus != oldStatus);
            Boolean isPendingDepartmentApproval =
                statusChanged && newStatus == 'Pending Department Approval';

            Boolean hasDeptHead = (deptHeads != null &&
            !deptHeads.isEmpty() &&
            deptHeads[0] != null); // The Last Department head

            if (isPendingDepartmentApproval && hasDeptHead) {
                Account contact = deptHeads[0].Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, String> variables = new Map<String, String>();
                variables.put('dlc_email', toAdd);
                variables.put('dlc_name', contact.Name);
                variables.put('disclosure_title', disclosure.Name__c);
                variables.put('disclosure_name', disclosure.Name);
                variables.put('comments', ''); //TODO Comments
                variables.put(
                    'submitter_name',
                    disclosure.Submitting_Contact__r.Name
                );
                variables.put('disclosure_type', disclosure.RecordType.Name);
                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }
        return sendNotificationEmails;
    }

    /**
    TLOS-2346, TLOS-793 Delegated Dept Head Notification - open source license request is in "Pending Department Approval". Endorsement Request Delegated
    Notify delegated Dept Head  that the open source disclosure  (Copyright or Software) has been assigned to a proxy or new delegate for Endorsement.
    */
    public static void createDelegatedToNotification(
        List<Department_Head__c> newDeptHeadsWithContactData,
        Map<Id, Department_Head__c> oldDeptHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();
        for (Department_Head__c deptHead : newDeptHeadsWithContactData) {
            Department_Head__c prevDeptHead = oldDeptHeads.get(deptHead.Id);

            Notification__c notification = createEndorsementRequestDelegatedNotification(
                deptHead,
                prevDeptHead
            );
            if (
                notification != null &&
                deptHead.Disclosure__r.Status__c ==
                'Pending Department Approval'
            ) {
                sendNotificationEmails.add(notification);
            }
            Notification__c proxyDeptHead = createEndorsementProxiedNotification(
                deptHead,
                prevDeptHead
            );
            if (
                proxyDeptHead != null &&
                deptHead.Disclosure__r.Status__c ==
                'Pending Department Approval'
            ) {
                sendNotificationEmails.add(proxyDeptHead);
            }
        }
        if (!sendNotificationEmails.isEmpty()) {
            insert sendNotificationEmails;
        }
    }

    /**
        TLOS-2346 Dept Head Notification - open source license request is in "Pending Department Approval". Endorsement Request and delegated to someone else
    */
    private static Notification__c createEndorsementRequestDelegatedNotification(
        Department_Head__c currDeptHead,
        Department_Head__c prevDeptHead
    ) {
        if (
            currDeptHead.Delegated_To__c != null &&
            (currDeptHead.Delegated_To__c != prevDeptHead?.Delegated_To__c)
        ) {
            Disclosure__c disclosure = currDeptHead.Disclosure__r;

            Account currDeptHeadContact = currDeptHead.Contact__r;
            String currDeptHeadEmail = currDeptHeadContact.PersonEmail != null
                ? currDeptHeadContact.PersonEmail
                : currDeptHeadContact.AltEmail__pc;

            Department_Head__c delegatedToDeptHead = currDeptHead.Delegated_To__r;
            Account delegatedToContact = delegatedToDeptHead.Contact__r;
            String delegatedToEmailAdd = delegatedToContact.PersonEmail != null
                ? delegatedToContact.PersonEmail
                : delegatedToContact.AltEmail__pc;

            Map<String, String> variables = new Map<String, String>();
            variables.put('dlc_delegated_email', delegatedToEmailAdd);
            variables.put('dlc_delegated_name', delegatedToContact.Name); //

            variables.put('dlc_email', currDeptHeadEmail);
            variables.put('dlc_name', currDeptHeadContact.Name);

            variables.put('disclosure_title', disclosure.Name__c);
            variables.put('disclosure_name', disclosure.Name);
            variables.put('disclosure_type', disclosure.RecordType.Name);
            variables.put('comments', currDeptHead.Comment__c);
            variables.put(
                'submitter_name',
                disclosure.Submitting_Contact__r.Name
            );

            System.debug('\n\nnvariables:- \n\n' + variables + '\n\n');

            Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                delegatedToEmailAdd,
                NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_REQUEST_DELEGATED,
                variables
            );
            return newEmail;
        }

        return null;
    }

    private static Notification__c createEndorsementProxiedNotification(
        Department_Head__c currDeptHead,
        Department_Head__c prevDeptHead
    ) {
        if (
            currDeptHead.Delegated_To__c != null &&
            (currDeptHead.Delegated_To__c != prevDeptHead?.Delegated_To__c)
        ) {
            Disclosure__c disclosure = currDeptHead.Disclosure__r;
            Department_Head__c proxyDeptHead = currDeptHead;

            Department_Head__c delegatedDeptHead = currDeptHead.Delegated_To__r;
            Account delegatedContact = delegatedDeptHead.Contact__r;
            String delegatedContactEmailAddress = delegatedContact.PersonEmail !=
                null
                ? delegatedContact.PersonEmail
                : delegatedContact.AltEmail__pc;
            String delegatedContactName = delegatedContact.Name;

            Account contact = proxyDeptHead.Contact__r;
            String toAdd = contact.PersonEmail != null
                ? contact.PersonEmail
                : contact.AltEmail__pc;
            Map<String, String> variables = new Map<String, String>();
            variables.put(
                'submitter_name',
                disclosure.Submitting_Contact__r.Name
            );
            variables.put('dlc_email', toAdd);
            variables.put('dlc_name', contact.Name);

            variables.put('dlc_delegated_email', delegatedContactEmailAddress);
            variables.put('dlc_delegated_name', delegatedContactName);

            variables.put('disclosure_title', disclosure.Name__c);
            variables.put('disclosure_name', disclosure.Name);
            variables.put('disclosure_type', disclosure.RecordType.Name);
            variables.put('comments', currDeptHead.Comment__c);

            Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                toAdd,
                NotificationBuilder.TEMPLATE_DEPT_HEAD_ENDORSEMENT_PROXIED,
                variables
            );
            return newEmail;
        }
        return null;
    }

    @TestVisible
    private static NotificationContext getNotificationContext(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<Department_Head__c> existingDepartmentHeads
    ) {
        Map<Id, Disclosure__c> disclosureLookup = new Map<Id, Disclosure__c>(
            disList
        );
        List<Id> disclosureIds = new List<Id>(disclosureLookup.keySet());

        Map<Id, List<Department_Head__c>> disclosureDeptHeadMap = new Map<Id, List<Department_Head__c>>();
        for (Disclosure__c disclosure : disList) {
            disclosureDeptHeadMap.put(
                disclosure.Id,
                new List<Department_Head__c>()
            );
        }

        for (Department_Head__c deptHead : existingDepartmentHeads) {
            disclosureDeptHeadMap.get(deptHead.Disclosure__r.Id).add(deptHead);
        }
        NotificationContext context = new NotificationContext();
        context.newDisclosures = disList;
        context.oldDisclosures = oldDisclosures;
        context.disclosureDeptHeadMap = disclosureDeptHeadMap;
        return context;
    }

    @TestVisible
    private class NotificationContext {
        @TestVisible
        private List<Disclosure__c> newDisclosures;
        @TestVisible
        private Map<Id, Disclosure__c> oldDisclosures;
        @TestVisible
        private Map<Id, List<Department_Head__c>> disclosureDeptHeadMap;
    }
}