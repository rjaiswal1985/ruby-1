/***********************************************************************************************************************
 * Name: CM_DMLSaveResult
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class to handle DMLs on sobjects
 * TestClass : CM_DMLSaveResult
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Service class to handle DML operations
 ***********************************************************************************************************************/
public with sharing class CM_DMLSaveResult {
    /**
     * @description : Method to upsert records with external Id based on the service
     */
    public static Map<String,DMLWrapper> upsertRecords(Map < String, Map < String, Sobject >> upsertMap, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata, String process) {
        final Map < Integer, DML_Orchestrator__mdt > dmlMap = process2Metadata.get(process).dmlMaps;
        final Map<String,DMLWrapper> dmlWrapMap = new Map<String,DMLWrapper>();
        for (Integer dmlCount = 1; dmlCount <= dmlMap.size(); dmlCount++) {
            dmlWrapMap.putall(upsertRecords(upsertMap, dmlMap.get(dmlCount)));
        }   
        return dmlWrapMap;    
    }
    /**
     * @description : Method to sequentially order the DMLs based on the order defined in custom metadata
     */
    public static Map<String,DMLWrapper> deleteRecords(List<Sobject> toBeDelSobjects) {       
        final Map<String,DMLWrapper> dmlWrapMap = new Map<String,DMLWrapper>();
        if (toBeDelSobjects != null && !toBeDelSobjects.isEmpty()) {
            final List <Database.DeleteResult> deleteResults = UCB_DMLUtility.deleteRecords(toBeDelSobjects,false,System.AccessLevel.SYSTEM_MODE);
            dmlWrapMap.putall(createDeleteResult(deleteResults, toBeDelSobjects));
        }
        return dmlWrapMap;
    }
    /**
     * @description : Method to sequentially order the DMLs based on the order defined in custom metadata
     */
    private static Map<String,DMLWrapper> upsertRecords(Map < String, Map < String, Sobject >> upsertMap, DML_Orchestrator__mdt dmlOrchestrator) {
        List < Database.UpsertResult > upsertResultList;
        final Map<String,DMLWrapper> dmlWrapMap = new Map<String,DMLWrapper>();
        List < Sobject > records;
        final String objectName = dmlOrchestrator.Sobject__r.QualifiedApiName;
        if (upsertMap.containsKey(objectName) && upsertMap.get(objectName) != null && !upsertMap.get(objectName).isEmpty()) {
            final String externalIdField = dmlOrchestrator.External_Id__r.QualifiedApiName;
            final Schema.SObjectField externalId = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(externalIdField);
            records = upsertMap.get(objectName).values();
            upsertResultList = UCB_DMLUtility.upsertRecords(records, false, externalId,System.AccessLevel.SYSTEM_MODE);
            dmlWrapMap.putall(createDMLResult(upsertResultList, records));
        }
        return dmlWrapMap;
    }
    /**
     * @description : Method to log the results of DML in UCB Logger Service
     */
    private static Map<String,DMLWrapper> createDMLResult(List < Database.UpsertResult > upsertResultList, List < Sobject > records) {
        final List<DMLWrapper> dmlWraps= new List<DMLWrapper>();
        final Map<String,DMLWrapper> dmlWrapMap = new Map<String,DMLWrapper>();
        DMLWrapper dmlWrap;       
        for (Integer recordCount = 0; recordCount < records.size(); recordCount++) {
            dmlWrap = new DMLWrapper();
            dmlWrap.record = records[recordCount];
            dmlWrap.upsertResult= upsertResultList[recordCount];
            dmlWrap.isDMLSucess = upsertResultList[recordCount].isSuccess();
            dmlWraps.add(dmlWrap);
            dmlWrapMap.put((String)dmlWrap.record.get('MDM_Id__c'),dmlWrap);
        }
        return dmlWrapMap;
    }
    private static Map<String,DMLWrapper> createDeleteResult(List < Database.DeleteResult > deleteResults, List <Sobject> toBeDelSobjects) {
        final List<DMLWrapper> dmlWraps= new List<DMLWrapper>();
        final Map<String,DMLWrapper> dmlWrapMap = new Map<String,DMLWrapper>();
        DMLWrapper dmlWrap;       
        for (Integer recordCount = 0; recordCount < toBeDelSobjects.size(); recordCount++) {
            dmlWrap = new DMLWrapper();
            dmlWrap.record = toBeDelSobjects[recordCount];
            dmlWrap.daeleteResult = deleteResults[recordCount];
            dmlWrap.isDMLSucess = deleteResults[recordCount].isSuccess();
            dmlWraps.add(dmlWrap);
            dmlWrapMap.put((String)dmlWrap.record.get('MDM_Id__c'),dmlWrap);
        }
        return dmlWrapMap;
    }
    /*Wrapper Class to handle the DML results */
    public class DMLWrapper {
        /* List of input records */
        public SObject record;
        /* List of Saveresult */
        public Database.UpsertResult upsertResult;
         /* List of Saveresult */
        public Database.DeleteResult daeleteResult;
        /* DML result */
        public Boolean isDMLSucess;
    }
    private CM_DMLSaveResult() {}
}