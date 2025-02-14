@isTest
private class IEdisonInventorTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = inventor1;
        IEdisonInventor inventor3 = new IEdisonInventor();
        IEdisonInventor inventor4 = inventor3;

        System.assert(inventor1.equals(inventor2));
        System.assert(inventor2.equals(inventor1));
        System.assert(inventor1.equals(inventor1));
        System.assert(inventor3.equals(inventor4));
        System.assert(inventor4.equals(inventor3));
        System.assert(inventor3.equals(inventor3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = IEdisonInventor.getExample();
        IEdisonInventor inventor3 = new IEdisonInventor();
        IEdisonInventor inventor4 = new IEdisonInventor();

        System.assert(inventor1.equals(inventor2));
        System.assert(inventor2.equals(inventor1));
        System.assert(inventor3.equals(inventor4));
        System.assert(inventor4.equals(inventor3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = new IEdisonInventor();

        System.assertEquals(false, inventor1.equals('foo'));
        System.assertEquals(false, inventor2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = new IEdisonInventor();
        IEdisonInventor inventor3;

        System.assertEquals(false, inventor1.equals(inventor3));
        System.assertEquals(false, inventor2.equals(inventor3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = new IEdisonInventor();

        System.assertEquals(inventor1.hashCode(), inventor1.hashCode());
        System.assertEquals(inventor2.hashCode(), inventor2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventor inventor1 = IEdisonInventor.getExample();
        IEdisonInventor inventor2 = IEdisonInventor.getExample();
        IEdisonInventor inventor3 = new IEdisonInventor();
        IEdisonInventor inventor4 = new IEdisonInventor();

        System.assert(inventor1.equals(inventor2));
        System.assert(inventor3.equals(inventor4));
        System.assertEquals(inventor1.hashCode(), inventor2.hashCode());
        System.assertEquals(inventor3.hashCode(), inventor4.hashCode());
    }
}