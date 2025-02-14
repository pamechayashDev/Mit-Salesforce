@isTest
private class IEdisonCommercialProdsTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = commercialProds1;
        IEdisonCommercialProds commercialProds3 = new IEdisonCommercialProds();
        IEdisonCommercialProds commercialProds4 = commercialProds3;

        System.assert(commercialProds1.equals(commercialProds2));
        System.assert(commercialProds2.equals(commercialProds1));
        System.assert(commercialProds1.equals(commercialProds1));
        System.assert(commercialProds3.equals(commercialProds4));
        System.assert(commercialProds4.equals(commercialProds3));
        System.assert(commercialProds3.equals(commercialProds3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds3 = new IEdisonCommercialProds();
        IEdisonCommercialProds commercialProds4 = new IEdisonCommercialProds();

        System.assert(commercialProds1.equals(commercialProds2));
        System.assert(commercialProds2.equals(commercialProds1));
        System.assert(commercialProds3.equals(commercialProds4));
        System.assert(commercialProds4.equals(commercialProds3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = new IEdisonCommercialProds();

        System.assertEquals(false, commercialProds1.equals('foo'));
        System.assertEquals(false, commercialProds2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = new IEdisonCommercialProds();
        IEdisonCommercialProds commercialProds3;

        System.assertEquals(false, commercialProds1.equals(commercialProds3));
        System.assertEquals(false, commercialProds2.equals(commercialProds3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = new IEdisonCommercialProds();

        System.assertEquals(commercialProds1.hashCode(), commercialProds1.hashCode());
        System.assertEquals(commercialProds2.hashCode(), commercialProds2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonCommercialProds commercialProds1 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds2 = IEdisonCommercialProds.getExample();
        IEdisonCommercialProds commercialProds3 = new IEdisonCommercialProds();
        IEdisonCommercialProds commercialProds4 = new IEdisonCommercialProds();

        System.assert(commercialProds1.equals(commercialProds2));
        System.assert(commercialProds3.equals(commercialProds4));
        System.assertEquals(commercialProds1.hashCode(), commercialProds2.hashCode());
        System.assertEquals(commercialProds3.hashCode(), commercialProds4.hashCode());
    }
}