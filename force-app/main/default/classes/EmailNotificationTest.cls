@IsTest
public with sharing class EmailNotificationTest {
    
    @IsTest
    static void testConvertTasksToEmailNotifications(){
        Case_CRDR__C crdr = new Case_CRDR__c();
        crdr.ExternalCaseCRDRId__c = '12334';
        crdr.Name = 'Unit Test CRDR';
        insert crdr;

        Case_CRDR__C savedCrdr = [SELECT Id, Name FROM Case_CRDR__c WHERE ExternalCaseCRDRId__c = '12334'];

        String subject = 'Unit Testing EmailNotification';
        List<Task> tasks = new List<Task>(); 
        Task testTsk = new Task();
        testTsk.Subject = subject;
        testTsk.WhatId = savedCrdr.Id;
        tasks.add(testTsk);
        insert tasks;

        Task savedTask = [SELECT Id, Subject, CreatedById, LastModifiedById, Description, Priority, Related_Type__c FROM Task WHERE Subject = :subject];
        savedTask.Description = 'Description Added';
        update savedTask;
        
        List<Task> tasksToTest = [SELECT Id, Subject, CreatedById, LastModifiedById, Description, Priority, Related_Type__c FROM Task WHERE Subject = :subject];

        List<Notification> emailNotifications = EmailNotification.convertTasksToEmailNotifications(tasksToTest);
        
        EmailNotification notificationToTest = (EmailNotification) emailNotifications.get(0);

        System.assert(notificationToTest.replyTo == 'noreply@salesforce.com', 'noreply@salesforce.com');
        
        System.assert(notificationToTest.subject == savedTask.Subject, 'subject: should match the tasks Subject');
        System.assert(notificationToTest.body == savedTask.Description, 'body: should match the tasks Body');
        System.assert(notificationToTest.targetId == savedTask.Id, 'targetId: should match the tasks Id');
        System.assert(notificationToTest.assignedTo.Id == savedTask.CreatedById, 'assignedTo: should match the tasks CreatedById');
        System.assert(notificationToTest.actionedBy.Id == savedTask.LastModifiedById, 'actionedBy: should match the tasks CreatedById');

        
        System.assert(notificationToTest.variables.size() > 1, 'Variables are setup');
        System.assert(notificationToTest.variables.get('Priority') == savedTask.Priority, 'Variables are setup');
        System.assert(notificationToTest.variables.get('Related_Type__c') == savedTask.Related_Type__c, 'Variables are setup');

    }
}