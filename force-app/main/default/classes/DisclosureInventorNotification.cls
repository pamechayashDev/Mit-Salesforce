public with sharing class DisclosureInventorNotification {
    public static void scheduleNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList,
        List<Department_Head__c> deptHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        sendNotificationEmails.addAll(
            signDisclosureNotifications(oldDisclosures, inventorList)
        );
        sendNotificationEmails.addAll(
            onDeptHeadDeclinedNotifications(
                disList,
                oldDisclosures,
                inventorList,
                deptHeads
            )
        );
        sendNotificationEmails.addAll(
            onTLOAdminRejectNotifications(disList, oldDisclosures, inventorList)
        );
        sendNotificationEmails.addAll(
            onEndorsedAndApprovedNotifications(
                disList,
                oldDisclosures,
                inventorList,
                deptHeads
            )
        );
        sendNotificationEmails.addAll(
            onApprovedNotifications(
                disList,
                oldDisclosures,
                inventorList,
                deptHeads
            )
        );
        sendNotificationEmails.addAll(
            onArchivedNotifications(disList, oldDisclosures, inventorList)
        );
        sendNotificationEmails.addAll(
            onDraftSubmittedForApprovalNotifications(
                disList,
                oldDisclosures,
                inventorList
            )
        );

        if (!sendNotificationEmails.isEmpty()) {
            insert sendNotificationEmails;
        }
    }

    /**
        TLOS-845 Inventor Notification - Disclosure draft for which you have been named has been deleted.
    */
    public static void onDeleteDisclosureNotification(
        List<Disclosure__c> disclosures
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Set<String> disclosureIds = new Set<String>();
        for (Disclosure__c d : disclosures) {
            disclosureIds.add(d.Id);
        }

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsByDisclosureIds(
            disclosureIds
        );

        for (DisclosureInventor__c inventor : inventors) {
            if (inventor.Review_Draft_Watcher__c == true) {
                String toAdd = inventor.Contact__r.PersonEmail != null
                    ? inventor.Contact__r.PersonEmail
                    : inventor.Contact__r.AltEmail__pc;
                Map<String, Object> variables = createVariables(
                    inventor.disclosure__r
                );
                variables.put('inventor_email', toAdd);
                variables.put('inventor_name', inventor.Contact__r.Name);
                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_DELETION,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }
        if (!sendNotificationEmails.isEmpty()) {
            insert sendNotificationEmails;
        }
    }

    /**
     - TLOS-1081: Inventor & Submitting Contact Notification - Dept Head Rejected/Declined Disclosure
       Notify MIT Inventor, Submitter or any named inventors who had been given access to the draft disclosure of a disclosure submission when their disclosure is rejected,
        so that they are aware that their disclosure has been rejected.

    */
    private static List<Notification__c> onDeptHeadDeclinedNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList,
        List<Department_Head__c> deptHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<Id, Department_Head__c> disclosureDeptHeadLookup = Helpers.toDisclosureDeptHeadLookup(
            deptHeads
        );

        Map<Id, Disclosure__c> disclosureSubmitterMap = new Map<Id, Disclosure__c>(); // Submitting Contact need to be notified on each disclosure
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);
            Boolean isRejected =
                disclosure != null &&
                disclosure.Status__c != null &&
                disclosure.Status__c == 'Rejected' &&
                oldDisclosure.Status__c != 'Rejected';
            Boolean isRejectedByDeptHead =
                disclosure.Rejected_By__c == 'Department Head' &&
                oldDisclosure.Status__c == 'Pending Department Approval';
            if (isRejected && isRejectedByDeptHead) {
                disclosureSubmitterMap.put(disclosure.Id, disclosure);
                Boolean inventorForSubmittingContact = (inventor.Contact__c ==
                disclosure.Submitting_Contact__c);

                if (
                    !inventorForSubmittingContact &&
                    inventor.Review_Draft_Watcher__c == true
                ) {
                    Department_Head__c deptHead = disclosureDeptHeadLookup.get(
                        disclosure.Id
                    );

                    String toAdd = inventor.Contact__r.PersonEmail != null
                        ? inventor.Contact__r.PersonEmail
                        : inventor.Contact__r.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put('inventor_email', toAdd);
                    variables.put('inventor_name', inventor.Contact__r.Name);
                    variables.put('comments', disclosure.Rejection_Reason__c);
                    if (deptHead != null) {
                        variables.put('dlc_name', deptHead.Contact__r.Name);
                        variables.put(
                            'dlc_email',
                            deptHead.Contact__r.PersonEmail
                        );
                    }

                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }
        }

        // Notify Submitter for each Disclosure
        for (Id key : disclosureSubmitterMap.keySet()) {
            Disclosure__c disclosure = disclosureSubmitterMap.get(key);

            if (disclosure != null) {
                Department_Head__c deptHead = disclosureDeptHeadLookup.get(
                    disclosure.Id
                );
                Account contact = disclosure.Submitting_Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('inventor_email', toAdd);
                variables.put('submitter_name', contact.Name);
                variables.put('inventor_name', contact.Name);
                variables.put('comments', disclosure.Rejection_Reason__c);
                if (deptHead != null) {
                    variables.put('dlc_name', deptHead.Contact__r.Name);
                    variables.put('dlc_email', deptHead.Contact__r.PersonEmail);
                }

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_DECLINED_DEPT_HEAD,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }
        return sendNotificationEmails;
    }

    /**
     - TLOS-1510: Primary Inventors & Submitting Contact Notification - TLO Admin Declined Disclosure
       Notify MIT Inventor, Submitter or any named inventors who had been given access to the draft disclosure of a disclosure submission when their disclosure is rejected,
        so that they are aware that their disclosure has been rejected.

    */
    private static List<Notification__c> onTLOAdminRejectNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<Id, Disclosure__c> disclosureSubmitterMap = new Map<Id, Disclosure__c>(); // Submitting Contact need to be notified on each disclosure
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);
            Boolean isRejected =
                disclosure != null &&
                disclosure.Status__c != null &&
                disclosure.Status__c == 'Rejected' &&
                oldDisclosure.Status__c != 'Rejected';
            Boolean isRejectedByTloAdmin =
                disclosure.Rejected_By__c == 'TLO Admin' &&
                oldDisclosure.Status__c == 'Inventor Submitted';
            if (isRejected && isRejectedByTloAdmin) {
                disclosureSubmitterMap.put(disclosure.Id, disclosure);
                Boolean inventorForSubmittingContact = (inventor.Contact__c ==
                disclosure.Submitting_Contact__c);

                if (
                    !inventorForSubmittingContact &&
                    inventor.Review_Draft_Watcher__c == true
                ) {
                    String toAdd = inventor.Contact__r.PersonEmail != null
                        ? inventor.Contact__r.PersonEmail
                        : inventor.Contact__r.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put('inventor_email', toAdd);
                    variables.put('inventor_name', inventor.Contact__r.Name);
                    variables.put('comments', disclosure.Rejection_Reason__c);

                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }
        }

        // Notify Submitter for each Disclosure
        for (Id key : disclosureSubmitterMap.keySet()) {
            Disclosure__c disclosure = disclosureSubmitterMap.get(key);

            if (disclosure != null) {
                Account contact = disclosure.Submitting_Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('inventor_email', toAdd);
                variables.put('submitter_name', contact.Name);
                variables.put('inventor_name', contact.Name);
                variables.put('comments', disclosure.Rejection_Reason__c);

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_REJECTION_TLO_ADMIN,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }

        return sendNotificationEmails;
    }

    /*
     * TLOS- 1082. To each Primary Inventor and Submitting Contact, DeptHead Endorsement request delegated event.
     */
    public static void onDeptHeadEndorsementRequestDelegation(
        List<Department_Head__c> depHeadQuery
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<String, String> idStatusMap = new Map<String, String>();
        for (Department_Head__c dep : depHeadQuery) {
            idStatusMap.put(dep.Id, dep.Disclosure__r.Status__c);
        }

        List<Disclosure__c> disclosures = new List<Disclosure__c>();
        for (Department_Head__c deptHead : depHeadQuery) {
            if (
                idStatusMap.get(deptHead.Id) == 'Pending Department Approval' &&
                deptHead.Delegated_To__c == null
            ) {
                disclosures.add(deptHead.Disclosure__r);
            }
        }

        Map<Id, Department_Head__c> disclosureDeptHeadLookup = Helpers.toDisclosureDeptHeadLookup(
            depHeadQuery
        );
        if (!disclosures.isEmpty()) {
            Set<String> disclosureIds = new Set<String>();
            for (Disclosure__c d : disclosures) {
                disclosureIds.add(d.Id);
            }

            List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsByDisclosureIds(
                disclosureIds
            );

            //Just to include the `Delegated From` in email as variable
            List<Department_Head__c> deptHeadsWithDelegatedToEmpty = DisclosureRecordFetch.getDepartmentHeadByDisclosureIds(
                disclosureIds
            );
            Map<Id, List<Department_Head__c>> disclosureDeptHeadListLookup = Helpers.toDisclosureDeptHeadListLookup(
                deptHeadsWithDelegatedToEmpty
            );

            Map<Id, Disclosure__c> disclosureSubmitterMap = new Map<Id, Disclosure__c>(); // Submitting Contact need to be notified on each disclosure
            for (DisclosureInventor__c inventor : inventors) {
                Disclosure__c disclosure = inventor.Disclosure__r;
                Boolean inventorForSubmittingContact = (inventor.Contact__c ==
                disclosure.Submitting_Contact__c);
                Boolean isPendingDepartmentApproval =
                    disclosure != null &&
                    disclosure.Status__c != null &&
                    disclosure.Status__c == 'Pending Department Approval';
                Boolean isWatcherAndOtherInventor =
                    !inventorForSubmittingContact &&
                    inventor.Review_Draft_Watcher__c == true;

                if (isPendingDepartmentApproval) {
                    disclosureSubmitterMap.put(disclosure.Id, disclosure);
                }

                if (isPendingDepartmentApproval && isWatcherAndOtherInventor) {
                    Department_Head__c deptHead = disclosureDeptHeadLookup.get(
                        disclosure.Id
                    );

                    //Search for Department Head that is not the newly inserted one. There will be two with the empty Delegated_To__c values.
                    Department_Head__c deptHeadDelegatedFrom = null;
                    List<Department_Head__c> beforeDelegateToList = disclosureDeptHeadListLookup.get(
                        disclosure.Id
                    );
                    if (beforeDelegateToList != null) {
                        for (Department_Head__c dh : beforeDelegateToList) {
                            if (dh.Id != deptHead.Id) {
                                deptHeadDelegatedFrom = dh;
                            }
                        }
                    }

                    String toAdd = inventor.Contact__r.PersonEmail != null
                        ? inventor.Contact__r.PersonEmail
                        : inventor.Contact__r.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put('inventor_email', toAdd);
                    variables.put('inventor_name', inventor.Contact__r.Name);
                    variables.put('comments', disclosure.Rejection_Reason__c);
                    if (deptHead != null) {
                        variables.put('dlc_name', deptHead.Contact__r.Name);
                        variables.put(
                            'dlc_email',
                            deptHead.Contact__r.PersonEmail
                        );
                    }
                    if (deptHeadDelegatedFrom != null) {
                        variables.put(
                            'dlc_from_name',
                            deptHeadDelegatedFrom.Contact__r.Name
                        );
                        variables.put(
                            'dlc_from_email',
                            deptHeadDelegatedFrom.Contact__r.PersonEmail
                        );
                    }

                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }

            // Notify Submitter if SOB for each Disclosure
            for (Id key : disclosureSubmitterMap.keySet()) {
                Disclosure__c disclosure = disclosureSubmitterMap.get(key);

                if (disclosure != null) {
                    Department_Head__c deptHead = disclosureDeptHeadLookup.get(
                        disclosure.Id
                    );

                    Department_Head__c deptHeadDelegatedFrom = null;
                    List<Department_Head__c> beforeDelegateToList = disclosureDeptHeadListLookup.get(
                        disclosure.Id
                    );
                    if (beforeDelegateToList != null) {
                        for (Department_Head__c dh : beforeDelegateToList) {
                            if (dh.Id != deptHead.Id) {
                                deptHeadDelegatedFrom = dh;
                            }
                        }
                    }
                    Account contact = disclosure.Submitting_Contact__r;
                    String toAdd = contact.PersonEmail != null
                        ? contact.PersonEmail
                        : contact.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put('inventor_email', toAdd);
                    variables.put('submitter_name', contact.Name);
                    variables.put('inventor_name', contact.Name);
                    variables.put('comments', disclosure.Rejection_Reason__c);
                    if (deptHead != null) {
                        variables.put('dlc_name', deptHead.Contact__r.Name);
                        variables.put(
                            'dlc_email',
                            deptHead.Contact__r.PersonEmail
                        );
                    }
                    if (deptHeadDelegatedFrom != null) {
                        variables.put(
                            'dlc_from_name',
                            deptHeadDelegatedFrom.Contact__r.Name
                        );
                        variables.put(
                            'dlc_from_email',
                            deptHeadDelegatedFrom.Contact__r.PersonEmail
                        );
                    }

                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_INVENTOR_ENDORSEMENT_REQUEST_DELEGATED,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }

            if (!sendNotificationEmails.isEmpty()) {
                insert sendNotificationEmails;
            }
        }
    }

    /**
     - TLOS-151: All Inventors - submitted disclosure must review and sign
    */
    private static List<Notification__c> signDisclosureNotifications(
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);
            if (
                disclosure != null &&
                disclosure.Status__c != null &&
                disclosure.Status__c == 'Approved' &&
                oldDisclosure.Status__c != 'Approved'
            ) {
                Boolean inventorMadeSigningDecision = (inventor.Signed_Status__c ==
                'Yes' ||
                inventor.Signed_Status__c == 'Opted Out');
                if (inventorMadeSigningDecision) {
                    continue;
                }
                String toAdd = inventor.Contact__r.PersonEmail != null
                    ? inventor.Contact__r.PersonEmail
                    : inventor.Contact__r.AltEmail__pc;
                String submitterName = disclosure.Submitting_Contact__c != null
                    ? disclosure.Submitting_Contact__r.Name
                    : '';
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('submitter_name', submitterName);
                variables.put('inventor_name', inventor.Contact__r.Name);
                variables.put('inventor_email', toAdd);
                if (inventor.Contact__r.InvitationCode__pc != null) {
                    variables.put(
                        'invitation_code',
                        inventor.Contact__r.InvitationCode__pc
                    );
                }
                Boolean isActiveKerb = Helpers.isActiveKerb(
                    inventor.Contact__r.MoiraStatus__pc
                );
                variables.put('isActiveKerb', isActiveKerb);
                variables.put('isAlumni', inventor.Contact__r.IsAlumni__pc);
                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED,
                    variables
                );

                sendNotificationEmails.add(newEmail);
            }
        }
        return sendNotificationEmails;
    }

    /**
         - TLOS-1089: Inventor & Submitting Contact Notification - Endorser has endorsed a disclosure and TLO has Approved
            When a Disclosure that required Department Head Approval (copyright open source) has been approved, all submitters and named inventors/authors  should get notified that it is approved and the case is now sent to TLO.

        */
    private static List<Notification__c> onEndorsedAndApprovedNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList,
        List<Department_Head__c> deptHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<Id, Department_Head__c> disclosureDeptHeadLookup = Helpers.toDisclosureDeptHeadLookup(
            deptHeads
        );

        Map<Id, Disclosure__c> disclosureSubmittingMap = new Map<Id, Disclosure__c>(); // Submitting Contact need to be notified on each disclosure
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);

            Boolean inventorForSubmittingContact = (inventor.Contact__c ==
            disclosure.Submitting_Contact__c);
            Boolean deptHeadForOpenSourceApproved =
                disclosureDeptHeadLookup.get(disclosure.Id) != null; // if dept head exist assume this was a opensource disclosure

            String oldStatus = oldDisclosure.Status__c;
            String newStatus = disclosure.Status__c;
            if (
                newStatus != oldStatus &&
                newStatus == 'Approved' &&
                deptHeadForOpenSourceApproved
            ) {
                disclosureSubmittingMap.put(disclosure.Id, disclosure);
                // Dont notify Inventor that is the Submitter
                if (
                    !inventorForSubmittingContact &&
                    inventor.Review_Draft_Watcher__c == true
                ) {
                    Department_Head__c dh = disclosureDeptHeadLookup.get(
                        disclosure.Id
                    );
                    String toAdd = inventor.Contact__r.PersonEmail != null
                        ? inventor.Contact__r.PersonEmail
                        : inventor.Contact__r.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put('inventor_name', inventor.Contact__r.Name);
                    variables.put('dlc_name', dh.Contact__r.Name);
                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }
        }

        // Notify Submitter for each Disclosure
        for (Id key : disclosureSubmittingMap.keySet()) {
            Disclosure__c disclosure = disclosureSubmittingMap.get(key);

            if (disclosure != null) {
                Department_Head__c dh = disclosureDeptHeadLookup.get(
                    disclosure.Id
                );
                Account contact = disclosure.Submitting_Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('submitter_name', contact.Name);
                variables.put('inventor_name', contact.Name);
                variables.put('dlc_name', dh.Contact__r.Name);

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_AND_SUBMITTER_DEPT_TLO_APPROVED,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }

        return sendNotificationEmails;
    }
    /**
         - TLOS-152: Submitting Contact Notification - TLO has Approved
            The Submitter of a disclosure should receive an email that the disclosure  is approved and include a link to the portal as well as the case number that was assigned

        */
    private static List<Notification__c> onApprovedNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList,
        List<Department_Head__c> deptHeads
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<Id, Department_Head__c> disclosureDeptHeadLookup = new Map<Id, Department_Head__c>();
        if (deptHeads != null && !deptHeads.isEmpty()) {
            disclosureDeptHeadLookup = Helpers.toDisclosureDeptHeadLookup(
                deptHeads
            );
        }

        Map<Id, Disclosure__c> disclosureSubmittingMap = new Map<Id, Disclosure__c>();
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);

            String oldStatus = oldDisclosure.Status__c;
            String newStatus = disclosure.Status__c;
            if (newStatus != oldStatus && newStatus == 'Approved') {
                disclosureSubmittingMap.put(disclosure.Id, disclosure);
            }
        }

        // Notify Submitter for each Disclosure
        for (Id key : disclosureSubmittingMap.keySet()) {
            Disclosure__c disclosure = disclosureSubmittingMap.get(key);
            Boolean deptHeadForOpenSourceApproved =
                disclosureDeptHeadLookup.get(disclosure.Id) != null; // if dept head exist assume this was a opensource disclosure
            // TLOS-3562
            if (disclosure != null && !deptHeadForOpenSourceApproved) {
                Account contact = disclosure.Submitting_Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('submitter_name', contact.Name);
                variables.put('inventor_name', contact.Name);
                // link need to exist

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTER_TLO_APPROVED,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }

        return sendNotificationEmails;
    }

    /**
         - TLOS-845: Primary Inventor & Submitting Contact Notification - Disclosure Archived
        */
    private static List<Notification__c> onArchivedNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        Map<Id, Disclosure__c> disclosureSubmitterMap = new Map<Id, Disclosure__c>(); // Submitting Contact need to be notified on each disclosure
        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);

            if (
                disclosure.Status__c != oldDisclosure.Status__c &&
                disclosure.Status__c == 'Archived'
            ) {
                Boolean inventorForSubmittingContact = (inventor.Contact__c ==
                disclosure.Submitting_Contact__c);

                // If Flagged as watcher, notify Inventor
                if (
                    !inventorForSubmittingContact &&
                    inventor.Review_Draft_Watcher__c == true
                ) {
                    String toAdd = inventor.Contact__r.PersonEmail != null
                        ? inventor.Contact__r.PersonEmail
                        : inventor.Contact__r.AltEmail__pc;
                    Map<String, Object> variables = createVariables(disclosure);
                    variables.put(
                        'submitter_name',
                        disclosure.Submitting_Contact__c != null
                            ? disclosure.Submitting_Contact__r.Name
                            : ''
                    );
                    variables.put('inventor_name', inventor.Contact__r.Name);

                    Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                        toAdd,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_ARCHIVED,
                        variables
                    );
                    sendNotificationEmails.add(newEmail);
                }
            }
        }

        // Possible for Disclosure to not have Inventors.
        for (Disclosure__c disclosure : disList) {
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);
            Boolean isArchived =
                disclosure.Status__c != oldDisclosure.Status__c &&
                disclosure.Status__c == 'Archived';
            if (isArchived) {
                disclosureSubmitterMap.put(disclosure.Id, disclosure);
            }
        }

        // Notify Submitter
        for (Id key : disclosureSubmitterMap.keySet()) {
            Disclosure__c disclosureSOB = disclosureSubmitterMap.get(key);

            if (disclosureSOB != null) {
                Account contact = disclosureSOB.Submitting_Contact__r;
                String toAdd = contact.PersonEmail != null
                    ? contact.PersonEmail
                    : contact.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosureSOB);
                variables.put('submitter_name', contact.Name);
                variables.put('inventor_name', contact.Name);

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_SUBMITTED_BY_DRAFT_ARCHIVED,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }
        return sendNotificationEmails;
    }

    public static void onPrimaryInventorRemoved(
        List<DisclosureInventor__c> disclosureInventorRelatedList,
        Map<Id, DisclosureInventor__c> oldDisclosureInventorMap
    ) {
        if (
            disclosureInventorRelatedList != null &&
            !disclosureInventorRelatedList.isEmpty()
        ) {
            List<Notification__c> notificationList = new List<Notification__c>();
            for (DisclosureInventor__c disinv : disclosureInventorRelatedList) {
                if (
                    oldDisclosureInventorMap.get(disinv.Id)
                        .PrimaryInventor__c == disinv.PrimaryInventor__c
                ) {
                    // Primary Inventor status did not change
                    continue;
                }
                // The person creating the disclosure as an inventor should not receive a notification that they have been added as an inventor since they are the ones doing the adding.
                Boolean inventorForSubmittingContact = (disinv.Contact__c ==
                disinv.Disclosure__r.Submitting_Contact__c);

                if (
                    !inventorForSubmittingContact &&
                    disinv.PrimaryInventor__c == false &&
                    oldDisclosureInventorMap.get(disinv.Id)
                        .Review_Draft_Watcher__c == true
                ) {
                    // No longer Primary Inventor
                    Map<String, Object> variables = createVariables(
                        disinv.Disclosure__r
                    );
                    variables.put('inventor_name', disinv.Contact__r.Name);
                    Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                        disinv.Contact__r.PersonEmail,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_REMOVED,
                        variables
                    );

                    notificationList.add(newNotification);
                }
            }
            if (notificationList != null && !notificationList.isEmpty()) {
                insert notificationList;
            }
        }
    }

    /**
     - TLOS-639: All Inventor Notification - Removing Inventors from a Disclosure that is already approved.
     This is a SysAdmin action only.
    */
    public static void onInventorDeleted(
        List<DisclosureInventor__c> disclosureInventorRelatedList
    ) {
        if (
            disclosureInventorRelatedList != null &&
            !disclosureInventorRelatedList.isEmpty()
        ) {
            List<Notification__c> notificationList = new List<Notification__c>();
            for (DisclosureInventor__c disinv : disclosureInventorRelatedList) {
                Disclosure__c disclosure = disinv.Disclosure__r;

                Boolean inventorForSubmittingContact = (disinv.Contact__c ==
                disinv.Disclosure__r.Submitting_Contact__c);
                String currentStatus = disclosure.Status__c;
                Boolean isWatcherAndNotSubmitter = (!inventorForSubmittingContact &&
                disinv.Review_Draft_Watcher__c == true);

                // Removing Inventors in Approved state
                if (currentStatus == 'Approved') {
                    Map<String, Object> variables = createVariables(
                        disinv.Disclosure__r
                    );
                    variables.put('inventor_name', disinv.Contact__r.Name);
                    Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                        disinv.Contact__r.PersonEmail,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_APPROVED_INVENTOR_DELETED,
                        variables
                    );

                    notificationList.add(newNotification);
                } else if (isWatcherAndNotSubmitter) {
                    // Primary Inventor Deleted
                    // Draft status: The person creating the disclosure as an inventor should not receive a notification that they have been added as an inventor since they are the ones doing the adding.
                    Map<String, Object> variables = createVariables(
                        disinv.Disclosure__r
                    );
                    variables.put('inventor_name', disinv.Contact__r.Name);
                    Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                        disinv.Contact__r.PersonEmail,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DELETED,
                        variables
                    );

                    notificationList.add(newNotification);
                }
            }
            if (notificationList != null && !notificationList.isEmpty()) {
                insert notificationList;
            }
        }
    }

    /**
     - TLOS-639: All Inventor Notification - Adding Inventors to a Disclosure that is already approved.
     - TLOS-151: Review and Sign.
        This is a SysAdmin action only.
    */
    public static void onApprovedInventorAdded(
        List<DisclosureInventor__c> disclosureInventorRelatedList
    ) {
        if (
            disclosureInventorRelatedList != null &&
            !disclosureInventorRelatedList.isEmpty()
        ) {
            List<Notification__c> notificationList = new List<Notification__c>();
            for (DisclosureInventor__c disinv : disclosureInventorRelatedList) {
                Disclosure__c disclosure = disinv.Disclosure__r;

                // Adding Inventors to Approved state
                if (disclosure.Status__c == 'Approved') {
                    Map<String, Object> variables = createVariables(
                        disinv.Disclosure__r
                    );
                    variables.put('inventor_name', disinv.Contact__r.Name);
                    variables.put(
                        'inventor_email',
                        disinv.Contact__r.PersonEmail
                    );
                    if (disinv.Contact__r.InvitationCode__pc != null) {
                        variables.put(
                            'invitation_code',
                            disinv.Contact__r.InvitationCode__pc
                        );
                    }
                    Boolean isActiveKerb = Helpers.isActiveKerb(
                        disinv.Contact__r.MoiraStatus__pc
                    );
                    variables.put('isActiveKerb', isActiveKerb);
                    variables.put('isAlumni', disinv.Contact__r.IsAlumni__pc);
                    Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                        disinv.Contact__r.PersonEmail,
                        NotificationBuilder.TEMPLATE_DISCLOSURE_SIGNATURE_REQUIRED,
                        variables
                    );

                    notificationList.add(newNotification);
                }
            }
            if (notificationList != null && !notificationList.isEmpty()) {
                insert notificationList;
            }
        }
    }

    /**
     - TLOS-1083: Primary Inventor Notification - named primary inventor on a draft get email that draft has been Submitted for Approval
    */
    private static List<Notification__c> onDraftSubmittedForApprovalNotifications(
        List<Disclosure__c> disList,
        Map<Id, Disclosure__c> oldDisclosures,
        List<DisclosureInventor__c> inventorList
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();

        for (DisclosureInventor__c inventor : inventorList) {
            Disclosure__c disclosure = inventor.Disclosure__r;
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);

            String newStatus = disclosure.Status__c;
            String oldStatus = oldDisclosure.Status__c;
            Boolean inventorForSubmittingContact = (inventor.Contact__c ==
            disclosure.Submitting_Contact__c);
            Boolean isDraftSubmitted =
                oldStatus == 'Draft' &&
                (newStatus == 'Inventor Submitted' ||
                newStatus == 'Pending Department Approval');
            Boolean isWatcherAndNotSubmitter =
                !inventorForSubmittingContact &&
                inventor.Review_Draft_Watcher__c == true; // The Submitter is the one Submitting, and should not get notified

            if (isDraftSubmitted && isWatcherAndNotSubmitter) {
                // If Flagged as watcher, notify Inventor
                String toAdd = inventor.Contact__r.PersonEmail != null
                    ? inventor.Contact__r.PersonEmail
                    : inventor.Contact__r.AltEmail__pc;
                Map<String, Object> variables = createVariables(disclosure);
                variables.put('inventor_name', inventor.Contact__r.Name);

                Notification__c newEmail = NotificationBuilder.buildNotificationEmail(
                    toAdd,
                    NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTORS_DRAFT_SUBMITTED,
                    variables
                );
                sendNotificationEmails.add(newEmail);
            }
        }
        return sendNotificationEmails;
    }

    private static Map<String, Object> createVariables(
        Disclosure__c disclosure
    ) {
        Map<String, Object> variables = new Map<String, Object>();
        variables.put('disclosure_title', disclosure.Name__c);
        variables.put('disclosure_name', disclosure.Name);
        variables.put('disclosure_type', disclosure.RecordType.Name);

        if (disclosure.Submitting_Contact__c != null) {
            variables.put(
                'submitter_name',
                disclosure.Submitting_Contact__r.Name
            );
        }

        if (disclosure.Case_Number__c != null) {
            variables.put('case_number', disclosure.Case_Number__c);
        }

        return variables;
    }
}