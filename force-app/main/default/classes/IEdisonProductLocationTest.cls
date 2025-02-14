@isTest
private class IEdisonProductLocationTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = productLocation1;
        IEdisonProductLocation productLocation3 = new IEdisonProductLocation();
        IEdisonProductLocation productLocation4 = productLocation3;

        System.assert(productLocation1.equals(productLocation2));
        System.assert(productLocation2.equals(productLocation1));
        System.assert(productLocation1.equals(productLocation1));
        System.assert(productLocation3.equals(productLocation4));
        System.assert(productLocation4.equals(productLocation3));
        System.assert(productLocation3.equals(productLocation3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation3 = new IEdisonProductLocation();
        IEdisonProductLocation productLocation4 = new IEdisonProductLocation();

        System.assert(productLocation1.equals(productLocation2));
        System.assert(productLocation2.equals(productLocation1));
        System.assert(productLocation3.equals(productLocation4));
        System.assert(productLocation4.equals(productLocation3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = new IEdisonProductLocation();

        System.assertEquals(false, productLocation1.equals('foo'));
        System.assertEquals(false, productLocation2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = new IEdisonProductLocation();
        IEdisonProductLocation productLocation3;

        System.assertEquals(false, productLocation1.equals(productLocation3));
        System.assertEquals(false, productLocation2.equals(productLocation3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = new IEdisonProductLocation();

        System.assertEquals(productLocation1.hashCode(), productLocation1.hashCode());
        System.assertEquals(productLocation2.hashCode(), productLocation2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonProductLocation productLocation1 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation2 = IEdisonProductLocation.getExample();
        IEdisonProductLocation productLocation3 = new IEdisonProductLocation();
        IEdisonProductLocation productLocation4 = new IEdisonProductLocation();

        System.assert(productLocation1.equals(productLocation2));
        System.assert(productLocation3.equals(productLocation4));
        System.assertEquals(productLocation1.hashCode(), productLocation2.hashCode());
        System.assertEquals(productLocation3.hashCode(), productLocation4.hashCode());
    }
}