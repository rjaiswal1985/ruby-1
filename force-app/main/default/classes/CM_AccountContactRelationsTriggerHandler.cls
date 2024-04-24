/***********************************************************************************************************************
* Name: CM_AccountContactRelationsTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles Account Contact relation
* TestClass : CM_AccountContactRelationsTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023          Trigger handler on the Account Contact Relationship
***********************************************************************************************************************/
public with sharing class CM_AccountContactRelationsTriggerHandler extends UCB_TriggerVirtual {
    /**
     * Variable name method names 
    * @description : After insert trigger handlers
    */
    public override void beforeTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {            
            CM_AccountContactRelationsTriggerHelper.beforeEvent(trgCtx.newList);
        } catch(Exception excp) {              
            CM_LoggerInitializationUtil.replayService(excp,'CM_AccountContactRelationsTriggerHandler');  
        }
    }
    /**
     * Variable name method names 
    * @description : After insert trigger handlers
    */
    /*public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {      
            CM_AccountContactRelationsTriggerHelper.afterUpdateEvent(trgCtx.newList,(Map<Id,AccountContactRelation>)trgCtx.oldMap);
        } catch(Exception excp) {              
            CM_LoggerInitializationUtil.replayService(excp,'CM_AccountContactRelationsTriggerHandler');  
        }
    }*/
}