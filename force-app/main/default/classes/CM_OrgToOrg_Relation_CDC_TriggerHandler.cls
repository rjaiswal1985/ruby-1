/***********************************************************************************************************************
* Name: CM_OrgToOrg_Relation_CDC_TriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handler/Subscriber for AccountAccountRelation Change event
* TestClass : CM_OrgToOrg_Relation_CDC_TriggerHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                     DATE                DETAIL
* 1.0             Sruthi M                   30/04/2024          Subscriber for Account-AccountRelation Change event
***********************************************************************************************************************/
public with sharing class CM_OrgToOrg_Relation_CDC_TriggerHandler extends UCB_TriggerVirtual {
    /**     
*@description : After insert trigger handler
*/
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {        
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;  
        try {              
            //CM_AcctContRelation_CDC_TriggerHelper.accountContactRelations(trgCtx.newList);
        } catch (Exception excp) {                         
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Account_Account Relation Change Event';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        }
    }
}