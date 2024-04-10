/***********************************************************************************************************************
 * Name: CM_ReltioHCOInboundPayloadTriggerHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio  MDM HCO platform event
 * TestClass : CM_ReltioHCOInboundPayloadTriggerHandler
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   11/12/2023          Class invoked from the Subscriber of the Reltio MDM HCO platform event.
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCOInboundPayloadTriggerHandler extends UCB_TriggerVirtual {
    /**********Metadat Records.************ */
    final Static Map <String, CM_ReltioHandlerService.SobjectData > PROCESS = CM_ReltioHandlerService.metadataRecords(CM_ReltioConstants.RELTIOHCO);
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            reltioPayloadTriggerService(trgCtx.newList);
        } catch (Exception excp) {
            CM_LoggerInitializationUtil.replayService(excp, 'CM_ReltioHCOInboundPayloadTriggerHandler'); //rename to logger
        }
    }
    /**
     * @description : This method processes platform event by process name
     * @parameters : platform event, process name
     */
    public static void reltioPayloadTriggerService(List <Reltio_CM_HCO_Inbound_Payload__e> masterRecord) {
        Map <String, Map < String, Sobject >> upsertNewMap = new Map < String, Map < String, Sobject >> ();
        for (Reltio_CM_HCO_Inbound_Payload__e event: masterRecord) {
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(CM_ReltioHCOService.upsertHCOServices(event.Input_Json__c, PROCESS), upsertNewMap);
        }
        final Map <String, Map < String, Sobject >> upsertOldMap =CM_ReltioHCOService.getOldAccountMap(upsertNewMap);
        upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);
        final List<Sobject> toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
        final Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS, CM_ReltioConstants.RELTIOHCO);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects));
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCO, 'dmlWrapMap', JSON.serialize(dmlWrapMap)),false);
        UCB_LoggerService.publishLogs();  
    }
}