@isTest
public class InventionDisclosureTriggerHandlerTest {

    @isTest
    public static void createInventionDisclosure() {
        Id recordTypeIdInventionDisclosure = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();	        
        Account cont = SampleDataFactory.createContact('Donald',true, '12345678');	        
        Disclosure__c d = SampleDataFactory.createDisclosure(recordTypeIdInventionDisclosure, 'Draft for Invention Disclosure', 'Draft', cont);
        system.debug('from test class:'+d.Id);
        try {
            Invention_Disclosure__c idis = new Invention_Disclosure__c();
            idis.Disclosure__c = d.Id;
            idis.Name = 'Test';
            idis.Disclosure_Published_Or_Disclosed__c = 'Yes';
            idis.Disclosure_Anticipated_Publication__c = 'Yes';
            idis.Disclosure_Oral_Presentation__c = 'Yes';
            idis.Disclosure_Anticipated_Publication__c = 'Yes';
            insert idis;
            
            Invention_Disclosure__c idis1 = new Invention_Disclosure__c();
            idis1.Disclosure__c = d.Id;
            idis1.Name = 'Test2';
            idis1.Disclosure_Published_Or_Disclosed__c = 'No';
            insert idis1;
            
            update idis;
            
        }catch(Exception ex) {
            String msg = ex.getMessage();
            system.debug('from test class 2:'+msg);
            system.assert(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }

    @isTest
    public static void updateInventionDisclosure() {
        Id recordTypeIdInventionDisclosure = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Invention_Disclosure').getRecordTypeId();	        
        Account cont = SampleDataFactory.createContact('Donald',true, '12345678');	        
        Disclosure__c d = SampleDataFactory.createDisclosure(recordTypeIdInventionDisclosure, 'Draft for Invention Disclosure', 'Draft', cont);
        system.debug('from test class:'+d.Id);
        try {
            Invention_Disclosure__c idis = new Invention_Disclosure__c();
            idis.Disclosure__c = d.Id;
            idis.Name = 'Test';
            idis.Disclosure_Published_Or_Disclosed__c = 'Yes';
            idis.Disclosure_Anticipated_Publication__c = 'No';
            idis.Disclosure_Oral_Presentation__c = 'No';
            idis.Disclosure_Anticipated_Publication__c = 'No';
            insert idis;
            
            Invention_Disclosure__c idis1 = new Invention_Disclosure__c();
            idis1.Disclosure__c = d.Id;
            idis1.Name = 'Test2';
            idis1.Disclosure_Published_Or_Disclosed__c = 'No';
            idis1.Disclosure_Anticipated_Publication__c = 'No';
            idis1.Disclosure_Oral_Presentation__c = 'No';
            idis1.Disclosure_Anticipated_Publication__c = 'No';
            idis1.Anticipated_Publication_Comment__c = '1';
            idis1.Oral_Disclosure_Date__c = date.today();
            insert idis1;
            d.Status__c = 'Approved';
            update d;
            update idis1;
            List<Invention_Disclosure__c> inList = new List<Invention_Disclosure__c>();
            inList.add(idis1);
            inList.add(idis);
        }catch(Exception ex) {
            String msg = ex.getMessage();
            system.debug('from test class 2:'+msg);
            system.assert(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
}