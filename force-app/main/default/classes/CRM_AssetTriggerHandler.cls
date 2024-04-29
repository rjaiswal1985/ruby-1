/***********************************************************************************************************************
* Name: CRM_AssetTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on Asset
* TestClass : CRM_AssetTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        06/03/2024          Asset trigger Handler.
***********************************************************************************************************************/
public with sharing class CRM_AssetTriggerHandler extends UCB_TriggerVirtual {
    /* to check recursion on trigger */
    public static Boolean isFirstRun = true; 
    /* 
    * @description : Asset trigger handler after insert
    */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {        
        String trgContextStr;
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;        
        try {            
            if(trgCtx.isInsert) { 
                trgContextStr =  CM_ReltioConstants.ASSETCREATED;                                                                
                CRM_AssetService.publishAssetEvent(trgCtx.newList,trgContextStr);
                //UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log('Publish Asset platformevent', 'CRM_AssetTriggerHandler','Published Asset platformevent' )});
            	//UCB_LoggerService.publishLogs();
            }            
        } catch(Exception excp) { 
        	custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Asset Owner Update';
			custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);
        } 
    }     
}