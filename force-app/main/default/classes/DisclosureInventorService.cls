/**
 * Created by Andreas du Preez on 2024/08/02.
 */

public without sharing class DisclosureInventorService {

    public static List<DisclosureInventor__c> linkDisclosureInventorToIPIARecords(List<DisclosureInventor__c> disclosureInventors) {
        Set<String> mitIds = new Set<String>();

        // Get unique MIT ID's
        for (DisclosureInventor__c disclosureInventor : disclosureInventors) {
            mitIds.add(disclosureInventor.Contact__r.MitId__pc);
        }

        // Get all the IPIA Records for the MitIds
        List<IPIA_Record__c> ipiaRecords = [
                SELECT Id, MitId__c, SignDatetime__c FROM IPIA_Record__c WHERE MitId__c IN :mitIds
        ];

        // Assign the `IPIA_Record__c` IPIA lookup field
        return DisclosureInventorService.processIPIARecordToDisclosureInventorLink(disclosureInventors, ipiaRecords);
    }

    public static List<DisclosureInventor__c> processIPIARecordToDisclosureInventorLink(List<DisclosureInventor__c> disclosureInventors, List<IPIA_Record__c> ipiaRecords) {
        System.debug('Total Disclosure Inventors: ' + disclosureInventors.size());
        Map<String, List<IPIA_Record__c>> mitIdToIpiaRecords = new Map<String, List<IPIA_Record__c>>();

        // Get the IPIA Records by MIT ID
        for (IPIA_Record__c ipiaRecord : ipiaRecords) {
            if (!mitIdToIpiaRecords.containsKey(ipiaRecord.MitId__c)) {
                mitIdToIpiaRecords.put(ipiaRecord.MitId__c, new List<IPIA_Record__c>{ipiaRecord});
            }
            else {
                mitIdToIpiaRecords.get(ipiaRecord.MitId__c).add(ipiaRecord);
            }
        }

        // Update the Disclosure Inventor's IPIA Lookup
        Integer matchingIpiaCount = 0;
        Integer noMatchingIpiaCount = 0;
        for (DisclosureInventor__c disclosureInventor : disclosureInventors) {
            if (mitIdToIpiaRecords.containsKey(disclosureInventor.Contact__r.MitId__pc)) {
                IPIA_Record__c latestIpia = mitIdToIpiaRecords.get(disclosureInventor.Contact__r.MitId__pc)[0];
                for (IPIA_Record__c ipia : mitIdToIpiaRecords.get(disclosureInventor.Contact__r.MitId__pc)) {
                    if (ipia.SignDatetime__c > latestIpia.SignDatetime__c) {
                        latestIpia = ipia;
                    }
                }
                disclosureInventor.IPIA_Record__c = latestIpia.Id;
                matchingIpiaCount++;
            }
            else {
                disclosureInventor.IPIA_Record__c = null;
                noMatchingIpiaCount++;
            }
        }

        System.debug('Disclosure Inventors to update: ' + matchingIpiaCount);
        System.debug('Disclosure Inventors with no matching IPIA Records: ' + noMatchingIpiaCount);
        return disclosureInventors;
    }
}