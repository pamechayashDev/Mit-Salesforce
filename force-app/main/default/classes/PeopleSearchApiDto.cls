public abstract class PeopleSearchApiDto {
    public class people {
        @AuraEnabled public String mitId = '';
        @AuraEnabled public Boolean affiliate = false;
        @AuraEnabled public String affiliateSource = '';
       
        @AuraEnabled public Boolean staff = false;
        @AuraEnabled public String staffSource = '';
        @AuraEnabled public String krbName = '';
        @AuraEnabled public String krbNameSource = '';

        @AuraEnabled public String legalFirstName = '';
        @AuraEnabled public String legalFirstNameSource = '';
        @AuraEnabled public String legalLastName = '';
        @AuraEnabled public String legalLastNameSource = '';
        @AuraEnabled public String legalMiddleName = '';
        @AuraEnabled public String legalMiddleNameSource = '';
        @AuraEnabled public String preferredName = '';
        @AuraEnabled public String preferredNameSource = '';
        
        @AuraEnabled public String dobDay = '';
        @AuraEnabled public String dobDaySource = '';
        @AuraEnabled public String dobMonth = '';
        @AuraEnabled public String dobMonthSource = '';

        @AuraEnabled public Boolean student = false;
        @AuraEnabled public String studentSource = '';
        @AuraEnabled public Boolean gradStudent = false;
        @AuraEnabled public String gradStudentSource = '';
        @AuraEnabled public Boolean undergradStudent = false;
        @AuraEnabled public String undergradStudentSource = '';
        @AuraEnabled public String visitingStudent = '';
        @AuraEnabled public String visitingStudentSource = '';

        @AuraEnabled public String moiraStatus = '';
        @AuraEnabled public String moiraStatusSource = '';
        @AuraEnabled public String moiraClass = '';
        @AuraEnabled public String moiraClassSource = '';
        @AuraEnabled public String mitEmail = '';
        @AuraEnabled public String mitEmailSource = '';
        @AuraEnabled public String nonMitEmail = '';
        @AuraEnabled public String nonMitEmailSource = '';
        
        @AuraEnabled public String mitHrOrgUnitId = '';
        @AuraEnabled public String mitHrOrgUnitIdSource = '';
        @AuraEnabled public String lastSyncedOn = '';
        @AuraEnabled public String lastSyncedOnSource = '';
        @AuraEnabled public String mitIdCreationDate = '';
        @AuraEnabled public String mitIdCreationDateSource = '';
        @AuraEnabled public String mitIdObsolete = '';
        @AuraEnabled public String mitIdObsoleteSource = '';
        
        @AuraEnabled public Boolean alumni = false;
        @AuraEnabled public String alumniSource = '';
        @AuraEnabled public String alumniEmail = '';
        @AuraEnabled public String alumniEmailSource = '';
        @AuraEnabled public String alumniCanLogin = '';
        @AuraEnabled public String alumniCanLoginSource = '';
        @AuraEnabled public String alumniRecordTypeCode = '';
        @AuraEnabled public String alumniRecordTypeCodeSource = '';
        @AuraEnabled public String alumniRecordTypeName = '';
        @AuraEnabled public String alumniRecordTypeNameSource = '';

        @AuraEnabled public String kerbStatus = '';
        @AuraEnabled public String kerbStatusSource = '';
        @AuraEnabled public Boolean deceased = false;
        @AuraEnabled public String deceasedSource = '';

        @AuraEnabled public Boolean guest = false;
        @AuraEnabled public String guestSource = '';
        @AuraEnabled public String guestCreationDate = '';
        @AuraEnabled public String guestCreationDateSource = '';
        
        @AuraEnabled public String dateOfBirthValue = '';
        @AuraEnabled public String kerbCreationDate = '';
        @AuraEnabled public String kerbCreationDateSource = '';

        @AuraEnabled public String dlcName = '';
        @AuraEnabled public String dlcNameSource = '';

        @AuraEnabled public String institution = '';
        @AuraEnabled public String institutionSource = '';
    }
}