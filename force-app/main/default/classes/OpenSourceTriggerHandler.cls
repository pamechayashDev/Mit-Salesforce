public class OpenSourceTriggerHandler {
    /**
     * Trigger handler for Open_Source__c before insert events
     * @param openSourceList List of new Open_Source__c objects to be processed
     */
    public static void onBeforeInsert(List<Open_Source__c> openSourceList) {
        validateOneToOne(openSourceList);
    }

    /**
     * Trigger handler for Open_Source__c before update events
     * @param openSourceList List of new Open_Source__c objects to be processed
     */
    public static void onBeforeUpdate(List<Open_Source__c> openSourceList) {
        validateOneToOne(openSourceList);
    }

    /**
     * Trigger handler for Open_Source__c after delete events
     * @param openSourceList List of new Open_Source__c objects to be processed
     */
    public static void onAfterDelete(List<Open_Source__c> openSourceList) {
        deleteRelatedDeptHeads(openSourceList);
    }

    /**
     * Validate that an Open_Source__c object is only assigned to either a
     * Software_Code_Disclosure__c object or a Copyright_Disclosure__c, but not
     * both
     * @param openSourceList List of Open_Source__c objects to be processed
     */
    private static void validateOneToOne(List<Open_Source__c> openSourceList) {
        for (Open_Source__c openSource : openSourceList) {
            if (openSource.Copyright_Disclosure__c != null && openSource.Software_Code_Disclosure__c != null) {
                openSource.addError('Open source may only be added to one of either a Copyright Disclosure or a Software Code Disclosure');
            }
        }
    }

    /**
     * Delete any Department_Head__c objects that are related to the parent if
     * the parent has the corresponding "Is Open Source" flag set to false
     * Disclosure__c objects
     * @param openSourceList List of Open_Source__c objects to be processed
     */
    private static void deleteRelatedDeptHeads(List<Open_Source__c> openSourceList) {
        List<Disclosure__c> discList = new List<Disclosure__c>();
        List<Id> softwareCodeDiscList = new List<Id>();
        List<Id> copyrightDiscList = new List<Id>();

        for(Open_Source__c openSource : openSourceList) {
            if(openSource.Copyright_Disclosure__c != null) {
                copyrightDiscList.add(openSource.Copyright_Disclosure__c);
            }
            if(openSource.Software_Code_Disclosure__c != null) {
                softwareCodeDiscList.add(openSource.Software_Code_Disclosure__c);
            }
        }

        discList.addAll([
            SELECT Id
            FROM Disclosure__c
            WHERE Id IN (
                SELECT Disclosure__c
                FROM Software_Code_Disclosure__c
                WHERE
                    Id IN :softwareCodeDiscList AND
                    Is_Open_Source_YN__c = 'No'
            )
        ]);

        discList.addAll([
            SELECT Id
            FROM Disclosure__c
            WHERE Id IN (
                SELECT Disclosure__c
                FROM Copyright_Disclosure__c
                WHERE
                    Id IN :copyrightDiscList AND
                    Creators_Request_Distrib_Open_Source_YN__c = 'No'
            )
        ]);

        List<Department_Head__c> deptHeadList = [
            SELECT Id
            FROM Department_Head__c
            WHERE Disclosure__c IN :discList
        ];

        delete deptHeadList;
    }
}