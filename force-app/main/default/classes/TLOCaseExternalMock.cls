public class TLOCaseExternalMock extends ExternalObjectQuery
    {
        final List<Forrester_Case__x > externalRecords;
        public TLOCaseExternalMock(List<Forrester_Case__x > externalRecords)
        {
            this.externalRecords = externalRecords;
        }

        protected override List<SObject> passThrough(List<SObject> records)
        {
            return externalRecords;
        }
    }