/***********************************************************************************************************************
* Name: CM_AccountContactRelationsTriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper class for CM_AccountContactRelationsTriggerHandler
* TestClass : CM_AccountContactRelationsTriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  08/01/2024          Trigger helper on the Account Contact Relationship
***********************************************************************************************************************/
public with sharing class CM_AccountContactRelationsTriggerHelper {
     
    /**    
    * @description : before event method of Account Contact relationship
    */
    public static void beforeEvent(List<AccountContactRelation> relationshipList) {  
        final Set<Id> accountIds = new Set<Id>();
        final Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation relation : relationshipList ) {
            if(relation.AccountContact_Id__c==null) {
                accountIds.add(relation.AccountId);  
                contactIds.add(relation.ContactId);    
            }    
        }
        if(accountIds!=null && !accountIds.isEmpty() && contactIds!=null && !contactIds.isEmpty()) {
            final Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,MDM_Id__c from Account where Id = : accountIds WITH SECURITY_ENFORCED ]);
            final Map<Id,Contact> contactMap =  new Map<Id,Contact>([Select Id,MDM_Id__c from Contact where Id = : contactIds WITH SECURITY_ENFORCED ]);
            for(AccountContactRelation relation : relationshipList ) {
                if(relation.AccountContact_Id__c==null && accountMap!=null && contactMap!=null) {
                    relation.AccountContact_Id__c= accountMap.get(relation.AccountId).MDM_Id__c+ contactMap.get(relation.ContactId).MDM_Id__c;     
                }
            }
        }
    }   
    /**    
    * @description : before event method of Account Contact relationship
    */
    /*public static void afterUpdateEvent(List<AccountContactRelation> relationshipList,Map<Id,AccountContactRelation> oldRelationMap) {  
        final List < Customer_Master_Enterprise_Payload__e > payloadList = new List < Customer_Master_Enterprise_Payload__e > ();
        Customer_Master_Enterprise_Payload__e record;
        for (AccountContactRelation relationship: relationshipList) {
            if(relationship.Status__c != oldRelationMap.get(relationship.Id).Status__c && 
                relationship.Status__c=='Inactive' && relationship.IsDirect) {
                record = new Customer_Master_Enterprise_Payload__e();
                record.Input_Json__c = JSON.serialize(relationship);
                record.Process__c = CM_ReltioConstants.ACCCONRELALIONS;
                payloadList.add(record);
            }
        }
        if(payloadList!=null && !payloadList.isEmpty()) {
            eventbus.publish(payloadList);
        } 
    }*/
    private CM_AccountContactRelationsTriggerHelper() {} 
}