@isTest
public class ContentVersionHandlerTest {
    @isTest
    public static void  contentVersionClassification() {
        
        String textFilesContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, Lorem ipsum dolor sit amet, consectetur adipiscing elit!';
        String fileName = 'This is also part for file.txt';
        
        ContentVersion conVer = new ContentVersion();
        conVer.Title = 'DocuSign ' + fileName; // Display name of the files
        conVer.PathOnClient = 'DocuSign ' + fileName;
        conVer.VersionData = Blob.valueOf(textFilesContent); 
        conVer.Document_Classification__c = 'Technical Description';
        insert conVer;  //Insert ContentVersion


        // asserts ========================
        ContentVersion savedCv = [SELECT Id, Title, RecordTypeId, Document_Classification__c from ContentVersion where Id = :conVer.Id LIMIT 1];
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();
        System.assertEquals('Technical Description', savedCv.Document_Classification__c, 'Documents with DocuSign in title should get Classification set only if the upload user belongs to the \'DocuSign_App_User_API\' permission set ');
        System.assertEquals(recordTypeId, savedCv.RecordTypeId, 'ID needed for ContentVersion.Recortype for Disclosure');

    }

    // @isTest
    // public static void  contentVersionClassificationDocuSignUser() {
        
    //     String textFilesContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, Lorem ipsum dolor sit amet, consectetur adipiscing elit!';
    //     String fileName = 'This is also part for file.txt';
        
    //     ContentVersion conVer = new ContentVersion();
    //     conVer.Title = 'DocuSign ' + fileName; // Display name of the files
    //     conVer.PathOnClient = 'DocuSign ' + fileName;
    //     conVer.VersionData = Blob.valueOf(textFilesContent); 
        
    //     User docuSignUser = SampleDataTest.getDocuSignUser();
    //     system.runAs(docuSignUser){
    //         insert conVer;  //Insert ContentVersion
    //     }


    //     // asserts ========================
    //     ContentVersion savedCv = [SELECT Id, Title, RecordTypeId, Document_Classification__c from ContentVersion where Id = :conVer.Id LIMIT 1];
    //     Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();
    //     System.assertEquals('Signed Disclosure', savedCv.Document_Classification__c, 'Documents with DocuSign in title should get Classification set to \'Signed Disclosure\'');
    //     System.assertEquals(recordTypeId, savedCv.RecordTypeId, 'ID needed for ContentVersion.Recortype for Disclosure');

    // }



}