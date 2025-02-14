@isTest
public class TLOContactUpdateReqTriggerHandlerTest {
    @isTest
    public static void testOnBeforeUpdate() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'BioTang',
            'Draft',
            cont
        );

        Account contact = SampleDataFactory.createContact(
            'Donald1',
            false,
            '12345671'
        );
        contact.PersonEmail = null;
        update contact;

        TLO_Contact_Update_Request__c cur = new TLO_Contact_Update_Request__c(
            Disclosure__c = d.Id,
            Contact__c = contact.Id,
            Email__c = 'test@gmail.com'
        );
        insert (cur);

        try {
            DisclosureRecordFetch.markCompleteTLOContactUpdateRequestById(
                cur.Id
            );
            System.assert(false, 'Validation error not thrown');
        } catch (Exception ex) {
            String msg = ex.getMessage();
            system.assert(
                msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Field Validation not thrown ' + msg
            );
        }
    }

    @isTest
    public static void testNoInstitutionOnContactWhenCompleted() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            false,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'BioTang',
            'Draft',
            cont
        );

        cont.Institution__pc = null;
        cont.InstitutionCode__pc = '';
        update cont;

        TLO_Contact_Update_Request__c cur = new TLO_Contact_Update_Request__c(
            Disclosure__c = d.Id,
            Contact__c = cont.Id,
            Email__c = 'test@gmail.com'
        );
        insert (cur);

        try {
            DisclosureRecordFetch.markCompleteTLOContactUpdateRequestById(
                cur.Id
            );
            System.assert(false, 'Validation error not thrown');
        } catch (Exception ex) {
            String msg = ex.getMessage();
            System.debug('\n\n ex:- ' + ex);
            System.debug('\n\n msg:- ' + msg);

            System.assert(
                msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Field Validation not thrown ' + msg
            );
            System.assert(
                msg.contains('Institution can not be empty'),
                'Field Validation not thrown ' + msg
            );
        }
    }

    @isTest
    public static void testNoInstitutionOnContactWhenRejected() {
        Test.startTest();
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            false,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'BioTang',
            'Draft',
            cont
        );

        cont.Institution__pc = null;
        cont.InstitutionCode__pc = '';
        update cont;

        TLO_Contact_Update_Request__c cur = new TLO_Contact_Update_Request__c(
            Disclosure__c = d.Id,
            Contact__c = cont.Id,
            Email__c = 'test@gmail.com'
        );
        insert (cur);

        try {
            DisclosureRecordFetch.rejectTLOContactUpdateRequestById(cur.Id);
            System.assert(false, 'Validation error not thrown');
        } catch (Exception ex) {
            String msg = ex.getMessage();
            System.debug('\n\n ex:- ' + ex);
            System.debug('\n\n msg:- ' + msg);

            System.assert(
                msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Field Validation not thrown ' + msg
            );
            System.assert(
                msg.contains('Institution can not be empty'),
                'Field Validation not thrown ' + msg
            );
        }
    }

    //TODO part of this also run under the community profile too
    //public static void testInactiveKerbMitEmailOnContact() {
}