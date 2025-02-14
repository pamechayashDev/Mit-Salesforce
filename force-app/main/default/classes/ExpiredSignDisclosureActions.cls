public class ExpiredSignDisclosureActions implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
     public class InvalidParameterException extends Exception {}

    // This need to be stateful batchable process
    Integer lastNDaysBefore = 120;
    Integer lastNDaysAfter = 999;

    public ExpiredSignDisclosureActions(){}

    public ExpiredSignDisclosureActions(Integer lastNDaysBeforeAugust, Integer lastNDaysAfterAugust ){
        this.lastNDaysBefore = lastNDaysBeforeAugust ;
        this.lastNDaysAfter = lastNDaysAfterAugust;
        if ( this.lastNDaysBefore <= 0 || this.lastNDaysAfter <= 0 ) {
            throw new InvalidParameterException('Expecting positive values');
        }
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
       Id recordTypeIdSignDisclosure = Schema.SObjectType.Disclosure_Action__c.getRecordTypeInfosByDeveloperName().get('Sign_Disclosure').getRecordTypeId();
       DateTime august = DateTime.newInstanceGmt(2024, 8, 1, 0, 0, 0);
       DateTime last120Days = Util.now().addDays(this.lastNDaysBefore * -1);
       DateTime last999Days = Util.now().addDays(this.lastNDaysAfter * -1);
       // The envelope create date is based on the first time someone attempts to sign the disclosure and NOT on the action create date
       // We dont store the envelope creation date only when it is modified
       return Database.getQueryLocator([ SELECT Id, Contact_Action__r.Id, Contact_Action__r.CreatedDate
                 FROM Disclosure_Action__c
                 WHERE
                     Contact_Action__r.Status__c = 'Pending'
                     AND Disclosure__r.Last_Modified_at_time_of_Signing_Request__c != null
                     AND (
                        (Disclosure__r.Last_Modified_at_time_of_Signing_Request__c < :august  AND Disclosure__r.Last_Modified_at_time_of_Signing_Request__c <= :last120Days)
                        OR (Disclosure__r.Last_Modified_at_time_of_Signing_Request__c >= :august  AND Disclosure__r.Last_Modified_at_time_of_Signing_Request__c <= :last999Days)
                     )
                     AND RecordTypeId = :recordTypeIdSignDisclosure
                   ]);
    }

    public void execute(Database.BatchableContext bc, List<Disclosure_Action__c> signActions) {
       List<Contact_Action__c> contactActions = new List<Contact_Action__c>();
       for (Disclosure_Action__c disclosureAction : signActions) {
           // Update all Contact Actions with new status
           Contact_Action__c contactAction = disclosureAction.Contact_Action__r;
           contactAction.Status__c = 'Canceled';
           contactActions.add(contactAction);
           System.debug('Contact Action to be updated: ' + contactAction.toString());    
       }
       System.debug('Contact Actions to be updated: ' + contactActions.toString());
       System.debug('Rows selected: ' + signActions.size());
       System.debug('Rows change: ' + contactActions.size());
       update contactActions;
       System.debug('Changes SUCCESSFUL');
    }

    public void finish(Database.BatchableContext bc) {
    }

}