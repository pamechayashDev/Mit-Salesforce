@IsTest
public with sharing class StringUtilsTest {

    @IsTest
    static void testConvertMapToQueryStringoneOne() {
        String recipientId = '123456789';
        Map<string, string> queryParams = new Map<String, String>();
        queryParams.put('documents_by_userid', 'false');
        
        String queryParamsStr = StringUtils.convertMapToQueryString(queryParams);

        System.assertEquals('documents_by_userid=false', queryParamsStr, 'queryParamsStr should include all values with = and &');
        System.assert(!queryParamsStr.contains('&'), 'queryParamsStr should NOTE have any &');
    }

    @IsTest
    static void testConvertMapToQueryStringMultipleEntries() {
        String recipientId = '123456789';
        Map<string, string> queryParams = new Map<String, String>();
        queryParams.put('documents_by_userid', 'false');
        queryParams.put('recipient_id', recipientId);
        
        String queryParamsStr = StringUtils.convertMapToQueryString(queryParams);

        System.assertEquals('documents_by_userid=false&recipient_id=' + recipientId, queryParamsStr, 'queryParamsStr should include all values with = and &');
        System.assert(queryParamsStr.contains('&'), 'queryParamsStr should have at least one &');
    }

    @IsTest
    static void testIfNullReplace() {
        System.assertEquals(null, StringUtils.ifNullReplace(null, null), 'null would be replaced with just null');
        System.assertEquals('1', StringUtils.ifNullReplace(null, '1'),'null is be replaced with 1 default');

        System.assertEquals('1', StringUtils.ifNullReplace('1', '2'), '1 is no null so should not be replaced with 2 here');
    }

    @IsTest
    static void testRemoveNonNumericCharacters() {
        System.assertEquals(null, StringUtils.removeNonNumericCharacters(null), 'null would be replaced with just null');
        System.assertEquals('1', StringUtils.removeNonNumericCharacters('1'), 'numbers should not be replaced');

        System.assertEquals('123', StringUtils.removeNonNumericCharacters('123HJ'), 'only numbers should remain');
        System.assertEquals('123', StringUtils.removeNonNumericCharacters('a123h'), 'only numbers should remain');
    }


    @IsTest
    static void testToSetStrings() {        
        System.assertEquals(new Set<String>(), StringUtils.toSetStrings(new Set<Decimal>()), 'emptySet should just give another emptySet');

        Set<String> oneEntry = StringUtils.toSetStrings(new Set<Decimal>{1234});        
        System.assertEquals(oneEntry.contains('1234'), true, 'oneEntry string for that number');
        
        Set<String> moreThanOneEntry = StringUtils.toSetStrings(new Set<Decimal>{1234, 5678, 91011});        
        System.assertEquals(moreThanOneEntry.contains('1234') && moreThanOneEntry.contains('5678') && moreThanOneEntry.contains('91011'), true, 'moreThanOneEntry string for all the numbers');
    }

}