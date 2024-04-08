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
    /* type of Asset event */
    final static string ACCOUNTSTRING = 'Account';
    /* type of Asset event */
    final static string ACCOUNTREL = 'Account__r';
     /* Set of MDM ID*/
    private static Map<String, set<String>> mdmIdSet;
    /* type of contact with Account */
    private static Map<String,String> conwithAccount;
    static {
        mdmIdSet = new Map<String, set<String>>();
        conwithAccount = new Map<String,String>();
    }
    /**
     * Variable name method names 
     * @description : After insert trigger handlers
     */
    public  static Map<String, set<String>>  compareOldNewRecords(Map <String, Map < String, Sobject >> upsertNewMap,Map <String, Map < String, Sobject >> upsertOldMap,String process) {
        parentMDMMap(upsertNewMap,process);
        getMDMIdsMap(upsertNewMap);
        getMDMIdsMap(upsertOldMap);
        return mdmIdSet;
    }
    public  static Map <String, Map < String, Sobject >>  toBeUpsertedRecords(Map <String, Map < String, Sobject >> upsertNewMap,Map <String, Map < String, Sobject >> upsertOldMap) {
        for (String obj : upsertNewMap.keySet()) {
            for(String mdmId: upsertNewMap.get(obj).keySet()) {               
                if(upsertOldMap.containsKey(obj)  
                && upsertOldMap.get(obj).containsKey(mdmId) && upsertOldMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c')!=null &&  
                Datetime.valueOf(upsertOldMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c'))>=Datetime.valueOf(upsertNewMap.get(obj).get(mdmId).get('TimeStamp_Decimal__c'))) { 
                    //UCB_LoggerService.logger(new UCB_Log(CM_ReltioConstants.RELTIOHCO, mdmIdMap.get(mdmId), 'Entry removed due to TimeStamp issue.'+JSON.serialize(upsertOldMap.get(obj).get(mdmId))),false);
                    upsertNewMap.get(obj).remove(mdmId);
                }                
            }            
        }
        return upsertNewMap;
    }
    public  static List<Sobject>  toBeDeletedRecords(Map <String, Map < String, Sobject >> upsertNewMap,Map <String, Map < String, Sobject >> upsertOldMap) {
        final List<Sobject> toBeDelSobjects = new List<Sobject>();
        for (String obj : upsertOldMap.keySet()) {
            for(String mdmId: upsertOldMap.get(obj).keySet()) {
                if(!upsertNewMap.containsKey(obj) || (upsertNewMap.containsKey(obj) && !upsertOldMap.get(obj).containsKey(mdmId))) { 
                    toBeDelSobjects.add(upsertOldMap.get(obj).get(mdmId));
                }                
            }            
        }
        return toBeDelSobjects;
    }
    private  static void  parentMDMMap(Map <String, Map < String, Sobject >> upsertMap,String process) {        
        if(process=='ReltioHCOHCOService') {
            Map<String,Object> objFields;
            Sobject relatedObject;
            for(String mdmId: upsertMap.get('Account_Relationship__c').keySet()) {
                mdmIdSet.put(mdmId,new set<String>());  
                mdmIdSet.get(mdmId).add(mdmId);
                objFields = upsertMap.get('Account_Relationship__c').get(mdmId).getPopulatedFieldsAsMap();
                relatedObject= (Sobject)objFields.get('From_Account__r');                    
                mdmIdSet.get(mdmId).add((String)relatedObject.get('MDM_Id__c')); 
                relatedObject= (Sobject)objFields.get('To_Account__r');                    
                mdmIdSet.get(mdmId).add((String)relatedObject.get('MDM_Id__c'));                          
            }            
        } else if(process=='ReltioHCPHCOService') {
            Map<String,Object> objFields;
            Sobject relatedObject;
            for(String mdmId: upsertMap.get('AccountContactRelation').keySet()) {
                mdmIdSet.put(mdmId,new set<String>());  
                mdmIdSet.get(mdmId).add(mdmId);
                objFields = upsertMap.get('AccountContactRelation').get(mdmId).getPopulatedFieldsAsMap();
                relatedObject= (Sobject)objFields.get('Account');                    
                mdmIdSet.get(mdmId).add((String)relatedObject.get('MDM_Id__c')); 
                relatedObject= (Sobject)objFields.get('Contact');                    
                mdmIdSet.get(mdmId).add((String)relatedObject.get('MDM_Id__c'));                          
            }
        }else if(process=='ReltioHCOService') {
            for(String mdmId: upsertMap.get('Account').keySet()) {
                mdmIdSet.get(mdmId).add(mdmId);
            } 
        } else {
            for(String mdmId: upsertMap.get('Contact').keySet()) {
                mdmIdSet.get(mdmId).add(mdmId);      
            }            
        } 
    }
    private  static void  getMDMIdsMap(Map <String, Map < String, Sobject >> upsertMap) {
        Sobject relatedObject;
        Map<String,Object> objFields;
        String key;
        final Map <String, Set<String>> mdmIdMaps = new Map <String, Set<String>>();
        for (String obj : upsertMap.keySet()) {
            for(String mdmId: upsertMap.get(obj).keySet()) {
                if(!(obj=='AccountContactRelation' || obj=='Account_Relationship__c' || obj=='Account' || obj=='Contact')) {
                    objFields = upsertMap.get(obj).get(mdmId).getPopulatedFieldsAsMap();
                    key = objFields.containskey('Account')?'Account':objFields.containskey('Contact')?'Contact':objFields.containskey(ACCOUNTREL)?ACCOUNTREL:'Contact__r';
                    relatedObject= (Sobject)objFields.get(key);  
                    if(!mdmIdMaps.containsKey((String)relatedObject.get('MDM_Id__c'))) {
                        mdmIdMaps.put((String)relatedObject.get('MDM_Id__c'),new Set<String>());
                    }
                    mdmIdMaps.get((String)relatedObject.get('MDM_Id__c')).add(mdmId);
                } 
            }      
        }  
        for(String mdmId :mdmIdSet.keyset()) {
            for(String childMDMId : mdmIdSet.get(mdmId)) {
                if(mdmIdMaps.containskey(childMDMId)) {
                    mdmIdSet.get(mdmId).addall(mdmIdMaps.get(childMDMId));
                }
            }
        }
    }  
    private CM_CompareOldNewRecords() {}
}