trigger AccountTrigger on Account(
    before insert,
    after insert,
    before update,
    after update
) {
    // Separate person accounts and other accounts
    List<Account> personAccounts = new List<Account>();
    List<Account> otherAccounts = new List<Account>();
    AccountUtils.separateAccounts(Trigger.new, personAccounts, otherAccounts);

    // Separate old person accounts and other accounts
    Map<Id, Account> personAccountsOld = new Map<Id, Account>();
    Map<Id, Account> businessAccountsOld = new Map<Id, Account>();
    AccountUtils.separateAccountsMap(
        Trigger.oldMap,
        personAccountsOld,
        businessAccountsOld
    );

    if (personAccounts != null && !personAccounts.isEmpty()) {
        System.debug('Person Accounts: ' + personAccounts);
        if (Trigger.isBefore && Trigger.isInsert) {
            PersonAccountTriggerHandler.onBeforeInsert(personAccounts);
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            PersonAccountTriggerHandler.onBeforeUpdate(
                personAccounts,
                personAccountsOld
            );
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            PersonAccountTriggerHandler.onAfterUpdate(
                personAccounts,
                personAccountsOld
            );
        }
    }
    if (otherAccounts != null && !otherAccounts.isEmpty()) {
        // Other accounts handler
        System.debug('Other Accounts: ' + otherAccounts);
    }

}