public with sharing class CustomReports {
    public static final String DEFAULT_TIME_ZONE = 'America/New_York';

    public void runContentDocumentReport(CustomReports.Settings reportSetting) {

       // Title of the CSV file

       String csvTitle = getTitle( reportSetting.csvTitle != null ? reportSetting.csvTitle : 'Content Document Report');


       Map<String, String> fieldMap = new Map<String, String > {
           'ContentDocumentId' => 'Content Document Id',
           'LinkedEntityId' => 'Linked Entity Id',
           'LinkedEntity.Name' => 'Linked Entity Name',
           'LinkedEntity.Type' => 'Linked Entity Type',
           'ContentDocument.Title' => 'Title',
           'ContentDocument.FileType' => 'File Type',
           'ContentDocument.ContentSize' => 'Content Size (Bytes)',
           'ContentDocument.CreatedDate' => 'Created Date',
           'ContentDocument.CreatedBy.Name' => 'Created By',
           'ContentDocument.LatestPublishedVersion.Document_Classification__c' => 'Document Type',
           'ContentDocument.LatestPublishedVersion.Entity_Sub_Type__c' => 'Data Sub Type',
           'ContentDocument.LatestPublishedVersion.RecordType.Name' => 'Record Type'
       };

        // List of field names corresponding to the query
        List<String> fieldNames = new List<String>(fieldMap.keySet());
        List<String> csvColumnNames = new List<String>();

        // Iteration Order for Maps and Sets Is Now Predictable
        for (String mapKey : fieldMap.keySet()) {
            csvColumnNames.add(fieldMap.get(mapKey));
        }

        // Define the SOQL query
        String query = 'SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Name, LinkedEntity.Type, ContentDocument.Title, ';
        query += 'ContentDocument.FileType, ';
        query += 'ContentDocument.ContentSize, ContentDocument.CreatedDate, ContentDocument.CreatedBy.Name, ';
        query += 'toLabel(ContentDocument.LatestPublishedVersion.Document_Classification__c), ';
        query += 'toLabel(ContentDocument.LatestPublishedVersion.Entity_Sub_Type__c), ';
        query += 'ContentDocument.LatestPublishedVersion.RecordType.Name ';
        query += 'FROM ContentDocumentLink WHERE ContentDocumentId in ( SELECT Id from ContentDocument )';



        String body = '<b>Report</b><br/><br/>';
        body += 'Details:<br/>' + csvTitle + '<br/>';
        body += 'Created Date:<br/>' + DateTime.now().format('MM/dd/yyyy hh:mm aa', DEFAULT_TIME_ZONE) + ' (' + DEFAULT_TIME_ZONE  + ')</div>';
        body += '<div="place_holder"></div>';
        body += '<br/><br/>Regards,<br/>Salesforce.com';

        List<ScopeFilter> filters = new List<ScopeFilter>();
        FieldFilterStrategy userFilter = new FieldFilterStrategy('LinkedEntity.Type', 'User', FieldFilterStrategy.FilterOperator.NOT_EQUALS);
        filters.add(userFilter);

        GenericCSVBatch.Settings batchSettings = new GenericCSVBatch.Settings();
        batchSettings.query = query;
        batchSettings.fieldNames = fieldNames;
        batchSettings.csvColumnNames = csvColumnNames;
        batchSettings.csvTitle = csvTitle;
        batchSettings.toEmailAddress = reportSetting.toEmailAddress;
        batchSettings.enableEmailDelivery = reportSetting.enableEmailDelivery;
        batchSettings.htmlBody = body;
        batchSettings.filters = filters;
        CustomReports.runCustomReport(batchSettings);

    }
    private String getTitle(String reportName) {
        return reportName + ' - ' + DateTime.now().format('MMM_dd_yyyy', DEFAULT_TIME_ZONE);
    }

    public static void runCustomReport(GenericCSVBatch.Settings batchSettings) {
        // Execute the batch job with a batch size of 50
        GenericCSVBatch batch = new GenericCSVBatch(batchSettings);
        Database.executeBatch(batch, 50);
    }

    public static CustomReports.Settings getDefaultCustomReportSettings(String name) {
        Settings settings = new Settings();
        settings.csvTitle = name;
        settings.toEmailAddress = GenericCSVBatch.getCustomReportEmailAddress();
        settings.enableEmailDelivery = GenericCSVBatch.getCustomReportEmailEnabled();
        return settings;
    }

    public class Settings {
        public String csvTitle { get; set; }
        public String toEmailAddress { get; set; }
        public Boolean enableEmailDelivery { get; set; }
    }

}