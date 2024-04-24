/***********************************************************************************************************************
* Name: CM_AccountUpdateCaptureTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handler/Subscriber for Account Change event
* TestClass : CM_AccountUpdateCaptureTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   02/04/2024          Subscriber for Account Change event
***********************************************************************************************************************/
public with sharing class CM_AccountUpdateCaptureTriggerHandler extends UCB_TriggerVirtual {
    /**     
*@description : After insert trigger handler
*/
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;  
        try {            
            CM_AccountUpdateCaptureTriggerHelper.accountContactRelations(trgCtx.newList);
        } catch (Exception excp) {                        
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Account Change Event';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        }
    }
}