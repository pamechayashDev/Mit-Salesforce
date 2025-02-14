@isTest
private class IEdisonLicenseesTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = licensees1;
        IEdisonLicensees licensees3 = new IEdisonLicensees();
        IEdisonLicensees licensees4 = licensees3;

        System.assert(licensees1.equals(licensees2));
        System.assert(licensees2.equals(licensees1));
        System.assert(licensees1.equals(licensees1));
        System.assert(licensees3.equals(licensees4));
        System.assert(licensees4.equals(licensees3));
        System.assert(licensees3.equals(licensees3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees3 = new IEdisonLicensees();
        IEdisonLicensees licensees4 = new IEdisonLicensees();

        System.assert(licensees1.equals(licensees2));
        System.assert(licensees2.equals(licensees1));
        System.assert(licensees3.equals(licensees4));
        System.assert(licensees4.equals(licensees3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = new IEdisonLicensees();

        System.assertEquals(false, licensees1.equals('foo'));
        System.assertEquals(false, licensees2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = new IEdisonLicensees();
        IEdisonLicensees licensees3;

        System.assertEquals(false, licensees1.equals(licensees3));
        System.assertEquals(false, licensees2.equals(licensees3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = new IEdisonLicensees();

        System.assertEquals(licensees1.hashCode(), licensees1.hashCode());
        System.assertEquals(licensees2.hashCode(), licensees2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonLicensees licensees1 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees2 = IEdisonLicensees.getExample();
        IEdisonLicensees licensees3 = new IEdisonLicensees();
        IEdisonLicensees licensees4 = new IEdisonLicensees();

        System.assert(licensees1.equals(licensees2));
        System.assert(licensees3.equals(licensees4));
        System.assertEquals(licensees1.hashCode(), licensees2.hashCode());
        System.assertEquals(licensees3.hashCode(), licensees4.hashCode());
    }
}