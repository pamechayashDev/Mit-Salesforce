public with sharing class IpiaRecordFetch {

    @AuraEnabled(cacheable=true)
    public static IPIA_Acknowledgement__c getIpiaAckByMitId(String mitid) {
        System.debug('**IPIA Get**');
        System.debug(mitid);

        IPIA_Acknowledgement__c ipiaAck = [
            SELECT
                Name,
                Date_Acknowledged__c,
                Acknowledged__c,
                Mit_Id__c
            FROM IPIA_Acknowledgement__c
            WHERE Mit_Id__c = :mitid
            LIMIT 1
        ];

        return ipiaAck;
    }

    @AuraEnabled
    public static String deleteIpiaRecords(String recordId) {
        try {
            IPIA_Record__c ipiaRecord = [
                SELECT Id 
                FROM IPIA_Record__c 
                WHERE Id = :recordId
                LIMIT 1
            ];

            delete ipiaRecord;

            return 'Success';
        } catch (DmlException e) {
            String errorMessage = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += e.getDmlMessage(i) + ' ';
            }

            // Return error message if the deletion fails
            return errorMessage;
        }
    }
    
}