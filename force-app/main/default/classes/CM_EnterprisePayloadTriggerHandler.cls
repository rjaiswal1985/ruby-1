/***********************************************************************************************************************
 * Name: CM_EnterprisePayloadTriggerHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber for CRM Enterprise events
 * TestClass : CM_EnterprisePayloadTriggerHandler
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Subscriber for CRM Enterprise trigger handler
 ***********************************************************************************************************************/
public with sharing class CM_EnterprisePayloadTriggerHandler extends UCB_TriggerVirtual {
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            CM_EnterprisePayloadTriggerHelper.reltioPayloadTriggerService(trgCtx.newList);
        } catch (Exception excp) {
            CM_LoggerInitializationUtil.replayService(excp, 'CM_EnterprisePayloadTriggerHandler');
        }
    }
}