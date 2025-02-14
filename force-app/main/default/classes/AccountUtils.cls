public with sharing class AccountUtils {
    public static void separateAccounts(
        List<Account> accounts,
        List<Account> personAccounts,
        List<Account> otherAccounts
    ) {
        if (accounts != null && !accounts.isEmpty()) {
            for (Account account : accounts) {
                if (account.IsPersonAccount) {
                    personAccounts.add(account);
                } else {
                    otherAccounts.add(account);
                }
            }
        }
    }

    public static void separateAccountsMap(
        Map<Id, Account> allAccountsMap,
        Map<Id, Account> personAccountsMap,
        Map<Id, Account> businessAccountsMap
    ) {
        if (allAccountsMap != null && !allAccountsMap.isEmpty()) {
            for (Id accountId : allAccountsMap.keySet()) {
                Account account = allAccountsMap.get(accountId);
                if (account.IsPersonAccount) {
                    personAccountsMap.put(accountId, account);
                } else {
                    businessAccountsMap.put(accountId, account);
                }
            }
        }
    }

    public static String getAccountIdFromCurrentUser() {
        // Get User
        User user = [
            SELECT Id, Contact.Account.Id
            FROM User
            WHERE Id = :userinfo.getUserId()
            LIMIT 1
        ];
        return user.Contact.Account.Id;
    }
}