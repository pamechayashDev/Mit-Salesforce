public class BipRequestHelper {

    public static void afterBipRequestUpdate(List<BIP_Request__c> newBips , List<Bip_Request__c> oldBips){
        
        
        List<BIP_Request__c> toUpdate = new  List<BIP_Request__c>();
        List<BIP_Request__c> newbipRecs = [Select Id, Account_Number__c,Status__c, Owner.Email , email_CCs__c, Requestor_Name__c, Primary_PI__c, Proposal_Number__c, Request_Type__c, Due_Date__c, Comments__c, Requestor_Department__c, Requestor_Email__c, Primary_PI_Lookup__c, Primary_PI_Lookup__r.PersonEmail,  Primary_PI_Lookup__r.PersonContactId ,Project_Title__c , (SELECT Id, Status__c, Role__c, TLO_Officer_Name__c, CreatedBy.Name ,CreatedBy.Email ,PI__c, PI__r.Id , PI__r.Name FROM BIP_PIs__r)  From BIP_Request__c Where Id IN :newBips];
        List<BIP_Request__c> oldbipRecs = [Select Id, Status__c from Bip_request__c where Id in :oldBips]; 
        try{ 
      		 for(Integer i=0;i<newbipRecs.size();i++){
                        system.debug('status not changed');
               system.debug(newbipRecs[i].Id);
                    system.debug(oldBips[i].Id);
                 
            	if(newbipRecs[i].Status__c != oldBips[i].Status__c){
                    
                 system.debug('status changes');

                 List<BIP_PI__c> children = newbipRecs[i].BIP_PIs__r;
                 List<String> childEmails = new List<String>();
                 String childEmailString = '';
                
                 for(BIP_PI__c c:children ){
  
                	system.debug('bipRec.Owner.Email-'+newbipRecs[i].Owner.Email+' c.Owner.Email-:'+c.CreatedBy.Email );
                	if( c.CreatedBy.Email!=newbipRecs[i].Owner.Email){
              
                 		if(c.CreatedBy.Email!=null){
                       		childEmails.add(c.CreatedBy.Email);
                    		childEmailString=childEmailString+ c.CreatedBy.Email +',';
                  		}
                 		}
                     
                if(c.PI__c!=null && c.PI__r.PersonEmail!=null)
              	{ 	system.debug('c.Primary_PI_Lookup__c!=null');
               
                	childEmails.add(c.PI__r.PersonEmail);

               		childEmailString=childEmailString+c.PI__r.PersonEmail+',';
              }
                     
            }
                newbipRecs[i].email_CCs__c = childEmailString;
                toUpdate.add(newbipRecs[i]);
                    
                string toEmail = newbipRecs[i].Primary_PI_Lookup__r.PersonEmail;
                
              system.debug('now calling sendEmail');
              SendEmailController.sendEmail(newbipRecs[i].Id,'NA', toEmail, false, '', childEmails, 'NA', newbipRecs[i].Primary_PI_Lookup__c==null, true);
                 system.debug('after calling sendEmail');  
            }
        }
       
        update toUpdate;
        }
         catch (Exception ex) {
            throw new AuraHandledException('Error while sending email: ' + ex.getMessage());
        }
        
    }

    // public static void afterBIPPIInsert(List<BIP_PI__c> vBIPPIList){

    //     if (!Test.isRunningTest()) {
    //         System.enqueueJob(new QueryQueueable(vBIPPIList));
    //     }
    // }
    
}