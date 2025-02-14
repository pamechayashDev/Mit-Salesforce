@isTest
public class CrdrViewExternalMock extends ExternalObjectQuery
    {
        final List<Forrester_SHIR_CRDR_VIEW__x > externalRecords;
        public CrdrViewExternalMock(List<Forrester_SHIR_CRDR_VIEW__x > externalRecords)
        {
            this.externalRecords = externalRecords;
        }

        protected override List<SObject> passThrough(List<SObject> records)
        {
            return externalRecords;
        }
    }