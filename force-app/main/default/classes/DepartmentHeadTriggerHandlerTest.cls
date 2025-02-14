@isTest
public with sharing class DepartmentHeadTriggerHandlerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void createDepartmentHead() {
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '123456711'
        );
        update cont1;

        Account cont2 = SampleDataFactory.createContact(
            'Donald2',
            true,
            '12345671'
        );
        update cont2;

        Disclosure__c d = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );
        Disclosure__c d1 = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont2
        );

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh3 = new Department_Head__c();
        dh3.Contact__c = cont2.ID;
        dh3.Disclosure__c = d.Id;
        insert dh3;

        Department_head__c dh2 = new Department_Head__c();
        dh2.Contact__c = cont.ID;
        dh2.Disclosure__c = d.Id;
        insert dh2;

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;
        insert dh;

        dh.Delegated_To__c = dh2.Id;
        update dh;

        dh.Delegated_To__c = dh3.Id;
        update dh;

        try {
            Department_head__c dh1 = new Department_Head__c();
            dh1.Contact__c = cont1.ID;
            dh1.Disclosure__c = d.Id;

            insert dh1;
        } catch (Exception ex) {
            String msg = ex.getMessage();
            system.assert(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Department_head__c del = [
            SELECT Id
            FROM Department_head__c
            WHERE Id = :dh.Id
        ];
        delete del;
    }

    @isTest
    public static void validateAction() {
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '123456711'
        );
        update cont1;

        Account cont2 = SampleDataFactory.createContact(
            'Donald2',
            true,
            '12345671'
        );
        update cont2;

        Disclosure__c d = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Pending Department Approval',
            cont
        );

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;
        insert dh;

        List<Contact_Action__c> conAction = [
            SELECT ID, Contact__r.Name
            FROM Contact_Action__c
            WHERE createddate = today
        ];
        system.assert(conAction.size() > 0);
    }
}