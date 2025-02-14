@isTest
private class IEdisonInventionSearchRequestTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = inventionSearchRequest1;
        IEdisonInventionSearchRequest inventionSearchRequest3 = new IEdisonInventionSearchRequest();
        IEdisonInventionSearchRequest inventionSearchRequest4 = inventionSearchRequest3;

        System.assert(inventionSearchRequest1.equals(inventionSearchRequest2));
        System.assert(inventionSearchRequest2.equals(inventionSearchRequest1));
        System.assert(inventionSearchRequest1.equals(inventionSearchRequest1));
        System.assert(inventionSearchRequest3.equals(inventionSearchRequest4));
        System.assert(inventionSearchRequest4.equals(inventionSearchRequest3));
        System.assert(inventionSearchRequest3.equals(inventionSearchRequest3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest3 = new IEdisonInventionSearchRequest();
        IEdisonInventionSearchRequest inventionSearchRequest4 = new IEdisonInventionSearchRequest();

        System.assert(inventionSearchRequest1.equals(inventionSearchRequest2));
        System.assert(inventionSearchRequest2.equals(inventionSearchRequest1));
        System.assert(inventionSearchRequest3.equals(inventionSearchRequest4));
        System.assert(inventionSearchRequest4.equals(inventionSearchRequest3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = new IEdisonInventionSearchRequest();

        System.assertEquals(false, inventionSearchRequest1.equals('foo'));
        System.assertEquals(false, inventionSearchRequest2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = new IEdisonInventionSearchRequest();
        IEdisonInventionSearchRequest inventionSearchRequest3;

        System.assertEquals(false, inventionSearchRequest1.equals(inventionSearchRequest3));
        System.assertEquals(false, inventionSearchRequest2.equals(inventionSearchRequest3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = new IEdisonInventionSearchRequest();

        System.assertEquals(inventionSearchRequest1.hashCode(), inventionSearchRequest1.hashCode());
        System.assertEquals(inventionSearchRequest2.hashCode(), inventionSearchRequest2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventionSearchRequest inventionSearchRequest1 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest2 = IEdisonInventionSearchRequest.getExample();
        IEdisonInventionSearchRequest inventionSearchRequest3 = new IEdisonInventionSearchRequest();
        IEdisonInventionSearchRequest inventionSearchRequest4 = new IEdisonInventionSearchRequest();

        System.assert(inventionSearchRequest1.equals(inventionSearchRequest2));
        System.assert(inventionSearchRequest3.equals(inventionSearchRequest4));
        System.assertEquals(inventionSearchRequest1.hashCode(), inventionSearchRequest2.hashCode());
        System.assertEquals(inventionSearchRequest3.hashCode(), inventionSearchRequest4.hashCode());
    }
}