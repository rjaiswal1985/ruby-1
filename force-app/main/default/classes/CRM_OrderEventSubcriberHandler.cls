/***********************************************************************************************************************
* Name: CRM_OrderEventSubcriberHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Order platform event
* TestClass : CRM_OrderEventSubcriberHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/02/2024          Subscriber of Order platform event.
***********************************************************************************************************************/
public with sharing class CRM_OrderEventSubcriberHandler extends UCB_TriggerVirtual {
    /* Variable name method names 
    * @description : After trigger handlers
    */    
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {     
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;
        try {              
        	CRM_OrderEventService.processOrderEvents(trgCtx.newList);
            UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log('Update Order owner', 'CRM_OrderEventSubcriberHandler','Updated Owner' )});
            UCB_LoggerService.publishLogs();             
        } catch(Exception excp) {
        	custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Order Owner Update Event';
			custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        } 
    }
}