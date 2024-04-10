/***********************************************************************************************************************
 * Name: CM_AccountUpdateCaptureTriggerHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: CM_AccountUpdateCaptureTriggerHandler
 * TestClass : CM_AccountUpdateCaptureTriggerHandler
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Subscriber for CRM Enterprise trigger handler
 ***********************************************************************************************************************/
public with sharing class CM_AccountUpdateCaptureTriggerHandler extends UCB_TriggerVirtual {
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            system.debug('trigger.new==>>'+trgCtx.newList);
            CM_AccountUpdateCaptureTriggerHelper.accountContactRelations(trgCtx.newList);
        } catch (Exception excp) {
            system.debug('Account CDC==>>'+excp.getMessage());
        }
    }
}