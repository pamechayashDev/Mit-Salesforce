/**
 * Created by Andreas du Preez on 2025/02/06.
 */

public with sharing class BIPController {

    // Get BIP PIs, available TLO Officers and recommended TLO Officer for TLO Assignment
    @AuraEnabled
    public static List<BIPPITLOAssignment> getBipPisForTLOAssignment(String bipRequestRecordId) {
        List<BIPPITLOAssignment> result = new List<BIPPITLOAssignment>();
        List<String> recordIds = new List<String>();
        for (BIP_PI__c bipPi : [SELECT Id FROM BIP_PI__c WHERE BIP_Request__c = :bipRequestRecordId]) {
            recordIds.add(bipPi.Id);
        }

        // Get BIP PIs with Cases
        List<BIP_PI__c> bipPis = GetBipWithCases.getBipInfo(recordIds, 'child');

        for (BIP_PI__c bipPi : bipPis) {
            if (bipPi.Role__c == 'Additional PI' && bipPi.BIP_Case_Junctions__r.size() == 0) {
                continue;
            }

            BIPPITLOAssignment bipPiTloAssignment = new BIPPITLOAssignment(bipPi, new List<TLOOfficer>(), new TLOOfficer());

            // Get the TLO Officers for each BIP PI and assign the recommended TLO Officer based on the number of cases
            Integer maxCases = 0;
            TLOOfficer recommendedTloOfficer = new TLOOfficer();
            for (BIP_Case_Junction__c caseJunction : bipPi.BIP_Case_Junctions__r) {
                if (caseJunction.Case__r != null && caseJunction.Case__r.TLO_MIT_ID__c != null && caseJunction.Case__r.TLO_NAME__c != null) {
                    TLOOfficer tloOfficer = new TLOOfficer(caseJunction.Case__r.TLO_NAME__c, caseJunction.Case__r.TLO_EMAIL__c, caseJunction.Case__r.TLO_MIT_ID__c);
                    Integer casesForTloOfficer = 1;
                    for (TLOOfficer availableTloOfficer : bipPiTloAssignment.availableTloOfficers) {
                        if (availableTloOfficer.mitId == tloOfficer.mitId) {
                            casesForTloOfficer++;
                        }
                    }

                    if (casesForTloOfficer > maxCases) {
                        maxCases = casesForTloOfficer;
                        recommendedTloOfficer = tloOfficer;
                    }

                    if (casesForTloOfficer == 1) {
                        bipPiTloAssignment.availableTloOfficers.add(tloOfficer);
                    }
                }
            }
            bipPiTloAssignment.recommendedTloOfficer = recommendedTloOfficer;

            result.add(bipPiTloAssignment);
        }

        return result;
    }

    @AuraEnabled
    public static Boolean updateBipPiTLOAssignment(List<BIP_PI__c> bipPis) {
        try {
            List<BIP_PI__c> bipPisToUpdate = new List<BIP_PI__c>();
            List<BIP_Request__c> bipRequestsToUpdate = new List<BIP_Request__c>();

            for (BIP_PI__c bipPi : bipPis) {
                BIP_PI__c bipPiToUpdate = new BIP_PI__c(
                        Id = bipPi.Id,
                        TLO_Officer_Email__c = bipPi.TLO_Officer_Email__c,
                        TLO_Officer_MIT_ID__c = bipPi.TLO_Officer_MIT_ID__c,
                        TLO_Officer_Name__c = bipPi.TLO_Officer_Name__c);
                bipPisToUpdate.add(bipPiToUpdate);

                if (bipPi.Role__c == 'Primary PI') {
                    BIP_Request__c bipRequestToUpdate = new BIP_Request__c(
                            Id = bipPi.BIP_Request__c,
                            TLO_Officer_Email__c = bipPi.TLO_Officer_Email__c,
                            TLO_Officer_MIT_ID__c = bipPi.TLO_Officer_MIT_ID__c,
                            TLO_Officer_Name__c = bipPi.TLO_Officer_Name__c,
                            Status__c = 'Assigned to TLO');
                    bipRequestsToUpdate.add(bipRequestToUpdate);
                }
            }

            update bipPisToUpdate;
            update bipRequestsToUpdate;

            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    // DTO Objects
    public class BIPPITLOAssignment {
        @AuraEnabled
        public BIP_PI__c bipPi { get; set; }
        @AuraEnabled
        public List<TLOOfficer> availableTloOfficers { get; set; }
        @AuraEnabled
        public TLOOfficer recommendedTloOfficer { get; set; }

        public BIPPITLOAssignment(BIP_PI__c bipPi, List<TLOOfficer> availableTloOfficers, TLOOfficer recommendedTloOfficer) {
            this.bipPi = bipPi;
            this.availableTloOfficers = availableTloOfficers;
            this.recommendedTloOfficer = recommendedTloOfficer;
        }
    }

    public class TLOOfficer {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public String mitId { get; set; }

        public TLOOfficer() {
        }

        public TLOOfficer(String name, String email, String mitId) {
            this.name = name;
            this.email = email;
            this.mitId = mitId;
        }
    }
}