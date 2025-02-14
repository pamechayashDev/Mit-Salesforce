/**
 * Created by Andreas du Preez on 2024/03/19.
 */

@IsTest
public with sharing class CrdrControllerTest {

    @TestSetup
    static void setup() {
       TestSetup.defaultConfiguration();
    }

    private static final String TEST_CASE_CRDR_REC_ID_1 = '123456789';
    private static final String TEST_CASE_CRDR_REC_ID_2 = '1234567892';
    private static final String TEST_CASE_CRDR_NAME = 'Test Case CRDR Name';
    private static final String TEST_CASE_CONTRACT_NUMBER = '987654321';
    private static final String TEST_ACREEMENT_REC_ID = '456123789';

    public static CrdrController.RelatedCRDRs getRelatedCRDRTestData()
    {
        return new CrdrController.RelatedCRDRs(
                null,
                TEST_CASE_CRDR_REC_ID_1,
                TEST_CASE_CRDR_NAME,
                null,
                TEST_CASE_CONTRACT_NUMBER,
                null,
                TEST_ACREEMENT_REC_ID,
                false,
                null,
                null
        );
    }

    @IsTest
    public static void getRelatedCRDROpenTaskCountTest()
    {
        String testCaseCRDRRecId = TEST_CASE_CRDR_REC_ID_1;
        String groupDeveloperName = 'Test_Queue';
        Group testGroup = new Group(Name='Test Queue', DeveloperName=groupDeveloperName, Type='Queue');
        insert testGroup;

        Case_CRDR__c testCaseCRDR = new Case_CRDR__c(Name='Test Account');
        testCaseCRDR.ExternalCaseCRDRId__c = testCaseCRDRRecId;
        insert testCaseCRDR;

        String taskSubject = 'Test Subject';
        String taskRelatedTo = 'Case_CRDR__c';
        String taskPriority = 'Normal';
        String taskStatusNotStarted = 'Not Started';
        String taskStatusCompleted = 'Completed';
        String taskDescription = 'Test Comment';

        TaskHelper.createTask(testCaseCRDR.Id, taskSubject, taskRelatedTo, taskPriority, taskStatusNotStarted, taskDescription, null, groupDeveloperName, 'Queue');
        TaskHelper.createTask(testCaseCRDR.Id, taskSubject, taskRelatedTo, taskPriority, taskStatusNotStarted, taskDescription, null, groupDeveloperName, 'Queue');
        TaskHelper.createTask(testCaseCRDR.Id, taskSubject, taskRelatedTo, taskPriority, taskStatusCompleted, taskDescription, null, groupDeveloperName, 'Queue');

        Test.startTest();
        List<CrdrController.RelatedCRDRs> result = CrdrController.getRelatedCRDROpenTaskCount(testCaseCRDRRecId);
        Test.stopTest();

        System.assertEquals(2, result[0].OpenTaskCount);
        System.assertEquals(testCaseCRDR.Id, result[0].CaseCrdrId);
    }

    @IsTest
    public static void updateMultipleCaseCRDRStatusTest()
    {
        List<Case_CRDR__c> testCaseCRDRList = new List<Case_CRDR__c>();
        List<Id> testCaseCRDRIds = new List<Id>();

        Case_CRDR__c testCaseCRDR1 = new Case_CRDR__c(Name='Test CRDR 1');
        testCaseCRDR1.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        testCaseCRDR1.Status__c = 'AWAITING_DRAFT';

        Case_CRDR__c testCaseCRDR2 = new Case_CRDR__c(Name='Test CRDR 2');
        testCaseCRDR2.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_2;
        testCaseCRDR2.ExternalCaseCRDRId__c = 'IN_REVIEW';

        testCaseCRDRList.add(testCaseCRDR1);
        testCaseCRDRList.add(testCaseCRDR2);

        insert testCaseCRDRList;

        for (Case_CRDR__c testCaseCRDR : testCaseCRDRList)
        {
            testCaseCRDRIds.add(testCaseCRDR.Id);
        }

        Test.startTest();
        CrdrController.updateMultipleCaseCRDRStatus(testCaseCRDRIds, 'APPROVED');
        Test.stopTest();

        testCaseCRDRList = [SELECT Id, Status__c FROM Case_CRDR__c WHERE Id IN :testCaseCRDRIds];

        for (Case_CRDR__c testCaseCRDR : testCaseCRDRList)
        {
            System.assertEquals('APPROVED', testCaseCRDR.Status__c);
        }
    }

    @IsTest
    public static void getCaseCRDRAuditEventsTest()
    {
        Case_CRDR__c testCaseCRDR1 = new Case_CRDR__c(Name='Test CRDR 1');
        testCaseCRDR1.ExternalCaseCRDRId__c = TEST_CASE_CRDR_REC_ID_1;
        testCaseCRDR1.Status__c = 'AWAITING_DRAFT';

        insert testCaseCRDR1;

        testCaseCRDR1.Status__c = 'DRAFT';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'IN_REVIEW';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'AWAITING_DRAFT';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'DRAFT';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'IN_REVIEW';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'APPROVED';
        update testCaseCRDR1;
        testCaseCRDR1.Status__c = 'FINALIZED';
        update testCaseCRDR1;

        Test.startTest();
        List<Case_CRDR_Audit_Event__c> result = CrdrController.getCaseCRDRAuditEvents(testCaseCRDR1.Id);
        Test.stopTest();

        System.assertEquals(8, result.size());
    }
}