public with sharing class CreateNoteRecord {
    @AuraEnabled
    public static void createRecord (ContentVersion nt, id PrentId){
        try{
            if(nt != null){
                /*
                * A ContentNote is the same as a ContentDocument where FileType=SNOTE.
                * Creating a ContentVersion where PathOnclient is suffixed with '.snote' is the same as inserting a Note
                * Createing a ContentVersion will automatically create a ContentDocument and set the LatestPublishedVersionId to the Id of the ContentVersion
                * Since the contentversion has required fields, We are inserting a ContentVersion then find the ContentDocument
                */
                Id noteRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Note').getRecordTypeId();

                // UNSAFE_HTML_CONTENT: Notes cant be saved because it contains HTML tags. We need to use the ContentNote to handle the save
                String base64VersionData = String.valueOf(nt.VersionData);
                if(Test.isRunningTest()) {
                   // JavaScript does not send a 'real' Blob Object, and the Unit test does. String.valueOf will return the value of 'Blob[32]'
                   // and toString System.UnexpectedException: Illegal arguments
                   base64VersionData = nt.VersionData.toString();
                }


                System.debug('nt.VersionData ' + base64VersionData);
                ContentVersion version = new ContentVersion(
                    Title = nt.Title,
                    Document_Classification__c = 'Original_Document',
                    Entity_Sub_Type__c = 'N_A',
                    VersionData = Blob.valueOf(base64VersionData),
                    PathOnClient = nt.Title + '.snote',
                    recordTypeId = noteRecordTypeId,
                    IsMajorVersion = false,
                    Note_level__c = nt.Note_level__c
                );
                insert version;

                ContentDocument cd = [SELECT id FROM ContentDocument WHERE LatestPublishedVersionId = :version.Id];

                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = cd.id,
                    LinkedEntityId = PrentId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                );
                insert cdl;

                // The Version Data is base 64 encoded
                ContentNote note = [SELECT Id, LatestPublishedVersionId, LatestContentId, Title, Content FROM ContentNote where Id =:cd.id];
                note.Content = EncodingUtil.base64Decode(base64VersionData);
                update note;

            }
        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void updateContentNote(String contentNoteId, String title, String contentBase64, String notelevel) {
        try {
            List<ContentVersion> updateContentVersionList = new List<ContentVersion>();
            System.debug('contentBase64 ' + contentBase64);
            ContentNote[] cntList = [SELECT Id, LatestPublishedVersionId, LatestContentId, Title FROM ContentNote where Id =:contentNoteId];
            String contentVersionId = cntList[0].LatestPublishedVersionId;

            updateContentVersionList.add(new ContentVersion(Id = contentVersionId,Title= title, Note_level__c = notelevel));

            // Update the record
            if(!updateContentVersionList.isEmpty()) {
                update updateContentVersionList;

                ContentNote note = [SELECT Id, LatestPublishedVersionId, LatestContentId, Title, Content FROM ContentNote where Id =:contentNoteId];
                note.Content = EncodingUtil.base64Decode(contentBase64);
                update note;

            }

        } catch(Exception e) {
            // Handle specific exception INSUFFICIENT_ACCESS_OR_READONLY
            if (e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY')) {
                throw new AuraHandledException('Action Denied: You do not have the necessary permissions to edit this note. Please contact the note owner or your administrator to request changes');
            } else {
                // Handle any other exceptions
                throw new AuraHandledException('Error updating ContentNote: ' + e.getMessage());
            }
        }
    }

    @AuraEnabled
    public static void deleteContentNote(String contentNoteId) {
        List<ContentNote> noteToDelete = new List<ContentNote>();
        try {
            noteToDelete = [SELECT Id FROM ContentNote WHERE Id =: contentNoteId AND OwnerId =: UserInfo.getUserId() LIMIT 1];

            // Delete the record
            if (!noteToDelete.isEmpty()) {
                delete noteToDelete;
            }
        } catch(Exception e) {
            throw new AuraHandledException('Error deleting ContentNote: ' + e.getMessage());
        }

        if (noteToDelete.isEmpty()) {
            throw new AuraHandledException('Action Denied: This note does not exist or you do not have the necessary permissions to delete it.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getNoteRecordTypeId (){

        return Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Note').getRecordTypeId();
    }
    
    @AuraEnabled
    public static list<NotesWrapper> getNoteRecords (id PrentId) {
        TimeZone tz = UserInfo.getTimeZone();
        Id currentUserId = UserInfo.getUserId();

        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :PrentId]){
            contentDocumentIds.add(conDoc.ContentDocumentId);
        }
        list<ContentNote> cntNotes =  [SELECT Id, Title, Content, CreatedBy.Name,CreatedById, CreatedDate, OwnerId from ContentNote where Id In: contentDocumentIds order by CreatedDate desc];
        list<ContentVersion> cntVersions = [SELECT Id, ContentDocumentId, Note_level__c FROM ContentVersion where ContentDocumentId In: contentDocumentIds];
        Map<Id,ContentVersion> CDId_cntVersnMap = new Map<Id,ContentVersion>();
        if(cntVersions.size() >0){
            for(ContentVersion cv: cntVersions){
                CDId_cntVersnMap.put(cv.ContentDocumentId,cv);
            }
        }
        List<NotesWrapper> wrapList = new List<NotesWrapper>();
        for(ContentNote cn: cntNotes){
            String contentStr = (cn.Content).toString();
            String createdDateStr = (cn.CreatedDate.format('MM/dd/yyyy, hh:mm aa', tz.getID())).toString();
            String noteLevel = '';
            if(CDId_cntVersnMap.containsKey(cn.Id)){
                noteLevel = CDId_cntVersnMap.get(cn.Id).Note_level__c;
            }
            wrapList.add(new NotesWrapper((cn.Id).toString(), (cn.Title).toString(), contentStr, (cn.CreatedById).toString(), createdDateStr, (cn.CreatedBy.Name).toString(),noteLevel, currentUserId == cn.OwnerId));
        }
        
        return wrapList;
    }
    
    public class NotesWrapper{
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String Title{get;set;}
        @AuraEnabled public String Content{get;set;}
        @AuraEnabled public String CreatedById{get;set;}
        @AuraEnabled public String CreatedDate{get;set;}
        @AuraEnabled public String CreatedByName{get;set;}
        @AuraEnabled public String noteLevel{get;set;}
        @AuraEnabled public Boolean isOwner{get;set;}
        public NotesWrapper(String Id, String Title, String Content, String CreatedById, String CreatedDate, String CreatedByName, String noteLevel, Boolean isOwner){
            this.Id = Id;
            this.Title = Title;
            this.Content = Content; 
            this.CreatedById = CreatedById;
            this.CreatedDate = CreatedDate;
            this.CreatedByName = CreatedByName;
            this.noteLevel = noteLevel;
            this.isOwner = isOwner;
        }
    }
    
}