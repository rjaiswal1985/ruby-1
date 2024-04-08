/***********************************************************************************************************************
 * Name: CM_ReltioHCORelationshipService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class handles Account-Account Relationship, service which is invoked from platform event trigger handler
 * TestClass : CM_ReltioHCORelationshipService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          Acount Account relationship service
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCORelationshipService {
    /* type of Asset event */
    final static string ACCOUNTSTRING = 'Account';
    /**     
     * @description : method to get Account-Account relationship data
     */
    public static Map < String, Map < String, Sobject >> upsertHCOHCOService(String inputJson, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata) {
        Map < String, Map < String, Sobject >> upsertMap = new Map < String, Map < String, Sobject >> ();
        Map < String, Map < String, Map < String, Object >>> key2value = CM_JSONParser.objectJsonParsers(inputJson, process2Metadata.get(CM_ReltioConstants.RELTIOHCOPHCO));

        final CM_AccountRelationshipService.AccountRelation accRelationship = CM_AccountRelationshipService.upsertAccountRelationship(key2value.get('Account_Relationship__c'));
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(accRelationship.resultMap, upsertMap);

        key2value = CM_JSONParser.attibuteParsers(accRelationship.startObjDetails, process2Metadata.get(CM_ReltioConstants.RELTIOHCO));
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(CM_ReltioHCOService.upsertHCOSelector(key2value), upsertMap);

        key2value = CM_JSONParser.attibuteParsers(accRelationship.endObjectDetails, process2Metadata.get(CM_ReltioConstants.RELTIOHCO));
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(CM_ReltioHCOService.upsertHCOSelector(key2value), upsertMap);

        return upsertMap;
    }
    public static Map<String, Map < String, Sobject >> getOldHCOHCOMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordIds = upsertNewMap.get(ACCOUNTSTRING).keyset();
        final Set<String> accRelIds = upsertNewMap.get('Account_Relationship__c').keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put(ACCOUNTSTRING,new Map <String, Sobject>());  
        upsertOldMap.put('Organization_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('Organization_E_Invoice__c',new Map <String, Sobject>());  
        upsertOldMap.put('Account_Relationship__c',new Map <String, Sobject>()); 
        for(Account acc : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_Communications__r),
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_E_Invoices__r),
                        (Select Id,MDM_Id__c,To_Account__r.MDM_Id__c,From_Account__r.MDM_Id__c,TimeStamp_Decimal__c from Account_Relationships__r where MDM_Id__c=:accRelIds),
                        (Select Id,MDM_Id__c,To_Account__r.MDM_Id__c,From_Account__r.MDM_Id__c,TimeStamp_Decimal__c from Account_Relationships1__r where MDM_Id__c=:accRelIds) 
                        from Account where MDM_Id__c = :recordIds with SECURITY_ENFORCED]) {
            upsertOldMap.get(ACCOUNTSTRING).put(acc.MDM_Id__c,acc);
            for(Organization_Communication__c communication: acc.Organization_Communications__r) {
                upsertOldMap.get('Organization_Communication__c').put(communication.MDM_Id__c,communication);  
            }
            for(Organization_E_Invoice__c invoice: acc.Organization_E_Invoices__r) {
                upsertOldMap.get('Organization_E_Invoice__c').put(invoice.MDM_Id__c,invoice); 
            }
            for(Account_Relationship__c relationship: acc.Account_Relationships__r) {
                upsertOldMap.get('Account_Relationship__c').put(relationship.MDM_Id__c,relationship); 
            }
            for(Account_Relationship__c relationship: acc.Account_Relationships1__r) {
                upsertOldMap.get('Account_Relationship__c').put(relationship.MDM_Id__c,relationship); 
            }
        }
        return upsertOldMap;
    }
    private CM_ReltioHCORelationshipService() {}
}