/***********************************************************************************************************************
* Name: CRM_OrderChangeEventTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handler/Subscriber for Order Change event
* TestClass : CRM_OrderChangeEventTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR               DATE                DETAIL
* 1.0             Sruthi M             24/04/2024          Handler/Subscriber for Account Change event
***********************************************************************************************************************/
public with sharing class CRM_OrderChangeEventTriggerHandler extends UCB_TriggerVirtual {
    /**     
*@description : After insert trigger handler
*/
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;  
        try {            
            CRM_OrderChangeEventTriggerHelper.processOrderEvents(trgCtx.newList);
        } catch (Exception excp) {                        
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Order Change Event';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        }
    }
}