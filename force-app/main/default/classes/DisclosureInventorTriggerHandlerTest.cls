@isTest
public class DisclosureInventorTriggerHandlerTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    public static void testInsertDisclosureInventor() {
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );
        update cont1;

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;

        insert dh;

        DisclosureInventor__c di = new DisclosureInventor__c();
        di.Disclosure__c = d.Id;
        di.PrimaryInventor__c = false;
        di.Contact__c = cont.Id;
        di.Signed_Status__c = 'Yes';
        insert di;

        try {
            di.WorkDoneOutsideMIT__c = 'Yes';
            di.Collaboration__c = 'Yes';
            update di;
        } catch (Exception ex) {
            String msg = ex.getMessage();
            system.assert(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }

    @isTest
    public static void testSignDisclosureAfterApproval() {
        // Setup variables
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account contact1 = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Account contact2 = SampleDataFactory.createContact(
            'James',
            false,
            '12345679'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            contact1
        );
        Software_Code_Disclosure__c softwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Draft Software Code',
            d
        );

        Account dhContact = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );
        update dhContact;

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = dhContact.ID;
        dh.Disclosure__c = d.Id;
        insert dh;

        DisclosureInventor__c di1 = SampleDataFactory.createInventor(
            d,
            true,
            contact1
        );
        DisclosureInventor__c di2 = SampleDataFactory.createInventor(
            d,
            false,
            contact2
        );

        di1.Signed_Status__c = 'Yes';
        update di1;

        d.Status__c = 'Inventor Submitted';
        update d;

        d.Status__c = 'Approved';
        update d;

        // Try to sign Disclosure after Approved
        try {
            di2.Signed_Status__c = 'Yes';
            update di2;
        } catch (Exception e) {
            System.assert(false, 'Error thrown: ' + e.getMessage());
        }
    }

    @isTest
    public static void callToForrester() {
        Test.setMock(HttpCalloutMock.class, new ForresterMock());
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;

        insert dh;

        DisclosureInventor__c di = new DisclosureInventor__c();
        di.Disclosure__c = d.Id;
        di.PrimaryInventor__c = false;
        di.Contact__c = cont.Id;
        di.Signed_Status__c = 'Yes';
        insert di;

        di.WorkDoneOutsideMIT__c = 'Yes';
        di.Collaboration__c = 'Yes';
        di.CollaborationDetails__c = 'Test Forrester';
        di.WorkDoneOutsideMITDetails__c = 'Test Forrester';
        di.SalaryWages__c = 'MIT';
        di.SalaryWagesDetails__c = 'Test';
        di.ThirdPartyMaterials__c = 'test';
        di.CollaborationDetails__c = 'TEST';
        di.WorkDoneAtMIT__c = 'Yes';
        di.ConsultantOrContract__c = 'No';
        update di;

        system.assertNotEquals(di.CollaborationDetails__c, '');
        system.assertNotEquals(di.WorkDoneOutsideMITDetails__c, '');
        system.assertEquals(di.ConsultantOrContractDetails__c, null);

        String jobId = Database.executeBatch(
            new DisclosureInventorSignedToForrester(),
            1
        );
        DisclosureInventorSignedForresterSch.scheduleMe();
        System.Assert(jobId != null);
    }

    @isTest
    public static void onBeforeTest() {
        Test.setMock(HttpCalloutMock.class, new ForresterMock());
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;

        insert dh;

        DisclosureInventor__c di = new DisclosureInventor__c();
        di.Disclosure__c = d.Id;
        di.PrimaryInventor__c = false;
        di.Contact__c = cont.Id;
        di.Signed_Status__c = 'Yes';
        insert di;

        di.WorkDoneOutsideMIT__c = 'Yes';
        di.Collaboration__c = 'Yes';
        di.CollaborationDetails__c = 'Test Forrester';
        di.WorkDoneOutsideMITDetails__c = 'Test Forrester';
        di.SalaryWages__c = 'MIT';
        di.SalaryWagesDetails__c = 'Test';
        di.ThirdPartyMaterials__c = 'test';
        di.CollaborationDetails__c = 'TEST';
        di.WorkDoneAtMIT__c = 'Yes';
        update di;

        DisclosureInventor__c disInv = [
            SELECT Id, SalaryWages__c, SalaryWagesDetails__c
            FROM DisclosureInventor__c
            WHERE Id = :di.Id
        ];
        system.assertEquals(disInv.SalaryWagesDetails__c, null);
    }

    @isTest
    public static void onBeforeQuestionUpdatetoNoTest() {
        Test.setMock(HttpCalloutMock.class, new ForresterMock());
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();
        Account cont = SampleDataFactory.createContact(
            'Donald',
            true,
            '12345678'
        );
        Disclosure__c d = SampleDataFactory.createDisclosure(
            recordTypeIdSoftwareCode,
            'Sample Draft Disclosure for Software Code',
            'Draft',
            cont
        );

        Account cont1 = SampleDataFactory.createContact(
            'Donald1',
            true,
            '12345671'
        );

        List<Disclosure__c> ddList = new List<Disclosure__c>();
        ddList.add(d);

        Department_head__c dh = new Department_Head__c();
        dh.Contact__c = cont1.ID;
        dh.Disclosure__c = d.Id;

        insert dh;

        DisclosureInventor__c di = new DisclosureInventor__c();
        di.Disclosure__c = d.Id;
        di.PrimaryInventor__c = false;
        di.Contact__c = cont.Id;
        di.Signed_Status__c = 'Yes';
        insert di;

        di.WorkDoneOutsideMIT__c = 'Yes';
        di.Collaboration__c = 'Yes';
        di.CollaborationDetails__c = 'Test Forrester';
        di.WorkDoneOutsideMITDetails__c = 'Test Forrester';
        di.SalaryWages__c = 'MIT';
        di.SalaryWagesDetails__c = 'Test';
        di.ThirdPartyMaterials__c = 'test';
        di.CollaborationDetails__c = 'TEST';
        di.WorkDoneAtMIT__c = 'Yes';
        update di;

        DisclosureInventor__c disInv = [
            SELECT Id, SalaryWages__c, SalaryWagesDetails__c
            FROM DisclosureInventor__c
            WHERE Id = :di.Id
        ];
        system.assertEquals(disInv.SalaryWagesDetails__c, null);
        di.ConsultantOrContract__c = 'No';
        di.HHMI_At_Time_of_Invention__c = false;
        update di;

        system.assertNotEquals(di.CollaborationDetails__c, '');
        system.assertNotEquals(di.WorkDoneOutsideMITDetails__c, '');

        system.assertEquals(di.ConsultantOrContractDetails__c, null);

        system.assertEquals(di.ConsultantOrContractDetails__c, null);
        system.assertEquals(di.HHMI_tenure_date_from__c, null);
        system.assertEquals(di.HHMI_tenure_date_to__c, null);
    }

    @IsTest
    public static void testAssignIPIALookup() {
        // Constants
        Id recordTypeIdSoftwareCode = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName().get('Software_Code_Disclosure').getRecordTypeId();

        // IPIA Records
        IPIA_Record__c ipiaRecord1 = new IPIA_Record__c(FormName__c = 'Test 1', MitId__c = '912345781' , SignDatetime__c = Date.today().addDays(-2));
        IPIA_Record__c ipiaRecord2 = new IPIA_Record__c(FormName__c = 'Test 2', MitId__c = '912345781' , SignDatetime__c = Date.today().addDays(-1));
        IPIA_Record__c ipiaRecord3 = new IPIA_Record__c(FormName__c = 'Test 3', MitId__c = '912123654' , SignDatetime__c = Date.today());
        List<IPIA_Record__c> ipiaRecords = new List<IPIA_Record__c>{ipiaRecord1, ipiaRecord2, ipiaRecord3};
        insert ipiaRecords;

        // Contacts
        Account contact1 = SampleDataFactory.createContact('Bob', true, '912345781' );
        Account contact2 = SampleDataFactory.createContact('Donald', true, '912123654' );

        // Disclosure
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(recordTypeIdSoftwareCode, 'Test Inventor Actions on Signing', 'Draft', contact1);

        // Inventors On Disclosure
        DisclosureInventor__c inventor1 = SampleDataFactory.createInventor(disclosure, true, contact1);
        DisclosureInventor__c inventor2 = SampleDataFactory.createInventor(disclosure, true, contact2);
        List<DisclosureInventor__c> disclosureInventors = new List<DisclosureInventor__c>{inventor1, inventor2};

        Test.startTest();
        List<DisclosureInventor__c> result = DisclosureInventorTriggerHandler.assignIPIALookup(disclosureInventors);
        Test.stopTest();

        Integer countDisclosureInventors = 0;
        for (DisclosureInventor__c disclosureInventor : result) {
            if (disclosureInventor.Id == inventor1.Id) {
                Assert.areEqual('912345781' , disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 123456781');
                Assert.areEqual(ipiaRecord2.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 2');
            }
            else if (disclosureInventor.Id == inventor2.Id) {
                Assert.areEqual('912123654' , disclosureInventor.Contact__r.MitId__pc, 'Disclosure Inventor should be linked to IPIA Record with MitId 123654');
                Assert.areEqual(ipiaRecord3.Id, disclosureInventor.IPIA_Record__c, 'Disclosure Inventor should be linked to IPIA Record 3');
            }
            countDisclosureInventors++;
        }
        Assert.areEqual(2, countDisclosureInventors, 'Should have linked 2 Disclosure Inventors to IPIA Records');
    }

    public class ForresterMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().containsignorecase('inventor')) {
                String responsebody = '{"status": "SUCCESS","message": "Success","dataObject":[{}]}';
                HTTPResponse res = new HTTPResponse();
                res.setBody(responsebody);
                res.setStatusCode(201);
                return res;
            }
            return null;
        }
    }
}