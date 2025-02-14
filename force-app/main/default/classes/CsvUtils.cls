public class CsvUtils {


    // Method to convert a list of SObjects to CSV
    public static String toCSV(List<SObject> records, List<String> fieldNames) {
        List<String> csvContent = new List<String>();

        // Add CSV rows
        for (SObject record : records) {
            List<String> row = new List<String>();

            for (String fieldName : fieldNames) {
                Object fieldValue = extractFieldValues(record, fieldName);
                String csvField = fieldValue == null ? '' : String.valueOf(fieldValue);
                row.add(csvField.escapeCsv());
            }
            csvContent.add(String.join(row, ','));
        }
        return String.join(csvContent,'\n');
    }

    public static void sendCSVFile(String htmlBody, String csvContent, String title, String subscriber) {
        Blob csvBlob = Blob.valueOf(csvContent);

        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(title+'.csv');
        emailAttachment.setBody(csvBlob);
        emailAttachment.setContentType('text/csv');

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>() ;
        attachments.add(emailAttachment);

        List<String> toAddresses = subscriber.split(',');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setFileAttachments(attachments);
        email.setSubject('Report results (' + title + ')');
        email.setToAddresses(toAddresses);
        email.setSenderDisplayName('Salesforce');

        email.setHtmlBody(htmlBody);

        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        for (Messaging.SendEmailResult result : r) {
            System.debug('Email result ' + result.isSuccess());
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError sendError : result.getErrors()) {
                    System.debug('Email message ' + sendError.getMessage());
                }
            }
        }
        System.debug('Email sent');

    }

    // Method to save CSV content to a file in Salesforce
    public static void saveCSVFile(String csvContent, String title) {
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Note').getRecordTypeId();

        ContentVersion conVer = new ContentVersion();
        conVer.Title = title + '.csv';
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = title + '.csv';
        conVer.RecordTypeId = recordTypeId;
        conVer.Document_Classification__c = 'Original_Document';
        conVer.Entity_Sub_Type__c = 'N_A';
        conVer.VersionData = Blob.valueOf(csvContent);
        insert conVer;

    }


    public static string extractFieldValues(sObject sb, string fieldAPIName){
    	String fValue = '';
    	if(fieldAPIName.contains('.')){
    		List<string> splitFields = fieldAPIName.split('\\.');
    		try {
    			for(integer i=0; i < splitFields.size()-1; i++){
    				sb=sb.getSObject(splitFields[i]);
    			}
    			fValue = String.valueOf(sb.get(splitFields[splitFields.size() -1]));
    		}catch(Exception ex){
    		   System.debug('Exception while fetching fieldValues as relationship ' + fieldAPIName + '  value is blank.' + ex.getMessage());
    		   fValue='';
    		}

    	}else if(sb.get(fieldAPIName)!=null){
    		fValue = string.valueOf(sb.get(fieldAPIName));
    	}
    	return fValue;
    }
}