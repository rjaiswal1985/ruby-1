/***********************************************************************************************************************
 * Name: CM_AccountRelationshipTriggerHelper
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Helper class for CM_AccountRelationshipTriggerHandler
 * TestClass : CM_AccountRelationshipTriggerHelper
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                  08/01/2024          Trigger helper publishes event for Account-Account Relationship
 ***********************************************************************************************************************/
public with sharing class CM_AccountRelationshipTriggerHelper {
    /**     
     * @description : publish the PE for the Account relationship record
     */
    public static void publishEvent(List < Account_Relationship__c > relationshipList) {
        final List < Customer_Master_Enterprise_Payload__e > payloadList = new List < Customer_Master_Enterprise_Payload__e > ();
        Customer_Master_Enterprise_Payload__e record;
        for (Account_Relationship__c relationship: relationshipList) {
            if(relationship.Relationship_Type__c == CM_ReltioConstants.ISAFFILIATED && 
                relationship.From_Account__c!=relationship.To_Account__c) {
                record = new Customer_Master_Enterprise_Payload__e();
                record.Input_Json__c = json.serialize(relationship);
                record.Process__c = CM_ReltioConstants.ACCRELALIONSERV;
                payloadList.add(record);
            }
        }
        if(payloadList!=null && !payloadList.isEmpty()) {
            eventbus.publish(payloadList);
        }        
    }
    private CM_AccountRelationshipTriggerHelper() {} 
}