@isTest
private class IEdisonApiHealthPingResponseStageTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = apiHealthPingResponseStage1;
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage3 = new IEdisonApiHealthPingResponseStage();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage4 = apiHealthPingResponseStage3;

        System.assert(apiHealthPingResponseStage1.equals(apiHealthPingResponseStage2));
        System.assert(apiHealthPingResponseStage2.equals(apiHealthPingResponseStage1));
        System.assert(apiHealthPingResponseStage1.equals(apiHealthPingResponseStage1));
        System.assert(apiHealthPingResponseStage3.equals(apiHealthPingResponseStage4));
        System.assert(apiHealthPingResponseStage4.equals(apiHealthPingResponseStage3));
        System.assert(apiHealthPingResponseStage3.equals(apiHealthPingResponseStage3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage3 = new IEdisonApiHealthPingResponseStage();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage4 = new IEdisonApiHealthPingResponseStage();

        System.assert(apiHealthPingResponseStage1.equals(apiHealthPingResponseStage2));
        System.assert(apiHealthPingResponseStage2.equals(apiHealthPingResponseStage1));
        System.assert(apiHealthPingResponseStage3.equals(apiHealthPingResponseStage4));
        System.assert(apiHealthPingResponseStage4.equals(apiHealthPingResponseStage3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = new IEdisonApiHealthPingResponseStage();

        System.assertEquals(false, apiHealthPingResponseStage1.equals('foo'));
        System.assertEquals(false, apiHealthPingResponseStage2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = new IEdisonApiHealthPingResponseStage();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage3;

        System.assertEquals(false, apiHealthPingResponseStage1.equals(apiHealthPingResponseStage3));
        System.assertEquals(false, apiHealthPingResponseStage2.equals(apiHealthPingResponseStage3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = new IEdisonApiHealthPingResponseStage();

        System.assertEquals(apiHealthPingResponseStage1.hashCode(), apiHealthPingResponseStage1.hashCode());
        System.assertEquals(apiHealthPingResponseStage2.hashCode(), apiHealthPingResponseStage2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage1 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage2 = IEdisonApiHealthPingResponseStage.getExample();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage3 = new IEdisonApiHealthPingResponseStage();
        IEdisonApiHealthPingResponseStage apiHealthPingResponseStage4 = new IEdisonApiHealthPingResponseStage();

        System.assert(apiHealthPingResponseStage1.equals(apiHealthPingResponseStage2));
        System.assert(apiHealthPingResponseStage3.equals(apiHealthPingResponseStage4));
        System.assertEquals(apiHealthPingResponseStage1.hashCode(), apiHealthPingResponseStage2.hashCode());
        System.assertEquals(apiHealthPingResponseStage3.hashCode(), apiHealthPingResponseStage4.hashCode());
    }
}