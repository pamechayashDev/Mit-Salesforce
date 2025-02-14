@isTest
private class IEdisonInventionResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = inventionResponse1;
        IEdisonInventionResponse inventionResponse3 = new IEdisonInventionResponse();
        IEdisonInventionResponse inventionResponse4 = inventionResponse3;

        System.assert(inventionResponse1.equals(inventionResponse2));
        System.assert(inventionResponse2.equals(inventionResponse1));
        System.assert(inventionResponse1.equals(inventionResponse1));
        System.assert(inventionResponse3.equals(inventionResponse4));
        System.assert(inventionResponse4.equals(inventionResponse3));
        System.assert(inventionResponse3.equals(inventionResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse3 = new IEdisonInventionResponse();
        IEdisonInventionResponse inventionResponse4 = new IEdisonInventionResponse();

        System.assert(inventionResponse1.equals(inventionResponse2));
        System.assert(inventionResponse2.equals(inventionResponse1));
        System.assert(inventionResponse3.equals(inventionResponse4));
        System.assert(inventionResponse4.equals(inventionResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = new IEdisonInventionResponse();

        System.assertEquals(false, inventionResponse1.equals('foo'));
        System.assertEquals(false, inventionResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = new IEdisonInventionResponse();
        IEdisonInventionResponse inventionResponse3;

        System.assertEquals(false, inventionResponse1.equals(inventionResponse3));
        System.assertEquals(false, inventionResponse2.equals(inventionResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = new IEdisonInventionResponse();

        System.assertEquals(inventionResponse1.hashCode(), inventionResponse1.hashCode());
        System.assertEquals(inventionResponse2.hashCode(), inventionResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventionResponse inventionResponse1 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse2 = IEdisonInventionResponse.getExample();
        IEdisonInventionResponse inventionResponse3 = new IEdisonInventionResponse();
        IEdisonInventionResponse inventionResponse4 = new IEdisonInventionResponse();

        System.assert(inventionResponse1.equals(inventionResponse2));
        System.assert(inventionResponse3.equals(inventionResponse4));
        System.assertEquals(inventionResponse1.hashCode(), inventionResponse2.hashCode());
        System.assertEquals(inventionResponse3.hashCode(), inventionResponse4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonInventionResponse inventionResponse = new IEdisonInventionResponse();
        System.assertEquals(new List<String>(), inventionResponse.institutionCodeForOtherInstitutions);
        System.assertEquals(new List<String>(), inventionResponse.keywords);
        System.assertEquals(new List<IEdisonInventor>(), inventionResponse.inventors);
        System.assertEquals(new List<IEdisonFundingAgreement>(), inventionResponse.fundingAgreements);
        System.assertEquals(new List<IEdisonSubContractInfo>(), inventionResponse.subContractInfos);
        System.assertEquals(new List<IEdisonNote>(), inventionResponse.explanatoryNotes);
        System.assertEquals(new List<IEdisonNote>(), inventionResponse.governmentNotes);
        System.assertEquals(new List<String>(), inventionResponse.budgetIdentifiers);
        System.assertEquals(new List<String>(), inventionResponse.disclosureDocumentRejectReasons);
        System.assertEquals(null, inventionResponse.id);
        System.assertEquals(null, inventionResponse.inventionReportNumber);
        System.assertEquals(null, inventionResponse.granteeOrganizationName);
        System.assertEquals(null, inventionResponse.institutionCode);
        System.assertEquals(null, inventionResponse.dunsNumber);
        System.assertEquals(null, inventionResponse.inventionTitle);
        System.assertEquals(null, inventionResponse.inventionDocketNumber);
        System.assertEquals(null, inventionResponse.doesNumber);
        System.assertEquals(null, inventionResponse.parentInventionNumber);
        System.assertEquals(null, inventionResponse.inventionReportDate);
        System.assertEquals(null, inventionResponse.inventionSubmitDate);
        System.assertEquals(null, inventionResponse.reportingOverdue);
        System.assertEquals(null, inventionResponse.firstPublicationDate);
        System.assertEquals(null, inventionResponse.domesticManufactureWaiver);
        System.assertEquals(null, inventionResponse.doeWaiver);
        System.assertEquals(null, inventionResponse.isExceptionCircumstanceDetermination);
        System.assertEquals(null, inventionResponse.primaryAgency);
        System.assertEquals(null, inventionResponse.inventionStatus);
        System.assertEquals(null, inventionResponse.agencyCustom1);
        System.assertEquals(null, inventionResponse.agencyCustom2);
        System.assertEquals(null, inventionResponse.agencyCustom3);
        System.assertEquals(null, inventionResponse.governmentStaff);
        System.assertEquals(null, inventionResponse.governmentCounsel);
        System.assertEquals(null, inventionResponse.disclosureDocumentAcceptDate);
        System.assertEquals(null, inventionResponse.disclosureDocumentRejectDate);
        System.assertEquals(null, inventionResponse.createdDate);
        System.assertEquals(null, inventionResponse.lastUpdatedDate);
    }
}