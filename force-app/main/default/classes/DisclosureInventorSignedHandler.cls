public with sharing class DisclosureInventorSignedHandler {
    public static void handleInventorSigned(
        List<DisclosureInventor__c> inventorList
    ) {
        System.debug('DisclosureInventorSignedHandler START');
        if (inventorList != null && !inventorList.isEmpty()) {
            List<Async_Request__c> asyncJobsForInventorSigning = new List<Async_Request__c>();

            for (DisclosureInventor__c inventor : inventorList) {
                Boolean inventorMadeSigningDecision = (inventor.Signed_Status__c !=
                null &&
                inventor.Signed_Status__c != 'Pending');
                Boolean isSubmittingInventor =
                    inventor.Disclosure__r.Submitting_Contact__c ==
                    inventor.Contact__c;
                // Need to send Opt Out comment, and Signed Status to Forrester
                if (inventorMadeSigningDecision && !isSubmittingInventor) {
                    // The additional questions of the inventor who submitted the disclosure should not be sent to Forrester twice.
                    // they are already sent for the submitting inventor (inventor.Disclosure__r.Submitting_Contact__c)
                    // when Disclosure is approved -> if Disclosure.SubmittedOnBehalf__c == false.
                    asyncJobsForInventorSigning.add(
                        AsyncRequestHelper.prepareAsyncRequest(
                            inventor.Id,
                            'DisclosureInventor__c',
                            'InventorSignedDisclosureToForresterJob'
                        )
                    );
                }

                if (inventor.Signed_Status__c == 'Yes') {
                    //nothing to do against DocuSign of Forrester if inventor opted out
                    asyncJobsForInventorSigning.add(
                        AsyncRequestHelper.prepareAsyncRequest(
                            inventor.Id,
                            'DisclosureInventor__c',
                            'FetchInventorSignedDocJob'
                        )
                    );
                }
            }
            System.debug(
                'DisclosureInventorSignedHandler asyncJobsForInventorSigning:- ' +
                asyncJobsForInventorSigning
            );
            if (
                asyncJobsForInventorSigning != null &&
                !asyncJobsForInventorSigning.isEmpty()
            ) {
                System.debug(
                    'DisclosureInventorSignedHandler asyncJobsForInventorSigning.size():- ' +
                    asyncJobsForInventorSigning.size()
                );
                insert asyncJobsForInventorSigning;
            }
        }
        System.debug('DisclosureInventorSignedHandler FINISH');
    }
}