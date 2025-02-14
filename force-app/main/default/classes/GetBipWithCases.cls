public with sharing class GetBipWithCases {
    @AuraEnabled
    public static List<SObject> getBipInfo(List<String> recordIds, String reqFrom) {
        try {
            System.debug('recordId-----' + recordIds);
            if (reqFrom == 'parent') {
                BIP_Request__c bipRequest = [
                        SELECT Id, Name, Status__c, Comments__c, Owner.Name, Primary_PI_Lookup__r.Name, (SELECT Case__c FROM BIP_Case_Junctions__r)
                        FROM BIP_Request__c
                        WHERE Id = :recordIds[0]
                        LIMIT 1
                ];

                if(bipRequest.Comments__c!=null){
                    bipRequest.Comments__c = bipRequest.Comments__c.stripHtmlTags();
                }

                // We need to get the Forrester Cases related to the BIP via the External Object:
                Set<String> forresterCaseIds = new Set<String>();
                for (BIP_Case_Junction__c caseJunction : bipRequest.BIP_Case_Junctions__r) {
                    forresterCaseIds.add(caseJunction.Case__c);
                }

                for(Forrester_Case__x forresterCase : getCaseRows(forresterCaseIds)) {
                    for (BIP_Case_Junction__c caseJunction : bipRequest.BIP_Case_Junctions__r) {
                        if (caseJunction.Case__c == forresterCase.CASE_RECID__c) {
                            caseJunction.Case__r = forresterCase;
                        }
                    }
                }

                return new List<SObject>{bipRequest};
            } else {
                List<BIP_PI__c> bipPis = [
                        SELECT Id, Name, Role__c, BIP_Request__c, Status__c, CreatedBy.Name, PI__r.Name, PI_MIT_ID__c, 
                               Comment__c, Requested_Action__c, 
                               (SELECT Case__c FROM BIP_Case_Junctions__r)
                        FROM BIP_PI__c
                        WHERE Id IN :recordIds
                ];

                Set<String> forresterCaseIds = new Set<String>();

                for (BIP_PI__c bipPi : bipPis) {
                    // We need to get the Forrester Cases related to the BIP via the External Object:
                    for (BIP_Case_Junction__c caseJunction : bipPi.BIP_Case_Junctions__r) {
                        forresterCaseIds.add(caseJunction.Case__c);
                    }
                }

                for (Forrester_Case__x forresterCase : getCaseRows(forresterCaseIds)) {

                    for (BIP_PI__c bipPi : bipPis) {
                        for (BIP_Case_Junction__c caseJunction : bipPi.BIP_Case_Junctions__r) {
                            if (caseJunction.Case__c == forresterCase.CASE_RECID__c) {
                                caseJunction.Case__r = forresterCase;
                            }
                        }
                    }
                }

                return bipPis;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<Forrester_Case__x> getCaseRows(Set<String> caseRecIds) {
        // Comments are the Column names in the childDetail LWC
        List<Forrester_Case__x> caseList = ExternalObjectQuery.records([
                SELECT Id,
                        CASE_RECID__c,
                        CONTRACT_CASE_NUM__c, // Case Button Label
                        DISCLOSURE_TITLE__c, //Case Title
                        STATUS__c, //Case Status
                        OPEN_DATE__c, //Open Date
                        ANTIC_PUBLISH_DATE__c, //Anticipated Publish Date
                        TLO_NAME__c, //TLO Officer
                        TLO_EMAIL__c, //TLO Email
                        TLO_MIT_ID__c, //TLO MIT ID
                        CASE_TYPE__c, //Case Type
                        CASE_SPONSOR_NAMES__c, //Sponsor Names
                        PATENT_COUNT__c, //Patents/Patent Count
                        CO_INVENTORS__c// Co-Inventors
                FROM Forrester_Case__x
                WHERE CASE_RECID__c IN :caseRecIds
        ]);

        if (caseList.size() > 0) {
            return caseList;
        } else {
            return new List<Forrester_Case__x>();
        }
    }
}