/***********************************************************************************************************************
 * Name: CM_ReltioHCOHCPPayloadTriggerHandler
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio MDM platform event
 * TestClass : CM_ReltioHCOHCPPayloadTriggerHandler
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          GSF-1139 - Class invoked from the Subscriber of the Reltio MDM platform event
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCOHCPPayloadTriggerHandler extends UCB_TriggerVirtual {
    /**********Metadat Records.************ */
    final Static Map <String, CM_ReltioHandlerService.SobjectData > PROCESS = CM_ReltioHandlerService.metadataRecords(CM_ReltioConstants.RELTIOHCPHCO);
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public override void afterTrigger(UCB_Trigger.TriggerContext trgCtx) {
        try {
            reltioPayloadTriggerService(trgCtx.newList);
        } catch (Exception excp) {
            CM_LoggerInitializationUtil.replayService(excp, 'CM_ReltioHCOHCPPayloadTriggerHandler');
        }
    }
    /**
     * @description : This method processes platform event by process name
     * @parameters : platform event, process name
     */
    public static void reltioPayloadTriggerService(List < Reltio_CM_HCO_HCP_Inbound_Payload__e > masterRecord) {
        Map < String, Map < String, Sobject >> upsertNewMap = new Map < String, Map < String, Sobject >> ();
        Map <String, Map < String, Sobject >> upsertOldMap=new Map <String, Map < String, Sobject >>();
        final Map < String, String > contact2Account = new Map < String, String > ();
        Map<String,String> conwithAccount = new Map<String,String>();
        Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = new Map <String,CM_DMLSaveResult.DMLWrapper>();
        Map<String,Sobject> upsertContactMap = new Map<String,Sobject>();

        List<Contact> contactNewList= new List<Contact>();
        CM_ReltioHandlerService.EVENTDETAILS eventDetail;
        final Map<String,String> mdmId2parent = new Map<String,String>(); 
        final Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event = new Map<String,CM_ReltioHandlerService.EVENTDETAILS>() ;

        List<Sobject> toBeDelSobjects = new List<Sobject>();
        CM_ReltioHandlerService.OBJECTPARSER objParser;

        for (Reltio_CM_HCO_HCP_Inbound_Payload__e event: masterRecord) {
            objParser = CM_ReltioHCOHCPService.upsertHCOHCPService(event.Input_Json__c, PROCESS);
            eventDetail = new CM_ReltioHandlerService.EVENTDETAILS();
            eventDetail.replayID = event.ReplayId;
            eventDetail.eventUUId =event.eventUUId;
            mdmId2Event.put(objParser.masterRecordId,eventDetail);
            mdmId2parent.putall(objParser.mdmId2parent);
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(objParser.resultMap, upsertNewMap);  
            contact2Account.putall(objParser.contact2Account);
        }   

        final CM_ReltioHandlerService.OBJECTPARSER oldObjParser = CM_ReltioHCOHCPService.getOldHCOHCPMap(upsertNewMap);
        upsertOldMap = oldObjParser.resultMap;
        mdmId2parent.putall(oldObjParser.mdmId2parent);

        contactNewList = upsertNewMap.get('Contact').values();  
        conwithAccount = CM_ReltioHCOHCPService.conwithAccount(upsertOldMap.get('Contact').values());

        toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
        upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);        
        
        upsertContactMap =CM_ReltioHCOHCPService.upsertContacttMap(contactNewList,conwithAccount,contact2Account);
        upsertNewMap.get('Contact').putall(upsertContactMap);

        CM_LoggerUtil.publishLogs(CM_ReltioConstants.RELTIOHCPHCO,mdmId2Event); 
        dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS.get(CM_ReltioConstants.RELTIOHCPHCO).dmlMaps);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects)); 
        CM_LoggerUtil.dmlLogger(CM_ReltioConstants.RELTIOHCPHCO, mdmId2Event,dmlWrapMap,mdmId2parent); 

        UCB_LoggerService.publishLogs();  
    }
}