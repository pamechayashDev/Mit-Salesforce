@isTest
public class BatchableContextMock implements Database.BatchableContext {
    private Id childJob, job;

    public BatchableContextMock() {
        Id fakeId = TestUtility.getFakeId(AsyncApexJob.sObjectType);
        this.job = fakeId;
        this.childJob = fakeId;
    }

    public BatchableContextMock(Id job, Id childJob){
        this.job = job;
        this.childJob = childJob;
    }
    public ID getChildJobID()
    {
        return childJob;
    }
    public ID getJobID()
    {
        return job;
    }
}