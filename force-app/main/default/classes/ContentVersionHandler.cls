// https://salesforce.stackexchange.com/questions/317757/how-to-automatically-change-the-name-of-a-file-upon-creation
// https://gist.github.com/erev1/ceb51a208c9d9343094ffc4e1786d06e
// https://salesforce.stackexchange.com/questions/363647/a-trigger-on-contentversion-object-with-additional-logic
// Document_Classification__c is a required field and we dont have a default type currently.
public class ContentVersionHandler {

    public static void onAfterInsert(List<ContentVersion> cvs) {
        List<ContentVersion> createDocumentLinks = new List<ContentVersion>();

        for (ContentVersion cv : cvs) {
            if (cv.Entity_RecId__c == '-1' || cv.TagCsv != null) { //TODO check on Entity_RecId__c != null, better way to flag the linking process
                createDocumentLinks.add(cv);
            }
        }

        if(!createDocumentLinks.isEmpty()) {
             Integer batchSize = 50;
             List<ContentVersion> batch = new List<ContentVersion>();
             for (ContentVersion cv : createDocumentLinks) {
                batch.add(cv);
                if (batch.size() >= batchSize) {
                    enqueueDocumentLinkJob(batch);
                    batch = new List<ContentVersion>();
                }
             }
             if (!batch.isEmpty()) {
                enqueueDocumentLinkJob(batch);
             }
        }
    }

    private static void enqueueDocumentLinkJob(List<ContentVersion> createDocumentLinks) {
        Integer delayInMinutes = 0;
        System.enqueueJob(new CreateDocumentLinkJob(createDocumentLinks), delayInMinutes);
        // Need to first Link the Documents to Container Object before calling the CRDRDocumentUploadJob to change the Status
    }

    public static void onBeforeInsert(List<ContentVersion> cvs) {
        Id cvDisclosureRecordTypeId = null; 
        List<PermissionSetAssignment> docuSignPermissionSetAssignment = null;

        for(ContentVersion cv : cvs){
            if (cv.Title != null && cv.Title.startsWith('DocuSign')) {
                if (docuSignPermissionSetAssignment == null) {
                    docuSignPermissionSetAssignment = getDocuSignPermissionSetAssignment();
                }
                Boolean isDocuSignUser = (!docuSignPermissionSetAssignment.isEmpty()) ? true : false;
                if(isDocuSignUser) {
                    if (cvDisclosureRecordTypeId == null) {
                        cvDisclosureRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Disclosure').getRecordTypeId();
                        System.debug('cvDisclosureRecordTypeId = ' + cvDisclosureRecordTypeId );
                    }

                    cv.RecordTypeId = cvDisclosureRecordTypeId;
                    cv.Document_Classification__c = 'Signed Disclosure';
                }
            }
        }        
    }

    // If no data found will return empty List
    private static List<PermissionSetAssignment> getDocuSignPermissionSetAssignment() {
        List<PermissionSetAssignment> docuSignPermissionSetAssignment = [SELECT Id
                       FROM PermissionSetAssignment where PermissionSetId IN (select Id from PermissionSet where Name='DocuSign_App_User_API')
                  AND AssigneeId = :UserInfo.getUserId()];
        System.debug('docuSignPermissionSetAssignment size() = ' + docuSignPermissionSetAssignment.size() );
        return docuSignPermissionSetAssignment;
    }
}