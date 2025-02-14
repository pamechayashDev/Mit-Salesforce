public with sharing class DisclosureTransitionValidation {


    private static Map<String, Integer> disclosureStatus {
        get {
            if (disclosureStatus == null) {
                disclosureStatus = new Map<String, Integer> {
                    'Draft' => 1000,
                    'Pending Department Approval' => 2000,
                    'Inventor Submitted' => 3000,
                    'Archived' => 4000,
                    'Approved' => 5000,
                    'Rejected' => 6000
                };
            }
            return disclosureStatus;
        }
        private set;
    }

    private static Map<Integer, List<Integer>> transitions {
        get {
            if (transitions == null) {
                transitions = new Map<Integer, List<Integer>> {
                     0 => new List<Integer>{1000}, // from null to Draft

                     1000 => new List<Integer>{2000, 3000, 4000}, //From Draft to [Pending Department Approval, Inventor Submitted, Archived]

                     2000 => new List<Integer>{3000, 6000}, //From Pending Department Approval to [Inventor Submitted, Rejected]

                     3000 => new List<Integer>{5000, 6000}, //From Inventor Submitted to [Approved, Rejected]

                     4000 => new List<Integer>{1000}, //From Archived back to Draft. TLOS-3550

                     5000 => new List<Integer>(), //No transition from Approved allowed

                     6000 => new List<Integer>() //Rejected
                };
            }
            return transitions;
        }
        private set;
    }


    public static void statusTransitionValidation(List<Disclosure__c> disList, Map<Id, Disclosure__c> oldDis) {
         for (Disclosure__c d : disList) {
            if (d.Status__c != oldDis.get(d.Id).Status__c ) {
                String status = d.Status__c;
                String oldStatus = oldDis.get(d.Id).Status__c;

                Integer key = 0;
                Integer oldKey = 0;
                if (disclosureStatus.containsKey(status)) {
                    key = disclosureStatus.get(status);
                }
                if (disclosureStatus.containsKey(oldStatus)) {
                    oldKey = disclosureStatus.get(oldStatus);
                }
                List<Integer> allowedTransition = transitions.get(oldKey);
                if (!allowedTransition.contains(key)) {
                    d.addError('Disclosure status transition not allowed from ' + oldStatus + ' to ' + status);
                }

            }
      }
    }
}