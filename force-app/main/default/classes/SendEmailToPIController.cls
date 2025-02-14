/**
* @File Name : SendEmailToPIController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : December 5, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 5, 2024 |   | Initial Version
**/

public class SendEmailToPIController {
	@AuraEnabled
    public static void sendEmailUsingTemplate(String recId) {
        try {
			// String templateDeveloperName = System.label.PIReviewEmailTemaplateDeveloperName;
			// EmailTemplate template = new EmailTemplate();
			// template = [SELECT Id, Name from EmailTemplate WHERE DeveloperName =:templateDeveloperName  LIMIT 1];
			// Case caseRec = [Select Id,Primary_PI_Lookup__c.PersonContactId,Primary_PI_Lookup__c.PersonEmail From Case Where Id =: recId];

            // List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // email.setTemplateId(template.Id);
            // email.setToAddresses(new List<String>{caseRec.Primary_PI_Lookup__c.PersonEmail});
            // email.settargetobjectId(caseRec.Primary_PI_Lookup__c.PersonContactId);
            // email.setWhatId(recId);

            // emails.add(email);
            // Messaging.sendEmail(emails);
        } catch (Exception ex) {
            throw new AuraHandledException('Error while sending email: ' + ex.getMessage());
        }
    }
}