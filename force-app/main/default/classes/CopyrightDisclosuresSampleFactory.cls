public class CopyrightDisclosuresSampleFactory {
    public static Disclosure__c createDisclosure(
        String title,
        Boolean includeFiles
    ) {
        // Record type id's
        Id recordTypeIdCopyright = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Copyright_Disclosure')
            .getRecordTypeId();

        /**
         * Contact creation to be used throughout
         */
        Account existingContact1 = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '900047497'
        ];

        Account sampleContact1 = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '12345678'
        ];

        Account sampleContact2 = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777777'
        ];

        Account departmentHeadContact2 = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777778'
        ];

        Account piContact = [
            SELECT Id
            FROM Account
            WHERE MitId__pc = '777777700'
        ];
        /**
         * Sample Data
         */

        /**
         * Copyright sample data
         */
        System.debug('Copyright: Sample');
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdCopyright,
            title,
            'Draft',
            sampleContact1
        );

        Department_Head__c firstDeptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            departmentHeadContact2
        );
        Department_Head__c secondDeptHead = SampleDataFactory.createDepartmentHead(
            disclosure,
            sampleContact1
        );
        firstDeptHead.Delegated_To__c = secondDeptHead.Id;
        update firstDeptHead;

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
        Copyright_Disclosure__c copyrightDisclosure = SampleDataFactory.createCopyright(
            'Sample Inventor Submitted Copyright',
            disclosure,
            piContact
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Copyright',
            copyrightDisclosure,
            null
        );
        Third_Party_Content__c thirdPartyContent = SampleDataFactory.createThirdPartyContent(
            'Third Party Content',
            copyrightDisclosure
        );
        Third_Party_Content__c thirdPartyContent2 = SampleDataFactory.createThirdPartyContent(
            'Third Party Content2',
            copyrightDisclosure
        );
        Third_Party_Content__c thirdPartyContent3 = SampleDataFactory.createThirdPartyContent(
            'Third Party Content3',
            copyrightDisclosure
        );
        SampleDataFactory.createInventor(disclosure, true, existingContact1);
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
            SampleDataFactory.createThirdPartyContentDocument(
                ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
                'ThirdPartyContent2.pdf',
                'pdf',
                thirdPartyContent2
            );
            SampleDataFactory.createThirdPartyContentDocument(
                ContentVersionClassification.THIRD_PARTY_AGREEMENTS,
                'ThirdPartyContent3.pdf',
                'pdf',
                thirdPartyContent3
            );
        }
        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        return disclosure;
    }
}