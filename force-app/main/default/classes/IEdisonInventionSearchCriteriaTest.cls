@isTest
private class IEdisonInventionSearchCriteriaTest {
    @isTest
    private static void equalsSameInstance() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = inventionSearchCriteria1;
        IEdisonInventionSearchCriteria inventionSearchCriteria3 = new IEdisonInventionSearchCriteria();
        IEdisonInventionSearchCriteria inventionSearchCriteria4 = inventionSearchCriteria3;

        System.assert(inventionSearchCriteria1.equals(inventionSearchCriteria2));
        System.assert(inventionSearchCriteria2.equals(inventionSearchCriteria1));
        System.assert(inventionSearchCriteria1.equals(inventionSearchCriteria1));
        System.assert(inventionSearchCriteria3.equals(inventionSearchCriteria4));
        System.assert(inventionSearchCriteria4.equals(inventionSearchCriteria3));
        System.assert(inventionSearchCriteria3.equals(inventionSearchCriteria3));
    }

    @isTest
    private static void equalsIdenticalInstance() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria3 = new IEdisonInventionSearchCriteria();
        IEdisonInventionSearchCriteria inventionSearchCriteria4 = new IEdisonInventionSearchCriteria();

        System.assert(inventionSearchCriteria1.equals(inventionSearchCriteria2));
        System.assert(inventionSearchCriteria2.equals(inventionSearchCriteria1));
        System.assert(inventionSearchCriteria3.equals(inventionSearchCriteria4));
        System.assert(inventionSearchCriteria4.equals(inventionSearchCriteria3));
    }

    @isTest
    private static void notEqualsDifferentType() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = new IEdisonInventionSearchCriteria();

        System.assertEquals(false, inventionSearchCriteria1.equals('foo'));
        System.assertEquals(false, inventionSearchCriteria2.equals('foo'));
    }

    @isTest
    private static void notEqualsNull() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = new IEdisonInventionSearchCriteria();
        IEdisonInventionSearchCriteria inventionSearchCriteria3;

        System.assertEquals(false, inventionSearchCriteria1.equals(inventionSearchCriteria3));
        System.assertEquals(false, inventionSearchCriteria2.equals(inventionSearchCriteria3));
    }

    @isTest
    private static void consistentHashCodeValue() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = new IEdisonInventionSearchCriteria();

        System.assertEquals(inventionSearchCriteria1.hashCode(), inventionSearchCriteria1.hashCode());
        System.assertEquals(inventionSearchCriteria2.hashCode(), inventionSearchCriteria2.hashCode());
    }

    @isTest
    private static void equalInstancesHaveSameHashCode() {
        IEdisonInventionSearchCriteria inventionSearchCriteria1 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria2 = IEdisonInventionSearchCriteria.getExample();
        IEdisonInventionSearchCriteria inventionSearchCriteria3 = new IEdisonInventionSearchCriteria();
        IEdisonInventionSearchCriteria inventionSearchCriteria4 = new IEdisonInventionSearchCriteria();

        System.assert(inventionSearchCriteria1.equals(inventionSearchCriteria2));
        System.assert(inventionSearchCriteria3.equals(inventionSearchCriteria4));
        System.assertEquals(inventionSearchCriteria1.hashCode(), inventionSearchCriteria2.hashCode());
        System.assertEquals(inventionSearchCriteria3.hashCode(), inventionSearchCriteria4.hashCode());
    }

    @isTest
    private static void maintainRenamedProperties() {
        IEdisonInventionSearchCriteria inventionSearchCriteria = new IEdisonInventionSearchCriteria();
        Map<String, String> x_property_mappings = inventionSearchCriteria.getPropertyMappings();
        System.assertEquals('r_limit', x_property_mappings.get('limit'));
    }

    @isTest
    private static void defaultValuesPopulated() {
        IEdisonInventionSearchCriteria inventionSearchCriteria = new IEdisonInventionSearchCriteria();
        System.assertEquals(new List<String>(), inventionSearchCriteria.titleElectionStatus);
        System.assertEquals(null, inventionSearchCriteria.r_limit);
        System.assertEquals(null, inventionSearchCriteria.offset);
        System.assertEquals(null, inventionSearchCriteria.inventionReportNumber);
        System.assertEquals(null, inventionSearchCriteria.inventionDocketNumber);
        System.assertEquals(null, inventionSearchCriteria.grantContractNumber);
        System.assertEquals(null, inventionSearchCriteria.inventorFirstName);
        System.assertEquals(null, inventionSearchCriteria.inventorLastName);
        System.assertEquals(null, inventionSearchCriteria.primaryAgency);
        System.assertEquals(null, inventionSearchCriteria.granteeOrganizationName);
        System.assertEquals(null, inventionSearchCriteria.inventionTitle);
        System.assertEquals(null, inventionSearchCriteria.inventionReportDateFrom);
        System.assertEquals(null, inventionSearchCriteria.inventionReportDateTo);
        System.assertEquals(null, inventionSearchCriteria.inventionKeyword);
        System.assertEquals(null, inventionSearchCriteria.doeWaiver);
        System.assertEquals(null, inventionSearchCriteria.governmentCounsel);
        System.assertEquals(null, inventionSearchCriteria.governmentStaff);
        System.assertEquals(null, inventionSearchCriteria.lastUpdatedFrom);
        System.assertEquals(null, inventionSearchCriteria.lastUpdatedTo);
    }
}