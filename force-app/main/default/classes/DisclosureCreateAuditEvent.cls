public with sharing class DisclosureCreateAuditEvent {
    public static void createAuditEvents(
        List<Disclosure__c> newDisList,
        Map<Id, Disclosure__c> oldDisList
    ) {
        User usr = [
            SELECT Id, Name, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        List<Id> ids = new List<Id>();
        for (Disclosure__c o : newDisList) {
            ids.add(o.Id);
        }

        List<Disclosure__c> newDisclosureWithDeptHead = [
            SELECT
                Id,
                Name,
                Status__c,
                Draft_Date__c,
                Submitted_Date__c,
                Submitting_Contact__c,
                Submitting_Contact__r.Id,
                Submitting_Contact__r.Name,
                (
                    SELECT
                        Id,
                        Contact__r.PersonDepartment,
                        Disclosure__c,
                        Signed_Date__c,
                        Contact__r.Id,
                        Contact__r.Name,
                        Delegated_To__c,
                        Comment__c
                    FROM Department_Heads__r
                    WHERE Delegated_To__c = NULL
                    LIMIT 1
                )
            FROM Disclosure__c
            WHERE Id IN :ids
        ];

        List<Disclosure_Audit_Event__c> disclosureAuditEvents = new List<Disclosure_Audit_Event__c>();
        for (Disclosure__c currentDisclosure : newDisclosureWithDeptHead) {
            Disclosure_Audit_Event__c auditEvent = createDisclosureStatusChangedEvent(
                currentDisclosure,
                oldDisList.get(currentDisclosure.Id),
                usr
            );
            if (auditEvent != null) {
                disclosureAuditEvents.add(auditEvent);
            }
        }

        Boolean checkPoint = !disclosureAuditEvents.isEmpty();
        Integer size = disclosureAuditEvents.size();
        System.debug(disclosureAuditEvents.size()); // Breakpoint here to look at each one
        System.debug(!disclosureAuditEvents.isEmpty()); // Breakpoint here to look at each one
        if (disclosureAuditEvents != null && !disclosureAuditEvents.isEmpty()) {
            insert disclosureAuditEvents;
        }
    }

    //this function is used to create a new audit event
    private static Disclosure_Audit_Event__c createDisclosureStatusChangedEvent(
        Disclosure__c currDisclosure,
        Disclosure__c prevDisclosure,
        User userDetails
    ) {
        String newStatus = currDisclosure.Status__c;
        String prevStatus = prevDisclosure?.Status__c;
        String msg = prevDisclosure == null ? '' : prevDisclosure.Status__c;
        Boolean statusChanged = (newStatus != prevStatus);

        //no audit trail for draft status or if status has not changed
        if (newStatus == 'Draft' && !statusChanged) {
            //TODO when sys admin move's back to draft is an audit trail needed?
            // and/or all the pending draft actions should also be created
            return null;
        }

        // The disclosure has just been created, so there is no previous status
        if (prevStatus == null) {
            return createCreatedAuditEvent(currDisclosure);
        }

        if (
            (prevStatus != 'Inventor Submitted' &&
            prevStatus != 'Pending Department Approval') &&
            newStatus == 'Inventor Submitted'
        ) {
            return createSubmittedAuditEvent(currDisclosure);
        }

        if (
            prevStatus == 'Draft' &&
            newStatus == 'Pending Department Approval'
        ) {
            return createPendingDepartmentApprovalAuditEvent(currDisclosure);
        }

        // TLO Approved
        if (prevStatus == 'Inventor Submitted' && newStatus == 'Approved') {
            return createApprovedAuditEvent(userDetails, currDisclosure);
        }

        // TLO Rejected
        if (prevStatus == 'Inventor Submitted' && newStatus == 'Rejected') {
            return createTloRejectedAuditEvent(userDetails, currDisclosure);
        }

        // Dept. Head Rejected
        if (
            prevStatus == 'Pending Department Approval' &&
            newStatus == 'Rejected'
        ) {
            return createDeptHeadRejectedAuditEvent(
                currDisclosure
            );
        }

        //NOTE: Dept. Head Endorsedment only happens on some Disclosure Types (those that have a Dept. Head)
        if (
            prevStatus == 'Pending Department Approval' &&
            newStatus == 'Inventor Submitted'
        ) {
            return createEndorsedAuditEvent(currDisclosure);
        }

        if (prevStatus == 'Draft' && newStatus == 'Archived') {
            return createArchivedAuditEvent(userDetails, currDisclosure);
        }

        if (prevStatus == 'Archived' && newStatus == 'Draft') {
            return createUnarchivedAuditEvent(userDetails, currDisclosure);
        }

        return null;
    }

    private static Disclosure_Audit_Event__c createCreatedAuditEvent(
        Disclosure__c currDisclosure
    ) {
        Id recordTypeApprovedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();
        Account submittedByContact = currDisclosure.Submitting_Contact__r;
        return insertBuiltAuditEventData(
            '<a href="/lightning/r/Account/' +
            submittedByContact.Id +
            '/view" target="_self">' +
            submittedByContact.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Created,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_Created,
            recordTypeApprovedId
        );
    }

    private static Disclosure_Audit_Event__c createSubmittedAuditEvent(
        Disclosure__c currDisclosure
    ) {
        Id recordTypeApprovedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();
        Account submittedByContact = currDisclosure.Submitting_Contact__r;
        return insertBuiltAuditEventData(
            '<a href="/lightning/r/Account/' +
            submittedByContact.Id +
            '/view" target="_self">' +
            submittedByContact.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Submitted,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_Submitted,
            recordTypeApprovedId
        );
    }

    private static Disclosure_Audit_Event__c createArchivedAuditEvent(
        User userDetails,
        Disclosure__c currDisclosure
    ) {
        Id recordTypeApprovedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();
        return insertBuiltAuditEventData(
            label.Disclosure_DAE_Description_Archived,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_Archived,
            recordTypeApprovedId
        );
    }
    // links to user because this would be a SF User doing the action and not community user from Native App
    private static Disclosure_Audit_Event__c createUnarchivedAuditEvent(
        User userDetails,
        Disclosure__c currDisclosure
    ) {
        Id recordTypeArchivedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Unarchived')
            .getRecordTypeId();
        return insertBuiltAuditEventData(
            '<a href="/lightning/r/User/' +
            userDetails.Id +
            '/view" target="_self">' +
            userDetails.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Unarchived,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_Unarchived,
            recordTypeArchivedId
        );
    }

    // links to user because this would be a SF User doing the action and not community user from Native App
    private static Disclosure_Audit_Event__c createApprovedAuditEvent(
        User userDetails,
        Disclosure__c currDisclosure
    ) {
        Id recordTypeApprovedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();
        return insertBuiltAuditEventData(
            '<a href="/lightning/r/User/' +
            userDetails.Id +
            '/view" target="_self">' +
            userDetails.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_Approved,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_Approved,
            recordTypeApprovedId
        );
    }

    // links to user because this would be a SF User doing the action and not community user from Native App
    private static Disclosure_Audit_Event__c createTloRejectedAuditEvent(
        User userDetails,
        Disclosure__c currDisclosure
    ) {
        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Rejection')
            .getRecordTypeId();
        return insertBuiltAuditEventData(
            '<a href="/lightning/r/User/' +
            userDetails.Id +
            '/view" target="_self">' +
            userDetails.Name +
            '</a> ' +
            label.Disclosure_DAE_Description_TloRejected,
            currDisclosure.Id,
            label.Disclosure_DAE_Subject_TloRejected,
            recordTypeRejectionId
        );
    }

    private static Disclosure_Audit_Event__c createDeptHeadRejectedAuditEvent(
        Disclosure__c currDisclosure
    ) {
        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Rejection')
            .getRecordTypeId();

        List<Department_Head__c> discDeptHeadList = currDisclosure.Department_Heads__r;
        if (!discDeptHeadList.isEmpty()) {
            Department_Head__c discDeptHead = discDeptHeadList[0];
            String deptHeadId = discDeptHead.Contact__r.Id;
            String deptHeadName = discDeptHead.Contact__r.Name;

            return insertBuiltAuditEventData(
                '<a href="/lightning/r/Account/' +
                deptHeadId +
                '/view" target="_self">' +
                deptHeadName +
                '</a> ' +
                label.Disclosure_DAE_Description_DeptHeadRejected,
                currDisclosure.Id,
                label.Disclosure_DAE_Subject_DeptHeadRejected,
                recordTypeRejectionId
            );
        }

        return null;
    }

    private static Disclosure_Audit_Event__c createEndorsedAuditEvent(
        Disclosure__c currDisclosure
    ) {
        Id recordTypeEndorsedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('InventorSubmitted')
            .getRecordTypeId();

        List<Department_Head__c> discDeptHeadList = currDisclosure.Department_Heads__r;
        if (!discDeptHeadList.isEmpty()) {
            Department_Head__c discDeptHead = discDeptHeadList[0];

            String deptHeadId = discDeptHead.Contact__r.Id;
            String deptHeadName = discDeptHead.Contact__r.Name;

            String description =
                '<a href="/lightning/r/Account/' +
                deptHeadId +
                '/view" target="_self">' +
                deptHeadName +
                '</a> ' +
                label.Disclosure_DAE_Description_Endorsed +
                (discDeptHead.Comment__c != null &&
                    discDeptHead.Comment__c != ''
                    ? ' with comment \"' + discDeptHead.Comment__c + '\"'
                    : '');

            return insertBuiltAuditEventData(
                description,
                currDisclosure.Id,
                label.Disclosure_DAE_Subject_Endorsed,
                recordTypeEndorsedId
            );
        }

        return null;
    }

    private static Disclosure_Audit_Event__c createPendingDepartmentApprovalAuditEvent(
        Disclosure__c currDisclosure
    ) {
        if (currDisclosure == null) {
            return null;
        }

        Id recordTypePendingDeptApprovalId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('PendingDepartmentApproval')
            .getRecordTypeId();

        List<Department_Head__c> deptHeads = currDisclosure.Department_Heads__r;
        if (deptHeads != null && !deptHeads.isEmpty()) {
            Department_Head__c discDeptHead = deptHeads[0];
            Account submittedByContact = currDisclosure.Submitting_Contact__r;

            String deptHeadId = discDeptHead.Contact__r.Id;
            String deptHeadName = discDeptHead.Contact__r.Name;
            String submittedByContactId = submittedByContact.Id;
            String submittedByContactName = submittedByContact.Name;

            return insertBuiltAuditEventData(
                '<a href="/lightning/r/Account/' +
                deptHeadId +
                '/view" target="_self">' +
                deptHeadName +
                '</a> ' +
                label.Disclosure_DAE_Description_PendingDepartmentApproval +
                ' <a href="/lightning/r/Account/' +
                submittedByContactId +
                '/view" target="_self">' +
                submittedByContactName +
                '</a>',
                currDisclosure.Id,
                label.Disclosure_DAE_Subject_PendingDepartmentApproval,
                recordTypePendingDeptApprovalId
            );
        }

        return null;
    }

    public static void createDelegatedToAuditEventChange(
        List<Department_Head__c> newDeptHeads,
        Map<Id, Department_Head__c> oldDeptHeads
    ) {
        Boolean newDeptHeadsExist = (newDeptHeads != null &&
        !newDeptHeads.isEmpty());
        Boolean oldDeptHeadsExist = (oldDeptHeads != null &&
        !oldDeptHeads.isEmpty());
        Boolean deptHeadDelegationsExist = (newDeptHeadsExist &&
        oldDeptHeadsExist);

        // If there are Deptartment Heads delegations to be processed
        if (deptHeadDelegationsExist) {
            List<Department_Head__c> newDeptHeadsWithContactData = [
                SELECT
                    Id,
                    Comment__c,
                    // Disclosure
                    Disclosure__c,
                    Disclosure__r.Name,
                    Disclosure__r.Name__c,
                    Disclosure__r.Status__c,
                    Disclosure__r.RecordType.Name,
                    Disclosure__r.Submitting_Contact__r.Name,
                    // Contact
                    Contact__c,
                    Contact__r.Name,
                    Contact__r.PersonEmail,
                    Contact__r.AltEmail__pc,
                    // Newly Delegated Department Head
                    Delegated_To__c,
                    Delegated_To__r.Id,
                    Delegated_To__r.Name,
                    Delegated_To__r.Contact__c,
                    Delegated_To__r.Contact__r.Name,
                    Delegated_To__r.Contact__r.PersonEmail,
                    Delegated_To__r.Contact__r.AltEmail__pc,
                    Delegated_To__r.Contact__r.Id
                FROM Department_Head__c
                WHERE Id IN :newDeptHeads
            ];

            List<Disclosure_Audit_Event__c> auditEventList = new List<Disclosure_Audit_Event__c>();
            // For each Department Head
            for (Department_Head__c deptHead : newDeptHeadsWithContactData) {
                Department_Head__c prevDeptHead = oldDeptHeads.get(deptHead.Id);

                Disclosure_Audit_Event__c auditEvent = createDelegatedToAuditEvent(
                    deptHead,
                    prevDeptHead
                );
                if (auditEvent != null) {
                    System.debug(
                        '****Audit Event:' + auditEvent.Description__c
                    );
                    auditEventList.add(auditEvent);
                }
            }

            if (
                auditEventList != null &&
                auditEventList.size() > 0 &&
                !auditEventList.isEmpty()
            ) {
                insert auditEventList;
            }

            DepartmentHeadNotification.createDelegatedToNotification(
                newDeptHeadsWithContactData,
                oldDeptHeads
            );
        }
    }

    private static Disclosure_Audit_Event__c createDelegatedToAuditEvent(
        Department_Head__c currDeptHead,
        Department_Head__c prevDeptHead
    ) {
        if (
            currDeptHead.Delegated_To__c != null &&
            (currDeptHead.Delegated_To__c != prevDeptHead?.Delegated_To__c)
        ) {
            String delegatedFromId = currDeptHead.Contact__r.Id;
            String delegatedFromName = currDeptHead.Contact__r.Name;
            String delegatedToId = currDeptHead.Delegated_To__r.Contact__r.Id;
            String delegatedToName = currDeptHead.Delegated_To__r.Contact__r.Name;
            String description =
                '<a href="/lightning/r/Account/' +
                delegatedFromId +
                '/view" target="_self">' +
                delegatedFromName +
                '</a> ' +
                label.Disclosure_DAE_Description_Delegated +
                ' <a href="/lightning/r/Account/' +
                delegatedToId +
                '/view" target="_self">' +
                delegatedToName +
                '</a>' +
                (currDeptHead.Comment__c != null &&
                    currDeptHead.Comment__c != ''
                    ? ' with comment "' + currDeptHead.Comment__c + '"'
                    : '');

            Id recordTypeDelegatedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
                .get('Delegation')
                .getRecordTypeId();
            return insertBuiltAuditEventData(
                description,
                currDeptHead.Disclosure__c,
                label.Disclosure_DAE_Subject_Delegated,
                recordTypeDelegatedId
            );
        }

        return null;
    }

    public static void createInventorSignatureAudit(
        List<DisclosureInventor__c> inventorList
    ) {
        if (inventorList != null && !inventorList.isEmpty()) {
            List<Disclosure_Audit_Event__c> auditEventList = new List<Disclosure_Audit_Event__c>();

            for (DisclosureInventor__c dis : inventorList) {
                Disclosure_Audit_Event__c auditEvent = createInventorSignedAuditEvent(
                    dis
                );
                if (auditEvent != null) {
                    auditEventList.add(auditEvent);
                }
            }

            if (auditEventList != null && !auditEventList.isEmpty()) {
                insert auditEventList;
            }
        }
    }

    private static Disclosure_Audit_Event__c createInventorSignedAuditEvent(
        DisclosureInventor__c currentDisclosureInventor
    ) {
        Id recordTypeSignedId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Signing')
            .getRecordTypeId();
        Id recordTypeRejectionId = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Rejection')
            .getRecordTypeId();

        if (currentDisclosureInventor.Signed_Status__c == 'Yes') {
            return insertBuiltAuditEventData(
                '<a href="/lightning/r/Account/' +
                currentDisclosureInventor.Contact__r.Id +
                '/view" target="_self">' +
                currentDisclosureInventor.Contact__r.Name +
                '</a> ' +
                label.Disclosure_DAE_Description_Signed,
                currentDisclosureInventor.Disclosure__c,
                label.Disclosure_DAE_Subject_Signed,
                recordTypeSignedId
            );
        }

        if (currentDisclosureInventor.Signed_Status__c == 'Opted Out') {
            return insertBuiltAuditEventData(
                '<a href="/lightning/r/Account/' +
                currentDisclosureInventor.Contact__r.Id +
                '/view" target="_self">' +
                currentDisclosureInventor.Contact__r.Name +
                '</a> ' +
                label.Disclosure_DAE_Description_OptedOut,
                currentDisclosureInventor.Disclosure__c,
                label.Disclosure_DAE_Subject_OptedOut,
                recordTypeRejectionId
            );
        }

        return null;
    }

    private static Disclosure_Audit_Event__c insertBuiltAuditEventData(
        String eventDescription,
        Id disclosureId,
        String subject,
        Id recordTypeId
    ) {
        Disclosure_Audit_Event__c event = new Disclosure_Audit_Event__c(
            Description__c = EventDescription,
            Disclosure__c = disclosureId,
            Event_Date__c = Datetime.now(),
            Subject__c = subject,
            RecordTypeId = recordTypeId
        );

        return event;
    }
}