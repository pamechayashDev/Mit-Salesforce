public virtual class TriggerHandler {
  
   
    public void run() {
      try{
        // dispatch to the correct handler method
        switch on Trigger.operationType  {
          when BEFORE_INSERT {
            this.beforeInsert(Trigger.new);
          }
          when BEFORE_UPDATE {
            this.beforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
          }
          when BEFORE_DELETE {
            this.beforeDelete(Trigger.old, Trigger.oldMap);
          }
          when AFTER_INSERT {
            this.afterInsert(Trigger.new, Trigger.newMap);
          }
          when AFTER_UPDATE {
            this.afterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
          }
          when AFTER_DELETE {
            this.afterDelete(Trigger.old, Trigger.oldMap);
          }
          when AFTER_UNDELETE {
            this.afterUndelete(Trigger.new, Trigger.newMap);
          }
        }

      } catch(exception ex) {
        String msg = ex.getMessage();
        System.debug('Error: Tlo Officer Batch ' + msg ) ; 
        HandleLogException.logException(ex);
        throw ex;
      }
    }
  
    @TestVisible
    protected virtual void beforeInsert(List<SObject> newRecords){}
    @TestVisible
    protected virtual void beforeUpdate(List<SObject> newRecords, List<SObject> oldRecords, Map<ID, SObject> newRecordMap , Map<ID, SObject> oldRecordMap ){}
    @TestVisible
    protected virtual void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap){}
    @TestVisible
    protected virtual void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){}
    @TestVisible
    protected virtual void afterUpdate(List<SObject> newRecords, List<SObject> oldRecords, Map<ID, SObject> newRecordMap, Map<ID, SObject> oldRecordMap){}
    @TestVisible
    protected virtual void afterDelete(List<SObject> newRecords, Map<ID, SObject> oldRecordMap){}
    @TestVisible
    protected virtual void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap){}
  
    public class TriggerHandlerException extends Exception {}
  
  }