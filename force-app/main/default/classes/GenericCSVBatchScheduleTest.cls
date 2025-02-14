@isTest
public with sharing class GenericCSVBatchScheduleTest {
    @TestSetup
    static void setup() {
        TestSetup.defaultConfiguration();
        TestSetup.defaultDocTemplatesConfiguration();
    }

    @isTest
    public static void testScheduleAbort() {
        Test.startTest();
        DraftDisclosureReminderSchedule.scheduleMe();
        DraftDisclosureReminderSchedule.abortSchedule();
        Test.stopTest();
    }


}