public with sharing class PeopleSearchApi {
    @AuraEnabled(cacheable=true)
    public static List<PeopleSearchApiDto.people>  getPeopleDataWithSource(String api, String resource) {
        System.debug('Resource: ' + resource);
        List<PeopleSearchApiDto.people> peopleListResult = new List<PeopleSearchApiDto.people>();

        try {
            String responseBody = AwsApiCall.restGet(api, resource);

            // Parse JSON response
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (response.containsKey('people')) {
                List<Object> peopleList = (List<Object>) response.get('people');

                for (Object personObj : peopleList) {
                    Map<String, Object> personMap = (Map<String, Object>) personObj;
                    PeopleSearchApiDto.people person = new PeopleSearchApiDto.people();

                    person.mitId = (String) personMap.get('mitId');
                    
                    person.affiliate = getBooleanValue(personMap, 'affiliate', false);
                    person.affiliateSource = getSourceValue(personMap, 'affiliate', '');
                    person.student = getBooleanValue(personMap, 'student', false);
                    person.studentSource = getSourceValue(personMap, 'student', '');
                    person.staff = getBooleanValue(personMap, 'staff', false);
                    person.staffSource = getSourceValue(personMap, 'staff', '');
                    person.alumni = getBooleanValue(personMap, 'alumni', false);
                    person.alumniSource = getSourceValue(personMap, 'alumni', '');
                    
                    person.krbName = getStringValue(personMap, 'krbName', '');
                    person.krbNameSource = getSourceValue(personMap, 'krbName', '');
                    
                    person.preferredName = getStringValue(personMap, 'preferredName', '');
                    person.preferredNameSource = getStringValue(personMap, 'preferredName', '');
                    person.legalFirstName = getStringValue(personMap, 'legalFirstName', '');
                    person.legalFirstNameSource = getSourceValue(personMap, 'legalFirstName', '');
                    person.legalLastName = getStringValue(personMap, 'legalLastName', '');
                    person.legalLastNameSource = getSourceValue(personMap, 'legalLastName', '');
                    person.legalMiddleName = getStringValue(personMap, 'legalMiddleName', '');
                    person.legalMiddleNameSource = getSourceValue(personMap, 'legalMiddleName', '');
                    
                    person.dobDay = getStringValue(personMap, 'dobDay', '');
                    person.dobDaySource = getSourceValue(personMap, 'dobDay', '');
                    person.dobMonth = getStringValue(personMap, 'dobMonth', '');
                    if (!String.isBlank(person.dobMonth) && !String.isBlank(person.dobDay)) {
                        person.dateOfBirthValue = person.dobMonth + '/' + person.dobDay;
                    }
                    person.dobMonthSource = getSourceValue(personMap, 'dobMonth', '');

                    person.gradStudent = getBooleanValue(personMap, 'gradStudent', false);
                    person.gradStudentSource = getSourceValue(personMap, 'gradStudent', '');
                    person.undergradStudent = getBooleanValue(personMap, 'undergradStudent', false);
                    person.undergradStudentSource = getSourceValue(personMap, 'undergradStudent', '');
                    person.visitingStudent = getStringValue(personMap, 'visitingStudent', '');
                    person.visitingStudentSource = getSourceValue(personMap, 'visitingStudent', '');
                    person.moiraStatus = getStringValue(personMap, 'moiraStatus', '');
                    person.moiraStatusSource = getSourceValue(personMap, 'moiraStatus', '');
                    person.moiraClass = getStringValue(personMap, 'moiraClass', '');
                    person.moiraClassSource = getSourceValue(personMap, 'moiraClass', '');
                    person.mitEmail = getStringValue(personMap, 'mitEmail', '');
                    person.mitEmailSource = getSourceValue(personMap, 'mitEmail', '');
                    person.nonMitEmail = getStringValue(personMap, 'nonMitEmail', '');
                    person.nonMitEmailSource = getSourceValue(personMap, 'nonMitEmail', '');
                    person.alumniEmail = getStringValue(personMap, 'alumniEmail', '');
                    person.alumniEmailSource = getSourceValue(personMap, 'alumniEmail', '');
                    person.mitHrOrgUnitId = getStringValue(personMap, 'mitHrOrgUnitId', '');
                    person.mitHrOrgUnitIdSource = getSourceValue(personMap, 'mitHrOrgUnitId', '');
                    person.lastSyncedOn = getStringValue(personMap, 'lastSyncedOn', '');
                    person.lastSyncedOnSource = getSourceValue(personMap, 'lastSyncedOn', '');
                    person.mitIdCreationDate = getStringValue(personMap, 'mitIdCreationDate', '');
                    person.mitIdCreationDateSource = getSourceValue(personMap, 'mitIdCreationDate', '');
                    person.mitIdObsolete = getStringValue(personMap, 'mitIdObsolete', '');
                    person.mitIdObsoleteSource = getSourceValue(personMap, 'mitIdObsolete', '');
                    person.alumniCanLogin = getStringValue(personMap, 'alumniCanLogin', '');
                    person.alumniCanLoginSource = getSourceValue(personMap, 'alumniCanLogin', '');
                    person.alumniRecordTypeCode = getStringValue(personMap, 'alumniRecordTypeCode', '');
                    person.alumniRecordTypeCodeSource = getSourceValue(personMap, 'alumniRecordTypeCode', '');
                    person.alumniRecordTypeName = getStringValue(personMap, 'alumniRecordTypeName', '');
                    person.alumniRecordTypeNameSource = getSourceValue(personMap, 'alumniRecordTypeName', '');
                    person.kerbStatus = getStringValue(personMap, 'kerbStatus', '');
                    person.kerbStatusSource = getSourceValue(personMap, 'kerbStatus', '');
                    person.deceased = getBooleanValue(personMap, 'deceased', false);
                    person.deceasedSource = getSourceValue(personMap, 'deceased', '');
                    
                    person.guest = getBooleanValue(personMap, 'guest', false);
                    person.guestSource = getSourceValue(personMap, 'guest', '');
                    person.guestCreationDate = getStringValue(personMap, 'guestCreationDate', '');
                    person.guestCreationDateSource = getSourceValue(personMap, 'guestCreationDate', '');
                    
                    person.kerbCreationDate = getStringValue(personMap, 'kerbCreationDate', '');
                    person.kerbCreationDateSource = getSourceValue(personMap, 'kerbCreationDate', '');
                    person.dlcName = getStringValue(personMap, 'dlcName', '');
                    person.dlcNameSource = getSourceValue(personMap, 'dlcName', '');

                    person.institution = getStringValue(personMap, 'institution', '');
                    person.institutionSource = getSourceValue(personMap, 'institution', '');

                    

                    // Add the person to the result list
                    peopleListResult.add(person);

                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return peopleListResult;
    }

    private static String getStringValue(Map<String, Object> mapValue, String key, String defaultValue) {
        if (mapValue.containsKey(key) && mapValue.get(key) instanceof Map<String, Object>) {
            Map<String, Object> nestedMap = (Map<String, Object>) mapValue.get(key);
            if (nestedMap.containsKey('value') && nestedMap.get('value') instanceof String) {
                return (String) nestedMap.get('value');
            }
        }
        return defaultValue;
    }

    private static Boolean getBooleanValue(Map<String, Object> mapValue, String key, Boolean defaultValue) {
        if (mapValue.containsKey(key) && mapValue.get(key) instanceof Map<String, Object>) {
            Map<String, Object> nestedMap = (Map<String, Object>) mapValue.get(key);
            if (nestedMap.containsKey('value') && nestedMap.get('value') instanceof Boolean) {
                return (Boolean) nestedMap.get('value');
            }
        }
        return defaultValue;
    }

    private static String getSourceValue(Map<String, Object> mapValue, String key, String defaultValue) {
        if (mapValue.containsKey(key) && mapValue.get(key) instanceof Map<String, Object>) {
            Map<String, Object> nestedMap = (Map<String, Object>) mapValue.get(key);
            if (nestedMap.containsKey('source') && nestedMap.get('source') instanceof String) {
                String source = (String) nestedMap.get('source');
                String sourceValue;
                if (source == 'guest_accounts') {
                    sourceValue = 'Guest Account';
                } else if (source == 'mit_id') {
                    sourceValue = 'MITID DB';
                } else if (source == 'sap') {
                    sourceValue = 'SAP';
                } else if (source == 'ldap') {
                    sourceValue = 'LDAP';
                } else if (source == 'alumni') {
                    sourceValue = 'Alumni';
                } else if (source == 'covid') {
                    sourceValue = 'Covid DB';
                } else if (source == 'mitsis') {
                    sourceValue = 'MITSIS';
                } else {
                    sourceValue = source;
                }
                return 'Source: ' + sourceValue;
            }
        }
        return defaultValue;
    }
}