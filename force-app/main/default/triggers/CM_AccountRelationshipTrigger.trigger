/***********************************************************************************************************************
* Name: CM_AccountRelationshipTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM HCO_HCO Relation platform event 
* TestClass : CM_AccountRelationshipTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                  07/10/2023          Inbound trigger handler
***********************************************************************************************************************/
trigger CM_AccountRelationshipTrigger on Account_Relationship__c (after insert,after Update) {
    UCB_MessageTriggerFactory.createHandler(Account_Relationship__c.SObjectType); 
}