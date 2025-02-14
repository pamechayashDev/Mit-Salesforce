public class SoftwareDisclosuresSampleFactory {
    public static Disclosure__c createDisclosure(
        String title,
        Boolean includeFiles
    ) {
        // Record type id's
        Id recordTypeIdSoftware = Schema.SObjectType.Disclosure__c.getRecordTypeInfosByDeveloperName()
            .get('Software_Code_Disclosure')
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

        Account sampleNonMitContact = [
            SELECT Id
            FROM Account
            WHERE PersonEmail = 'cr11@guest.test'
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
         * Software Code sample data
         */

        System.debug('Software: Sample');
        Disclosure__c disclosure = SampleDataFactory.createDisclosureSOB(
            recordTypeIdSoftware,
            title,
            'Draft',
            sampleContact1
        );
        SampleDataFactory.createDepartmentHead(
            disclosure,
            departmentHeadContact2
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
        Software_Code_Disclosure__c softwareCodeDisclosure = SampleDataFactory.createSoftwareCode(
            'Sample Inventor Submitted Software Code',
            disclosure
        );
        SampleDataFactory.createOpenSource(
            'Open Source for Inventor Submitted Software Code',
            null,
            softwareCodeDisclosure
        );
        Third_Party_Code__c thirdPartyCode = SampleDataFactory.createThirdPartyCode(
            'Third Party Code',
            softwareCodeDisclosure
        );
        Third_Party_Code__c thirdPartyCode2 = SampleDataFactory.createThirdPartyCode(
            'Third Party Code2',
            softwareCodeDisclosure
        );
        Third_Party_Code__c thirdPartyCode3 = SampleDataFactory.createThirdPartyCode(
            'Third Party Code3',
            softwareCodeDisclosure
        );
        SampleDataFactory.createInventor(disclosure, true, existingContact1);
        SampleDataFactory.createInventor(
            disclosure,
            false,
            sampleNonMitContact
        );

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
        // Department head approval, Can not directly go to Inventor Submitted
        disclosure.Status__c = 'Pending Department Approval';
        update disclosure;

        return disclosure;
    }
}