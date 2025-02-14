@isTest
private class IEdisonUtilizationResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = utilizationResponse1;
        IEdisonUtilizationResponse utilizationResponse3 = new IEdisonUtilizationResponse();
        IEdisonUtilizationResponse utilizationResponse4 = utilizationResponse3;

        System.assert(utilizationResponse1.equals(utilizationResponse2));
        System.assert(utilizationResponse2.equals(utilizationResponse1));
        System.assert(utilizationResponse1.equals(utilizationResponse1));
        System.assert(utilizationResponse3.equals(utilizationResponse4));
        System.assert(utilizationResponse4.equals(utilizationResponse3));
        System.assert(utilizationResponse3.equals(utilizationResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse3 = new IEdisonUtilizationResponse();
        IEdisonUtilizationResponse utilizationResponse4 = new IEdisonUtilizationResponse();

        System.assert(utilizationResponse1.equals(utilizationResponse2));
        System.assert(utilizationResponse2.equals(utilizationResponse1));
        System.assert(utilizationResponse3.equals(utilizationResponse4));
        System.assert(utilizationResponse4.equals(utilizationResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = new IEdisonUtilizationResponse();

        System.assertEquals(false, utilizationResponse1.equals('foo'));
        System.assertEquals(false, utilizationResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = new IEdisonUtilizationResponse();
        IEdisonUtilizationResponse utilizationResponse3;

        System.assertEquals(false, utilizationResponse1.equals(utilizationResponse3));
        System.assertEquals(false, utilizationResponse2.equals(utilizationResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = new IEdisonUtilizationResponse();

        System.assertEquals(utilizationResponse1.hashCode(), utilizationResponse1.hashCode());
        System.assertEquals(utilizationResponse2.hashCode(), utilizationResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonUtilizationResponse utilizationResponse1 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse2 = IEdisonUtilizationResponse.getExample();
        IEdisonUtilizationResponse utilizationResponse3 = new IEdisonUtilizationResponse();
        IEdisonUtilizationResponse utilizationResponse4 = new IEdisonUtilizationResponse();

        System.assert(utilizationResponse1.equals(utilizationResponse2));
        System.assert(utilizationResponse3.equals(utilizationResponse4));
        System.assertEquals(utilizationResponse1.hashCode(), utilizationResponse2.hashCode());
        System.assertEquals(utilizationResponse3.hashCode(), utilizationResponse4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonUtilizationResponse utilizationResponse = new IEdisonUtilizationResponse();
        System.assertEquals(new List<IEdisonLicensees>(), utilizationResponse.licensees);
        System.assertEquals(new List<String>(), utilizationResponse.exclusiveLicensees);
        System.assertEquals(new List<String>(), utilizationResponse.nonExclusiveLicensees);
        System.assertEquals(new List<IEdisonManufacturingCommProds>(), utilizationResponse.manufacturingCommProds);
        System.assertEquals(new List<IEdisonCommercialProds>(), utilizationResponse.commercialProds);
        System.assertEquals(null, utilizationResponse.inventionReportNumber);
        System.assertEquals(null, utilizationResponse.granteeOrganizationName);
        System.assertEquals(null, utilizationResponse.inventionTitle);
        System.assertEquals(null, utilizationResponse.primaryAgency);
        System.assertEquals(null, utilizationResponse.inventionReportDate);
        System.assertEquals(null, utilizationResponse.titleElectDate);
        System.assertEquals(null, utilizationResponse.reportingYear);
        System.assertEquals(null, utilizationResponse.latestStageDev);
        System.assertEquals(null, utilizationResponse.firstCommercialSaleYear);
        System.assertEquals(null, utilizationResponse.totalIncome);
        System.assertEquals(null, utilizationResponse.exclusiveLicensesOptions);
        System.assertEquals(null, utilizationResponse.nonExclusiveLicensesOptions);
        System.assertEquals(null, utilizationResponse.smallBusinessLicensesOptions);
        System.assertEquals(null, utilizationResponse.isUSManufacturingRequired1);
        System.assertEquals(null, utilizationResponse.isUSManufacturingRequired2);
        System.assertEquals(null, utilizationResponse.isUSManufacturingRequired3);
        System.assertEquals(null, utilizationResponse.notes);
        System.assertEquals(null, utilizationResponse.commercializationPlanId);
        System.assertEquals(null, utilizationResponse.newUsJobs);
        System.assertEquals(null, utilizationResponse.newUsCompanies);
        System.assertEquals(null, utilizationResponse.createdDate);
        System.assertEquals(null, utilizationResponse.lastUpdatedDate);
    }
}