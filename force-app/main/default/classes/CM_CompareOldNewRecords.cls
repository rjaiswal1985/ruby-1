/***********************************************************************************************************************
 * Name: CM_CompareOldNewRecords
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio  MDM HCO platform event
 * TestClass : CM_CompareOldNewRecords
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                  11/12/2023           Class invokedto compare old and new records.
 ***********************************************************************************************************************/
public with sharing class CM_CompareOldNewRecords {
    /**
    * @description : returns the Map of new record to be upserted 
    */
    public  static Map <String, Map < String, Sobject >>  toBeUpsertedRecords(Map <String, Map < String, Sobject >> upsertNewMap,Map <String, Map < String, Sobject >> upsertOldMap) {
        for (String obj : upsertNewMap.keySet()) {
            for(String mdmId: upsertNewMap.get(obj).keySet()) {               
                if(upsertOldMap.containsKey(obj)  
                && upsertOldMap.get(obj).containsKey(mdmId) && upsertOldMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c')!=null &&  
                Datetime.valueOf(upsertOldMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c'))>=Datetime.valueOf(upsertNewMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c'))) { 
                    ////UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCO, mdmIdMap.get(mdmId), 'Entry removed due to TimeStamp issue.'+JSON.serialize(upsertOldMap.get(obj).get(mdmId))),false);
                    upsertNewMap.get(obj).remove(mdmId);
                }                
            }            
        }
        return upsertNewMap;
    }
    /**
    * @description : returns the List of new record need to be deleted.
    */
    public  static List<Sobject>  toBeDeletedRecords(Map <String, Map < String, Sobject >> upsertNewMap,Map <String, Map < String, Sobject >> upsertOldMap) {
        final List<Sobject> toBeDelSobjects = new List<Sobject>();
        for (String obj : upsertOldMap.keySet()) {
            for(String mdmId: upsertOldMap.get(obj).keySet()) {
                if(!upsertNewMap.containsKey(obj) || (upsertNewMap.containsKey(obj) && !upsertNewMap.get(obj).containsKey(mdmId))) { 
                    toBeDelSobjects.add(upsertOldMap.get(obj).get(mdmId));
                }                
            }            
        }
        return toBeDelSobjects;
    }
    private CM_CompareOldNewRecords() {}
}