public with sharing class CrdrDao {

    public static Forrester_SHIR_CRDR_VIEW__x getCrdrWithAllFields(String crdrIdStr) {

        // Get all of the fields on the object
        Map<String, Schema.SObjectField> fieldMap = Forrester_SHIR_CRDR_VIEW__x.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        List<String> lstFieldNames = new List<String>(setFieldNames);
        String qryString = 'SELECT ' + String.join(lstFieldNames, ',') + ' FROM Forrester_SHIR_CRDR_VIEW__x WHERE Id = \'' + crdrIdStr + '\'';
        List<Forrester_SHIR_CRDR_VIEW__x> crdrs = ExternalObjectQuery.records(Database.query(qryString));
        if (!crdrs.isEmpty()) {
            return crdrs[0];
        }
        return null;
    }

    public static List<CrdrNoteWrapper> getCrdrNotes(String caseCrdrRecId) {
        List<CrdrNoteWrapper> notes = new List<CrdrNoteWrapper>();

        List<Case_CRDR__c> parentObjects = [SELECT ID from Case_CRDR__c WHERE ExternalCaseCRDRId__c = :caseCrdrRecId];
        if (!parentObjects.isEmpty()) {
            List<CreateNoteRecord.NotesWrapper> noteRecords = CreateNoteRecord.getNoteRecords(parentObjects[0].Id);
            for (CreateNoteRecord.NotesWrapper document : noteRecords) {
                CrdrNoteWrapper note = new CrdrNoteWrapper();
                note.title = document.Title;
                note.createdDate = document.CreatedDate;
                note.createdBy = document.CreatedByName ;
                note.text = document.Content;
                note.noteLevel = document.noteLevel;
                notes.add(note);
            }
        }
        return notes;
    }

    public static CrdrWrapper getCrdrWrapperById(String crdrIdStr) {

        Forrester_SHIR_CRDR_VIEW__x crdr = getCrdrWithAllFields(crdrIdStr);
        List<CrdrNoteWrapper> notes = getCrdrNotes(crdr.CASE_CRDR_RECID__c);

        Map<String, CrdrNoteLevelWrapper> levelMap = new Map<String, CrdrNoteLevelWrapper> ();

        // The Figma require Empty Level [x] sections. It is not guaranteed that all the Level notes will exist.
        Schema.DescribeFieldResult fieldDetail = ContentVersion.Note_level__c.getDescribe();
        List<Schema.PicklistEntry> validApplicationValues = fieldDetail.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : validApplicationValues ) {
            String value =  pickListVal.getValue();
            levelMap.put(value, new CrdrNoteLevelWrapper(value));
        }


        for (CrdrNoteWrapper note : notes ) {
            String key = !String.isEmpty(note.noteLevel) ? note.noteLevel : '';
            if (!levelMap.containsKey(key)) {
                levelMap.put(key, new CrdrNoteLevelWrapper(note.noteLevel));
            }
            CrdrNoteLevelWrapper noteLevel = levelMap.get(key);
            noteLevel.notes.add(note);

        }
        List<CrdrNoteLevelWrapper> levels = levelMap.values();
        levels.sort(); // Sort by levelName

        CrdrWrapper crdrWrapper = new CrdrWrapper();
        crdrWrapper.caseNumber = crdr.CONTRACT_CASE_NUM__c;
        crdrWrapper.financialYear = crdr.FY__c;
        crdrWrapper.disclosureTitle = crdr.DISCLOSURE_TITLE__c;
        crdrWrapper.levels = levels;


        String strJSON = JSON.serialize(crdrWrapper);
        System.debug(strJSON);
       
        return crdrWrapper;
    }


}