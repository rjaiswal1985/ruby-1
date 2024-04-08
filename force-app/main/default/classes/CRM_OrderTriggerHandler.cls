/***********************************************************************************************************************
* Name: CRM_OrderTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on order
* TestClass : CRM_OrderTriggerHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/02/2024          Class invoked on Order triggered events.
***********************************************************************************************************************/
public with sharing class CRM_OrderTriggerHandler extends UCB_TriggerVirtual {
    /* to check recursion on trigger */
    public static Boolean isFirstRun = true; 
    
    /*
* @description : Order trigger handler for after events
*/
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {        
        String trgContextStr;        
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;		        
        try {                            
            if(trgCtx.isInsert) {                                                                      
                trgContextStr = 'Create_Order';                                                              
                CRM_OrderService.publishOrderEvent(trgCtx.newList,trgContextStr);
                UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log('Publish Order platformevent', 'CRM_OrderTriggerHandler', 'Published Order platformevent')});
                UCB_LoggerService.publishLogs();                
            } 
            
        } catch(Exception excp) {
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Order Owner Update';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);             
            
        } 
    }
    
}