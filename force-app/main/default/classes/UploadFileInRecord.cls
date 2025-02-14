public with sharing class UploadFileInRecord {
    public UploadFileInRecord() {}
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String result) {
        system.debug('upload file');
        
          ContentVersion cv = createContentVersion(base64, filename);
          ContentDocumentLink cdl = createContentLink(cv.Id, result);
          if (cv == null || cdl == null) { return null; }
          return cdl.Id;
    }

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.Document_Classification__c = 'Original_Document';
        cv.PathOnClient = filename;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
    insert cdl;
    return cdl;
    } catch(DMLException e) {
        System.debug(e);
        return null;
    }
    }

}