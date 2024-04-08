trigger accountTrigger on Account (before insert, before update, after insert, after update) {
    Set<Id> AccountIds = new Set<Id>();
    Map<Id,List<Id>> accntTerrMap = new Map<Id,List<Id>>();
    if(trigger.isinsert && trigger.isbefore){
        system.debug('is before insert trigger');
    }
    if(trigger.isinsert && trigger.isafter){
        system.debug('is after insert trigger');
        AccountTriggerHandler_check.afterInsert(trigger.new);
    }
    if(trigger.isupdate && trigger.isbefore){
        system.debug('is before update trigger');
        AccountTriggerHandler_check.beforeInsert(trigger.new);
    }
    if(trigger.isupdate && trigger.isafter){
        system.debug('is after insert trigger');
    }
    


}