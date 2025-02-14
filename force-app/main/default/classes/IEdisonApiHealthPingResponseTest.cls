@isTest
private class IEdisonApiHealthPingResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = apiHealthPingResponse1;
        IEdisonApiHealthPingResponse apiHealthPingResponse3 = new IEdisonApiHealthPingResponse();
        IEdisonApiHealthPingResponse apiHealthPingResponse4 = apiHealthPingResponse3;

        System.assert(apiHealthPingResponse1.equals(apiHealthPingResponse2));
        System.assert(apiHealthPingResponse2.equals(apiHealthPingResponse1));
        System.assert(apiHealthPingResponse1.equals(apiHealthPingResponse1));
        System.assert(apiHealthPingResponse3.equals(apiHealthPingResponse4));
        System.assert(apiHealthPingResponse4.equals(apiHealthPingResponse3));
        System.assert(apiHealthPingResponse3.equals(apiHealthPingResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse3 = new IEdisonApiHealthPingResponse();
        IEdisonApiHealthPingResponse apiHealthPingResponse4 = new IEdisonApiHealthPingResponse();

        System.assert(apiHealthPingResponse1.equals(apiHealthPingResponse2));
        System.assert(apiHealthPingResponse2.equals(apiHealthPingResponse1));
        System.assert(apiHealthPingResponse3.equals(apiHealthPingResponse4));
        System.assert(apiHealthPingResponse4.equals(apiHealthPingResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = new IEdisonApiHealthPingResponse();

        System.assertEquals(false, apiHealthPingResponse1.equals('foo'));
        System.assertEquals(false, apiHealthPingResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = new IEdisonApiHealthPingResponse();
        IEdisonApiHealthPingResponse apiHealthPingResponse3;

        System.assertEquals(false, apiHealthPingResponse1.equals(apiHealthPingResponse3));
        System.assertEquals(false, apiHealthPingResponse2.equals(apiHealthPingResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = new IEdisonApiHealthPingResponse();

        System.assertEquals(apiHealthPingResponse1.hashCode(), apiHealthPingResponse1.hashCode());
        System.assertEquals(apiHealthPingResponse2.hashCode(), apiHealthPingResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthPingResponse apiHealthPingResponse1 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse2 = IEdisonApiHealthPingResponse.getExample();
        IEdisonApiHealthPingResponse apiHealthPingResponse3 = new IEdisonApiHealthPingResponse();
        IEdisonApiHealthPingResponse apiHealthPingResponse4 = new IEdisonApiHealthPingResponse();

        System.assert(apiHealthPingResponse1.equals(apiHealthPingResponse2));
        System.assert(apiHealthPingResponse3.equals(apiHealthPingResponse4));
        System.assertEquals(apiHealthPingResponse1.hashCode(), apiHealthPingResponse2.hashCode());
        System.assertEquals(apiHealthPingResponse3.hashCode(), apiHealthPingResponse4.hashCode());
    }
}