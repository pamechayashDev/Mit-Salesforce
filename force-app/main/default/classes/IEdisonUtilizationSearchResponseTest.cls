@isTest
private class IEdisonUtilizationSearchResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = utilizationSearchResponse1;
        IEdisonUtilizationSearchResponse utilizationSearchResponse3 = new IEdisonUtilizationSearchResponse();
        IEdisonUtilizationSearchResponse utilizationSearchResponse4 = utilizationSearchResponse3;

        System.assert(utilizationSearchResponse1.equals(utilizationSearchResponse2));
        System.assert(utilizationSearchResponse2.equals(utilizationSearchResponse1));
        System.assert(utilizationSearchResponse1.equals(utilizationSearchResponse1));
        System.assert(utilizationSearchResponse3.equals(utilizationSearchResponse4));
        System.assert(utilizationSearchResponse4.equals(utilizationSearchResponse3));
        System.assert(utilizationSearchResponse3.equals(utilizationSearchResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse3 = new IEdisonUtilizationSearchResponse();
        IEdisonUtilizationSearchResponse utilizationSearchResponse4 = new IEdisonUtilizationSearchResponse();

        System.assert(utilizationSearchResponse1.equals(utilizationSearchResponse2));
        System.assert(utilizationSearchResponse2.equals(utilizationSearchResponse1));
        System.assert(utilizationSearchResponse3.equals(utilizationSearchResponse4));
        System.assert(utilizationSearchResponse4.equals(utilizationSearchResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = new IEdisonUtilizationSearchResponse();

        System.assertEquals(false, utilizationSearchResponse1.equals('foo'));
        System.assertEquals(false, utilizationSearchResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = new IEdisonUtilizationSearchResponse();
        IEdisonUtilizationSearchResponse utilizationSearchResponse3;

        System.assertEquals(false, utilizationSearchResponse1.equals(utilizationSearchResponse3));
        System.assertEquals(false, utilizationSearchResponse2.equals(utilizationSearchResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = new IEdisonUtilizationSearchResponse();

        System.assertEquals(utilizationSearchResponse1.hashCode(), utilizationSearchResponse1.hashCode());
        System.assertEquals(utilizationSearchResponse2.hashCode(), utilizationSearchResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse1 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse2 = IEdisonUtilizationSearchResponse.getExample();
        IEdisonUtilizationSearchResponse utilizationSearchResponse3 = new IEdisonUtilizationSearchResponse();
        IEdisonUtilizationSearchResponse utilizationSearchResponse4 = new IEdisonUtilizationSearchResponse();

        System.assert(utilizationSearchResponse1.equals(utilizationSearchResponse2));
        System.assert(utilizationSearchResponse3.equals(utilizationSearchResponse4));
        System.assertEquals(utilizationSearchResponse1.hashCode(), utilizationSearchResponse2.hashCode());
        System.assertEquals(utilizationSearchResponse3.hashCode(), utilizationSearchResponse4.hashCode());
    }

    @isTest
    private static void maintainRenamedProperties() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse = new IEdisonUtilizationSearchResponse();
        Map<String, String> x_property_mappings = utilizationSearchResponse.getPropertyMappings();
        System.assertEquals('r_limit', x_property_mappings.get('limit'));
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonUtilizationSearchResponse utilizationSearchResponse = new IEdisonUtilizationSearchResponse();
        System.assertEquals(new List<IEdisonUtilizationResponse>(), utilizationSearchResponse.utilizations);
        System.assertEquals(null, utilizationSearchResponse.totalRecords);
        System.assertEquals(null, utilizationSearchResponse.r_limit);
        System.assertEquals(null, utilizationSearchResponse.offset);
    }
}