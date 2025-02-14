public with sharing class TloContactEmailEventProducer {
    public TloContactEmailEventProducer() {
    }

    public static void onTloContactEmailChanged(
        List<Account> contactChangedList
    ) {
        if (contactChangedList != null && !contactChangedList.isEmpty()) {
            List<Tlo_Contact_Email_Event__e> events = new List<Tlo_Contact_Email_Event__e>();
            for (Account contact : contactChangedList) {
                Tlo_Contact_Email_Event__e event = new Tlo_Contact_Email_Event__e(
                    Event_Name__c = 'onEmailUpdated',
                    TloContactId__c = contact.Id,
                    Email__c = contact.PersonEmail
                );
                events.add(event);
            }
            if (events != null && !events.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(events);
                validateEventBusPublish(results);
            }
        }
    }

    public static void validateEventBusPublish(
        List<Database.SaveResult> results
    ) {
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                EventBusException ex;
                for (Database.Error err : sr.getErrors()) {
                    System.debug(
                        'Error returned: ' +
                        err.getStatusCode() +
                        ' - ' +
                        err.getMessage()
                    );
                    if (ex == null) {
                        ex = new EventBusException(err.getMessage());
                    }
                }
                throw ex;
            }
        }
    }
    public class EventBusException extends Exception {
    }
}