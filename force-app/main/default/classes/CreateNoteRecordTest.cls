@isTest
private class CreateNoteRecordTest {
    
    @isTest
    static void testCreateRecord() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ContentVersion note = new ContentVersion(
            Title = 'Test Note',
            VersionData = Blob.valueOf(EncodingUtil.base64Encode(Blob.valueOf('Test Content <b>Bold<b/>'))),
            Note_level__c='Level A'
        );
        System.debug('note.VersionData ' + note.VersionData.toString());
        Test.startTest();
        CreateNoteRecord.createRecord(note, acc.Id);
        List<CreateNoteRecord.NotesWrapper> notesList = CreateNoteRecord.getNoteRecords(acc.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateContentNote() {
        // Create a test ContentNote
        ContentNote testContentNote = new ContentNote(Title = 'Test Content Note');
        insert testContentNote;
        Id noteRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Note').getRecordTypeId();
        // Retrieve the Id of the inserted ContentNote
        Id LatestPublishedVersionId = [SELECT Id,LatestPublishedVersionId FROM ContentNote WHERE Id = :testContentNote.Id][0].LatestPublishedVersionId;
        
        ContentVersion testContentVersion= new ContentVersion(Id = LatestPublishedVersionId,Entity_Sub_Type__c = 'N_A',recordTypeId = noteRecordTypeId,Document_Classification__c = 'Original_Document');
        update testContentVersion;
        
        // Call the method
        Test.startTest();
        CreateNoteRecord.updateContentNote(testContentNote.Id, 'Updated Title', EncodingUtil.base64Encode(Blob.valueOf('Updated Content')), 'Level A');
        Test.stopTest();
        
    }

    @IsTest
    static void testDeleteContentNoteIsOwner() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ContentVersion note = new ContentVersion(
                Title = 'Test Note',
                VersionData = Blob.valueOf(EncodingUtil.base64Encode(Blob.valueOf('Test Content  <b>Bold<b/>'))),
                Note_level__c='Level A'
        );

        CreateNoteRecord.createRecord(note, acc.Id);
        List<CreateNoteRecord.NotesWrapper> notesList = CreateNoteRecord.getNoteRecords(acc.Id);

        Test.startTest();
        CreateNoteRecord.deleteContentNote(notesList[0].Id);
        Test.stopTest();

        List<CreateNoteRecord.NotesWrapper> notesListAfterDelete = CreateNoteRecord.getNoteRecords(acc.Id);
        System.assertEquals(0, notesListAfterDelete.size());
    }

    @IsTest
    static void testDeleteContentNoteIsNotOwner() {
        Account acc;

        // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                Username=uniqueUserName);

        System.runAs(u) {
            // This code runs as the user u
            // Create a Note as user u
            acc = new Account(Name = 'Test Account');
            insert acc;
            ContentVersion note = new ContentVersion(
                    Title = 'Test Note',
                    VersionData = Blob.valueOf(EncodingUtil.base64Encode(Blob.valueOf('Test Content <b>Bold<b/>'))),
                    Note_level__c='Level A'
            );
            CreateNoteRecord.createRecord(note, acc.Id);
        }

        List<CreateNoteRecord.NotesWrapper> notesList = CreateNoteRecord.getNoteRecords(acc.Id);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            // Try to delete the Note as a different user
            CreateNoteRecord.deleteContentNote(notesList[0].Id);
        }
        catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should be thrown trying to delete Note as non-owner');
    }
}