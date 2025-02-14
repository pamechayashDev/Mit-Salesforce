/**
 * Created by Andreas du Preez on 2024/03/20.
 */

@IsTest
public with sharing class TaskHelperTest {

    @IsTest
    public static void createTaskTest()
    {
        String groupDeveloperName = 'Test_Queue';
        Group testGroup = new Group(Name='Test Queue', DeveloperName=groupDeveloperName, Type='Queue');
        insert testGroup;

        Case_CRDR__c testCaseCRDR = new Case_CRDR__c(Name='Test Account');
        insert testCaseCRDR;

        String taskSubject = 'Test Subject';
        String taskRelatedTo = 'Case_CRDR__c';
        SObjectType sObjectType = Schema.getGlobalDescribe().get(taskRelatedTo);
        String relatedType = sObjectType.getDescribe().label;
        String taskPriority = 'Normal';
        String taskStatus = 'Not Started';
        String taskDescription = 'Test Comment';


        Test.startTest();
        Id createdTaskId = TaskHelper.createTask(testCaseCRDR.Id, taskSubject, taskRelatedTo, taskPriority, taskStatus, taskDescription, null, groupDeveloperName, 'Queue');
        Test.stopTest();

        Task createdTask = [SELECT Id, Subject, Status, Priority, WhatId, Description, OwnerId, Related_Type__c FROM Task WHERE Id = :createdTaskId LIMIT 1];

        System.assertEquals(taskSubject, createdTask.Subject);
        System.assertEquals(taskPriority, createdTask.Priority);
        System.assertEquals(taskStatus, createdTask.Status);
        System.assertEquals(testCaseCRDR.Id, createdTask.WhatId);
        System.assertEquals(taskDescription, createdTask.Description);
        System.assertEquals(testGroup.Id, createdTask.OwnerId);
        System.assertEquals(relatedType, createdTask.Related_Type__c);
    }
}