public with sharing class Email {
    public class EmailBody {
        public List<String> to;
        public String template;
        public Map<String, Object> variables;
        public List<String> cc;
        public List<String> bcc;

        public EmailBody(List<String> to, String template, Map<String, Object> variables, List<String> cc, List<String> bcc) {
            this.to = to;
            this.template = template;
            this.variables = variables;
            this.cc = cc;
            this.bcc = bcc;
        }
    }

    public static void sendEmail(List<String> to, String template, Map<String, Object> variables, List<String> cc, List<String> bcc, Id EmailId) {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/json;charset=UTF-8');
        
        Email_Templates__c emailTemplateSettings = NotificationBuilder.getEmailTemplateCustomSettings(template);
        EmailBody body = new EmailBody(to, emailTemplateSettings.Template__c, variables, cc, bcc);
        String bodyStringified = JSON.serialize(body).replace('sender', 'from');  //TODO what is this
        System.debug(bodyStringified);
        
        if(!emailTemplateSettings.Enabled__c ){
            Notification__c notification = [SELECT Status__c, Failure_Count__c FROM Notification__c WHERE Id = :EmailId];
            update new Notification__c(Id = EmailId, Status__c = 'Disabled');

        } else {
            String apiName = 'notificationApi';
            String response = AwsApiCall.restPost(apiName, '/usernotification', headers, bodyStringified);
            System.debug(response);
        
            if (response.contains('message')) {
                Notification__c notification = [SELECT Status__c, Failure_Count__c FROM Notification__c WHERE Id = :EmailId];
                if (notification.Failure_Count__c < 5) {
                    update new Notification__c(Id = EmailId, Failure_Count__c = notification.Failure_Count__c + 1);
                } else {
                    update new Notification__c(Id = EmailId, Status__c = 'Failed');
                }
                
            } else {
                update new Notification__c(Id = EmailId, Status__c = 'Successful');
            }
        }
    }
}