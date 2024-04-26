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
        final Map<String,String> mdmId2parent = new Map<String,String>(); 
        final Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event = new Map<String,CM_ReltioHandlerService.EVENTDETAILS>() ;
        List<Sobject> toBeDelSobjects = new List<Sobject>();
        CM_ReltioHandlerService.OBJECTPARSER objParser;
        Boolean entiryUpdated = false;
        CM_ReltioHandlerService.EVENTDETAILS eventDetail;

        for (Reltio_CM_HCP_Inbound_Payload__e event: masterRecord) {
            objParser = CM_ReltioHCPService.upsertHCPServices(event.Input_Json__c, PROCESS);
            if(objParser.apiType==CM_ReltioConstants.ENTITYUPDATED && !entiryUpdated) {
                entiryUpdated=true;
            }
            eventDetail = new CM_ReltioHandlerService.EVENTDETAILS();
            eventDetail.replayID = event.ReplayId;
            eventDetail.eventUUId =event.eventUUId;
            mdmId2Event.put(objParser.masterRecordId,eventDetail);
            mdmId2parent.putall(objParser.mdmId2parent);
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(objParser.resultMap, upsertNewMap);
        }
        if(entiryUpdated) {
            upsertOldMap = new Map <String, Map < String, Sobject >>();
            final CM_ReltioHandlerService.OBJECTPARSER oldObjParser =CM_ReltioHCPService.getOldContactMap(upsertNewMap);
            upsertOldMap =oldObjParser.resultMap;
            mdmId2parent.putall(oldObjParser.mdmId2parent);
            toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
            upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);            
        }
        CM_LoggerUtil.publishLogs(CM_ReltioConstants.RELTIOHCP,mdmId2Event); 
        dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS.get(CM_ReltioConstants.RELTIOHCP).dmlMaps);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects)); 
        CM_LoggerUtil.dmlLogger(CM_ReltioConstants.RELTIOHCP, mdmId2Event,dmlWrapMap,mdmId2parent); 
         
        UCB_LoggerService.publishLogs(); 
    } 
}