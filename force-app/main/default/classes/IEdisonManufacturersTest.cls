@isTest
private class IEdisonManufacturersTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = manufacturers1;
        IEdisonManufacturers manufacturers3 = new IEdisonManufacturers();
        IEdisonManufacturers manufacturers4 = manufacturers3;

        System.assert(manufacturers1.equals(manufacturers2));
        System.assert(manufacturers2.equals(manufacturers1));
        System.assert(manufacturers1.equals(manufacturers1));
        System.assert(manufacturers3.equals(manufacturers4));
        System.assert(manufacturers4.equals(manufacturers3));
        System.assert(manufacturers3.equals(manufacturers3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers3 = new IEdisonManufacturers();
        IEdisonManufacturers manufacturers4 = new IEdisonManufacturers();

        System.assert(manufacturers1.equals(manufacturers2));
        System.assert(manufacturers2.equals(manufacturers1));
        System.assert(manufacturers3.equals(manufacturers4));
        System.assert(manufacturers4.equals(manufacturers3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = new IEdisonManufacturers();

        System.assertEquals(false, manufacturers1.equals('foo'));
        System.assertEquals(false, manufacturers2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = new IEdisonManufacturers();
        IEdisonManufacturers manufacturers3;

        System.assertEquals(false, manufacturers1.equals(manufacturers3));
        System.assertEquals(false, manufacturers2.equals(manufacturers3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = new IEdisonManufacturers();

        System.assertEquals(manufacturers1.hashCode(), manufacturers1.hashCode());
        System.assertEquals(manufacturers2.hashCode(), manufacturers2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonManufacturers manufacturers1 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers2 = IEdisonManufacturers.getExample();
        IEdisonManufacturers manufacturers3 = new IEdisonManufacturers();
        IEdisonManufacturers manufacturers4 = new IEdisonManufacturers();

        System.assert(manufacturers1.equals(manufacturers2));
        System.assert(manufacturers3.equals(manufacturers4));
        System.assertEquals(manufacturers1.hashCode(), manufacturers2.hashCode());
        System.assertEquals(manufacturers3.hashCode(), manufacturers4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonManufacturers manufacturers = new IEdisonManufacturers();
        System.assertEquals(new List<IEdisonProductLocation>(), manufacturers.productLocation);
        System.assertEquals(null, manufacturers.id);
        System.assertEquals(null, manufacturers.manufacturerName);
    }
}