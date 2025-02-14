public class ContentDocumentLinkUtils {
    
    public static void deleteContentVersions(List<Id> linkedEntityIds) {
        List<ContentDocument> contentDocuments = new List<ContentDocument>();
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocument.Id 
                                                          FROM ContentDocumentLink 
                                                          WHERE LinkedEntityId 
                                                          IN :linkedEntityIds];

        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            contentDocuments.add(contentDocumentLink.ContentDocument);
        }

        // We need to delete the Content Document Links first so that the Content Document Delete trigger can handle the deletion of the Content Versions
        if (!contentDocumentLinks.isEmpty()) {
            delete contentDocumentLinks;
        }

        if (!contentDocuments.isEmpty()) {
            delete contentDocuments;
        }
    }
}