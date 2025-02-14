public with sharing class UpdateRecordHelper {
    /**
     * Update some fields for a TLO Contact Record
     * @param id The Id of the record to be updated
     * @param moiraStatus The new Moira Status to be used
     * @param isAlumni The new Alumni status to be used
     */
    @AuraEnabled
    public static void updateContactFields(
        String id,
        String moiraStatus,
        Boolean isAlumni
    ) {
        try {
            Account contact = [
                SELECT Id, MoiraStatus__pc, IsAlumni__pc
                FROM Account
                WHERE Id = :id AND IsPersonAccount = TRUE
            ];
            contact.MoiraStatus__pc = moiraStatus;
            contact.IsAlumni__pc = isAlumni;
            update contact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Update Birthday field for a TLO Contact Record
     * @param id The Id of the record to be updated
     * @param dateOfBirth The new Birth Date to be used
     */
    @AuraEnabled
    public static void updateContactDoB(String id, Date dateOfBirth) {
        try {
            Account contact = [
                SELECT Id, PersonBirthdate
                FROM Account
                WHERE Id = :id AND IsPersonAccount = TRUE
            ];
            contact.PersonBirthdate = dateOfBirth;
            update contact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}