@isTest
public class ExternalMock extends ExternalObjectQuery
    {
        final List<SObject > externalRecords;
        public ExternalMock(List<SObject > externalRecords)
        {
            this.externalRecords = externalRecords;
        }

        protected override List<SObject> passThrough(List<SObject> records)
        {
            return externalRecords;
        }
    }