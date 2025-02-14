public with sharing class DisclosureInventorEventHandler extends TriggerHandler {
    public DisclosureInventorEventHandler() {

    }

    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap) {
        List<String> futureJsonRecords = new List<String>();

        for (SObject event : newRecords) {
            futureJsonRecords.add(JSON.serialize(event));
        }

        DisclosureInventorEventHandler.futureAfterInsertEvent(futureJsonRecords);
    }

    /** 
     * Need to do a callout and can only be done from with in a Future method
     * Methods with the future annotation must be static methods, and can only return a void type. 
     * The specified parameters must be primitive data types, arrays of primitive data types, or collections of primitive data types. 
     * Methods with the future annotation can’t take sObjects or objects as arguments.
    */
    @Future(callout=true)
    public static void futureAfterInsertEvent(List<String> newRecordsJson) {

        List<DisclosureInventor_Event__e> newRecords = new List<DisclosureInventor_Event__e>();
        for (String jsonEvent : newRecordsJson) {
           
            DisclosureInventor_Event__e event =  (DisclosureInventor_Event__e) System.JSON.deserialize(jsonEvent, DisclosureInventor_Event__e.class); 
            newRecords.add(event);
        }
        DisclosureInventorEventHandler handler = new DisclosureInventorEventHandler();

        handler.handleOnApprovedInventorInvitationCode(newRecords);
        handler.handleOnApprovedInventorAdded(newRecords);
    }

    public void handleOnApprovedInventorInvitationCode(List<DisclosureInventor_Event__e> newRecords) {
        List<String> entityIds = new List<String>();
        Set<String> disclosureIds = new Set<String>();
        for (DisclosureInventor_Event__e event : newRecords) {
            if (event.Event_Name__c == 'onApprovedInventorAdded') {
                 entityIds.add(event.LinkedEntityId__c);
            }
        }
        if (!entityIds.isEmpty()) {
             // Callout Methods
             GuestAccount.createGuestAccountByInventorIds(entityIds);
        }


    }

    public void handleOnApprovedInventorAdded(List<DisclosureInventor_Event__e> newRecords) {
        List<String> entityIds = new List<String>();
        for (DisclosureInventor_Event__e event : newRecords) {
            if (event.Event_Name__c == 'onApprovedInventorAdded') {
                entityIds.add(event.LinkedEntityId__c);
            }
        }
        if (!entityIds.isEmpty()) {
            List<DisclosureInventor__c> inventorList = DisclosureRecordFetch.getDisclosureInventorsByIds(entityIds);
            DisclosureInventorNotification.onApprovedInventorAdded(inventorList);

            List<Async_Request__c> asyncJobsForApprovedInventorAdd = new List<Async_Request__c>();
            for (DisclosureInventor__c inventor : inventorList) {
                 if(inventor.Signed_Status__c == null || inventor.Signed_Status__c == 'Pending') {
                    // Need to send new Contact to Forrester
                    asyncJobsForApprovedInventorAdd.add(AsyncRequestHelper.prepareAsyncRequest(inventor.Id, 'DisclosureInventor__c', 'InventorAddedToApprovedDisclosureToForresterJob'));
                }
            }
            if (!asyncJobsForApprovedInventorAdd.isEmpty()) {
                insert asyncJobsForApprovedInventorAdd;
            }
        }
    }

}