@isTest
private class IEdisonFundingAgreementTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = fundingAgreement1;
        IEdisonFundingAgreement fundingAgreement3 = new IEdisonFundingAgreement();
        IEdisonFundingAgreement fundingAgreement4 = fundingAgreement3;

        System.assert(fundingAgreement1.equals(fundingAgreement2));
        System.assert(fundingAgreement2.equals(fundingAgreement1));
        System.assert(fundingAgreement1.equals(fundingAgreement1));
        System.assert(fundingAgreement3.equals(fundingAgreement4));
        System.assert(fundingAgreement4.equals(fundingAgreement3));
        System.assert(fundingAgreement3.equals(fundingAgreement3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement3 = new IEdisonFundingAgreement();
        IEdisonFundingAgreement fundingAgreement4 = new IEdisonFundingAgreement();

        System.assert(fundingAgreement1.equals(fundingAgreement2));
        System.assert(fundingAgreement2.equals(fundingAgreement1));
        System.assert(fundingAgreement3.equals(fundingAgreement4));
        System.assert(fundingAgreement4.equals(fundingAgreement3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = new IEdisonFundingAgreement();

        System.assertEquals(false, fundingAgreement1.equals('foo'));
        System.assertEquals(false, fundingAgreement2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = new IEdisonFundingAgreement();
        IEdisonFundingAgreement fundingAgreement3;

        System.assertEquals(false, fundingAgreement1.equals(fundingAgreement3));
        System.assertEquals(false, fundingAgreement2.equals(fundingAgreement3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = new IEdisonFundingAgreement();

        System.assertEquals(fundingAgreement1.hashCode(), fundingAgreement1.hashCode());
        System.assertEquals(fundingAgreement2.hashCode(), fundingAgreement2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonFundingAgreement fundingAgreement1 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement2 = IEdisonFundingAgreement.getExample();
        IEdisonFundingAgreement fundingAgreement3 = new IEdisonFundingAgreement();
        IEdisonFundingAgreement fundingAgreement4 = new IEdisonFundingAgreement();

        System.assert(fundingAgreement1.equals(fundingAgreement2));
        System.assert(fundingAgreement3.equals(fundingAgreement4));
        System.assertEquals(fundingAgreement1.hashCode(), fundingAgreement2.hashCode());
        System.assertEquals(fundingAgreement3.hashCode(), fundingAgreement4.hashCode());
    }
}