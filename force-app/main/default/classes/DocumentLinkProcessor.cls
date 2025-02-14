public with sharing virtual class DocumentLinkProcessor {

    public void execute(List<ContentVersion> scope) {
        try {
            if(scope != null && !scope.isEmpty()) {
                createDocumentLink(scope);
            }
        } catch(Exception ex) {
            HandleLogException.logException(ex);
            throw ex;
        }
    }

    protected virtual Log_Document_Link__c getLogDocumentLinkInstance(Id id, String pathOnClient ,String logType, String message){
        Log_Document_Link__c log = new Log_Document_Link__c();
        log.ContentVersion_Id__c = String.valueOf(id);
        log.Type__c = logType;
        log.Message__c = message;
        log.PathOnClient__c = pathOnClient;
        return log;

    }

    @TestVisible
    protected virtual void createDocumentLink(List<ContentVersion> contentVersions) {}

    @TestVisible
    protected virtual FileNameDefinition parsePathOnClient(String pathOnClient) {
        return null;
    }

    @TestVisible
    protected virtual FileNameDefinition parsePathOnClient(String pathOnClient, String entityRecId) {
        return null;
    }

    @TestVisible
    public class FileNameDefinition {
        public String caseNumber;
        public String agreementNumber;
        public String financialYear;
        public String classification;
        public String mitId;
        public DateTime fileWriteDate;
    }

}