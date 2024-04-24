/***********************************************************************************************************************
 * Name: CM_EnterprisePayloadTriggerHelper
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Helper for CM_EnterprisePayloadTriggerHandler
 * TestClass : CM_EnterprisePayloadTriggerHelper
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   08/01/2024             Helper for CRM Enterprise events
 ***********************************************************************************************************************/
public with sharing class CM_EnterprisePayloadTriggerHelper {
    /**********Metadat Records.************ */
    final Static Map <String, CM_ReltioHandlerService.SobjectData > ACCOUNTRELATION = CM_ReltioHandlerService.metadataRecords(CM_ReltioConstants.ACCRELALIONSERV);
    
    /**      
     * @description : Method to handle enterprise payload event data
     */
    public static void reltioPayloadTriggerService(List < Customer_Master_Enterprise_Payload__e > masterRecord) {       
        final List<Account_Relationship__c> accountRelations = new List<Account_Relationship__c>();
        final List<AccountContactRelation> accConRelations = new List<AccountContactRelation>();
        for (Customer_Master_Enterprise_Payload__e event: masterRecord) {
            if (event.Process__c == CM_ReltioConstants.ACCRELALIONSERV) {
                accountRelations.add((Account_Relationship__c) System.JSON.deserialize(event.Input_Json__c, Account_Relationship__c.class)); 
            }
            if (event.Process__c == CM_ReltioConstants.ACCCONRELALIONS) {
                accConRelations.add((AccountContactRelation) System.JSON.deserialize(event.Input_Json__c, AccountContactRelation.class));
            }
        }        
        if(accountRelations!=null && !accountRelations.isEmpty()) {
            accountRelations(accountRelations);
        }        
        if(accConRelations!=null && !accConRelations.isEmpty()) {
            accountContactRelations(accConRelations);
        }
        UCB_LoggerService.publishLogs(); 
    }
    /**      
     * @description : Method to handle Account-Account relation data
     */
    private static void accountRelations(List<Account_Relationship__c> accountRelations) {
        final Map < String, Map < String, Sobject >> upsertMap = new Map < String, Map < String, Sobject >> ();
        Map < String, Account > accountMap = new Map < String, Account >();
        for(Account_Relationship__c relationship : accountRelations ) {
            accountMap = upsertAccountRelation(relationship,accountMap);
        }
        upsertMap.put('Account',accountMap);
        CM_DMLSaveResult.upsertRecords(upsertMap, ACCOUNTRELATION.get(CM_ReltioConstants.ACCRELALIONSERV).dmlMaps);
    }
    private static Map < String, Account > upsertAccountRelation(Account_Relationship__c relationship,Map < String, Account > accountMap) {
        final Account account = new Account();
        account.Id = relationship.To_Account__c;
        account.ParentId = relationship.From_Account__c;
        accountMap.put(account.Id, account);
        return accountMap;
    }
    private static void accountContactRelations(List<AccountContactRelation> accConRelations) {
        final Set<Id> conIdSet = new Set<Id>();        
        for(AccountContactRelation relation : accConRelations) {
            conIdSet.add(relation.contactId);            
        }
        CM_AssociateActiveAccountonContact.updateContwithActiveAccnt(conIdSet);
    }
    private CM_EnterprisePayloadTriggerHelper() {}
}