/**
* @File Name : ChildBipRecordsController .cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 13, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 13, 2025 |   | Initial Version
**/

public class ChildBipRecordsController  {
	@AuraEnabled
	public static List<BIP_Request__c> getChildRecords(Id parentId) {
        return [SELECT Id, Primary_PI__c, Primary_PI_Lookup__c,
				Status__c, Owner.Name
                FROM BIP_Request__c 
                WHERE Parent_BIP__c = :parentId 
                ORDER BY CreatedDate DESC];
    }
}