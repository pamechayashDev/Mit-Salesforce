@isTest
private class IEdisonSubContractInfoTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = subContractInfo1;
        IEdisonSubContractInfo subContractInfo3 = new IEdisonSubContractInfo();
        IEdisonSubContractInfo subContractInfo4 = subContractInfo3;

        System.assert(subContractInfo1.equals(subContractInfo2));
        System.assert(subContractInfo2.equals(subContractInfo1));
        System.assert(subContractInfo1.equals(subContractInfo1));
        System.assert(subContractInfo3.equals(subContractInfo4));
        System.assert(subContractInfo4.equals(subContractInfo3));
        System.assert(subContractInfo3.equals(subContractInfo3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo3 = new IEdisonSubContractInfo();
        IEdisonSubContractInfo subContractInfo4 = new IEdisonSubContractInfo();

        System.assert(subContractInfo1.equals(subContractInfo2));
        System.assert(subContractInfo2.equals(subContractInfo1));
        System.assert(subContractInfo3.equals(subContractInfo4));
        System.assert(subContractInfo4.equals(subContractInfo3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = new IEdisonSubContractInfo();

        System.assertEquals(false, subContractInfo1.equals('foo'));
        System.assertEquals(false, subContractInfo2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = new IEdisonSubContractInfo();
        IEdisonSubContractInfo subContractInfo3;

        System.assertEquals(false, subContractInfo1.equals(subContractInfo3));
        System.assertEquals(false, subContractInfo2.equals(subContractInfo3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = new IEdisonSubContractInfo();

        System.assertEquals(subContractInfo1.hashCode(), subContractInfo1.hashCode());
        System.assertEquals(subContractInfo2.hashCode(), subContractInfo2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonSubContractInfo subContractInfo1 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo2 = IEdisonSubContractInfo.getExample();
        IEdisonSubContractInfo subContractInfo3 = new IEdisonSubContractInfo();
        IEdisonSubContractInfo subContractInfo4 = new IEdisonSubContractInfo();

        System.assert(subContractInfo1.equals(subContractInfo2));
        System.assert(subContractInfo3.equals(subContractInfo4));
        System.assertEquals(subContractInfo1.hashCode(), subContractInfo2.hashCode());
        System.assertEquals(subContractInfo3.hashCode(), subContractInfo4.hashCode());
    }
}