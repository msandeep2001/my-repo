public class triggerParent{
/* edited in local*/
/*
public virtual class CB_Trigger
{
    //Variable  Usage
    //Returns true if the current context for the Apex code is a trigger, not a Visualforce page, 
    //a Web service, or an executeanonymous() API call.
    public boolean isExecuting; 
    //Returns true if this trigger was fired due to an insert operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isInsert;    
    //Returns true if this trigger was fired due to an update operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isUpdate;    
    //Returns true if this trigger was fired due to a delete operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isDelete;    
    //Returns true if this trigger was fired before any record was saved.
    public boolean isBefore;    
    //Returns true if this trigger was fired after all records were saved.
    public boolean isAfter;     
    //Returns true if this trigger was fired after a record is recovered from the Recycle Bin 
    //(that is, after an undelete operation from the Salesforce user interface, Apex, or the API.)
    public boolean isUndelete;  
    //Returns a list of the new versions of the sObject records.
    //Note that this sObject list is only available in insert and update triggers, and the records 
    //can only be modified in before triggers.
    public list<sObject> newlist;           
    //A map of IDs to the new versions of the sObject records.
    //Note that this map is only available in before update, after insert, and after update triggers.
    public map<id,sObject> newMap;      
    //Returns a list of the old versions of the sObject records.
    //Note that this sObject list is only available in update and delete triggers.
    public list<sObject> oldlist;           
    //A map of IDs to the old versions of the sObject records.
    //Note that this map is only available in update and delete triggers.
    public map<id,sObject> oldMap;      
    //The total number of records in a trigger invocation, both old and new.    
    public integer size;
    
    public virtual boolean getUpdateFlag()  {   return false;   }
    public virtual void setUpdateFlag(boolean newVal)   {       }
    
    public boolean HasAlreadyUpdated
    {
        get {   
            boolean RetVal = getUpdateFlag();
            return (RetVal == null) ? false :   RetVal;
        }
        set {   setUpdateFlag(value);   }
    }
    
    public static boolean BypassAllTriggers
    {
        get
        {
            if (BypassAllTriggers == null) return false;
            return BypassAllTriggers;
        }
        set;
    }
    
    //Allows an individual trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.     
    protected boolean BypassInheritedTrigger
    {
        get
        {
            if (BypassInheritedTrigger == null) return false;
            return BypassInheritedTrigger;
        }
        set;
    }
    
    //Constructor to pass in all values of the trigger
    //@param : All Trigger values
    //@return : null
    public CB_Trigger(list<sObject> newlistin, map<id,sObject> newMapin, list<sObject> oldlistin, map<id,sObject> oldMapin,
                         boolean isExecutingin, boolean isInsertin, boolean isUpdatein,   boolean isDeletein, 
                         boolean isBeforein,    boolean isAfterin,  boolean isUndeletein, integer sizein)
    {
        this.newlist    = newlistin;
        this.newMap     = newMapin;
        this.oldlist    = oldlistin;
        this.oldMap     = oldMapin;
        this.isExecuting = isExecutingin;
        this.isInsert   = isInsertin;
        this.isUpdate   = isUpdatein;
        this.isDelete   = isDeletein;
        this.isBefore   = isBeforein;
        this.isAfter    = isAfterin;
        this.isUndelete = isUndeletein;
        this.size       = sizein;
    }
    
    //Public method to execute any functionality contained in the extension classes
    //@param : none 
    //@return : null
    public virtual void ProcessTrigger()
    {
        system.debug('CLQ_Trigger.ProcessTrigger: ' + TriggerExecutionType + '  IsBefore: ' + IsBefore + ' isAfter: ' + isAfter + ' isInsert: ' + isInsert + 
                      ' isUpdate: ' + isUpdate + ' isDelete: ' + isDelete + ' isUndelete: ' + isUndelete + ' size: ' + size);
        // BypassAllTriggers is public static, BypassInheritedTrigger is protected instance variable
        system.debug('BypassAllTriggers'+BypassAllTriggers);
        system.debug('BypassInheritedTrigger'+BypassInheritedTrigger);
        system.debug('HasAlreadyUpdated'+HasAlreadyUpdated);
        
        if (BypassAllTriggers || BypassInheritedTrigger) return;
        system.debug('ProcessTrigger: ' + ObjectName + ' ' + TriggerExecutionType + ' Trigger SOQL Start -----' + Limits.getQueries());
        
        if (IsBefore)
        {
            if (isInsert)        BeforeInsert();
            else if (isUpdate && !HasAlreadyUpdated)
            {
                BeforeUpdate();
            }
            else if (isUpdate && HasAlreadyUpdated)
            {
                system.Debug('Has Updated - Bypass Trigger');
            }
            else if (isDelete)   BeforeDelete();
            else if (isUndelete) BeforeUndelete();
        }
        else if (isAfter)
        {
            if (isInsert)        AfterInsert();
            else if (isUpdate && !HasAlreadyUpdated) 
            {
                AfterUpdate();
                //This flag will stop the trigger from running in a loop
                //In unit tests, we want the trigger to run many time in a test.
                //Allow testing to run many times, unless someone's code is really messed up
                //if (!Test.isRunningTest() || TestingNeedsToStopRecycle) - Breaks too many tests
                HasAlreadyUpdated = true;
            }
            else if (isUpdate && HasAlreadyUpdated)
            {
                system.Debug('Has Updated - Bypass Trigger');
            }
            else if (isDelete)   AfterDelete();
            else if (isUndelete) AfterUndelete();
        }
        
    }
    
    //The developer can override any of these methods when necessary
    public virtual void BeforeInsert() {}
    public virtual void BeforeUpdate() {}
    public virtual void BeforeDelete() {}
    public virtual void BeforeUndelete() {}
    public virtual void AfterInsert() {}
    public virtual void AfterUpdate() {}
    public virtual void AfterDelete() {}
    public virtual void AfterUndelete() {}
    
    public string ObjectName
    {
        get
        {
            sObject so;
            if(isInsert || isUpdate || isUndelete   )
            {
                so = newList[0] ;
            }else if(isDelete )
            {
                so = OldList[0] ;
            }
            if (so != null)
                return so.getSobjectType().getDescribe().getName() ;
            else
                return 'Null object';        
        }
    }
    //Returns the Type of execution being performed
    public string TriggerExecutionType
    {
        get
        {
            string ExcType = '';
            if (IsBefore) ExcType = 'Before';
            if (IsAfter) ExcType = 'After';
            if (isInsert) ExcType += 'Insert';
            if (isUpdate) ExcType += 'Update';
            if (isDelete) ExcType += 'Delete';
            if (isUndelete) ExcType += 'Undelete';
            return ExcType;
        }
    }
    
    public static boolean TestingNeedsToStopRecycle
    {
        get
        {
            if (TestingNeedsToStopRecycle == null) TestingNeedsToStopRecycle = false;
            return TestingNeedsToStopRecycle;
        }
        set;
    }
    
    public static boolean BypassSelectiveTriggers
    {
        get
        {
            if (Label.BypassAllTriggers == null || Label.BypassAllTriggers == '' || Label.BypassAllTriggers.equalsIgnoreCase('false')) return false;
            return Boolean.valueOf(Label.BypassAllTriggers);
        }
        set;
    }
    
    
}

*/
}