@isTest
private class IEdisonApiHealthPingResponseDeploymeTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = apiHealthPingResponseDeployment1;
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment3 = new IEdisonApiHealthPingResponseDeployme();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment4 = apiHealthPingResponseDeployment3;

        System.assert(apiHealthPingResponseDeployment1.equals(apiHealthPingResponseDeployment2));
        System.assert(apiHealthPingResponseDeployment2.equals(apiHealthPingResponseDeployment1));
        System.assert(apiHealthPingResponseDeployment1.equals(apiHealthPingResponseDeployment1));
        System.assert(apiHealthPingResponseDeployment3.equals(apiHealthPingResponseDeployment4));
        System.assert(apiHealthPingResponseDeployment4.equals(apiHealthPingResponseDeployment3));
        System.assert(apiHealthPingResponseDeployment3.equals(apiHealthPingResponseDeployment3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment3 = new IEdisonApiHealthPingResponseDeployme();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment4 = new IEdisonApiHealthPingResponseDeployme();

        System.assert(apiHealthPingResponseDeployment1.equals(apiHealthPingResponseDeployment2));
        System.assert(apiHealthPingResponseDeployment2.equals(apiHealthPingResponseDeployment1));
        System.assert(apiHealthPingResponseDeployment3.equals(apiHealthPingResponseDeployment4));
        System.assert(apiHealthPingResponseDeployment4.equals(apiHealthPingResponseDeployment3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = new IEdisonApiHealthPingResponseDeployme();

        System.assertEquals(false, apiHealthPingResponseDeployment1.equals('foo'));
        System.assertEquals(false, apiHealthPingResponseDeployment2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = new IEdisonApiHealthPingResponseDeployme();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment3;

        System.assertEquals(false, apiHealthPingResponseDeployment1.equals(apiHealthPingResponseDeployment3));
        System.assertEquals(false, apiHealthPingResponseDeployment2.equals(apiHealthPingResponseDeployment3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = new IEdisonApiHealthPingResponseDeployme();

        System.assertEquals(apiHealthPingResponseDeployment1.hashCode(), apiHealthPingResponseDeployment1.hashCode());
        System.assertEquals(apiHealthPingResponseDeployment2.hashCode(), apiHealthPingResponseDeployment2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment1 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment2 = IEdisonApiHealthPingResponseDeployme.getExample();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment3 = new IEdisonApiHealthPingResponseDeployme();
        IEdisonApiHealthPingResponseDeployme apiHealthPingResponseDeployment4 = new IEdisonApiHealthPingResponseDeployme();

        System.assert(apiHealthPingResponseDeployment1.equals(apiHealthPingResponseDeployment2));
        System.assert(apiHealthPingResponseDeployment3.equals(apiHealthPingResponseDeployment4));
        System.assertEquals(apiHealthPingResponseDeployment1.hashCode(), apiHealthPingResponseDeployment2.hashCode());
        System.assertEquals(apiHealthPingResponseDeployment3.hashCode(), apiHealthPingResponseDeployment4.hashCode());
    }
}