public with sharing class DisclosureInventorEventProducer {
    public DisclosureInventorEventProducer() {

    }

    public static void onApprovedInventorAdded(List<DisclosureInventor__c> disclosureInventorRelatedList) {
        if(disclosureInventorRelatedList != null && !disclosureInventorRelatedList.isEmpty()) {

            List<DisclosureInventor_Event__e> events = new List<DisclosureInventor_Event__e>();
            for(DisclosureInventor__c disinv: disclosureInventorRelatedList) {
                Disclosure__c disclosure = disinv.Disclosure__r;

                // Adding Inventors to Approved state
                if (disclosure.Status__c == 'Approved') {
                    DisclosureInventor_Event__e event = new DisclosureInventor_Event__e(Event_Name__c = 'onApprovedInventorAdded', LinkedEntityId__c = disinv.Id );
                    events.add(event);
                }
            }
            if(events != null && !events.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(events);
                validateEventBusPublish(results);
            }
        }

    }

    public static void validateEventBusPublish(List<Database.SaveResult> results) {
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                EventBusException ex;
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode() +  ' - ' +  err.getMessage());
                    if (ex == null) {
                     ex = new EventBusException(err.getMessage());
                    }
                }
                throw ex;
            }
        }
    }
    public class EventBusException extends Exception {}
}