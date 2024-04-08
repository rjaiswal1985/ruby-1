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
        final Map < String, String > contact2Account = new Map < String, String > ();
        CM_ReltioHCOHCPService.AccountRelation accRelation;
        for (Reltio_CM_HCO_HCP_Inbound_Payload__e event: masterRecord) {
            accRelation = CM_ReltioHCOHCPService.upsertHCOHCPService(event.Input_Json__c, PROCESS);
            upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(accRelation.upsertNewMap, upsertNewMap);
            contact2Account.putall(accRelation.contact2Account);
        } 
            
        final Map <String, Map < String, Sobject >> upsertOldMap =CM_ReltioHCOHCPService.getOldHCOHCPMap(upsertNewMap);
        upsertOldMap.putAll(CM_ReltioHCOHCPService.getOldContactMap(upsertNewMap));
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'upsertOldMap', JSON.serialize(upsertOldMap)),false);
        List<Contact> contactNewList = upsertNewMap.get('Contact').values();        
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'upsertOldMap', JSON.serialize(upsertOldMap)),false);
        final Map<String,String> conwithAccount = CM_ReltioHCOHCPService.conwithAccount(upsertOldMap.get('Contact').values());        
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'conwithAccount', JSON.serialize(conwithAccount)),false); 
        upsertNewMap= CM_CompareOldNewRecords.toBeUpsertedRecords(upsertNewMap,upsertOldMap);
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'upsertNewMap', JSON.serialize(upsertNewMap)),false); 
        List<Sobject> toBeDelSobjects = CM_CompareOldNewRecords.toBeDeletedRecords(upsertNewMap,upsertOldMap);
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'toBeDelSobjects', JSON.serialize(toBeDelSobjects)),false); 
        Map<String,Sobject> contactMap= CM_ReltioHCOHCPService.upsertContacttMap(contactNewList,conwithAccount,contact2Account);
        upsertNewMap.get('Contact').putall(contactMap);
        final Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap = CM_DMLSaveResult.upsertRecords(upsertNewMap, PROCESS, CM_ReltioConstants.RELTIOHCPHCO);
        dmlWrapMap.putAll(CM_DMLSaveResult.deleteRecords(toBeDelSobjects));
        UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCPHCO, 'dmlWrapMap', JSON.serialize(dmlWrapMap)),false);
        UCB_LoggerService.publishLogs();  
    }
}