@isTest
private class IEdisonErrorResponseTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = errorResponse1;
        IEdisonErrorResponse errorResponse3 = new IEdisonErrorResponse();
        IEdisonErrorResponse errorResponse4 = errorResponse3;

        System.assert(errorResponse1.equals(errorResponse2));
        System.assert(errorResponse2.equals(errorResponse1));
        System.assert(errorResponse1.equals(errorResponse1));
        System.assert(errorResponse3.equals(errorResponse4));
        System.assert(errorResponse4.equals(errorResponse3));
        System.assert(errorResponse3.equals(errorResponse3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse3 = new IEdisonErrorResponse();
        IEdisonErrorResponse errorResponse4 = new IEdisonErrorResponse();

        System.assert(errorResponse1.equals(errorResponse2));
        System.assert(errorResponse2.equals(errorResponse1));
        System.assert(errorResponse3.equals(errorResponse4));
        System.assert(errorResponse4.equals(errorResponse3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = new IEdisonErrorResponse();

        System.assertEquals(false, errorResponse1.equals('foo'));
        System.assertEquals(false, errorResponse2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = new IEdisonErrorResponse();
        IEdisonErrorResponse errorResponse3;

        System.assertEquals(false, errorResponse1.equals(errorResponse3));
        System.assertEquals(false, errorResponse2.equals(errorResponse3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = new IEdisonErrorResponse();

        System.assertEquals(errorResponse1.hashCode(), errorResponse1.hashCode());
        System.assertEquals(errorResponse2.hashCode(), errorResponse2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonErrorResponse errorResponse1 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse2 = IEdisonErrorResponse.getExample();
        IEdisonErrorResponse errorResponse3 = new IEdisonErrorResponse();
        IEdisonErrorResponse errorResponse4 = new IEdisonErrorResponse();

        System.assert(errorResponse1.equals(errorResponse2));
        System.assert(errorResponse3.equals(errorResponse4));
        System.assertEquals(errorResponse1.hashCode(), errorResponse2.hashCode());
        System.assertEquals(errorResponse3.hashCode(), errorResponse4.hashCode());
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonErrorResponse errorResponse = new IEdisonErrorResponse();
        System.assertEquals(new List<IEdisonError>(), errorResponse.errors);
        System.assertEquals(null, errorResponse.responseCode);
        System.assertEquals(null, errorResponse.message);
    }
}