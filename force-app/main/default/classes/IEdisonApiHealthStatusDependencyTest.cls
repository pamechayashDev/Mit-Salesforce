@isTest
private class IEdisonApiHealthStatusDependencyTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = apiHealthStatusDependency1;
        IEdisonApiHealthStatusDependency apiHealthStatusDependency3 = new IEdisonApiHealthStatusDependency();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency4 = apiHealthStatusDependency3;

        System.assert(apiHealthStatusDependency1.equals(apiHealthStatusDependency2));
        System.assert(apiHealthStatusDependency2.equals(apiHealthStatusDependency1));
        System.assert(apiHealthStatusDependency1.equals(apiHealthStatusDependency1));
        System.assert(apiHealthStatusDependency3.equals(apiHealthStatusDependency4));
        System.assert(apiHealthStatusDependency4.equals(apiHealthStatusDependency3));
        System.assert(apiHealthStatusDependency3.equals(apiHealthStatusDependency3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency3 = new IEdisonApiHealthStatusDependency();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency4 = new IEdisonApiHealthStatusDependency();

        System.assert(apiHealthStatusDependency1.equals(apiHealthStatusDependency2));
        System.assert(apiHealthStatusDependency2.equals(apiHealthStatusDependency1));
        System.assert(apiHealthStatusDependency3.equals(apiHealthStatusDependency4));
        System.assert(apiHealthStatusDependency4.equals(apiHealthStatusDependency3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = new IEdisonApiHealthStatusDependency();

        System.assertEquals(false, apiHealthStatusDependency1.equals('foo'));
        System.assertEquals(false, apiHealthStatusDependency2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = new IEdisonApiHealthStatusDependency();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency3;

        System.assertEquals(false, apiHealthStatusDependency1.equals(apiHealthStatusDependency3));
        System.assertEquals(false, apiHealthStatusDependency2.equals(apiHealthStatusDependency3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = new IEdisonApiHealthStatusDependency();

        System.assertEquals(apiHealthStatusDependency1.hashCode(), apiHealthStatusDependency1.hashCode());
        System.assertEquals(apiHealthStatusDependency2.hashCode(), apiHealthStatusDependency2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonApiHealthStatusDependency apiHealthStatusDependency1 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency2 = IEdisonApiHealthStatusDependency.getExample();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency3 = new IEdisonApiHealthStatusDependency();
        IEdisonApiHealthStatusDependency apiHealthStatusDependency4 = new IEdisonApiHealthStatusDependency();

        System.assert(apiHealthStatusDependency1.equals(apiHealthStatusDependency2));
        System.assert(apiHealthStatusDependency3.equals(apiHealthStatusDependency4));
        System.assertEquals(apiHealthStatusDependency1.hashCode(), apiHealthStatusDependency2.hashCode());
        System.assertEquals(apiHealthStatusDependency3.hashCode(), apiHealthStatusDependency4.hashCode());
    }
}