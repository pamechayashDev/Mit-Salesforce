public with sharing class TaskTriggerHandler {
    public static Map<Id,Case_CRDR__c> vCaseCRDRMap;
    
    public static void onBeforeInsert(List<Task> taskList) {
        TaskTriggerHandler.getCaseCRDR(taskList);
        TaskTriggerHandler.setRelatedType(taskList);
    }

    public static void onAfterInsert(List<Task> taskList) {
        TaskTriggerHandler.getCaseCRDR(taskList);
        TaskTriggerHandler.onTaskCreatedChangeCRDRStatus(taskList);
    }

    public static void onBeforeUpdate(List<Task> taskList, Map<Id, Task> oldTaskMap) {
        TaskTriggerHandler.getCaseCRDR(taskList);
        TaskTriggerHandler.setRelatedType(taskList);
    }

    public static void onAfterUpdate(List<Task> taskList, Map<Id, Task> oldTaskMap) {
        System.debug('onAfterUpdate taskList:- ' + taskList); 
        TaskTriggerHandler.onTaskClosed(taskList, oldTaskMap);
    }
   
    public static void getCaseCRDR(List<Task> taskList){
        if(vCaseCRDRMap==null){
        	Set<Id> vCaseCRDRIds = new Set<Id>();
            for (Task task : taskList) {
                vCaseCRDRIds.add(task.WhatId);
            }
            vCaseCRDRMap=new Map<Id,Case_CRDR__c>([SELECT Id, ExternalCaseCRDRId__c, Status__c FROM Case_CRDR__c WHERE Id =: vCaseCRDRIds]);
        }
    }

    private static void setRelatedType(List<Task> taskList) {
        
        for (Task task : taskList) {
            if (task.WhatId != null) {
                task.Related_Type__c = task.WhatId.getSObjectType().getDescribe().getLabel();
                //Populate the External Lookup to the CRDR only if not already set
                if (task.Related_Type__c == 'CRDR' && task.CRDR__c == null) {
                    task.CRDR__c = String.valueOf(vCaseCRDRMap.get(task.WhatId).ExternalCaseCRDRId__c);
                }
            }
        }
    }

    // https://mailtrap.io/blog/apex-send-email/
    // https://www.sfdc99.com/2014/03/01/sending-emails-using-apex/
    private static void onTaskClosed(List<Task> taskList, Map<Id, Task> oldTaskMap) {
        Set<String> closedStatusSet = TaskUtils.getTaskCloseStatuses(); 
        System.debug('closedStatusSet:- ' + closedStatusSet); 

        //https://writeforce.blogspot.com/2012/10/sending-email-notification-when.html
        Set<Id> ownerIds = new Set<Id>();
        for(Task task: taskList) { ownerIds.add(task.ownerId); }
        Map<Id, User> userMap = new Map<Id,User>([SELECT Id, Name, Email FROM User WHERE Id in :ownerIds]); //TODO include & status in this Query

        List<Task> closedTasks = new List<Task>();
        for (Task task : taskList) {
            Task oldTask = oldTaskMap.get(task.Id);
            Boolean hasStatusChanged = task.Status != oldTask.Status;
            // only if the status changed send Notifications
            if (hasStatusChanged && closedStatusSet.contains(task.Status)) {
                System.debug('task:- ' + task); 
                closedTasks.add(task);
                
            }
        }
        
        System.debug('onAfterUpdate email start'); 
        List<Notification> emailNotifications = EmailNotification.convertTasksToEmailNotifications(closedTasks);
        NotificationStrategy email = new EmailNotificationStrategy();
        email.send(emailNotifications);
        System.debug('onAfterUpdate email end'); 

        System.debug('onAfterUpdate bell start'); 
        List<Notification> bellNotifications = BellNotification.convertTasksToBellNotifications(closedTasks);
        NotificationStrategy bell = new BellNotificationStrategy();
        bell.send(bellNotifications);
        System.debug('onAfterUpdate bell end');
    }


    // When CRDR is in Draft Status, if task created against it move to In Review
    private static void onTaskCreatedChangeCRDRStatus(List<Task> taskList) {
        List<Case_CRDR__c> updateList = new List<Case_CRDR__c>();
        for (Case_CRDR__c crdr :vCaseCRDRMap.values()) {
            if (crdr.Status__c == 'DRAFT') {
                crdr.Status__c = 'IN_REVIEW';
                updateList.add(crdr);
            }
        }
        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
}