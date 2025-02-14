@isTest
private class IEdisonInventionSearchResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = inventionSearchResponse1;
        IEdisonInventionSearchResponse inventionSearchResponse3 = new IEdisonInventionSearchResponse();
        IEdisonInventionSearchResponse inventionSearchResponse4 = inventionSearchResponse3;

        System.assert(inventionSearchResponse1.equals(inventionSearchResponse2));
        System.assert(inventionSearchResponse2.equals(inventionSearchResponse1));
        System.assert(inventionSearchResponse1.equals(inventionSearchResponse1));
        System.assert(inventionSearchResponse3.equals(inventionSearchResponse4));
        System.assert(inventionSearchResponse4.equals(inventionSearchResponse3));
        System.assert(inventionSearchResponse3.equals(inventionSearchResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse3 = new IEdisonInventionSearchResponse();
        IEdisonInventionSearchResponse inventionSearchResponse4 = new IEdisonInventionSearchResponse();

        System.assert(inventionSearchResponse1.equals(inventionSearchResponse2));
        System.assert(inventionSearchResponse2.equals(inventionSearchResponse1));
        System.assert(inventionSearchResponse3.equals(inventionSearchResponse4));
        System.assert(inventionSearchResponse4.equals(inventionSearchResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = new IEdisonInventionSearchResponse();

        System.assertEquals(false, inventionSearchResponse1.equals('foo'));
        System.assertEquals(false, inventionSearchResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = new IEdisonInventionSearchResponse();
        IEdisonInventionSearchResponse inventionSearchResponse3;

        System.assertEquals(false, inventionSearchResponse1.equals(inventionSearchResponse3));
        System.assertEquals(false, inventionSearchResponse2.equals(inventionSearchResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = new IEdisonInventionSearchResponse();

        System.assertEquals(inventionSearchResponse1.hashCode(), inventionSearchResponse1.hashCode());
        System.assertEquals(inventionSearchResponse2.hashCode(), inventionSearchResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventionSearchResponse inventionSearchResponse1 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse2 = IEdisonInventionSearchResponse.getExample();
        IEdisonInventionSearchResponse inventionSearchResponse3 = new IEdisonInventionSearchResponse();
        IEdisonInventionSearchResponse inventionSearchResponse4 = new IEdisonInventionSearchResponse();

        System.assert(inventionSearchResponse1.equals(inventionSearchResponse2));
        System.assert(inventionSearchResponse3.equals(inventionSearchResponse4));
        System.assertEquals(inventionSearchResponse1.hashCode(), inventionSearchResponse2.hashCode());
        System.assertEquals(inventionSearchResponse3.hashCode(), inventionSearchResponse4.hashCode());
    }

    @isTest
    private static void maintainRenamedProperties() {
        IEdisonInventionSearchResponse inventionSearchResponse = new IEdisonInventionSearchResponse();
        Map<String, String> x_property_mappings = inventionSearchResponse.getPropertyMappings();
        System.assertEquals('r_limit', x_property_mappings.get('limit'));
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonInventionSearchResponse inventionSearchResponse = new IEdisonInventionSearchResponse();
        System.assertEquals(new List<IEdisonInventionResponse>(), inventionSearchResponse.inventions);
        System.assertEquals(null, inventionSearchResponse.totalRecords);
        System.assertEquals(null, inventionSearchResponse.r_limit);
        System.assertEquals(null, inventionSearchResponse.offset);
    }
}