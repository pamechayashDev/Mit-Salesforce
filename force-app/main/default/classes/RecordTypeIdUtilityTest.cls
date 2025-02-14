@IsTest
public with sharing class RecordTypeIdUtilityTest {

    @IsTest
    static void testContentVersion() {
        Set<Id> recordTypeIds = RecordTypeIdUtility.getContentVersionRecordTypIds(new List<String>{'Sponsor_Agreement', 'Other_Agreement', 'TLO_Agreement', 'CRDR', 'IPIA_Type_Template'});
        System.assert(!recordTypeIds.isEmpty(),'Record Type Ids should not be Empty');
    }

}