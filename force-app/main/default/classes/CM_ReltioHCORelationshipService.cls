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
    /* Account String */
    final static string ACCOUNTSTRING = 'Account';
    /* Account Relationship Strinsg */
    final static string ACCRELATION = 'Account_Relationship__c';
    /**     
     * @description : method to get Account-Account relationship datas
     */
    public static CM_ReltioHandlerService.OBJECTPARSER upsertHCOHCOService(String inputJson, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata) {
        final CM_ReltioHandlerService.OBJECTPARSER  objParser= new CM_ReltioHandlerService.OBJECTPARSER() ;
        CM_ReltioHandlerService.ATTRIBUTEPARSER attriParser = new CM_ReltioHandlerService.ATTRIBUTEPARSER();
        Map < String, Map < String, Sobject >> upsertMap = new Map < String, Map < String, Sobject >> ();
        Map < String, Map < String, Map < String, Object >>> key2value = new Map < String, Map < String, Map < String, Object >>>();
        
        final CM_ReltioHandlerService.JSPARSER parser = CM_JSONParser.objectJsonParser(inputJson, process2Metadata.get(CM_ReltioConstants.RELTIOHCOPHCO));
        key2value = parser.key2value;
        objParser.apiType=parser.apiType;
        objParser.mdmId2parent=parser.mdmId2parent;
        objParser.masterRecordId=parser.masterRecordId;

        final CM_AccountRelationshipService.AccountRelation accRelationship = CM_AccountRelationshipService.upsertAccountRelationship(key2value.get(ACCRELATION),parser.masterRecordId);
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(accRelationship.resultMap, upsertMap);
        
        attriParser = CM_JSONParser.attibuteParsers(accRelationship.startObjDetails, process2Metadata.get(CM_ReltioConstants.RELTIOHCO),parser.masterRecordId);
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(CM_ReltioHCOService.upsertHCOSelector(attriParser.key2value,parser.masterRecordId),upsertMap);
        objParser.mdmId2parent.putall(attriParser.mdmId2parent); 
        
        attriParser = CM_JSONParser.attibuteParsers(accRelationship.endObjectDetails, process2Metadata.get(CM_ReltioConstants.RELTIOHCO),parser.masterRecordId);
        upsertMap = CM_ReltioHandlerService.upsertSobjectMap(CM_ReltioHCOService.upsertHCOSelector(attriParser.key2value,parser.masterRecordId), upsertMap);
        objParser.mdmId2parent.putall(attriParser.mdmId2parent);
        
        objParser.resultMap=upsertMap;        
        return objParser;
    }
    /**     
     * @description : get old Map of the Account
     */
    public static Map<String, Map < String, Sobject >> getOldHCOHCOMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordIds = upsertNewMap.get(ACCOUNTSTRING).keyset();
        final Set<String> accRelIds = upsertNewMap.get(ACCRELATION).keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put(ACCOUNTSTRING,new Map <String, Sobject>());  
        upsertOldMap.put('Organization_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('Organization_E_Invoice__c',new Map <String, Sobject>());  
        upsertOldMap.put(ACCRELATION,new Map <String, Sobject>()); 
        for(Account acc : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_Communications__r),
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_E_Invoices__r),
                        (Select Id,MDM_Id__c,To_Account__r.MDM_Id__c,From_Account__r.MDM_Id__c,TimeStamp_Decimal__c from Account_Relationships__r where MDM_Id__c=:accRelIds)
                        from Account where MDM_Id__c = :recordIds with SECURITY_ENFORCED]) {
            upsertOldMap.get(ACCOUNTSTRING).put(acc.MDM_Id__c,acc);
            for(Organization_Communication__c communication: acc.Organization_Communications__r) {
                upsertOldMap.get('Organization_Communication__c').put(communication.MDM_Id__c,communication);  
            }
            for(Organization_E_Invoice__c invoice: acc.Organization_E_Invoices__r) {
                upsertOldMap.get('Organization_E_Invoice__c').put(invoice.MDM_Id__c,invoice); 
            }
            for(Account_Relationship__c relationship: acc.Account_Relationships__r) {
                upsertOldMap.get(ACCRELATION).put(relationship.MDM_Id__c,relationship); 
            }
        }
        return upsertOldMap;
    }
    private CM_ReltioHCORelationshipService() {}
}