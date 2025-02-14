public virtual inherited sharing class ExternalObjectQuery
{
   static ExternalObjectQuery instance = new ExternalObjectQuery();
   @TestVisible static void setMock(ExternalObjectQuery mock ) { 
        instance = mock; 
   }

   public static List<SObject> records(List<SObject> records)
   {
      return instance.passThrough(records);
   }

   public static SObject singleRecord(List<SObject> records)
   {
      return instance.singlePassThrough(records);
   }

   protected virtual List<SObject> passThrough(List<SObject> records)
   {
      return records;
   }

   protected virtual SObject singlePassThrough(List<SObject> records)
   {
      return records[0];
   }
}