public with sharing class getEmailData {
    public getEmailData() {}
    @AuraEnabled
    public static Map<String,Object> getEmailInfo(String recId){
        system.debug(recId);
        EmailTemplate template = new EmailTemplate();
			template = [SELECT Id, Name,Body from EmailTemplate WHERE DeveloperName ='Send_BIP_Request'  LIMIT 1];
      system.debug(template);
			BIP_Request__c bipRec = [Select Id, Account_Number__c, Owner.Email , email_CCs__c, Requestor_Name__c, Primary_PI__c, Proposal_Number__c, Request_Type__c, Due_Date__c, Comments__c, Requestor_Department__c, Requestor_Email__c, Primary_PI_Lookup__c, Primary_PI_Lookup__r.PersonEmail,  Primary_PI_Lookup__r.PersonContactId ,Project_Title__c , (select Account_Number__c,Owner.Email ,Owner.Name, Primary_PI_Lookup__c ,Primary_PI_Lookup__r.PersonEmail from BIP_Requests__r) From BIP_Request__c Where Id =:recId];
            List<BIP_Request__c> children = bipRec.BIP_Requests__r;
            List<String> childEmails = new List<String>();
           String PersonContactId = bipRec.Primary_PI_Lookup__r.PersonContactId;
             system.debug('-------'+PersonContactId);
             if(bipRec.email_CCs__c==null){
              String childEmailString = '';
            system.debug('children-----'+children);
              for(BIP_Request__c c:children ){
  
                system.debug('bipRec.Owner.Email-'+bipRec.Owner.Email+' c.Owner.Email-:'+c.Owner.Email );
                 if( c.Owner.Email!=bipRec.Owner.Email){
              
                  if(c.Owner.Email!=null){
                    childEmails.add(c.Owner.Email);
                    childEmailString=childEmailString+ c.Owner.Email +',';
                  }
                 }
                if(c.Primary_PI_Lookup__c!=null && c.Primary_PI_Lookup__r.PersonEmail!=null)
              { 
               
                childEmails.add(c.Primary_PI_Lookup__r.PersonEmail);

               childEmailString=childEmailString+c.Primary_PI_Lookup__r.PersonEmail+',';
              }
            }
            bipRec.email_CCs__c = childEmailString;
            update bipRec;
             
             }
             else{
              childEmails= bipRec.email_CCs__c.split(',');
              system.debug('childEmails'+childEmails);
             }
             
             system.debug(bipRec.Primary_PI_Lookup__r.PersonEmail);
             String reqName =  bipRec.Requestor_Name__c==null ? '': bipRec.Requestor_Name__c;
             String reqEmail=  bipRec.Requestor_Email__c==null ? '': bipRec.Requestor_Email__c;
             String proposalNumber =  bipRec.Proposal_Number__c==null ? '': bipRec.Proposal_Number__c;
             String reqDep =  bipRec.Requestor_Department__c==null ? '': bipRec.Requestor_Department__c;
             String ppi =  bipRec.Primary_PI__c==null ? '': bipRec.Primary_PI__c;
             String dueDate =  bipRec.Due_Date__c==null ? '' : String.valueOf(bipRec.Due_Date__c);
             String projectTitle =  bipRec.Project_Title__c == null ? '': bipRec.Project_Title__c;
             String comments =  bipRec.Comments__c == null ? '': bipRec.Comments__c;
             String reqType =  bipRec.Request_Type__c == null ? '': bipRec.Request_Type__c;
   

           String previewEmailBody =  String.valueOf(template.Body).replace('{!BIP_Request__c.Requestor_Name__c}',reqName)
                                         .replace('{!BIP_Request__c.Requestor_Email__c}',reqEmail)
                                        .replace('{!BIP_Request__c.Proposal_Number__c}',proposalNumber)
                                        .replace('{!BIP_Request__c.Requestor_Department__c}',reqDep)
                                        .replace('{!BIP_Request__c.Primary_PI__c}',ppi)
                                        .replace('{!BIP_Request__c.Due_Date__c}',dueDate)
                                        .replace('{!BIP_Request__c.Project_Title__c}',projectTitle)
                                        .replace('{!BIP_Request__c.Comments__c}',comments)
                                        .replace('{!BIP_Request__c.Request_Type__c}',reqType);
                                        
               system.debug(previewEmailBody);
                                
            string toEmail = bipRec.Primary_PI_Lookup__r.PersonEmail;
            system.debug('Email='+bipRec.Primary_PI_Lookup__r.PersonEmail);
            system.debug('Temp='+template);
            Map<String,Object> result = new Map<String,Object>{
                'to' =>toEmail,
                'cc' => childEmails,
                'templateBody'=>previewEmailBody,
                'templateId'=>template.Id,
                'PersonContactId'=>PersonContactId,
               'isPrimaryPiLookupNull'=> bipRec.Primary_PI_Lookup__c == null
            };
            return result;


    }
}