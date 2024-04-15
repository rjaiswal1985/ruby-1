/***********************************************************************************************************************
 * Name: CM_ReltioHCOHCOPayloadTriggerHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio  MDM platform event
 * TestClass : CM_ReltioHCOHCOPayloadTriggerHandler
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          GSF-1139 - Class invoked from the Subscriber of the Reltio MDM platform event
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCOHCOPayloadTriggerHandler extends UCB_TriggerVirtual {
    /**********Metadat Records.************ */
    final Static Map <String, CM_ReltioHandlerService.SobjectData > PROCESS = CM_ReltioHandlerService.metadataRecords(CM_ReltioConstants.RELTIOHCOPHCO);
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            reltioPayloadTriggerService(trgCtx.newList);
        } catch (Exception excp) {
            CM_LoggerInitializationUtil.replayService(excp, 'CM_ReltioHCOHCOPayloadTriggerHandler');
        }
    }
    /**
     * @description : This method processes platform event by process name
     * @parameters : platform event, process name
     */
    public static void reltioPayloadTriggerService(List < Reltio_CM_HCO_HCO_Inbound_Payload__e > masterRecord) {
        Map <String, Map < String, Sobject >> upsertNewMap = new Map < String, Map < String, Sobject >> ();
        Map <String, Map < String, Sobject >> upsertOldMap;
        Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = new Map <String,CM_DMLSaveResult.DMLWrapper>();
        
        List<Sobject> toBeDelSobjects = new List<Sobject>();
        CM_ReltioHandlerService.OBJECTPARSER objParser;
        
        for (Reltio_CM_HCO_HCO_Inbound_Payload__e event: masterRecord) {
            objParser = CM_ReltioHCORelationshipService.upsertHCOHCOService(event.Input_Json__c, PROCESS);
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(objParser.resultMap, upsertNewMap);
        }

        upsertOldMap = new Map <String, Map < String, Sobject >>();
        upsertOldMap =CM_ReltioHCORelationshipService.getOldHCOHCOMap(upsertNewMap);
        upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);
        toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);

        dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS, CM_ReltioConstants.RELTIOHCOPHCO);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects));

        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCOPHCO, 'dmlWrapMap', JSON.serialize(dmlWrapMap)),false);
        UCB_LoggerService.publishLogs();  
    }
}