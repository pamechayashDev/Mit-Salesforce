@RestResource(urlMapping='/api/disclosure-enable-watchers/v1/*')
global with sharing class DisclosureEnableWatchers {
    global class DisclosureWatcher {
        public String disclosureId;
        public String status;
        public Set<Id> disclosureInventors;
    }

    @HttpPost
    global static String enableWatchersRest() {
        RestResponse response = RestContext.response;

        String disclosureIdStr = RestContext.request.params.get('disclosureId');

        DisclosureWatcher disclosureWatcher = enableDraftWatchers(
            disclosureIdStr
        );
        if (disclosureWatcher != null) {
            String json = JSON.serialize(disclosureWatcher, true);
            response.statusCode = 200;
            return json;
        } else {
            response.statusCode = 304; // Not Modified
            return null;
        }
    }

    public static DisclosureWatcher enableDraftWatchers(
        String disclosureIdStr
    ) {
        List<DisclosureInventor__c> updateList = new List<DisclosureInventor__c>();

        List<DisclosureInventor__c> inventors = DisclosureRecordFetch.getDisclosureInventorsWithContactByDisclosureId(
            disclosureIdStr
        );
        for (DisclosureInventor__c inventor : inventors) {
            Boolean inventorForSubmittingContact =
                inventor.Contact__c ==
                inventor.Disclosure__r.Submitting_Contact__c; // Dont ask submitting contact to review Draft

            if (
                inventor.Disclosure__r.Status__c == 'Draft' &&
                inventor.PrimaryInventor__c == true &&
                inventorForSubmittingContact == false
            ) {
                inventor.Review_Draft_Watcher__c = true;
                updateList.add(inventor);
            }
        }

        if (!updateList.isEmpty()) {
            update updateList;

            Map<Id, DisclosureInventor__c> inventorMap = new Map<Id, DisclosureInventor__c>(
                updateList
            );

            sendDraftForReviewEvent(inventorMap);

            DisclosureWatcher disclosureWatcher = new DisclosureWatcher();
            disclosureWatcher.disclosureId = disclosureIdStr;
            disclosureWatcher.status = 'successful';
            disclosureWatcher.disclosureInventors = inventorMap.keySet();
            return disclosureWatcher;
        } else {
            return null;
        }
    }

    private static void sendDraftForReviewEvent(
        Map<Id, DisclosureInventor__c> inventorMap
    ) {
        List<Notification__c> notificationList = new List<Notification__c>();
        for (Id key : inventorMap.keySet()) {
            DisclosureInventor__c inventor = inventorMap.get(key);

            Map<String, String> variables = new Map<String, String>();
            variables.put('inventor_name', inventor.Contact__r.Name);
            variables.put('disclosure_title', inventor.Disclosure__r.Name__c);
            variables.put('disclosure_name', inventor.Disclosure__r.Name);
            variables.put(
                'disclosure_type',
                inventor.Disclosure__r.RecordType.Name
            );
            variables.put(
                'submitter_name',
                inventor.Disclosure__r.Submitting_Contact__r.Name
            );
            variables.put(
                'submitter_email',
                inventor.Disclosure__r.Submitting_Contact__r.PersonEmail
            );

            Notification__c newNotification = NotificationBuilder.buildNotificationEmail(
                inventor.Contact__r.PersonEmail,
                NotificationBuilder.TEMPLATE_DISCLOSURE_PRIMARY_INVENTOR_DRAFT_REVIEW,
                variables
            );
            notificationList.add(newNotification);
        }

        if (notificationList != null && !notificationList.isEmpty()) {
            insert notificationList;
        }
    }
}