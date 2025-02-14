@isTest
public class CreateAccountTest {
    @isTest
    public static void testSaveAccount() {
        // Test Data Setup
        // Create a record type for Person Account if needed
        Id personAccountRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id;

        // Pre-existing Person Account with MIT ID
        Account existingAccount = new Account(
            LastName = 'Doe',
            RecordTypeId = personAccountRecordTypeId,
 
            MitId__pc = '12345'
        );
        insert existingAccount;

        // Test inputs
        List<String> mitIdList = new List<String>{'12345', '', '67890'};
        List<String> accNames = new List<String>{'Doe', 'Smith', 'Johnson'};

        // Call the method
        Test.startTest();
        List<String> result = CreateAccount.saveAccount(mitIdList, accNames);
        Test.stopTest();

        // Assertions
        System.assertEquals(3, result.size(), 'Three accounts should be processed.');
        System.assertEquals(existingAccount.Id, result[0], 'The first account should match the pre-existing account with MIT ID 12345.');

        
        List<Account> createdAccounts = [SELECT Id, LastName, MitId__pc, IsPersonAccount 
                                         FROM Account 
                                         WHERE Id IN :result AND Id != :existingAccount.Id];
        System.assertEquals(2, createdAccounts.size(), 'Two new accounts should have been created.');

        // Verify Smith and Johnson accounts
        Boolean smithFound = false;
        Boolean johnsonFound = false;

        for (Account acc : createdAccounts) {
            if (acc.LastName == 'Smith') {
                smithFound = true;
                System.assertEquals(null, acc.MitId__pc, 'Smith account should not have an MIT ID.');
            }
            if (acc.LastName == 'Johnson') {
                johnsonFound = true;
                System.assertEquals('67890', acc.MitId__pc, 'Johnson account should have MIT ID 67890.');
            }
        }

        System.assert(smithFound, 'Account for Smith should exist.');
        System.assert(johnsonFound, 'Account for Johnson should exist.');
    }
}