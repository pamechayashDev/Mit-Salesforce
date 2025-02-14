//@isTest
public with sharing class DisclosureSampleDataFactory {
    public static void submitForDeptHeadEndorsement(Disclosure__c disclosure) {
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;
    }

    public static void archiveDisclosure(Disclosure__c disclosure) {
        disclosure.Status__c = 'Archived';
        update disclosure;
    }

    public static void sysAdminMoveBackToDraftDisclosure(
        Disclosure__c disclosure
    ) {
        disclosure.Status__c = 'Draft';
        update disclosure;
    }

    public static void deptHeadEndorsesDisclosure(
        Disclosure__c disclosure,
        String comment
    ) {
        System.debug('**** Dept Head Endorse ****');
        disclosure.Status__c = 'Inventor Submitted';
        if (comment != null && comment != '') {
            Department_Head__c deptHead = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
                disclosure.Id
            )[0];
            System.debug(deptHead);
            deptHead.Comment__c = comment;
            System.debug(deptHead);
            update deptHead;
        }
        update disclosure;
    }

    public static void deptHeadRejectsDisclosure(
        Disclosure__c disclosure,
        String rejectionReason
    ) {
        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = rejectionReason;
        disclosure.Rejected_By__c = 'Department Head';
        update disclosure;
    }

    public static void tloRejectsDisclosure(
        Disclosure__c disclosure,
        String rejectionReason
    ) {
        disclosure.Status__c = 'Rejected';
        disclosure.Rejection_Reason__c = rejectionReason;
        disclosure.Rejected_By__c = 'TLO Admin';
        update disclosure;
    }

    public static void tloApprovesDisclosure(Disclosure__c disclosure) {
        if (disclosure.Status__c == 'Draft') {
            disclosure.Status__c = 'Pending Department Approval';
            update disclosure;

            disclosure.Status__c = 'Inventor Submitted';
            update disclosure;
        }

        disclosure.Status__c = 'Approved';
        update disclosure;
    }

    // TODO
    public static void submittingInventorToSignDisclosure(
        Disclosure__c disclosure
    ) {
        // disclosure.Status__c = 'Pending Department Approval';
        // update disclosure;
    }

    public static void deptHeadDelegateDisclosure(
        Disclosure__c disclosure,
        Department_Head__c secondDeptHead,
        String comment
    ) {
        List<Department_Head__c> deptHeads = DisclosureRecordFetch.getDepartmentHeadByDisclosureId(
            disclosure.Id
        );
        Department_Head__c currDeptHead = deptHeads[0];

        currDeptHead.Delegated_To__c = secondDeptHead.Id;
        currDeptHead.Comment__c = (comment == null ? '' : comment);
        update currDeptHead;
    }

    public static Disclosure__c createCopyrightDisclosureWithDeptHeadAsInventor(
        String title,
        Boolean includeFiles
    ) {
        Account submittedBy = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '12345678'
        ];
        Account piContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        Account departmentHead = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777778'
        ];
        Account inventor1 = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '900047497'
        ];
        //Account sampleContact2 = [ SELECT Id FROM Account WHERE MitId__pc = '777777777' ];

        System.debug('Copyright: Sample');
        // main disclosure for copyright type
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            RecordTypeIdUtility.DISCLOSURE_COPYRIGHT,
            title,
            'Draft',
            submittedBy
        );
        Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
            title,
            disclosure,
            piContact
        );

        // dept head
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Copyright',
            copyrightDisclosure,
            null
        );
        Department_Head__c firstDeptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            departmentHead
        );

        // other data for copyright
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            'OPP1201537',
            '6945744',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            copyrightDisclosure
        );

        // inventors
        SampleDataFactory.createInventor(disclosure, true, submittedBy); // submitting for yourself (as inventor) Submitted Person MUST be one of the inventors
        SampleDataFactory.createInventor(disclosure, true, inventor1);

        if (includeFiles) {
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Copyright.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.createThirdPartyContentDocument(
                ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
                'ThirdPartyContent1.pdf',
                'pdf',
                thirdPartyContent
            );
        }

        return disclosure;
    }

    public static Disclosure__c createDraftSoftwareDisclosureNoDeptHead(
        String title,
        Boolean includeFiles
    ) {
        Account submittingContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '12345678'
        ];
        Account piContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        Account nonMitInventor = [
            SELECT Id
            FROM Account
            WHERE PersonEmail = 'cr11@guest.test'
        ];
        Account mitInventor = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '900047497'
        ];

        System.debug('Software: Sample');
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            RecordTypeIdUtility.DISCLOSURE_SOFTWARE,
            title,
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            disclosure
        );

        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            'OPP1201537',
            '6945744',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        Third_Party_Code__c thirdPartyCode = SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );

        SampleDataFactory.createInventor(disclosure, true, submittingContact);
        SampleDataFactory.createInventor(disclosure, true, mitInventor);
        SampleDataFactory.createInventor(disclosure, false, nonMitInventor);

        if (includeFiles) {
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.updateTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software.pdf',
                'pdf',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software2.txt',
                'txt',
                disclosure
            );
            SampleDataFactory.createThirdPartyCodeDocument(
                ContentVersionClassification.THIRD_PARTY_CODE,
                'ThirdPartyCode1.pdf',
                'pdf',
                thirdPartyCode
            );
        }

        update disclosure;

        return disclosure;
    }

    public static Disclosure__c createApprovedSOBInventionDisclosure(
        String title
    ) {
        Id recordTypeIdInvention = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Invention_Disclosure')
            .getRecordTypeId();

        Account submittingContact1 = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '700000001'
        ];
        Account inventorContact2 = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '900047497'
        ];
        Account piContact = [
            SELECT Id, Name
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        TLO_Officer__c tloOfficer = [
            SELECT Id, Name
            FROM TLO_Officer__c
            WHERE MitId__c = '777773000'
        ];

        Disclosure__c disclosureSOB = SampleDataFactory.createDisclosureSOB(
            recordTypeIdInvention,
            title,
            'Draft',
            submittingContact1
        );
        SampleDataFactory.createDisclosureExternalFunding(
            disclosureSOB,
            '12345',
            '6789',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosureSOB,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosureSOB);
        Invention_Disclosure__c inventionApprovedSample = SampleDataFactory.createInvention(
            'Invention Disclosure Draft Sample',
            disclosureSOB
        );
        SampleDataFactory.createThesis(
            'Thesis Sample for Invention Inventor Submitted',
            inventionApprovedSample
        );
        SampleDataFactory.createThirdPartyMaterial(
            'create third party material comments',
            inventionApprovedSample
        );
        SampleDataFactory.createInventor(disclosureSOB, true, inventorContact2);
        disclosureSOB.Status__c = 'Inventor Submitted';
        update disclosureSOB;
        disclosureSOB.Status__c = 'Approved';
        disclosureSOB.Case_Number__c = '12345J';
        disclosureSOB.TLO_License_Officer__c = tloOfficer.Id;
        update disclosureSOB;
        return disclosureSOB;
    }

    public static Disclosure__c createDraftSoftwareDisclosureFullyPopulated(
        String title,
        Boolean includeFiles
    ) {
        Account submittingContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '12345678'
        ];
        Account piContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        Account departmentHead = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777778'
        ];
        Account nonMitInventor = [
            SELECT Id
            FROM Account
            WHERE PersonEmail = 'cr11@guest.test'
        ];
        Account mitInventor = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '900047497'
        ];

        System.debug('Software: Sample');
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            RecordTypeIdUtility.DISCLOSURE_SOFTWARE,
            title,
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            disclosure
        );

        SampleDataFactory.createDepartmentHead(disclosure, departmentHead);
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            'OPP1201537',
            '6945744',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        Third_Party_Code__c thirdPartyCode = SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );

        SampleDataFactory.createInventor(disclosure, true, submittingContact);
        SampleDataFactory.createInventor(disclosure, true, mitInventor);
        SampleDataFactory.createInventor(disclosure, false, nonMitInventor);

        if (includeFiles) {
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.updateTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software.pdf',
                'pdf',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software2.txt',
                'txt',
                disclosure
            );
            SampleDataFactory.createThirdPartyCodeDocument(
                ContentVersionClassification.THIRD_PARTY_CODE,
                'ThirdPartyCode1.pdf',
                'pdf',
                thirdPartyCode
            );
        }

        update disclosure;

        return disclosure;
    }

    public static Disclosure__c createDraftSoftwareDisclosurePrimaryInventorOnly(
        String title,
        Boolean includeFiles
    ) {
        Account submittingContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '12345678'
        ];
        Account piContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        Account departmentHead = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777778'
        ];

        System.debug('Software: Sample');
        Disclosure__c disclosure = SampleDataFactory.createDisclosure(
            RecordTypeIdUtility.DISCLOSURE_SOFTWARE,
            title,
            'Draft',
            submittingContact
        );
        Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            disclosure
        );

        SampleDataFactory.createDepartmentHead(disclosure, departmentHead);
        SampleDataFactory.createDisclosureExternalFunding(
            disclosure,
            'OPP1201537',
            '6945744',
            piContact,
            'External Sponsor 1'
        );
        SampleDataFactory.createDisclosureInternalFunding(
            disclosure,
            'Yes',
            '12345678',
            'Internal Funding 1'
        );
        SampleDataFactory.createCommercialInterest(disclosure);
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        Third_Party_Code__c thirdPartyCode = SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );

        SampleDataFactory.createInventor(disclosure, true, submittingContact);

        if (includeFiles) {
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.updateTechnicalDocument(
                ContentVersionClassification.TECHNICAL_DESCRIPTION,
                'Technical_Description_Software.docx',
                'docx',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software.pdf',
                'pdf',
                disclosure
            );
            SampleDataFactory.createTechnicalDocument(
                ContentVersionClassification.SOFTWARE_CODE,
                'Open_Source_Software2.txt',
                'txt',
                disclosure
            );
            SampleDataFactory.createThirdPartyCodeDocument(
                ContentVersionClassification.THIRD_PARTY_CODE,
                'ThirdPartyCode1.pdf',
                'pdf',
                thirdPartyCode
            );
        }

        update disclosure;

        return disclosure;
    }
}