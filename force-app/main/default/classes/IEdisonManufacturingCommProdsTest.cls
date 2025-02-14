@isTest
private class IEdisonManufacturingCommProdsTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = manufacturingCommProds1;
        IEdisonManufacturingCommProds manufacturingCommProds3 = new IEdisonManufacturingCommProds();
        IEdisonManufacturingCommProds manufacturingCommProds4 = manufacturingCommProds3;

        System.assert(manufacturingCommProds1.equals(manufacturingCommProds2));
        System.assert(manufacturingCommProds2.equals(manufacturingCommProds1));
        System.assert(manufacturingCommProds1.equals(manufacturingCommProds1));
        System.assert(manufacturingCommProds3.equals(manufacturingCommProds4));
        System.assert(manufacturingCommProds4.equals(manufacturingCommProds3));
        System.assert(manufacturingCommProds3.equals(manufacturingCommProds3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds3 = new IEdisonManufacturingCommProds();
        IEdisonManufacturingCommProds manufacturingCommProds4 = new IEdisonManufacturingCommProds();

        System.assert(manufacturingCommProds1.equals(manufacturingCommProds2));
        System.assert(manufacturingCommProds2.equals(manufacturingCommProds1));
        System.assert(manufacturingCommProds3.equals(manufacturingCommProds4));
        System.assert(manufacturingCommProds4.equals(manufacturingCommProds3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = new IEdisonManufacturingCommProds();

        System.assertEquals(false, manufacturingCommProds1.equals('foo'));
        System.assertEquals(false, manufacturingCommProds2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = new IEdisonManufacturingCommProds();
        IEdisonManufacturingCommProds manufacturingCommProds3;

        System.assertEquals(false, manufacturingCommProds1.equals(manufacturingCommProds3));
        System.assertEquals(false, manufacturingCommProds2.equals(manufacturingCommProds3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = new IEdisonManufacturingCommProds();

        System.assertEquals(manufacturingCommProds1.hashCode(), manufacturingCommProds1.hashCode());
        System.assertEquals(manufacturingCommProds2.hashCode(), manufacturingCommProds2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonManufacturingCommProds manufacturingCommProds1 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds2 = IEdisonManufacturingCommProds.getExample();
        IEdisonManufacturingCommProds manufacturingCommProds3 = new IEdisonManufacturingCommProds();
        IEdisonManufacturingCommProds manufacturingCommProds4 = new IEdisonManufacturingCommProds();

        System.assert(manufacturingCommProds1.equals(manufacturingCommProds2));
        System.assert(manufacturingCommProds3.equals(manufacturingCommProds4));
        System.assertEquals(manufacturingCommProds1.hashCode(), manufacturingCommProds2.hashCode());
        System.assertEquals(manufacturingCommProds3.hashCode(), manufacturingCommProds4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonManufacturingCommProds manufacturingCommProds = new IEdisonManufacturingCommProds();
        System.assertEquals(new List<IEdisonLicenceeManCommProds>(), manufacturingCommProds.licensees);
        System.assertEquals(null, manufacturingCommProds.id);
        System.assertEquals(null, manufacturingCommProds.productName);
        System.assertEquals(null, manufacturingCommProds.naicsCode);
    }
}