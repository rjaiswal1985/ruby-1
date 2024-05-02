/***********************************************************************************************************************
* Name: CM_AcctContRelation_CDC_TriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handler/Subscriber for AccountContactRelation Change event
* TestClass : CM_AcctContRelation_CDC_TriggerHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   18/04/2024          Subscriber for AccountContactRelation Change event
***********************************************************************************************************************/
public with sharing class CM_AcctContRelationCDC_TriggerHandler extends UCB_TriggerVirtual {
    /**     
*@description : After insert trigger handler
*/
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {        
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;  
        try {              
            CM_AcctContRelation_CDC_TriggerHelper.accountContactRelations(trgCtx.newList);
        } catch (Exception excp) {                         
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'AccountContactRelation Change Event';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        }
    }
}