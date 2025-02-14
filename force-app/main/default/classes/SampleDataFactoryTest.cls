@isTest
public with sharing class SampleDataFactoryTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
    }

    @isTest
    static void testBioTang_MouseStrain_Creation() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();

        Id recordTypeIdCellLine = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('cellLine')
            .getRecordTypeId();
        Id recordTypeIdAntibody = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('antibody')
            .getRecordTypeId();
        Id recordTypeIdOtherMaterial = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('otherMaterial')
            .getRecordTypeId();
        Id recordTypeIdPlasmid = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('plasmid')
            .getRecordTypeId();
        Id recordTypeIdMouseStrain = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('mouseStrain')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Test.startTest();
        /**
         * BioTang
         */

        // Mouse Strain
        Disclosure__c newMouseStrainBioDisclosureSample = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Mouse Strain Disclosure for BioTang',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newMouseStrainBioDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newMouseStrainBioDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newMouseStrainBioDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newMouseStrainBioDisclosureSample
        );
        BioTang_Disclosure__c newMouseStrainBioSample = SampleDataFactory.createBioTang(
            'Sample Mouse Strain BioTang',
            newMouseStrainBioDisclosureSample,
            recordTypeIdMouseStrain,
            sampleContact1,
            sampleContact2
        );
        SampleDataFactory.createMouseStrain(
            'Mouse Strain Sample',
            newMouseStrainBioSample
        );
        SampleDataFactory.createInventor(
            newMouseStrainBioDisclosureSample,
            true,
            sampleContact1
        );
        SampleDataFactory.createInventor(
            newMouseStrainBioDisclosureSample,
            false,
            sampleContact2
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 6',
            newMouseStrainBioSample
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 7',
            newMouseStrainBioSample
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 8',
            newMouseStrainBioSample
        );

        Test.stopTest();
    }

    @isTest
    static void testBioTang_Antibody_Creation() {
        Id recordTypeIdBioTang = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('BioTang_Disclosure')
            .getRecordTypeId();

        Id recordTypeIdCellLine = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('cellLine')
            .getRecordTypeId();
        Id recordTypeIdAntibody = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('antibody')
            .getRecordTypeId();
        Id recordTypeIdOtherMaterial = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('otherMaterial')
            .getRecordTypeId();
        Id recordTypeIdPlasmid = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('plasmid')
            .getRecordTypeId();
        Id recordTypeIdMouseStrain = Schema.SObjectType.BioTang_Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('mouseStrain')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Test.startTest();
        /**
         * BioTang
         */

        // Antibody
        Disclosure__c newAntibodyBioDisclosureSample = SampleDataFactory.createDisclosure(
            recordTypeIdBioTang,
            'Sample Antibody Disclosure for BioTang',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newAntibodyBioDisclosureSample,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newAntibodyBioDisclosureSample,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newAntibodyBioDisclosureSample,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newAntibodyBioDisclosureSample
        );
        BioTang_Disclosure__c newAntibodyBioSample = SampleDataFactory.createBioTang(
            'Sample Antibody BioTang',
            newAntibodyBioDisclosureSample,
            recordTypeIdAntibody,
            sampleContact1,
            sampleContact2
        );
        SampleDataFactory.createAntibody(
            'Antibody Sample',
            newAntibodyBioSample
        );
        SampleDataFactory.createInventor(
            newAntibodyBioDisclosureSample,
            true,
            sampleContact1
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 9',
            newAntibodyBioSample
        );
        SampleDataFactory.createLabMaterials(
            'Lab Material 10',
            newAntibodyBioSample
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.PUBLICATION_MANUSCRIPTS,
            'Antibody1.docx',
            'docx',
            newAntibodyBioDisclosureSample
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_Antibody.docx',
            'docx',
            newAntibodyBioDisclosureSample
        );

        Test.stopTest();
    }

    @isTest
    static void testInventionCreation() {
        Id recordTypeIdInvention = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );
        Test.startTest();
        /**
         * Invention
         */

        // Draft
        Disclosure__c newDraftInventionDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdInvention,
            'Sample Draft Disclosure for Invention',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newDraftInventionDisclosure,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newDraftInventionDisclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newDraftInventionDisclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(newDraftInventionDisclosure);
        Invention_Disclosure__c inventionDraftSample = SampleDataFactory.createInvention(
            'Invention Disclosure Draft Sample',
            newDraftInventionDisclosure
        );
        SampleDataFactory.createThesis(
            'Thesis Sample for Invention Draft',
            inventionDraftSample
        );
        SampleDataFactory.createThirdPartyMaterial(
            'createThirdPartyMaterial Comments',
            inventionDraftSample
        );
        SampleDataFactory.createInventor(
            newDraftInventionDisclosure,
            true,
            sampleContact1
        );
        List<Thesis__c> thesisList = DisclosureRecordFetch.getThesisDetailsByInventionId(
            inventionDraftSample.Id
        );

        // Inventor Submitted
        Disclosure__c newInventorSubmittedInventionDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdInvention,
            'Sample Draft Disclosure for Invention',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newInventorSubmittedInventionDisclosure,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newInventorSubmittedInventionDisclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newInventorSubmittedInventionDisclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newInventorSubmittedInventionDisclosure
        );
        Invention_Disclosure__c inventionInventorSubmittedSample = SampleDataFactory.createInvention(
            'Invention Disclosure Draft Sample',
            newInventorSubmittedInventionDisclosure
        );
        SampleDataFactory.createThesis(
            'Thesis Sample for Invention Inventor Submitted',
            inventionInventorSubmittedSample
        );
        SampleDataFactory.createInventor(
            newInventorSubmittedInventionDisclosure,
            true,
            sampleContact1
        );

        // Pending Department Approval
        Disclosure__c newPendingDepartmentApprovalInventionDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdInvention,
            'Sample Pending Department Approval Disclosure for Invention',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newPendingDepartmentApprovalInventionDisclosure,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newPendingDepartmentApprovalInventionDisclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newPendingDepartmentApprovalInventionDisclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newPendingDepartmentApprovalInventionDisclosure
        );
        Invention_Disclosure__c inventionPendingDepartmentApprovalSample = SampleDataFactory.createInvention(
            'Invention Disclosure Pending Department Approval Sample',
            newPendingDepartmentApprovalInventionDisclosure
        );
        SampleDataFactory.createThesis(
            'Thesis Sample for Invention Inventor Submitted',
            inventionPendingDepartmentApprovalSample
        );
        SampleDataFactory.createInventor(
            newPendingDepartmentApprovalInventionDisclosure,
            true,
            sampleContact1
        );

        Test.stopTest();
    }

    @isTest
    static void testCopyrightCreation() {
        Id recordTypeIdInvention = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );
        Test.startTest();

        /**
         * Copyright
         */

        Disclosure__c newInventorSubmittedCopyrightDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdCopyright,
            'Sample Inventor Submitted Disclosure for Copyright',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newInventorSubmittedCopyrightDisclosure,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newInventorSubmittedCopyrightDisclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newInventorSubmittedCopyrightDisclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newInventorSubmittedCopyrightDisclosure
        );
        Copyright_Disclosure__c newInventorSubmittedCopy = SampleDataFactory.createCopyright(
            'Sample Inventor Submitted Copyright',
            newInventorSubmittedCopyrightDisclosure,
            piContact
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Copyright',
            newInventorSubmittedCopy,
            null
        );
        SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            newInventorSubmittedCopy
        );
        Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            newInventorSubmittedCopy
        );
        SampleDataFactory.createInventor(
            newInventorSubmittedCopyrightDisclosure,
            true,
            sampleContact1
        );
        SampleDataFactory.createThirdPartyContentDocument(
            ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
            'ThirdPartyContent1.pdf',
            'pdf',
            thirdPartyContent
        );
        List<Open_Source__c> openSourceCopyrightList = DisclosureRecordFetch.getOpenSourceByCopyrightId(
            newInventorSubmittedCopy.Id
        );
        List<Third_Party_Content__c> thirdPartyContentList = DisclosureRecordFetch.getThirdPartyContentByCopyrightId(
            newInventorSubmittedCopy.Id
        );

        Test.stopTest();
    }

    @isTest
    static void testSoftwaverCode_Creation() {
        Id recordTypeIdInvention = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
            .getRecordTypeId();

        Account sampleContact1 = SampleDataFactory.createContact(
            'Peter',
            true,
            '777777777'
        );
        Account sampleContact2 = SampleDataFactory.createContact(
            'John',
            false,
            '12345678'
        );
        Account deptHeadContact = SampleDataFactory.createContact(
            'Traverso',
            true,
            '12345679'
        );
        Account piContact = SampleDataFactory.createContact(
            'Paul',
            true,
            '77777700'
        );

        Test.startTest();

        /**
         * Software Code
         */
        Disclosure__c newInventorSubmittedSoftwareDisclosure = SampleDataFactory.createDisclosure(
            recordTypeIdSoftware,
            'Sample Inventor Submitted Disclosure for Software Code',
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            newInventorSubmittedSoftwareDisclosure,
            deptHeadContact
        );
        SampleDataFactory.createDisclosureExternalFunding(
            newInventorSubmittedSoftwareDisclosure,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            newInventorSubmittedSoftwareDisclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(
            newInventorSubmittedSoftwareDisclosure
        );
        Software_Code_Disclosure__c newInventorSubmittedSoftwareCode = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            newInventorSubmittedSoftwareDisclosure
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            newInventorSubmittedSoftwareCode
        );
        SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            newInventorSubmittedSoftwareCode
        );
        SampleDataFactory.createInventor(
            newInventorSubmittedSoftwareDisclosure,
            true,
            sampleContact1
        );
        SampleDataFactory.createInventor(
            newInventorSubmittedSoftwareDisclosure,
            false,
            sampleContact2
        );

        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_Software.docx',
            'docx',
            newInventorSubmittedSoftwareDisclosure
        );
        SampleDataFactory.updateTechnicalDocument(
            ContentVersionClassification.TECHNICAL_DESCRIPTION,
            'Technical_Description_Software.docx',
            'docx',
            newInventorSubmittedSoftwareDisclosure
        );
        SampleDataFactory.createTechnicalDocument(
            ContentVersionClassification.SOFTWARE_CODE,
            'Open_Source_Software.docx',
            'docx',
            newInventorSubmittedSoftwareDisclosure
        );

        List<Open_Source__c> openSourceList = DisclosureRecordFetch.getOpenSourceBySoftwareCodeId(
            newInventorSubmittedSoftwareCode.Id
        );
        List<Third_Party_Code__c> thirdPartyCodeList = DisclosureRecordFetch.getThirdPartyCodeBySoftwareCodeId(
            newInventorSubmittedSoftwareCode.Id
        );

        Test.stopTest();
    }
}