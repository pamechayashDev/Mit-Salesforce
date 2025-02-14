@isTest
private class IEdisonApiHealthStatusResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = apiHealthStatusResponse1;
        IEdisonApiHealthStatusResponse apiHealthStatusResponse3 = new IEdisonApiHealthStatusResponse();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse4 = apiHealthStatusResponse3;

        System.assert(apiHealthStatusResponse1.equals(apiHealthStatusResponse2));
        System.assert(apiHealthStatusResponse2.equals(apiHealthStatusResponse1));
        System.assert(apiHealthStatusResponse1.equals(apiHealthStatusResponse1));
        System.assert(apiHealthStatusResponse3.equals(apiHealthStatusResponse4));
        System.assert(apiHealthStatusResponse4.equals(apiHealthStatusResponse3));
        System.assert(apiHealthStatusResponse3.equals(apiHealthStatusResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse3 = new IEdisonApiHealthStatusResponse();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse4 = new IEdisonApiHealthStatusResponse();

        System.assert(apiHealthStatusResponse1.equals(apiHealthStatusResponse2));
        System.assert(apiHealthStatusResponse2.equals(apiHealthStatusResponse1));
        System.assert(apiHealthStatusResponse3.equals(apiHealthStatusResponse4));
        System.assert(apiHealthStatusResponse4.equals(apiHealthStatusResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = new IEdisonApiHealthStatusResponse();

        System.assertEquals(false, apiHealthStatusResponse1.equals('foo'));
        System.assertEquals(false, apiHealthStatusResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = new IEdisonApiHealthStatusResponse();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse3;

        System.assertEquals(false, apiHealthStatusResponse1.equals(apiHealthStatusResponse3));
        System.assertEquals(false, apiHealthStatusResponse2.equals(apiHealthStatusResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = new IEdisonApiHealthStatusResponse();

        System.assertEquals(apiHealthStatusResponse1.hashCode(), apiHealthStatusResponse1.hashCode());
        System.assertEquals(apiHealthStatusResponse2.hashCode(), apiHealthStatusResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse1 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse2 = IEdisonApiHealthStatusResponse.getExample();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse3 = new IEdisonApiHealthStatusResponse();
        IEdisonApiHealthStatusResponse apiHealthStatusResponse4 = new IEdisonApiHealthStatusResponse();

        System.assert(apiHealthStatusResponse1.equals(apiHealthStatusResponse2));
        System.assert(apiHealthStatusResponse3.equals(apiHealthStatusResponse4));
        System.assertEquals(apiHealthStatusResponse1.hashCode(), apiHealthStatusResponse2.hashCode());
        System.assertEquals(apiHealthStatusResponse3.hashCode(), apiHealthStatusResponse4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonApiHealthStatusResponse apiHealthStatusResponse = new IEdisonApiHealthStatusResponse();
        System.assertEquals(new List<IEdisonApiHealthStatusDependency>(), apiHealthStatusResponse.dependencies);
        System.assertEquals(null, apiHealthStatusResponse.service);
        System.assertEquals(null, apiHealthStatusResponse.deployment);
        System.assertEquals(null, apiHealthStatusResponse.stage);
        System.assertEquals(null, apiHealthStatusResponse.status);
    }
}