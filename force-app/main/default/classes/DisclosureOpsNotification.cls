public with sharing class DisclosureOpsNotification {
    public static void scheduleNotificationsForOps(
        List<Disclosure__c> queryDisclosures,
        Map<Id, Disclosure__c> oldDisclosures,
        List<Department_Head__c> deptHeads
    ) {
        List<Disclosure__c> rejectedByDeptHeadQuery = new List<Disclosure__c>();
        List<Disclosure__c> inventorSubmittedQuery = new List<Disclosure__c>();

        for (Disclosure__c disclosure : queryDisclosures) {
            Disclosure__c oldDisclosure = oldDisclosures.get(disclosure.Id);

            if (
                oldDisclosure.Status__c == 'Pending Department Approval' &&
                disclosure.Status__c == 'Rejected'
            ) {
                // Declined by Dept head from Pending Department Approval state only.
                rejectedByDeptHeadQuery.add(disclosure);
            }
            if (
                oldDisclosure.Status__c != disclosure.Status__c &&
                disclosure.Status__c == 'Inventor Submitted'
            ) {
                inventorSubmittedQuery.add(disclosure);
            }
        }

        if (!rejectedByDeptHeadQuery.isEmpty()) {
            insertNotificationProcessEmail(
                rejectedByDeptHeadQuery,
                deptHeads,
                NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_DECLINED_DEPT_HEAD
            ); // Notify TLO on Disclosure Notification Address of rejections
        }
        if (!inventorSubmittedQuery.isEmpty()) {
            insertNotificationProcessEmail(
                inventorSubmittedQuery,
                deptHeads,
                NotificationBuilder.TEMPLATE_OPS_DISCLOSURE_CREATION
            );
        }
    }

    private static void insertNotificationProcessEmail(
        List<Disclosure__c> disclosureList,
        List<Department_Head__c> deptHeads,
        String template
    ) {
        Map<Id, Department_Head__c> disclosureDeptHeadLookup = Helpers.toDisclosureDeptHeadLookup(
            deptHeads
        );
        if (disclosureList != null && !disclosureList.isEmpty()) {
            List<Notification__c> notificationList = new List<Notification__c>();
            for (Disclosure__c dis : disclosureList) {
                Department_Head__c deptHead = disclosureDeptHeadLookup.get(
                    dis.Id
                );

                Map<String, String> variables = new Map<String, String>();
                variables.put('disclosure_title', dis.Name__c);
                variables.put('disclosure_name', dis.Name);
                variables.put('submitter_name', dis.Submitting_Contact__r.Name);
                variables.put('disclosure_type', dis.RecordType.Name);
                variables.put(
                    'link',
                    URL.getSalesforceBaseUrl().toExternalForm() +
                        '/lightning/r/Disclosure__c/' +
                        dis.Id +
                        '/view'
                );
                if (deptHead != null) {
                    variables.put('dlc_name', deptHead.Contact__r.Name);
                    variables.put('dlc_email', deptHead.Contact__r.PersonEmail);
                }
                if (dis.Rejection_Reason__c != null) {
                    variables.put('comments', dis.Rejection_Reason__c);
                }
                Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                    getOpsEmailAddress(),
                    template,
                    variables
                );
                notificationList.add(newNotification);
            }
            if (notificationList != null && !notificationList.isEmpty()) {
                insert notificationList;
            }
        }
    }

    public static void sendNotificationForSigned(
        List<Disclosure__c> findAllDisclosure,
        Map<Id, Disclosure__c> oldDis
    ) {
        // TLOS - 2460 Changes
        List<Notification__c> sendNotificationEmail = new List<Notification__c>();
        for (Disclosure__c d : findAllDisclosure) {
            Boolean sendNotification = false;
            Boolean onApproved =
                d.Status__c == 'Approved' &&
                d.Status__c != oldDis.get(d.Id).Status__c;
            Boolean onlyOnePrimaryInventor = d.Inventors_Count__c == 1;

            // The Primary Inventor can only Submit for Approval if he has signed the Draft earlier
            if (
                onApproved &&
                onlyOnePrimaryInventor &&
                d.All_Inventors_Signed__c
            ) {
                sendNotification = true;
            } else if (
                !onlyOnePrimaryInventor &&
                d.All_Inventors_Signed__c &&
                d.All_Inventors_Signed__c !=
                oldDis.get(d.Id).All_Inventors_Signed__c
            ) {
                sendNotification = true;
            }

            if (sendNotification) {
                Map<String, String> variables = new Map<String, String>();
                variables.put('disclosure_title', d.Name__c);
                variables.put('disclosure_name', d.Name);
                variables.put('submitter_name', d.Submitting_Contact__r.Name);
                variables.put('case_number', d.Case_Number__c); //TODO for the 1st inventor who sign's a disclosure the Case# will not be set as Disclosure is not approved yet to create case
                variables.put('disclosure_type', d.RecordType.Name);
                variables.put(
                    'link',
                    URL.getSalesforceBaseUrl().toExternalForm() +
                        '/lightning/r/Disclosure__c/' +
                        d.Id +
                        '/view'
                );

                sendNotificationEmail.add(
                    NotificationBuilder.buildNotificationEmail(
                        getOpsEmailAddress(),
                        NotificationBuilder.TEMPLATE_DISCLOSURE_ALL_SIGNED,
                        variables
                    )
                );
            }
        }
        if (sendNotificationEmail != null && !sendNotificationEmail.isEmpty()) {
            insert sendNotificationEmail;
        }
        // TLOS - 2460 Changes
    }

    public static void sendNotificationEachSignedInventor(
        List<DisclosureInventor__c> signedInventors
    ) {
        List<Notification__c> sendNotificationEmails = new List<Notification__c>();
        for (DisclosureInventor__c inventor : signedInventors) {
            Boolean inventorIsSubmitter = (inventor.Contact__c ==
            inventor.Disclosure__r.Submitting_Contact__c);
            Boolean inventorMadeSigningDecision = (inventor.Signed_Status__c ==
            'Yes' ||
            inventor.Signed_Status__c == 'Opted Out');

            //The Ops team does not need to get a “Signature Received” email  when the inventor signs upon Submission.
            //They already get an email telling them a case has been submitted
            if (inventorMadeSigningDecision && !inventorIsSubmitter) {
                Map<String, String> variables = new Map<String, String>();
                variables.put('inventor_name', inventor.Contact__r.Name);
                variables.put(
                    'inventor_email',
                    inventor.Contact__r.PersonEmail
                );
                variables.put(
                    'disclosure_title',
                    inventor.Disclosure__r.Name__c
                );
                variables.put('disclosure_name', inventor.Disclosure__r.Name);
                variables.put(
                    'case_number',
                    inventor.Disclosure__r.Case_Number__c
                );
                variables.put(
                    'submitter_name',
                    inventor.Disclosure__r.Submitting_Contact__r.Name
                );

                variables.put('signed_status', inventor.Signed_Status__c);
                variables.put('signed_comment', inventor.Signed_Comment__c);

                variables.put(
                    'additional_comments',
                    inventor.AdditionalComments__c
                );

                variables.put(
                    'link',
                    URL.getSalesforceBaseUrl().toExternalForm() +
                        '/lightning/r/Disclosure__c/' +
                        inventor.Disclosure__c +
                        '/view'
                );

                String templateToUse = inventor.Signed_Status__c == 'Yes'
                    ? NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_EACH_SIGNED_MIT
                    : NotificationBuilder.TEMPLATE_DISCLOSUREINVENTOR_OPTED_OUT;

                sendNotificationEmails.add(
                    NotificationBuilder.buildNotificationEmail(
                        getOpsEmailAddress(),
                        templateToUse,
                        variables
                    )
                );
            }
        }
        if (
            sendNotificationEmails != null && !sendNotificationEmails.isEmpty()
        ) {
            insert sendNotificationEmails;
        }
    }
    private static String getOpsEmailAddress() {
        return ConfigurationBuilder.getConfigurationToString(
            'DisclosureOpsEmail'
        );
    }
}