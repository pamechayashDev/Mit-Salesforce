@isTest
public class RecordFetchTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    private static Disclosure__c initDisclosure(String type) {
        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );

        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get(type)
            .getRecordTypeId();
        Disclosure__c testDisclosure = new Disclosure__c(
            Name__c = 'Test Disclosure',
            Status__c = 'Draft',
            RecordTypeId = recordTypeId,
            Submitting_Contact__c = sampleContact.Id
        );
        insert testDisclosure;

        DisclosureInventor__c sampleInventor1 = new DisclosureInventor__c(
            MitAtTimeOfInvention__c = true,
            PrimaryInventor__c = true,
            Signed_Status__c = 'Yes',
            Contact__c = sampleContact.Id,
            Disclosure__c = testDisclosure.Id
        );

        insert sampleInventor1;

        Department_Head__c depHead = new Department_Head__c(
            Disclosure__c = testDisclosure.Id,
            Signed_Date__c = Date.newInstance(2020, 7, 7),
            Contact__c = deptHeadContact.Id
        );
        insert depHead;

        update new Disclosure__c(Id = testDisclosure.Id, Status__c = 'Inventor Submitted');
        return testDisclosure;
    }

    private static Invention_Disclosure__c initInventionDisclosure() {
        Disclosure__c testDisclosure = initDisclosure('Invention_Disclosure');

        Invention_Disclosure__c test = new Invention_Disclosure__c(
            Name = 'Test Invention',
            Disclosure__c = testDisclosure.Id,
            Materials_From_Other_Labs__c = 'Yes',
            materialsFurtherComments__c = 'Testing comment'
        );
        insert test;
        return test;
    }

    private static BioTang_Disclosure__c initBioTang(String bioType) {
        Disclosure__c testDisclosure = initDisclosure('BioTang_Disclosure');
        Id recordTypeBioId = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get(bioType)
            .getRecordTypeId();
        BioTang_Disclosure__c testBio = new BioTang_Disclosure__c(
            Name = 'Test BioTang',
            Disclosure__c = testDisclosure.Id,
            RecordTypeId = recordTypeBioId
        );
        insert testBio;
        return testBio;
    }

    private static Copyright_Disclosure__c initCopyright() {
        Disclosure__c testDisclosure = initDisclosure('Copyright_Disclosure');
        Copyright_Disclosure__c testCopyright = new Copyright_Disclosure__c(
            Name = 'Copyright',
            Creators_Request_Distrib_Open_Source_YN__c = 'No',
            Disclosure__c = testDisclosure.Id,
            Part_Of_Employment_YN__c = 'Yes',
            Incorporate_Third_Party_Content__c = 'Yes',
            Years_Code_First_Created__c = '2022, 2023',
            Years_Code_First_Published__c = '2022, 2023'
        );
        insert testCopyright;
        return testCopyright;
    }

    private static Antibody__c initAntibody() {
        BioTang_Disclosure__c testBio = initBioTang('antibody');
        Antibody__c testAntibody = new Antibody__c(
            Name = 'Test Antibody',
            bioTangDisclosure__c = testBio.Id
        );
        insert testAntibody;
        return testAntibody;
    }

    private static Cell_Line__c initCellLine() {
        BioTang_Disclosure__c testBio = initBioTang('cellLine');
        Cell_Line__c testCell = new Cell_Line__c(
            Name = 'Test Cell Line',
            bioTangDisclosure__c = testBio.Id
        );
        insert testCell;
        return testCell;
    }

    private static Lab_Materials__c initLabMaterials() {
        BioTang_Disclosure__c testBio = initBioTang('otherMaterial');
        Lab_Materials__c testLabMaterials = new Lab_Materials__c(
            Name = 'Test Lab Materials',
            BioTang_Disclosure__c = testBio.Id
        );
        insert testLabMaterials;
        return testLabMaterials;
    }

    private static Commercial_Interest__c initCommercialInterest() {
        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure');
        Commercial_Interest__c testCommercialInterest = new Commercial_Interest__c(
            Disclosure__c = testDisclosure.Id
        );
        insert testCommercialInterest;
        return testCommercialInterest;
    }

    private static Account initContact() {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testContact = new Account(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = personAccountRecordTypeId
        );
        insert testContact;
        return testContact;
    }

    private static TLO_Officer__c initTloOfficer(
        String officerId,
        String name,
        String mitId,
        String email
    ) {
        TLO_Officer__c testContact = new TLO_Officer__c(
            Name = name,
            MitId__c = mitId,
            Forrester_OfficerId__c = officerId,
            Email__c = email
        );
        insert testContact;
        return testContact;
    }

    private static DisclosureInventor__c initDisclosureInventor(
        Disclosure__c disclosure
    ) {
        Account testContact = initContact();
        DisclosureInventor__c testInventor = new DisclosureInventor__c(
            Disclosure__c = disclosure.Id,
            MitAtTimeOfInvention__c = true,
            PrimaryInventor__c = true,
            Signed_Status__c = 'Pending',
            SalaryWages__c = 'MIT',
            SalaryWagesDetails__c = 'SalaryWagesDetails 1',
            WorkDoneAtMIT__c = 'Yes',
            WorkDoneOutsideMIT__c = 'Yes',
            WorkDoneOutsideMITDetails__c = 'WorkDoneOutsideMITDetails 1',
            Collaboration__c = 'Yes',
            CollaborationDetails__c = 'CollaborationDetails 1',
            ConsultantOrContract__c = 'Yes',
            ConsultantOrContractDetails__c = 'ConsultantOrContractDetails 1',
            FundingThroughDlc__c = 'BitsAndAtoms',
            AffiliatedWithOrgsDlcs__c = 'Wyss;Whitehead',
            AdditionalSponsorsOrFunding__c = 'AdditionalSponsorsOrFunding 1',
            PartOfClass__c = 'Yes',
            PartOfClassDetails__c = 'PartOfClassDetails 1',
            ThirdPartyMaterials__c = 'ThirdPartyMaterials 1',
            AdditionalComments__c = 'AdditionalComments 1',
            Contact__c = testContact.Id
        );
        insert testInventor;
        return testInventor;
    }

    private static void createAuditEventDetails(
        String description,
        Id disclosureId,
        String subject,
        Id recordTypeId
    ) {
        Disclosure_Audit_Event__c event = new Disclosure_Audit_Event__c(
            Description__c = description,
            Disclosure__c = disclosureId,
            Event_Date__c = Datetime.now(),
            Subject__c = subject,
            RecordTypeId = recordTypeId
        );

        insert event;
    }

    private static Department_Head__c initDepartmentHead(
        Disclosure__c disclosure,
        Account testContact
    ) {
        Department_Head__c departmentHead = new Department_Head__c(
            Disclosure__c = disclosure.Id,
            Contact__c = testContact.Id,
            Signed_Date__c = Date.newInstance(2022, 9, 11)
        );
        insert departmentHead;
        return departmentHead;
    }

    @isTest
    public static void bioTangTest() {
        System.debug('======bioTangTest======');
        BioTang_Disclosure__c testBioTang = initBioTang('cellLine');
        DisclosureRecordFetch.getBioTangByDisclosureId(
            testBioTang.disclosure__c
        );
    }

    @isTest
    public static void bioTangAntibodyTest() {
        System.debug('======bioTangAntibodyTest======');
        Antibody__c testAntibody = initAntibody();
        // BioTang_Disclosure__c testBioTang = testAntibody.bioTangDisclosure__r;
        // Disclosure__c testDisclosure =
        // DisclosureRecordFetch.getBioTangByDisclosureId(testAntibody.bioTangDisclosure__r.disclosure__c);
        DisclosureRecordFetch.getAntibodyByBioTangId(
            testAntibody.bioTangDisclosure__c
        );
    }

    @isTest
    public static void bioTangLabMaterialsTest() {
        System.debug('======bioTangLabMaterialsTest======');
        Lab_Materials__c testLabMaterials = initLabMaterials();
        DisclosureRecordFetch.getLabMaterialsByBioTangId(
            testLabMaterials.BioTang_Disclosure__c
        );
    }

    @isTest
    public static void bioTangCellLineTest() {
        System.debug('======bioTangCellLineTest======');
        Cell_Line__c testCell = initCellLine();
        // BioTang_Disclosure__c testBioTang = DisclosureRecordFetch.getBioTangByDisclosureId(testCell.bioTangDisclosure__r.disclosure__c)[0];
        // System.assert(testBioTang.Id == testCell.bioTangDisclosure__r.Id);

        DisclosureRecordFetch.getCellLineByBioTangId(
            testCell.bioTangDisclosure__c
        );
    }

    @isTest
    public static void bioTangPlasmidTest() {
        System.debug('======bioTangPlasmidTest======');
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeBioId = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('plasmid')
            .getRecordTypeId();
        Disclosure__c testDisclosure = initDisclosure('BioTang_Disclosure');
        BioTang_Disclosure__c testBio = new BioTang_Disclosure__c(
            Name = 'Test BioTang',
            Disclosure__c = testDisclosure.Id,
            RecordTypeId = recordTypeBioId
        );
        insert testBio;
        Plasmid__c testPlasmid = new Plasmid__c(
            Name = 'Test Plasmid',
            bioTangDisclosure__c = testBio.Id
        );
        insert testPlasmid;
        DisclosureRecordFetch.getPlasmidByBioTangId(testBio.Id);
    }

    @isTest
    public static void bioTangOtherMaterialsTest() {
        System.debug('======bioTangOtherMaterialsTest======');
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeBioId = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('otherMaterial')
            .getRecordTypeId();
        Disclosure__c testDisclosure = initDisclosure('BioTang_Disclosure');
        BioTang_Disclosure__c testBio = new BioTang_Disclosure__c(
            Name = 'Test BioTang',
            Disclosure__c = testDisclosure.Id,
            RecordTypeId = recordTypeBioId
        );
        insert testBio;
        Other_Material__c testOtherMaterial = new Other_Material__c(
            Name = 'Test Other Material',
            bioTangDisclosure__c = testBio.Id
        );
        insert testOtherMaterial;
        DisclosureRecordFetch.getOtherMaterialByBioTangId(testBio.Id);
    }

    @isTest
    public static void bioTangMouseStrainTest() {
        System.debug('======bioTangMouseStrainTest======');
        Id recordTypeId = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();
        Id recordTypeBioId = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('mouseStrain')
            .getRecordTypeId();
        Disclosure__c testDisclosure = initDisclosure('BioTang_Disclosure');
        BioTang_Disclosure__c testBio = new BioTang_Disclosure__c(
            Name = 'Test BioTang',
            Disclosure__c = testDisclosure.Id,
            RecordTypeId = recordTypeBioId
        );
        insert testBio;
        Mouse_Strain__c mouseStrain = new Mouse_Strain__c(
            Name = 'Test Mouse Strain',
            bioTangDisclosure__c = testBio.Id
        );
        insert mouseStrain;
        DisclosureRecordFetch.getMouseStrainByBioTangId(testBio.Id);
    }

    @isTest
    public static void copyrightMasterDetailTest() {
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();

        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );
        Disclosure__c newInventorSubmittedCopyrightDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdCopyright,
            'Sample Inventor Submitted Disclosure for Copyright',
            'Draft',
            sampleContact
        );
        Copyright_Disclosure__c newInventorSubmittedCopy = SampleDataFactory.createCopyright(
            'Sample Inventor Submitted Copyright',
            newInventorSubmittedCopyrightDisclosure,
            piContact
        );
        SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            newInventorSubmittedCopy
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Copyright',
            newInventorSubmittedCopy,
            null
        );
        List<Open_Source__c> openSourceCopyrightList = DisclosureRecordFetch.getOpenSourceByCopyrightId(
            newInventorSubmittedCopy.Id
        );
        List<Third_Party_Content__c> thirdPartyContentList = DisclosureRecordFetch.getThirdPartyContentByCopyrightId(
            newInventorSubmittedCopy.Id
        );

        System.assert(
            openSourceCopyrightList.size() == 1,
            'OpenSource List should not be empty'
        );
        System.assert(
            thirdPartyContentList.size() == 1,
            'ThirdParty List should not be empty'
        );
    }

    @isTest
    public static void softwareCodeMasterDetailTest() {
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account sampleContact = SampleDataFactory.createContact(
            'Donald',
            true,
            '777777777'
        );
        Disclosure__c newInventorSubmittedSoftwareDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftware,
            'Sample Inventor Submitted Disclosure for Software Code',
            'Draft',
            sampleContact
        );
        Software_Code_Disclosure__c newInventorSubmittedSoftwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            newInventorSubmittedSoftwareDisclosure
        );
        Third_Party_Code__c thirdPartyCode = SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            newInventorSubmittedSoftwareCode
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            newInventorSubmittedSoftwareCode
        );

        List<Open_Source__c> openSourceList = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
            newInventorSubmittedSoftwareCode.Id
        );
        List<Third_Party_Code__c> thirdPartyCodeList = DisclosureRecordFetch.getThirdPartyCodeBySoftwareCodeId(
            newInventorSubmittedSoftwareCode.Id
        );

        System.assert(
            openSourceList.size() == 1,
            'OpenSource List should not be empty'
        );
        System.assert(
            thirdPartyCodeList.size() == 1,
            'ThirdParty List should not be empty'
        );

        SampleDataFactory.createThirdPartyCodeDocument(
            ContentVersionClassification.THIRD_PARTY_CODE,
            'ThirdPartyCode1.pdf',
            'pdf',
            thirdPartyCode
        );

        List<ContentDocumentLink> result = DisclosureRecordFetch.getThirdPartyCodeFilesByDisclosureId(
            newInventorSubmittedSoftwareDisclosure.Id
        );
        System.assert(result.size() == 1);
    }

    @isTest
    public static void commercialInterestTest() { 
        System.debug('======commercialInterestTest======');
        Commercial_Interest__c testCommercialInterest = initCommercialInterest();
        DisclosureRecordFetch.getCommercialInterestsByDisclosureId(
            testCommercialInterest.Disclosure__c
        );
    }

    @isTest
    public static void disclosureInventorTest() {
        System.debug('======disclosureInventorTest======');
        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure');
        DisclosureInventor__c testInventor = initDisclosureInventor(
            testDisclosure
        );
        List<DisclosureInventor__c> result = DisclosureRecordFetch.getDisclosureInventorByDisclosureId(
            testInventor.Disclosure__c
        );

        for (DisclosureInventor__c inventor : result) {
            if (inventor.Id == testInventor.Id) {
                System.assert(
                    inventor.SalaryWages__c == testInventor.SalaryWages__c,
                    'Salary Wages'
                );
            }
        }
    }

    @isTest
    public static void disclosuresByExternalIdTest() {
        System.debug('======disclosuresByExternalIdTest======');
        Disclosure__c disclosure = initDisclosure('BioTang_Disclosure');
        Disclosure__c relatedObject = [
            SELECT Id, External_ID__c
            FROM Disclosure__c
            WHERE Id = :disclosure.Id
        ];
        Set<String> externalIds = new Set<String>();
        externalIds.add(relatedObject.External_ID__c);
        List<Disclosure__c> disclosures = DisclosureRecordFetch.getDisclosuresByExternalId(
            externalIds
        );
        System.assert(
            disclosures.size() > 0,
            'Expecting Disclosures by External Ids'
        );
    }

    @isTest
    public static void disclosureInventorAffiliatedPicklist() {
        Map<String, String> mapLookup = DisclosureRecordFetch.getDisclosureInventorAffiliatedPicklist();
        System.assert(
            mapLookup.get('Wyss') == 'Wyss Institute',
            'Label not found'
        );
    }

    @isTest
    public static void disclosureInventorFundingDlcPicklist() {
        Map<String, String> mapLookup = DisclosureRecordFetch.getDisclosureInventorFundingDlcPicklist();
        System.assert(
            mapLookup.get('MediaLab') == 'Media Lab',
            'Label not found'
        );
    }

    @isTest
    public static void antibodyApplicationsPicklist() {
        Map<String, String> mapLookup = DisclosureRecordFetch.getAntibodyApplicationsPicklist();

        System.assert(!mapLookup.isEmpty(), 'The result should not be empty');
        System.assert(mapLookup.get('ELISA') == 'ELISA', 'Label does exist');
    }

    @isTest
    public static void getDisclosureReasonPicklist() {
        Map<String, String> mapLookup = DisclosureRecordFetch.getDisclosureReasonPicklist();

        System.assert(!mapLookup.isEmpty(), 'The result should not be empty');
        System.assert(
            mapLookup.get('PartnerOrColleagueSuggestion') ==
            'A partner in development/colleague suggested I should',
            'Label does exist'
        );
    }

    @isTest
    public static void getInventionTypePicklist() {
        Map<String, String> mapLookup = DisclosureRecordFetch.getInventionDisclosureTypeOfPresentationPicklist();

        System.assert(!mapLookup.isEmpty(), 'The result should not be empty');
        System.assert(
            mapLookup.get('Electronic Disclosure') == 'Electronic Disclosure',
            'Label does exist'
        );
    }

    @isTest
    public static void contactTest() {
        Account testContact = initContact();
        DisclosureRecordFetch.getContactById(testContact.Id);
    }

    @isTest
    public static void tloOfficerTest() {
        TLO_Officer__c testContact = initTloOfficer(
            'JOE',
            'Joe',
            '123456789',
            'tlo-tech@mit.edu'
        );
        // TLO License Officer could share email address
        TLO_Officer__c duplicateEmailContact = initTloOfficer(
            'ELI',
            'Elise',
            '123456788',
            'tlo-tech@mit.edu'
        );

        DisclosureRecordFetch.getTLOOfficerById(testContact.Id);
        List<String> ids = new List<String>();
        ids.add(testContact.Id);
        List<TLO_Officer__c> entries = DisclosureRecordFetch.getTLOOfficersByIds(
            ids
        );
        System.assert(!entries.isEmpty(), 'TLO Officer By Ids failed');
        System.assert(
            entries.size() == ids.size(),
            'Ids size need to match result size'
        );

        Set<String> mitIds = new Set<String>();
        mitIds.add(testContact.MitId__c);
        entries = DisclosureRecordFetch.getTLOOfficersByMitIds(mitIds);
        System.assert(!entries.isEmpty(), 'TLO Officer By MitIds failed');
        System.assert(
            entries.size() == mitIds.size(),
            'MitIds size need to match result size'
        );

        Set<String> officerIds = new Set<String>();
        officerIds.add(testContact.Forrester_OfficerId__c);
        entries = DisclosureRecordFetch.getTLOOfficersByForresterIds(
            officerIds
        );
        System.assert(!entries.isEmpty(), 'TLO Officer By MitIds failed');
        System.assert(
            entries.size() == officerIds.size(),
            'Forrester OfficerIds size need to match result size'
        );
    }

    @isTest
    public static void departmentHeadTest() {
        System.debug('======departmentHeadTest======');
        Disclosure__c testDisclosure = initDisclosure('Software_Code_Disclosure');
        System.assert(
            testDisclosure.Status__c != null &&
            testDisclosure.Status__c == 'Draft',
            'Only Draft Disclosures can be edited. Expecting Draft Status ' +
            testDisclosure.Status__c
        );
        Account testContact = initContact();
        Department_Head__c departmentHead = initDepartmentHead(
            testDisclosure,
            testContact
        );
        List<Department_Head__c> result = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            testDisclosure.Id
        );
        // System.assert(result[0].Id == departmentHead.Id , 'Unable to find DepartmentHead');
    }

    @isTest
    public static void auditEventCoverage() {
        System.debug('======auditEventCoverage======');
        Disclosure__c testDisclosure = initDisclosure('Copyright_Disclosure');
        Copyright_Disclosure__c sampleCopyright = new Copyright_Disclosure__c(
            Name = 'Test',
            Creators_Request_Distrib_Open_Source_YN__c = 'Yes',
            Disclosure__c = testDisclosure.Id,
            Incorporate_Third_Party_Content__c = 'No',
            Part_Of_Employment_YN__c = 'Yes',
            Years_Code_First_Created__c = '2022, 2023',
            Years_Code_First_Published__c = '2022, 2023'
        );
        Id recordTypeIdAuditEventApproval = Schema.SObjectType.Disclosure_Audit_Event__c.getRecordTypeInfosByDeveloperName()
            .get('Approval')
            .getRecordTypeId();

        createAuditEventDetails(
            '<a href=\"/r/0058N000000tfpIQAQ\" target=\"_blank\">User User</a> Approved the Disclosure',
            testDisclosure.Id,
            'Approval',
            recordTypeIdAuditEventApproval
        );

        List<Disclosure_Audit_Event__c> auditEvents = DisclosureRecordFetch.getDisclosureAuditEventsByDisclosureId(
            testDisclosure.Id
        );
        List<Copyright_Disclosure__c> copyright = DisclosureRecordFetch.getCopyrightByDisclosureId(
            testDisclosure.Id
        );
        Disclosure__c disclosure = DisclosureRecordFetch.getDisclosureById(
            testDisclosure.Id
        );
        List<Invention_Disclosure__c> invention = DisclosureRecordFetch.getInventionByDisclosureId(
            disclosure.Id
        );
    }

    @isTest
    public static void inventionThirdPartyMaterialTest() {
        System.runAs(SampleDataTest.getJitUser()) {
            Invention_Disclosure__c inventionDraftSample = initInventionDisclosure();
            SampleDataFactory.createThirdPartyMaterial(
                'createThirdPartyMaterial Comments',
                inventionDraftSample
            );
            List<Third_Party_Material__c> materials = DisclosureRecordFetch.getThirdPartyMaterialByInventionId(
                inventionDraftSample.Id
            );
            System.assert(materials.size() == 1);
        }
    }

    @isTest
    public static void contentVersionLDocumentTest() {
        System.debug('======contentVersionLDocumentTest======');
        BioTang_Disclosure__c testBio = initBioTang('antibody');
        Disclosure__c disclosure = DisclosureRecordFetch.getDisclosureById(
            testBio.Disclosure__c
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang2.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.updateTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang.docx',
            'docx',
            disclosure
        );

        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.PUBLICATION_MANUSCRIPTS,
            'Publication_BioTang1.docx',
            'docx',
            disclosure
        );

        List<ContentDocumentLink> result = DisclosureRecordFetch.getFilesByTypeAndClassification(
            disclosure.Id,
            'Disclosure',
            ContentVersionClassification.TECHNICAL_DESCRIPTION
        );
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink documentLink : result) {
            contentDocumentIds.add(documentLink.ContentDocumentId);
        }
        List<ContentVersion> contentVersionResult = DisclosureRecordFetch.getFileContentVersionsByDocumentIds(
            contentDocumentIds
        );
        for (ContentVersion contentVersion : contentVersionResult) {
            System.assert(contentVersion.Title != null);
        }
        System.assert(result.size() == 2);
    }

    @isTest
    public static void contentVersionLAllDocumentTest() {
        System.debug('======contentVersionLAllDocumentTest======');
        BioTang_Disclosure__c testBio = initBioTang('antibody');
        Disclosure__c disclosure = DisclosureRecordFetch.getDisclosureById(
            testBio.Disclosure__c
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang2.docx',
            'docx',
            disclosure
        );
        SampleDataFactory.updateTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_BioTang.docx',
            'docx',
            disclosure
        );

        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.PUBLICATION_MANUSCRIPTS,
            'Publication_BioTang1.docx',
            'docx',
            disclosure
        );

        List<ContentDocumentLink> result = DisclosureRecordFetch.getFilesByType(
            disclosure.Id,
            'Disclosure'
        );

        System.assert(result.size() == 3);
    }

    @isTest
    public static void contentVersionLMasterDetailDocumentTest() {
        System.debug('======contentVersionLMasterDetailDocumentTest======');
        Copyright_Disclosure__c testCopyright = initCopyright();
        Disclosure__c disclosure = DisclosureRecordFetch.getDisclosureById(
            testCopyright.Disclosure__c
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_Copyright.docx',
            'docx',
            disclosure
        );

        Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            testCopyright
        );
        SampleDataFactory.createThirdPartyContentDocument(
            ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
            'ThirdPartyContent1.pdf',
            'pdf',
            thirdPartyContent
        );

        Third_Party_Content__c thirdPartyContent2 = SampleDataFactory.createThirdPartyContent(
            'Third Party Content2',
            testCopyright
        );
        SampleDataFactory.createThirdPartyContentDocument(
            ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
            'ThirdPartyContent2.pdf',
            'pdf',
            thirdPartyContent2
        );

        List<ContentDocumentLink> result = DisclosureRecordFetch.getThirdPartyContentFilesByDisclosureId(
            disclosure.Id
        );
        System.assert(result.size() == 2);

        List<Id> linkedEntityIds = new List<Id>();
        linkedEntityIds.add(thirdPartyContent.Id);
        linkedEntityIds.add(thirdPartyContent2.Id);
        List<ContentDocumentLink> resultEntityIds = DisclosureRecordFetch.getFilesByIdsAndType(
            linkedEntityIds,
            'Disclosure'
        );
        System.assert(resultEntityIds.size() == 2);
    }
}