@isTest
public with sharing class TaskTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        TestSetup.defaultConfiguration();
    }
    
    @isTest
    public static void testOnBeforeInsert() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c = '1234';
        insert crdr;

        Task task = new Task();
        task.WhatId = crdr.Id;
        task.Subject = 'New Task';
        insert task;

        Task taskToTest = [SELECT Id, Subject, Related_Type__c from Task WHERE Id = :task.Id];

        System.assertEquals('New Task', taskToTest.Subject, 'The tasks subject shoudl be New Task');
        System.assertEquals(Case_CRDR__c.getSObjectType().getDescribe().getLabel(), taskToTest.Related_Type__c, 'Related_Type__c should be the same value as label for Case_CRDR__c');
    }

    @isTest
    public static void testOnBeforeUpdate() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c = '1234';
        insert crdr;

        Task task = new Task();
        task.WhatId = crdr.Id;
        task.Subject = 'New Task';
        insert task;

        Task taskToTest = [SELECT Id, Subject, Related_Type__c from Task WHERE Id = :task.Id];
        taskToTest.Subject = 'Updated Task';

        System.assertEquals('Updated Task', taskToTest.Subject, 'The tasks subject shoudl be New Task');
        System.assertEquals(Case_CRDR__c.getSObjectType().getDescribe().getLabel(), taskToTest.Related_Type__c, 'Related_Type__c should be the same value as label for Case_CRDR__c');
    }

    @isTest
    public static void testOnAfterInsertDraftCRDR() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c = '1234';
        crdr.Status__c = 'DRAFT';
        insert crdr;

        Test.startTest();
            Task task = new Task();
            task.WhatId = crdr.Id;
            task.Subject = 'New Task';
            insert task;
        Test.stopTest();

        Case_CRDR__c crdrToTest = [SELECT Id, Status__c from Case_CRDR__c WHERE ID = :crdr.Id];

        System.assertEquals('IN_REVIEW', crdrToTest.Status__c, 'The CRDR Status should be IN_REVIEW');
    }

    @isTest
    public static void testOnAfterInsertInReviewCRDR() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c = '1234';
        crdr.Status__c = 'IN_REVIEW';
        insert crdr;
        
        Test.startTest();
            Task task = new Task();
            task.WhatId = crdr.Id;
            task.Subject = 'New Task';
            insert task;
        Test.stopTest();
        Case_CRDR__c crdrToTest = [SELECT Id, Status__c from Case_CRDR__c WHERE ID = :crdr.Id];

        System.assertEquals('IN_REVIEW', crdrToTest.Status__c, 'The CRDR Status should remain IN_REVIEW');
    }
    
}