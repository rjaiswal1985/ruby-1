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
        Map <String, Map < String, Sobject >> upsertOldMap = new Map <String, Map < String, Sobject >>();
        Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = new Map <String,CM_DMLSaveResult.DMLWrapper>();
        
        final Map<String,String> mdmId2parent = new Map<String,String>(); 
        final Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event = new Map<String,CM_ReltioHandlerService.EVENTDETAILS>() ;

        List<Sobject> toBeDelSobjects = new List<Sobject>();
        CM_ReltioHandlerService.OBJECTPARSER objParser;
        CM_ReltioHandlerService.EVENTDETAILS eventDetail;

        
        for (Reltio_CM_HCO_HCO_Inbound_Payload__e event: masterRecord) {
            CM_LoggerUtil.jsonLogger(new CM_Log(CM_ReltioConstants.RELTIOHCOPHCO, event.replayid,event.eventuuid, event.Input_Json__c));
            objParser = CM_ReltioHCORelationshipService.upsertHCOHCOService(event.Input_Json__c, PROCESS);
            eventDetail = new CM_ReltioHandlerService.EVENTDETAILS();
            eventDetail.replayID = event.ReplayId;
            eventDetail.eventUUId =event.eventUUId;
            mdmId2Event.put(objParser.masterRecordId,eventDetail);
            mdmId2parent.putall(objParser.mdmId2parent);
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(objParser.resultMap, upsertNewMap);
        }
        final CM_ReltioHandlerService.OBJECTPARSER oldObjParser =CM_ReltioHCORelationshipService.getOldHCOHCOMap(upsertNewMap);
        upsertOldMap =  oldObjParser.resultMap;
        mdmId2parent.putall(oldObjParser.mdmId2parent);

        toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
        upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);
        
        dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS.get(CM_ReltioConstants.RELTIOHCOPHCO).dmlMaps);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects)); 
        
        CM_LoggerUtil.publishLogs(CM_ReltioConstants.RELTIOHCOPHCO,mdmId2Event); 
        CM_LoggerUtil.dmlLogger(CM_ReltioConstants.RELTIOHCOPHCO, mdmId2Event,dmlWrapMap,mdmId2parent); 

        UCB_LoggerService.publishLogs();  
    }
}