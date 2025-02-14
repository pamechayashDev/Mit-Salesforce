@isTest
private class IEdisonUtilizationSearchRequestTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = utilizationSearchRequest1;
        IEdisonUtilizationSearchRequest utilizationSearchRequest3 = new IEdisonUtilizationSearchRequest();
        IEdisonUtilizationSearchRequest utilizationSearchRequest4 = utilizationSearchRequest3;

        System.assert(utilizationSearchRequest1.equals(utilizationSearchRequest2));
        System.assert(utilizationSearchRequest2.equals(utilizationSearchRequest1));
        System.assert(utilizationSearchRequest1.equals(utilizationSearchRequest1));
        System.assert(utilizationSearchRequest3.equals(utilizationSearchRequest4));
        System.assert(utilizationSearchRequest4.equals(utilizationSearchRequest3));
        System.assert(utilizationSearchRequest3.equals(utilizationSearchRequest3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest3 = new IEdisonUtilizationSearchRequest();
        IEdisonUtilizationSearchRequest utilizationSearchRequest4 = new IEdisonUtilizationSearchRequest();

        System.assert(utilizationSearchRequest1.equals(utilizationSearchRequest2));
        System.assert(utilizationSearchRequest2.equals(utilizationSearchRequest1));
        System.assert(utilizationSearchRequest3.equals(utilizationSearchRequest4));
        System.assert(utilizationSearchRequest4.equals(utilizationSearchRequest3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = new IEdisonUtilizationSearchRequest();

        System.assertEquals(false, utilizationSearchRequest1.equals('foo'));
        System.assertEquals(false, utilizationSearchRequest2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = new IEdisonUtilizationSearchRequest();
        IEdisonUtilizationSearchRequest utilizationSearchRequest3;

        System.assertEquals(false, utilizationSearchRequest1.equals(utilizationSearchRequest3));
        System.assertEquals(false, utilizationSearchRequest2.equals(utilizationSearchRequest3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = new IEdisonUtilizationSearchRequest();

        System.assertEquals(utilizationSearchRequest1.hashCode(), utilizationSearchRequest1.hashCode());
        System.assertEquals(utilizationSearchRequest2.hashCode(), utilizationSearchRequest2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest1 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest2 = IEdisonUtilizationSearchRequest.getExample();
        IEdisonUtilizationSearchRequest utilizationSearchRequest3 = new IEdisonUtilizationSearchRequest();
        IEdisonUtilizationSearchRequest utilizationSearchRequest4 = new IEdisonUtilizationSearchRequest();

        System.assert(utilizationSearchRequest1.equals(utilizationSearchRequest2));
        System.assert(utilizationSearchRequest3.equals(utilizationSearchRequest4));
        System.assertEquals(utilizationSearchRequest1.hashCode(), utilizationSearchRequest2.hashCode());
        System.assertEquals(utilizationSearchRequest3.hashCode(), utilizationSearchRequest4.hashCode());
    }

    @isTest
    private static void maintainRenamedProperties() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest = new IEdisonUtilizationSearchRequest();
        Map<String, String> x_property_mappings = utilizationSearchRequest.getPropertyMappings();
        System.assertEquals('r_limit', x_property_mappings.get('limit'));
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonUtilizationSearchRequest utilizationSearchRequest = new IEdisonUtilizationSearchRequest();
        System.assertEquals(new List<String>(), utilizationSearchRequest.titleElectionStatus);
        System.assertEquals(null, utilizationSearchRequest.r_limit);
        System.assertEquals(null, utilizationSearchRequest.offset);
        System.assertEquals(null, utilizationSearchRequest.inventionReportNumber);
        System.assertEquals(null, utilizationSearchRequest.inventionDocketNumber);
        System.assertEquals(null, utilizationSearchRequest.grantContractNumber);
        System.assertEquals(null, utilizationSearchRequest.latestStageDev);
        System.assertEquals(null, utilizationSearchRequest.primaryAgency);
        System.assertEquals(null, utilizationSearchRequest.granteeOrganizationName);
        System.assertEquals(null, utilizationSearchRequest.inventionTitle);
        System.assertEquals(null, utilizationSearchRequest.inventionReportDateFrom);
        System.assertEquals(null, utilizationSearchRequest.inventionReportDateTo);
        System.assertEquals(null, utilizationSearchRequest.fiscalYear);
        System.assertEquals(null, utilizationSearchRequest.commercialProductName);
        System.assertEquals(null, utilizationSearchRequest.fdaApprovalNumber);
        System.assertEquals(null, utilizationSearchRequest.fdaReportType);
        System.assertEquals(null, utilizationSearchRequest.lastUpdatedFrom);
        System.assertEquals(null, utilizationSearchRequest.lastUpdatedTo);
    }
}