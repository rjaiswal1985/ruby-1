/***********************************************************************************************************************
* Name: CM_AccountRelationshipTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Publishes event on Account-Account Relationship
* TestClass : CM_AccountRelationshipTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023          Trigger handler publishes event for Account-Account Relationship
***********************************************************************************************************************/
public with sharing class CM_AccountRelationshipTriggerHandler extends UCB_TriggerVirtual {
    /**
    * @description : After insert trigger handlers
    */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {            
            CM_AccountRelationshipTriggerHelper.publishEvent(trgCtx.newList);
        } catch(Exception excp) {              
            CM_LoggerInitializationUtil.replayService(excp,'CM_AccountRelationshipTriggerHandler');  
        }
    }
}