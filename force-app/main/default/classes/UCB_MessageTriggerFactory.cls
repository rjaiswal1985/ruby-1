/**
 * Created by kverheyden on 12.02.20.
 */

public with sharing class UCB_MessageTriggerFactory {
    /**
    * 
    *
    * @author kverheyden
    */
    public static Boolean isEventPublished {
        get {
            if(isEventPublished==null) {
                isEventPublished=false;
        	}
            return isEventPublished;
        }set;}
    /**
    * 
    * @description : boolean flag to control trigger execution
    * @author kverheyden
    */
    public static Boolean isSkipTrigger {
        get {
            if(isSkipTrigger==null) {
                isSkipTrigger=false;
        	}
            return isSkipTrigger;
        }
        set;}
    /**
    * 
    * @description : a map of triggerhandler vs flag to skip execution
    * @author kverheyden
    */
    final public static Map<String, Boolean> HANDLERSKIPMAP = new Map<String, Boolean>();
    /**
    * 
    *
    * @author kverheyden
    */
    private UCB_MessageTriggerFactory() {
    }
    /**
    * 
    * @description : static method to create an instance of related sObject trigger handler 
    * @author kverheyden
    */
    public static void createHandler(Schema.SObjectType soType) {
        final UCB_ITrigger handler = getHandler(soType);
        if (handler == null) {
            throw new UCB_TriggerException('No Trigger Handler registered for Object Type: ', soType);
        }
        execute(handler);
    }
    /**
    * 
    * @description : method to add a mapping for handlers to be skipped 
    * @author kverheyden
    */
    public static void setSkipHandler(String handlerName, Boolean skip) {
       HANDLERSKIPMAP.put(handlerName, skip);
    }
    /**
    * 
    * @description : method to execute the trigger logic based on the events
    * @author kverheyden
    */
    private static void execute(UCB_ITrigger handler) {
        Boolean skip = false;
        // The skip flag in the map has a higher priority than global flag
        if (HANDLERSKIPMAP.containsKey(String.valueOf(handler).split(':')[0])) {
            skip = HANDLERSKIPMAP.get(String.valueOf(handler).split(':')[0]);
        } else if (UCB_MessageTriggerFactory.isSkipTrigger) {
            skip = UCB_MessageTriggerFactory.isSkipTrigger;
        }
        if (skip) {
            return;
        }
        System.debug('--! Trigger.isBefore '+Trigger.isBefore);
        System.debug('--! Trigger.isAfter '+Trigger.isAfter);
        System.debug('--! Trigger.isInsert '+Trigger.isInsert);
        System.debug('--! Trigger.isUpdate '+Trigger.isUpdate);
        System.debug('--! Trigger.isDelete '+Trigger.isDelete);
        System.debug('--! Trigger.isUndelete '+Trigger.isUndelete);
        /*System.debug('--! Trigger.new '+Trigger.new);
                System.debug('--! Trigger.newMap '+Trigger.newMap);
                System.debug('--! Trigger.old '+Trigger.old);
                System.debug('--! Trigger.oldMap '+Trigger.oldMap);*/
        System.debug('--! Trigger.isUndelete '+Trigger.isUndelete);
        final UCB_Trigger.TriggerContext trgCtx = new UCB_Trigger.TriggerContext(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        if (Trigger.isBefore) {
            handler.bulkBefore(trgCtx);
            handler.beforeTrigger(trgCtx);
        } else {
            handler.bulkAfter(trgCtx);
            handler.afterTrigger(trgCtx);
        }
        handler.andFinally(trgCtx);
    }
    /**
    * 
    * @description : method to create handler instance for the related sobject
    * @author kverheyden
    */
    private static UCB_ITrigger getHandler(Schema.SObjectType soType) {
        final UCB_TriggerVirtual handler;
        Map<String, String> mapSoTypeHandler = new Map<String, String>();
        mapSoTypeHandler = UCB_FactorySelector.getFactoryHandlers();
        System.debug('--! Map of Handlers : '+mapSoTypeHandler);
        final String sObjectType = String.valueOf(soType);
        if (mapSoTypeHandler.containsKey(sObjectType)) {
            final Type type = Type.forName(mapSoTypeHandler.get(sObjectType));
            handler = (UCB_TriggerVirtual) type.newInstance();
        }
        System.debug('---! Handler Created ' +handler);
        return handler;
    }
}