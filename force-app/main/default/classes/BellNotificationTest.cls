@IsTest
public with sharing class BellNotificationTest {
    
    @IsTest
    static void testConvertTasksToBellNotifications(){
       // String assignedToId = UserInfo.getUserId();
        Case_CRDR__C crdr = new Case_CRDR__c();
        crdr.ExternalCaseCRDRId__c = '12334';
        crdr.Name = 'Unit Test CRDR';
        insert crdr;

        Case_CRDR__C savedCrdr = [SELECT Id, Name FROM Case_CRDR__c WHERE ExternalCaseCRDRId__c = '12334'];

        String subject = 'Unit Testing BellNotification';
        List<Task> tasks = new List<Task>(); 
        Task testTsk = new Task();
        testTsk.Subject = subject;
        testTsk.WhatId = savedCrdr.Id;
        //testTsk.WhoId = assignedToId;
        tasks.add(testTsk);
        insert tasks;

        List<Task> savedTasks = [SELECT Id, Subject, CreatedById FROM Task WHERE Subject = :subject];

        List<Notification> bellNotifications = BellNotification.convertTasksToBellNotifications(savedTasks);
        
        BellNotification notificationToTest = (BellNotification) bellNotifications.get(0);

        System.assert(notificationToTest.title == 'Task Completed', 'title: should be Task Completed');
        System.assert(notificationToTest.body == savedTasks[0].Subject, 'body: should match the tasks Subject');
        System.assert(notificationToTest.targetId == savedTasks[0].Id, 'targetId: should match the tasks Id');
        System.assert(notificationToTest.assignedToId == savedTasks[0].CreatedById, 'assignedToId: should match the tasks CreatedById');

    }
}