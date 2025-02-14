public with sharing class ShirleyConstants {
    public static final String MIT_INVENTOR_ACCOUNT_NAME = 'Account for MIT Inventor (Contacts)';

    public static final String COMMUNITY_PROFILE_NAME = '[CUSTOM] Customer Community Plus Login';

    public static final String COMMUNITY_PROFILE_ID = ([
        SELECT Id
        FROM Profile
        WHERE Name = :COMMUNITY_PROFILE_NAME
        LIMIT 1
    ]).Id;

    public static final String ADMIN_PROFILE_ID = ([
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
    ]).Id;

    public static final String INTEGRATION_PROFILE_ID = ([
        SELECT Id
        FROM Profile
        WHERE Name = 'Integration User'
        LIMIT 1
    ]).Id;

    public static final String DISCLOSURE_DELETE_ROLE_ID = ([
        SELECT Id
        FROM UserRole
        WHERE DeveloperName  = 'Disclosure_Management_Deleter'
        LIMIT 1
    ]).Id;

    public static final Id PERSON_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId();
}