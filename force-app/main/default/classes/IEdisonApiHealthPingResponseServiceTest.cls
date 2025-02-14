@isTest
private class IEdisonApiHealthPingResponseServiceTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = apiHealthPingResponseService1;
        IEdisonApiHealthPingResponseService apiHealthPingResponseService3 = new IEdisonApiHealthPingResponseService();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService4 = apiHealthPingResponseService3;

        System.assert(apiHealthPingResponseService1.equals(apiHealthPingResponseService2));
        System.assert(apiHealthPingResponseService2.equals(apiHealthPingResponseService1));
        System.assert(apiHealthPingResponseService1.equals(apiHealthPingResponseService1));
        System.assert(apiHealthPingResponseService3.equals(apiHealthPingResponseService4));
        System.assert(apiHealthPingResponseService4.equals(apiHealthPingResponseService3));
        System.assert(apiHealthPingResponseService3.equals(apiHealthPingResponseService3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService3 = new IEdisonApiHealthPingResponseService();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService4 = new IEdisonApiHealthPingResponseService();

        System.assert(apiHealthPingResponseService1.equals(apiHealthPingResponseService2));
        System.assert(apiHealthPingResponseService2.equals(apiHealthPingResponseService1));
        System.assert(apiHealthPingResponseService3.equals(apiHealthPingResponseService4));
        System.assert(apiHealthPingResponseService4.equals(apiHealthPingResponseService3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = new IEdisonApiHealthPingResponseService();

        System.assertEquals(false, apiHealthPingResponseService1.equals('foo'));
        System.assertEquals(false, apiHealthPingResponseService2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = new IEdisonApiHealthPingResponseService();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService3;

        System.assertEquals(false, apiHealthPingResponseService1.equals(apiHealthPingResponseService3));
        System.assertEquals(false, apiHealthPingResponseService2.equals(apiHealthPingResponseService3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = new IEdisonApiHealthPingResponseService();

        System.assertEquals(apiHealthPingResponseService1.hashCode(), apiHealthPingResponseService1.hashCode());
        System.assertEquals(apiHealthPingResponseService2.hashCode(), apiHealthPingResponseService2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthPingResponseService apiHealthPingResponseService1 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService2 = IEdisonApiHealthPingResponseService.getExample();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService3 = new IEdisonApiHealthPingResponseService();
        IEdisonApiHealthPingResponseService apiHealthPingResponseService4 = new IEdisonApiHealthPingResponseService();

        System.assert(apiHealthPingResponseService1.equals(apiHealthPingResponseService2));
        System.assert(apiHealthPingResponseService3.equals(apiHealthPingResponseService4));
        System.assertEquals(apiHealthPingResponseService1.hashCode(), apiHealthPingResponseService2.hashCode());
        System.assertEquals(apiHealthPingResponseService3.hashCode(), apiHealthPingResponseService4.hashCode());
    }
}