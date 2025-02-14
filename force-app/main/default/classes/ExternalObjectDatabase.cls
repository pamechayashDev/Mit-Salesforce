public virtual inherited sharing class ExternalObjectDatabase
{
   static ExternalObjectDatabase instance = new ExternalObjectDatabase();
   @TestVisible static void setMock(ExternalObjectDatabase mock ) {
        instance = mock; 
   }

   public static void updateAsync(SObject sfObject, DataSource.AsyncSaveCallback asyncSaveCallback, System.AccessLevel accessLevel)
   {
      instance.updatePassThrough(sfObject, asyncSaveCallback, accessLevel);
   }

   public static void insertAsync(SObject sfObject, DataSource.AsyncSaveCallback asyncSaveCallback, System.AccessLevel accessLevel)
   {
      instance.insertPassThrough(sfObject, asyncSaveCallback, accessLevel);
   }

   protected virtual void updatePassThrough(SObject sfObject , DataSource.AsyncSaveCallback asyncSaveCallback, System.AccessLevel accessLevel)
   {
       Database.updateAsync(sfObject, asyncSaveCallback, accessLevel);
   }

  protected virtual void insertPassThrough(SObject sfObject , DataSource.AsyncSaveCallback asyncSaveCallback, System.AccessLevel accessLevel)
  {
      Database.insertAsync(sfObject, asyncSaveCallback, accessLevel);
  }
}