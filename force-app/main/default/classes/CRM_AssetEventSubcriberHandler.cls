/***********************************************************************************************************************
* Name: CRM_AssetEventSubcriberHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Publisher of Order platform event
* TestClass : CRM_AssetEventSubcriberHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/03/2024         Subscriber of Asset platform event.
***********************************************************************************************************************/
public with sharing class CRM_AssetEventSubcriberHandler extends UCB_TriggerVirtual {
    /* Variable name method names 
    * @description : After insert trigger handlers
    */    
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;
        try {              
            final List<CRM_Asset_Event__e> asstEvntLst = CRM_AssetEventService.processAssetEvents(trgCtx.newList);
            if( asstEvntLst != null && !asstEvntLst.isEmpty() ) {
                final List<Asset> assetUpdateLst = CRM_AssetEventSubcriberHelper.assetOwnerupdate(asstEvntLst);             
                final List <Database.SaveResult> updateResult = UCB_DMLUtility.updateRecords(assetUpdateLst,false);   
                UCB_LoggerService.logger(new UCB_Log('Asset Owner Update', 'DML Upsert Result', JSON.Serialize(updateResult)),false);  
                UCB_LoggerService.publishLogs(); 
            }                        
        } catch(Exception excp) {                            
        	custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Asset Owner Update Event';
			custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst); 
        } 
    }
}