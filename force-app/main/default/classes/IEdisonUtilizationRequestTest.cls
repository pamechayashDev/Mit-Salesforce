@isTest
private class IEdisonUtilizationRequestTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = utilizationRequest1;
        IEdisonUtilizationRequest utilizationRequest3 = new IEdisonUtilizationRequest();
        IEdisonUtilizationRequest utilizationRequest4 = utilizationRequest3;

        System.assert(utilizationRequest1.equals(utilizationRequest2));
        System.assert(utilizationRequest2.equals(utilizationRequest1));
        System.assert(utilizationRequest1.equals(utilizationRequest1));
        System.assert(utilizationRequest3.equals(utilizationRequest4));
        System.assert(utilizationRequest4.equals(utilizationRequest3));
        System.assert(utilizationRequest3.equals(utilizationRequest3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest3 = new IEdisonUtilizationRequest();
        IEdisonUtilizationRequest utilizationRequest4 = new IEdisonUtilizationRequest();

        System.assert(utilizationRequest1.equals(utilizationRequest2));
        System.assert(utilizationRequest2.equals(utilizationRequest1));
        System.assert(utilizationRequest3.equals(utilizationRequest4));
        System.assert(utilizationRequest4.equals(utilizationRequest3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = new IEdisonUtilizationRequest();

        System.assertEquals(false, utilizationRequest1.equals('foo'));
        System.assertEquals(false, utilizationRequest2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = new IEdisonUtilizationRequest();
        IEdisonUtilizationRequest utilizationRequest3;

        System.assertEquals(false, utilizationRequest1.equals(utilizationRequest3));
        System.assertEquals(false, utilizationRequest2.equals(utilizationRequest3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = new IEdisonUtilizationRequest();

        System.assertEquals(utilizationRequest1.hashCode(), utilizationRequest1.hashCode());
        System.assertEquals(utilizationRequest2.hashCode(), utilizationRequest2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonUtilizationRequest utilizationRequest1 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest2 = IEdisonUtilizationRequest.getExample();
        IEdisonUtilizationRequest utilizationRequest3 = new IEdisonUtilizationRequest();
        IEdisonUtilizationRequest utilizationRequest4 = new IEdisonUtilizationRequest();

        System.assert(utilizationRequest1.equals(utilizationRequest2));
        System.assert(utilizationRequest3.equals(utilizationRequest4));
        System.assertEquals(utilizationRequest1.hashCode(), utilizationRequest2.hashCode());
        System.assertEquals(utilizationRequest3.hashCode(), utilizationRequest4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonUtilizationRequest utilizationRequest = new IEdisonUtilizationRequest();
        System.assertEquals(new List<IEdisonLicensees>(), utilizationRequest.licensees);
        System.assertEquals(new List<IEdisonManufacturingCommProds>(), utilizationRequest.manufacturingCommProds);
        System.assertEquals(new List<IEdisonCommercialProds>(), utilizationRequest.commercialProds);
        System.assertEquals(null, utilizationRequest.inventionReportNumber);
        System.assertEquals(null, utilizationRequest.reportingYear);
        System.assertEquals(null, utilizationRequest.latestStageDev);
        System.assertEquals(null, utilizationRequest.firstCommercialSaleYear);
        System.assertEquals(null, utilizationRequest.totalIncome);
        System.assertEquals(null, utilizationRequest.exclusiveLicensesOptions);
        System.assertEquals(null, utilizationRequest.nonExclusiveLicensesOptions);
        System.assertEquals(null, utilizationRequest.smallBusinessLicensesOptions);
        System.assertEquals(null, utilizationRequest.isUSManufacturingRequired1);
        System.assertEquals(null, utilizationRequest.isUSManufacturingRequired2);
        System.assertEquals(null, utilizationRequest.isUSManufacturingRequired3);
        System.assertEquals(null, utilizationRequest.notes);
        System.assertEquals(null, utilizationRequest.commercializationPlanId);
        System.assertEquals(null, utilizationRequest.newUsJobs);
        System.assertEquals(null, utilizationRequest.newUsCompanies);
    }
}