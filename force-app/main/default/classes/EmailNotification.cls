public with sharing class EmailNotification implements Notification {
    
    public String subject; 
    public String body; 
    public Id targetId; 
    public User assignedTo;
    public User actionedBy;
    public String replyTo;
    public String senderDisplayName;

    public Map<String,String> variables;

    public static List<Notification> convertTasksToEmailNotifications(List<Task> tasks) {
        //https://writeforce.blogspot.com/2012/10/sending-email-notification-when.html
        Set<Id> createdByIds = new Set<Id>();
        for(Task task: tasks) { createdByIds.add(task.CreatedById); }
        Map<Id, User> createdByMap = new Map<Id,User>([SELECT Id, Name, Email FROM User WHERE Id in :createdByIds]);

        Set<Id> lastModifiedByIds = new Set<Id>();
        for(Task task: tasks) { lastModifiedByIds.add(task.LastModifiedById); }
        Map<Id, User> lastModifiedByMap = new Map<Id,User>([SELECT Id, Name, Email FROM User WHERE Id in :lastModifiedByIds]);


        Set<Id> taskDetailIds = new Set<Id>();
        for(Task task: tasks) { taskDetailIds.add(task.Id); }
        Map<Id, Task> taskDetailsByMap = new Map<Id,Task>([SELECT Id, WhatId, What.Name FROM Task WHERE Id in :taskDetailIds]);
        System.debug('taskDetailIds:- ' + taskDetailIds);

        List<Notification> emailNotifications = new List<EmailNotification>();
        for(Task tsk : tasks) {
            System.debug('EmailNotificationStrategy tsk:- ' + tsk);

            EmailNotification emailNotification = new EmailNotification();

            User actionedBy = lastModifiedByMap.get(tsk.LastModifiedById);
            
            emailNotification.replyTo = 'noreply@salesforce.com';
            emailNotification.senderDisplayName = actionedBy.Name;
            emailNotification.subject = tsk.Subject;
            emailNotification.body = tsk.Description;
            emailNotification.targetId = tsk.Id;
            emailNotification.assignedTo = createdByMap.get(tsk.CreatedById);
            emailNotification.actionedBy = actionedBy;
            emailNotification.variables = new Map<String, String>();
            emailNotification.variables.put('Priority', tsk.Priority);
            emailNotification.variables.put('Related_Type__c', tsk.Related_Type__c);
            emailNotification.variables.put('Related_To_Name', taskDetailsByMap.get(tsk.Id).What.Name);

            System.debug('EmailNotificationStrategy emailNotification:- ' + emailNotification);
            
            emailNotifications.add(emailNotification);
        }

        return emailNotifications;
    }
}