@isTest
public with sharing class CaseCRDRTriggerHandlerTest {
    private static final String TEST_CASE_CRDR_REC_ID_1 = '123456789';

    @TestSetup
    static void setup() {
       TestSetup.defaultConfiguration();
    }

  @isTest
    public static void testOnCrdrStatusChange_AwaitingDraftToDraft() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'AWAITING_DRAFT';
        insert crdr;

        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal',
                                         'Not Started', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'DRAFT';
        update crdrContainerToUpdate;

        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId LIMIT 1];
        System.assertEquals('987654321', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');

        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should have been updated to Complete');

    }

    @isTest
    public static void testOnCrdrStatusChange_InReviewToDraft() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'IN_REVIEW';
        insert crdr;

        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal',
                'Not Started', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'DRAFT';
        update crdrContainerToUpdate;

        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId LIMIT 1];
        System.assertEquals('987654321', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');

        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should have been updated to Complete');

    }

    @isTest
    public static void testOnCrdrStatusChange_DraftToDraft() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'DRAFT';
        insert crdr;

        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal',
                'Not Started', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'DRAFT';
        update crdrContainerToUpdate;

        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId LIMIT 1];
        System.assertEquals('987654321', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');

        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should have been updated to Complete');

    }

    @isTest
    public static void testOnCrdrStatusChange_DraftToFinalized() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'DRAFT';
        insert crdr;

        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal',
                'Not Started', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'FINALIZED';
        update crdrContainerToUpdate;

        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId LIMIT 1];
        System.assertEquals('987654321', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');

        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should have been updated to Complete');

    }

    @isTest
    public static void testOnCrdrStatusChange_TaskValidation() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'AWAITING_DRAFT';
        insert crdr;

        List<Case_CRDR_Audit_Event__c> auditEvents = [SELECT Id, Status__c, Message__c, Subject__c
                                                                  FROM Case_CRDR_Audit_Event__c
                                                                  WHERE Case_CRDR__c = :crdr.Id
                                                                  ];
        System.assertEquals(1, auditEvents.size(), 'Audit event created linked to Container object');

        // Queue Task
        String groupDeveloperName = 'Test_Queue';
        Group testGroup = new Group(Name='Test Queue', DeveloperName=groupDeveloperName, Type='Queue');
        insert testGroup;
        Id queueTaskId = TaskHelper.createTask(crdr.Id, 'Test Awaiting draft', 'Case_CRDR__c', 'Normal',
                                         'Not Started', 'Test Awaiting draft', null, groupDeveloperName, 'Queue');

        // User Task
        Id currentUserId = UserInfo.getUserId();
        Id userTaskId = TaskHelper.createTask(crdr.Id, 'Test Awaiting draft', 'Case_CRDR__c', 'Normal',
                                              'Not Started', 'Test Awaiting draft', currentUserId, null, null);

        // Finance Queue Task
        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal', 
                                         'Not Started', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');

        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Test.startTest();
        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'DRAFT';
        update crdrContainerToUpdate;

        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654000'; // crdr was deleted and re-created in forrester
        update crdrContainerToUpdate;

        Test.stopTest();

        //Main test is to check that the tasks CRDR__c has infact changed
        String taskStatusNotStarted = 'Not Started';
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId and Id = :taskId LIMIT 1];
        System.assertEquals('987654000', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');
        
        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should have been updated to Complete');

        Task updatedQueueTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId and Id = :queueTaskId LIMIT 1];
        System.assertEquals(taskStatusNotStarted, updatedQueueTask.Status, 'Task Status value should match initial value');

        Task updatedUserTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId and Id = :userTaskId LIMIT 1];
        System.assertEquals(taskStatusNotStarted, updatedUserTask.Status, 'Task Status value should match initial value');

        System.assertEquals(1, BellNotificationStrategy.sendCounter, 'Only one Bell Notification should have been send');

    }

    @isTest
    public static void testOnStatusChangeCloseFinanceTasks_TaskAlreadyCompleted() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'AWAITING_DRAFT';
        insert crdr;

        Id taskId = TaskHelper.createTask(crdr.Id, 'Rerun Draft CRDR', 'Case_CRDR__c', 'Normal', 
                                         'Completed', 'Rerun Draft CRDR', null, 'Finance_Queue', 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status, LastModifiedDate FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');

        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.Status__c = 'DRAFT';
        update crdrContainerToUpdate;
        
        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status, LastModifiedDate FROM Task WHERE WhatId = :containerId LIMIT 1];
        
        System.assertEquals('123456789', updatedTask.CRDR__c, 'Task CRDR__c value should still match original Container object as it was not changed in this test');        
        System.assertEquals('Completed', updatedTask.Status, 'Finance Task Status value should still be Completed as thats where it starting in this test');

        // ie: no updates should have been made to the Task, as nothing change to affect the task
        System.assertEquals(newTask.LastModifiedDate, updatedTask.LastModifiedDate, 'Finance Task LastModifiedDate should not have changed');
        
    }

    @isTest
    public static void testOnStatusChangeSyncToForrester() {
        List<Forrester_SHIR_CASE_CRDR_STATUS__x> mockRecords = new List<Forrester_SHIR_CASE_CRDR_STATUS__x>();
        Forrester_SHIR_CASE_CRDR_STATUS__x mockRecord = new Forrester_SHIR_CASE_CRDR_STATUS__x();
        mockRecord.CASE_CRDR_RECID__c = TEST_CASE_CRDR_REC_ID_1;
        mockRecord.CRDR_STATUS__c = 'DRAFT';
        mockRecords.add(mockRecord);

        ExternalObjectQuery.setMock(new ExternalMock(mockRecords));

        Test.startTest();

        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        crdr.Status__c = 'DRAFT';
        insert crdr;

        crdr.Status__c = 'IN_REVIEW';
        update crdr;

        Test.stopTest();
    }

    @IsTest
    public static void testIgnore2023FinalizedAudit()
    {
        Id currentUserId = UserInfo.getUserId();
        String currentUserNames = UserInfo.getName();

        Case_CRDR__c crdr = new Case_CRDR__c(Name='14817RJM - [2023] (30-JUN-23)');
        crdr.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        crdr.Status__c = 'FINALIZED';
        insert crdr;

        try {
            Case_CRDR_Audit_Event__c auditEventInFinalized = [SELECT Id, Status__c, Message__c, Subject__c 
                                                          FROM Case_CRDR_Audit_Event__c 
                                                          WHERE Case_CRDR__c = :crdr.Id 
                                                          AND Status__c = 'FINALIZED' LIMIT 1];

            System.assert(false, 'If FY in the name has [2023], NO audit trail for FINALIZED must get created.');
        } catch (Exception error) {
            System.assert(true, error.getMessage());
        }
        
    }

    @IsTest
    public static void testDontIgnore2023FinalizedAudit()
    {
        Id currentUserId = UserInfo.getUserId();
        String currentUserNames = UserInfo.getName();

        Case_CRDR__c crdr = new Case_CRDR__c(Name='14817RJM - [2024] (30-JUN-23)');
        crdr.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        crdr.Status__c = 'FINALIZED';
        insert crdr;

        try {
            Case_CRDR_Audit_Event__c auditEventInFinalized = [SELECT Id, Status__c, Message__c, Subject__c 
                                                          FROM Case_CRDR_Audit_Event__c 
                                                          WHERE Case_CRDR__c = :crdr.Id 
                                                          AND Status__c = 'FINALIZED' LIMIT 1];

            System.assert(true, 'If FY in the name is anything other than [2023], audit trail for FINALIZED must get created.');
        } catch (Exception error) {
            System.assert(false, error.getMessage());
        }
        
    }


    @IsTest
    public static void insertAuditEventTest()
    {
        Id currentUserId = UserInfo.getUserId();
        String currentUserNames = UserInfo.getName();

        Case_CRDR__c testCaseCRDR1 = new Case_CRDR__c(Name='Test CRDR 1');
        testCaseCRDR1.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        testCaseCRDR1.Status__c = 'DRAFT';

        insert testCaseCRDR1;

        testCaseCRDR1.Status__c = 'DRAFT';
        Test.startTest(); // Only test one iteration of the trigger for governor limits
        update testCaseCRDR1;
        Test.stopTest();
        Case_CRDR_Audit_Event__c auditEventDraft = [SELECT Id, Status__c, Message__c, Subject__c FROM Case_CRDR_Audit_Event__c WHERE Case_CRDR__c = :testCaseCRDR1.Id AND Status__c = 'DRAFT' LIMIT 1];
        testCaseCRDR1.Status__c = 'IN_REVIEW';
        update testCaseCRDR1;
        Case_CRDR_Audit_Event__c auditEventInReview = [SELECT Id, Status__c, Message__c, Subject__c FROM Case_CRDR_Audit_Event__c WHERE Case_CRDR__c = :testCaseCRDR1.Id AND Status__c = 'IN_REVIEW' LIMIT 1];
        testCaseCRDR1.Status__c = 'AWAITING_DRAFT';
        update testCaseCRDR1;
        Case_CRDR_Audit_Event__c auditEventInAwaitingDraft = [SELECT Id, Status__c, Message__c, Subject__c FROM Case_CRDR_Audit_Event__c WHERE Case_CRDR__c = :testCaseCRDR1.Id AND Status__c = 'AWAITING_DRAFT' ORDER BY CreatedDate DESC LIMIT 1];
        testCaseCRDR1.Status__c = 'DRAFT';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'IN_REVIEW';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'APPROVED';
        update testCaseCRDR1;
        Case_CRDR_Audit_Event__c auditEventInApproved = [SELECT Id, Status__c, Message__c, Subject__c FROM Case_CRDR_Audit_Event__c WHERE Case_CRDR__c = :testCaseCRDR1.Id AND Status__c = 'APPROVED' LIMIT 1];
        testCaseCRDR1.Status__c = 'FINALIZED';
        update testCaseCRDR1;
        Case_CRDR_Audit_Event__c auditEventInFinalized = [SELECT Id, Status__c, Message__c, Subject__c FROM Case_CRDR_Audit_Event__c WHERE Case_CRDR__c = :testCaseCRDR1.Id AND Status__c = 'FINALIZED' LIMIT 1];


        System.assertEquals(auditEventDraft.Subject__c, 'Draft Created');
        System.assertEquals(auditEventDraft.Message__c, 'CRDR Draft has been created');

        System.assertEquals(auditEventInReview.Subject__c, 'In Review');
        System.assertEquals(auditEventInReview.Message__c, '{' + currentUserId + ';' + currentUserNames + '} has started reviewing the CRDR');

        System.assertEquals(auditEventInAwaitingDraft.Subject__c, 'Sent for Adjustment/Feedback');
        System.assertEquals(auditEventInAwaitingDraft.Message__c, '{' + currentUserId + ';' + currentUserNames + '} has requested adjustments');

        System.assertEquals(auditEventInApproved.Subject__c, 'Approved');
        System.assertEquals(auditEventInApproved.Message__c, '{' + currentUserId + ';' + currentUserNames + '} has approved the CRDR');

        System.assertEquals(auditEventInFinalized.Subject__c, 'Finalized');
        System.assertEquals(auditEventInFinalized.Message__c, '{' + currentUserId + ';' + currentUserNames + '} has finalized the CRDR');
    }

    @IsTest
    public static void testOnCrdrStatusChange_ApprovedToFinalized() {
        Case_CRDR__c crdr = new Case_CRDR__c();
        crdr.Name = '1234';
        crdr.ExternalCaseCRDRId__c =  '123456789';
        crdr.Status__c = 'AWAITING_DRAFT';
        insert crdr;

        String groupDeveloperName = 'Test_Queue';
        String taskSubject = 'Test Subject';
        String taskRelatedTo = 'Case_CRDR__c';
        String taskPriority = 'Normal';
        String taskStatusNotStarted = 'Not Started';
        String taskStatusCompleted = 'Completed';
        String taskDescription = 'Test Comment';

        Id taskId = TaskHelper.createTask(crdr.Id, taskSubject, taskRelatedTo, taskPriority, taskStatusNotStarted, taskDescription, null, groupDeveloperName, 'Queue');
        Task newTask = [SELECT Id, CRDR__c, Status FROM Task WHERE Id = :taskId LIMIT 1];
        System.assertEquals('123456789', newTask.CRDR__c, 'Task CRDR__c value should match the Container object');
        System.assertEquals(taskStatusNotStarted, newTask.Status, 'Task Status value should match initial value');

        crdr.Status__c = 'DRAFT';
        update crdr;

        crdr.Status__c = 'IN_REVIEW';
        update crdr;

        crdr.Status__c = 'APPROVED';
        update crdr;

        Test.startTest();
        Case_CRDR__c crdrContainerToUpdate = [SELECT Id, ExternalCaseCRDRId__c FROM Case_CRDR__c WHERE Name = '1234' LIMIT 1];
        crdrContainerToUpdate.ExternalCaseCRDRId__c =  '987654321';
        crdrContainerToUpdate.Status__c = 'FINALIZED';
        update crdrContainerToUpdate;
        Test.stopTest();
        
        //Main test is to check that the tasks CRDR__c has infact changed
        Id containerId = crdrContainerToUpdate.id;
        Task updatedTask = [SELECT Id, CRDR__c, Status FROM Task WHERE WhatId = :containerId LIMIT 1];
        System.assertEquals('987654321', updatedTask.CRDR__c, 'Task CRDR__c value should match the updated one on Container object');        
        System.assertEquals(taskStatusNotStarted, updatedTask.Status, 'Task Status value should match initial value');


    }
}