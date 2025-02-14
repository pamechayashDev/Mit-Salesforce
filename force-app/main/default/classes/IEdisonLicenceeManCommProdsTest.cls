@isTest
private class IEdisonLicenceeManCommProdsTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = licenceeManCommProds1;
        IEdisonLicenceeManCommProds licenceeManCommProds3 = new IEdisonLicenceeManCommProds();
        IEdisonLicenceeManCommProds licenceeManCommProds4 = licenceeManCommProds3;

        System.assert(licenceeManCommProds1.equals(licenceeManCommProds2));
        System.assert(licenceeManCommProds2.equals(licenceeManCommProds1));
        System.assert(licenceeManCommProds1.equals(licenceeManCommProds1));
        System.assert(licenceeManCommProds3.equals(licenceeManCommProds4));
        System.assert(licenceeManCommProds4.equals(licenceeManCommProds3));
        System.assert(licenceeManCommProds3.equals(licenceeManCommProds3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds3 = new IEdisonLicenceeManCommProds();
        IEdisonLicenceeManCommProds licenceeManCommProds4 = new IEdisonLicenceeManCommProds();

        System.assert(licenceeManCommProds1.equals(licenceeManCommProds2));
        System.assert(licenceeManCommProds2.equals(licenceeManCommProds1));
        System.assert(licenceeManCommProds3.equals(licenceeManCommProds4));
        System.assert(licenceeManCommProds4.equals(licenceeManCommProds3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = new IEdisonLicenceeManCommProds();

        System.assertEquals(false, licenceeManCommProds1.equals('foo'));
        System.assertEquals(false, licenceeManCommProds2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = new IEdisonLicenceeManCommProds();
        IEdisonLicenceeManCommProds licenceeManCommProds3;

        System.assertEquals(false, licenceeManCommProds1.equals(licenceeManCommProds3));
        System.assertEquals(false, licenceeManCommProds2.equals(licenceeManCommProds3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = new IEdisonLicenceeManCommProds();

        System.assertEquals(licenceeManCommProds1.hashCode(), licenceeManCommProds1.hashCode());
        System.assertEquals(licenceeManCommProds2.hashCode(), licenceeManCommProds2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonLicenceeManCommProds licenceeManCommProds1 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds2 = IEdisonLicenceeManCommProds.getExample();
        IEdisonLicenceeManCommProds licenceeManCommProds3 = new IEdisonLicenceeManCommProds();
        IEdisonLicenceeManCommProds licenceeManCommProds4 = new IEdisonLicenceeManCommProds();

        System.assert(licenceeManCommProds1.equals(licenceeManCommProds2));
        System.assert(licenceeManCommProds3.equals(licenceeManCommProds4));
        System.assertEquals(licenceeManCommProds1.hashCode(), licenceeManCommProds2.hashCode());
        System.assertEquals(licenceeManCommProds3.hashCode(), licenceeManCommProds4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonLicenceeManCommProds licenceeManCommProds = new IEdisonLicenceeManCommProds();
        System.assertEquals(new List<IEdisonManufacturers>(), licenceeManCommProds.manufacturers);
        System.assertEquals(null, licenceeManCommProds.id);
        System.assertEquals(null, licenceeManCommProds.licenseeName);
    }
}