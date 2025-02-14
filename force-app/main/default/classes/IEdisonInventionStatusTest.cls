@isTest
private class IEdisonInventionStatusTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = inventionStatus1;
        IEdisonInventionStatus inventionStatus3 = new IEdisonInventionStatus();
        IEdisonInventionStatus inventionStatus4 = inventionStatus3;

        System.assert(inventionStatus1.equals(inventionStatus2));
        System.assert(inventionStatus2.equals(inventionStatus1));
        System.assert(inventionStatus1.equals(inventionStatus1));
        System.assert(inventionStatus3.equals(inventionStatus4));
        System.assert(inventionStatus4.equals(inventionStatus3));
        System.assert(inventionStatus3.equals(inventionStatus3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus3 = new IEdisonInventionStatus();
        IEdisonInventionStatus inventionStatus4 = new IEdisonInventionStatus();

        System.assert(inventionStatus1.equals(inventionStatus2));
        System.assert(inventionStatus2.equals(inventionStatus1));
        System.assert(inventionStatus3.equals(inventionStatus4));
        System.assert(inventionStatus4.equals(inventionStatus3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = new IEdisonInventionStatus();

        System.assertEquals(false, inventionStatus1.equals('foo'));
        System.assertEquals(false, inventionStatus2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = new IEdisonInventionStatus();
        IEdisonInventionStatus inventionStatus3;

        System.assertEquals(false, inventionStatus1.equals(inventionStatus3));
        System.assertEquals(false, inventionStatus2.equals(inventionStatus3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = new IEdisonInventionStatus();

        System.assertEquals(inventionStatus1.hashCode(), inventionStatus1.hashCode());
        System.assertEquals(inventionStatus2.hashCode(), inventionStatus2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventionStatus inventionStatus1 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus2 = IEdisonInventionStatus.getExample();
        IEdisonInventionStatus inventionStatus3 = new IEdisonInventionStatus();
        IEdisonInventionStatus inventionStatus4 = new IEdisonInventionStatus();

        System.assert(inventionStatus1.equals(inventionStatus2));
        System.assert(inventionStatus3.equals(inventionStatus4));
        System.assertEquals(inventionStatus1.hashCode(), inventionStatus2.hashCode());
        System.assertEquals(inventionStatus3.hashCode(), inventionStatus4.hashCode());
    }
}