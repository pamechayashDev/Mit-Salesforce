public with sharing class IPIARecordUpsertJob implements Queueable, Database.AllowsCallouts {
    public final Set<Id> asyncRequestIdsList;
    public class IPIARecordSyncException extends Exception {
    }

    public IPIARecordUpsertJob(Set<Id> asyncRequestIdsList) {
        this.asyncRequestIdsList = asyncRequestIdsList;
    }

    public List<Async_Request__c> start(QueueableContext ctx) {
        System.debug('🐞 ~ IPIARecordUpsertJob:start ' + ctx.getJobId());
         Integer retryCount = Integer.ValueOf(
                ConfigurationBuilder.getConfigurationToString(
                    'batchJobMaxNumberOfRetry'
                )
            );
         List<Async_Request__c> asyncRequests = [SELECT
                            Id,
                            Has_Processed__c,
                            Retry_Count__c,
                            Record_Id__c,
                            sObject_Name__c,
                            Job_Name__c
                        FROM Async_Request__c
                        WHERE
                            Has_Processed__c = FALSE
                            AND Retry_Count__c < :retryCount
                            AND sObject_Name__c = 'IPIA_Record__c'
                            AND Job_Name__c = 'IPIASignedToForresterJob'
                            AND Id = :asyncRequestIdsList
                        ORDER BY Job_Name__c
                    ];

         return asyncRequests;
    }

    private List<Forrester_IPIA_TYPES__x> invalidExternalIpiaTypes(List<IPIA_Record__c> ipiaRecords ) {
        List<Forrester_IPIA_TYPES__x> ipiaTypes = new List<Forrester_IPIA_TYPES__x>();

        List<String> ipiaTypeNames = new List<String>();
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
          if (ipiaRecord.IPIA_Type__r.Exemption__c == true && ipiaRecord.IPIA_Type__r.Name != null) {
            ipiaTypeNames.add(ipiaRecord.IPIA_Type__r.Name);
          }
        }
        if (ipiaTypeNames.isEmpty()) {
            return ipiaTypes;
        }
        List<Forrester_IPIA_TYPES__x> externalIpiaTypes = ExternalObjectRepository.getExternalIpiaTypesByName(ipiaTypeNames);
        for(String ipiaTypeName : ipiaTypeNames) {
            Boolean exist = false;
            for (Forrester_IPIA_TYPES__x  externalIpiaType : externalIpiaTypes) {
                if (externalIpiaType.IPIA_TYPE__c == ipiaTypeName) {
                    exist = true;
                    break;
                }
            }
            if(!exist) {
                Forrester_IPIA_TYPES__x forresterIPIAType = new Forrester_IPIA_TYPES__x();
                forresterIPIAType.IPIA_TYPE__c = ipiaTypeName;
                ipiaTypes.add(forresterIPIAType);
            }
        }

        return ipiaTypes;
    }

    public void execute(QueueableContext ctx) {
        System.debug('🐞 ~ IPIARecordUpsertJob.execute');
        List<Async_Request__c> scope = start(ctx);

        Map<String, Async_Request__c> asyncRequestMap = new Map<String, Async_Request__c>();
        for(Async_Request__c asyncRequest : scope) {
            asyncRequestMap.put(asyncRequest.Record_Id__c, asyncRequest);
        }
        List<IPIA_Record__c> ipiaRecords = [
             SELECT Id, MitId__c, SignDatetime__c, IPIA_Type__r.Exemption__c ,IPIA_Type__r.Name, FormName__c, Contact_Recid__c
             FROM IPIA_Record__c
             WHERE Id IN :asyncRequestMap.keySet()
         ];

        if (!ipiaRecords.isEmpty()) {
            List<Forrester_IPIA_TYPES__x> insertIpiaTypes = invalidExternalIpiaTypes (ipiaRecords);
            // Lookup Map
            List<String> contactMitIds = new List<String>();
            for (IPIA_Record__c ipiaRecord : ipiaRecords) {
              contactMitIds.add(ipiaRecord.MitId__c);
            }
            Map<String, List<Forrester_CONTACT__x>> mitIdMap = new Map<String, List<Forrester_CONTACT__x>>();

            List<Forrester_CONTACT__x> externalContacts = ExternalObjectRepository.getExternalContactByMitIds(contactMitIds);
            for(Forrester_CONTACT__x forresterContact : externalContacts ) {
                if (!mitIdMap.containsKey(forresterContact.MIT_ID__c)) {
                    mitIdMap.put(forresterContact.MIT_ID__c, new List<Forrester_CONTACT__x>());
                }
                List<Forrester_CONTACT__x> mitIdContact = mitIdMap.get(forresterContact.MIT_ID__c);
                mitIdContact.add(forresterContact);
            }
            if (!insertIpiaTypes.isEmpty()) {
                // Cannot be async need to wait for types to exist. On retry will cover concurrent issues
                // A callout was unsuccessful because of pending uncommitted work
                // Setting up the unit test has uncommitted transactions.
                // There is no pending commit before this call
                if (!Test.isRunningTest()) {
                    Database.insertImmediate(insertIpiaTypes);
                }else {
                    Database.insertAsync(insertIpiaTypes);
                 }
            }
            List<IPIA_Record__c> updateIpiaRecords = new List<IPIA_Record__c>();
            List<Async_Request__c> asyncUpdateList = new List<Async_Request__c>();
            for (IPIA_Record__c ipiaRecord : ipiaRecords) {
                try {

                    // Lookup forrester contact
                    List<Forrester_CONTACT__x> forresterContacts = mitIdMap.get(ipiaRecord.MitId__c);

                    if (forresterContacts != null && forresterContacts.size() == 1) {
                        Forrester_CONTACT__x forresterContact = forresterContacts[0];
                        Integer maxLength = 4000;
                        String formName = (!String.isBlank(ipiaRecord.FormName__c)) ? ipiaRecord.FormName__c : '(no matching IPIA Type found)';
                        String formNameType = (!String.isBlank(ipiaRecord.IPIA_Type__r.Name)) ? ipiaRecord.IPIA_Type__r.Name : formName ;
                        forresterContact.IPIA_COMMENT__c = getIPIATypeComment(maxLength, forresterContact.IPIA_COMMENT__c, formNameType, ipiaRecord.SignDatetime__c);
                        if (ipiaRecord.IPIA_Type__r.Exemption__c == true) {
                            forresterContact.ALTERNATE_IPIA_AGMT_FLAG__c = 'Y';
                            forresterContact.ALTERNATE_IPIA_AGMT_DATE__c = Helpers.dateToEdmDateTimeOffset(ipiaRecord.SignDatetime__c);
                            forresterContact.ALTERNATE_IPIA_TYPE__c = ipiaRecord.IPIA_Type__r.Name;
                            // Blank Normal IPIA
                            forresterContact.IPIA_SIGNED_FLAG__c = 'N';
                            forresterContact.IPIA_SIGNED_DATE__c = null;

                        } else {
                            forresterContact.IPIA_SIGNED_FLAG__c = 'Y';
                            forresterContact.IPIA_SIGNED_DATE__c = Helpers.dateToEdmDateTimeOffset(ipiaRecord.SignDatetime__c);
                            // Blank Alternate IPIA
                            forresterContact.ALTERNATE_IPIA_AGMT_FLAG__c = 'N';
                            forresterContact.ALTERNATE_IPIA_AGMT_DATE__c = null;
                            forresterContact.ALTERNATE_IPIA_TYPE__c = null;
                        }
                        if (ipiaRecord.Contact_Recid__c != forresterContact.CONTACT_RECID__c) {
                            // WARNING: Dont add any new fields, this could cause infinite loop if triggered parent fields are also updated
                            ipiaRecord.Contact_Recid__c = forresterContact.CONTACT_RECID__c;
                            updateIpiaRecords.add(ipiaRecord);
                        }
                        System.debug('🐞 ~ IPIARecordUpsertJob.execute: updating forresterContact' + JSON.serializePretty(forresterContact));
                        Async_Request__c asyncRequest = asyncRequestMap.get(ipiaRecord.Id);
                        ForresterIPIAAsyncSaveHandler forresterIPIACallbackHandler = new ForresterIPIAAsyncSaveHandler(asyncRequest.Id);

                        ExternalObjectDatabase.updateAsync(forresterContact, forresterIPIACallbackHandler, AccessLevel.SYSTEM_MODE);
                    } else if (forresterContacts != null && forresterContacts.size() > 1) {
                        // TODO: What to do when more than one primary contact point email address exists for the same record?
                        IPIARecordSyncException multipleContactFound = new IPIARecordSyncException('Multiple forrester contact found for account with MIT ID ' + ipiaRecord.MitId__c);
                        throw multipleContactFound;
                    } else if (forresterContacts == null || forresterContacts.isEmpty()) {
                        // TODO create new Contact
                        System.debug('🐞 ~ IPIARecordUpsertJob.execute: No forrester contact found for account with MIT ID ' + ipiaRecord.MitId__c);
                        IPIARecordSyncException noContactFound = new IPIARecordSyncException('No forrester contact found for account with MIT ID ' + ipiaRecord.MitId__c);
                        throw noContactFound;
                    }
                } catch (Exception ex) {
                    System.debug('🐞 ~ IPIARecordUpsertJob.execute: Exception ex: ' + ex);
                    Async_Request__c asyncRequest = asyncRequestMap.get(ipiaRecord.Id);
                    asyncRequest.Retry_Count__c =  Integer.valueOf(asyncRequest.Retry_Count__c) + 1;
                    asyncUpdateList.add(asyncRequest);
                    HandleLogException.logException(ex);
                }
            }
            if (!updateIpiaRecords.isEmpty()) {
                update updateIpiaRecords;
            }
            if(!asyncUpdateList.isEmpty()) {
                update asyncUpdateList;
            }
        }
    }

    /*
        Create a comment and truncate the value if needed. When truncated an ellipsis is used to indicate it.
        Forrester can only store a value upto 4000 varchar2
    */
    @TestVisible
    private String getIPIATypeComment(Integer maxLength, String originalString, String ipiaTypeName, Date signedDate ) {

        String firstChar = '\n';
        if (originalString == null || originalString == '' ) {
            originalString = '';
            // If original String is empty we dont need a new line
            firstChar = '';
        }

        List<String> appendTexts = new List<String>{
            firstChar + 'Signed: ' + ipiaTypeName
        };

        String signedDateFormatted = Helpers.formatDateGMT(signedDate, 'MM/dd/yyyy');
        if (signedDateFormatted != null) {
            appendTexts.add(' Date: ' + signedDateFormatted);
        }

       // Calculate total length of all append texts
       Integer totalAppendLength = 0;
       for (String appendText : appendTexts) {
           totalAppendLength += appendText.length();
       }

       // Determine available length for the original string
       Integer availableLength = maxLength - totalAppendLength;
       String ellipsis = '';

       // Check if truncation is needed
       if (originalString.length() > availableLength) {
           ellipsis = '...';
           availableLength -= ellipsis.length();
           if (availableLength > 0) {
               originalString = originalString.substring(originalString.length() - availableLength);
           } else {
               originalString = '';
           }
       }

       // Build the final string
       String finalString = ellipsis + originalString;
       for (String appendText : appendTexts) {
           finalString += appendText;
       }

       System.debug('Final String (' + finalString.length() + ' chars): ' + finalString);
       return finalString;
    }

}