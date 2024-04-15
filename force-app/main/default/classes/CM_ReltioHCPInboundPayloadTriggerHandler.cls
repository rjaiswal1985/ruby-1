/***********************************************************************************************************************
* Name: CM_ReltioHCPInboundPayloadTriggerHandler
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM HCP platform event
* TestClass : CM_ReltioHCPInboundPayloadTriggerHandler
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   11/12/2023          Class invoked from the Subscriber of the Reltio MDM HCP platform event.
***********************************************************************************************************************/
public with sharing class CM_ReltioHCPInboundPayloadTriggerHandler extends UCB_TriggerVirtual {
    /**********Metadat Records.************ */
    final Static Map <String, CM_ReltioHandlerService.SobjectData > PROCESS = CM_ReltioHandlerService.metadataRecords(CM_ReltioConstants.RELTIOHCP);
    /* Variable name method names 
    * @description : After insert trigger handlers
    */
    public  override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            reltioPayloadTriggerService(trgCtx.newList);            
        } catch(Exception excp) {              
            CM_LoggerInitializationUtil.replayService(excp,'CM_ReltioHCPInboundPayloadTriggerHandler');  
        } 
    }
    /**
    * @description : This method processes platform event by process name
    * @parameters : platform event, process name
    */
    public static void reltioPayloadTriggerService(List<Reltio_CM_HCP_Inbound_Payload__e > masterRecord) {  
        Map <String, Map < String, Sobject >> upsertNewMap = new Map < String, Map < String, Sobject >> ();
        Map <String, Map < String, Sobject >> upsertOldMap;        
        Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = new Map <String,CM_DMLSaveResult.DMLWrapper>();

        List<Sobject> toBeDelSobjects = new List<Sobject>();
        CM_ReltioHandlerService.OBJECTPARSER objParser;
        Boolean entiryUpdated = false;

        for (Reltio_CM_HCP_Inbound_Payload__e event: masterRecord) {
            objParser = CM_ReltioHCPService.upsertHCPServices(event.Input_Json__c, PROCESS);
            if(objParser.apiType==CM_ReltioConstants.ENTITYUPDATED && !entiryUpdated) {
                entiryUpdated=true;
            }
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(objParser.resultMap, upsertNewMap);
        }
        
        if(entiryUpdated) {
            upsertOldMap =CM_ReltioHCPService.getOldContactMap(upsertNewMap);
            upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);
            toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
        }

        dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS, CM_ReltioConstants.RELTIOHCP);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects));

        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCP, 'dmlWrapMap', JSON.serialize(dmlWrapMap)),false);
        UCB_LoggerService.publishLogs();  
    }   
}