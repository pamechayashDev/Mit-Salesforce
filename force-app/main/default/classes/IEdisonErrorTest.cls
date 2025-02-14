@isTest
private class IEdisonErrorTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = error1;
        IEdisonError error3 = new IEdisonError();
        IEdisonError error4 = error3;

        System.assert(error1.equals(error2));
        System.assert(error2.equals(error1));
        System.assert(error1.equals(error1));
        System.assert(error3.equals(error4));
        System.assert(error4.equals(error3));
        System.assert(error3.equals(error3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = IEdisonError.getExample();
        IEdisonError error3 = new IEdisonError();
        IEdisonError error4 = new IEdisonError();

        System.assert(error1.equals(error2));
        System.assert(error2.equals(error1));
        System.assert(error3.equals(error4));
        System.assert(error4.equals(error3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = new IEdisonError();

        System.assertEquals(false, error1.equals('foo'));
        System.assertEquals(false, error2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = new IEdisonError();
        IEdisonError error3;

        System.assertEquals(false, error1.equals(error3));
        System.assertEquals(false, error2.equals(error3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = new IEdisonError();

        System.assertEquals(error1.hashCode(), error1.hashCode());
        System.assertEquals(error2.hashCode(), error2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonError error1 = IEdisonError.getExample();
        IEdisonError error2 = IEdisonError.getExample();
        IEdisonError error3 = new IEdisonError();
        IEdisonError error4 = new IEdisonError();

        System.assert(error1.equals(error2));
        System.assert(error3.equals(error4));
        System.assertEquals(error1.hashCode(), error2.hashCode());
        System.assertEquals(error3.hashCode(), error4.hashCode());
    }
}