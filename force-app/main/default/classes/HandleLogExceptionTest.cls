@isTest
public with sharing class HandleLogExceptionTest {
    
    static testMethod void testLogException() {
        try {
            Integer i = 0/0;
            
        }catch(Exception e) {
            HandleLogException.logException(e);
            List<Log_Exception__c> log = [Select Id From Log_Exception__c];
            system.assertEquals(1, log.size());
        }
    }
}