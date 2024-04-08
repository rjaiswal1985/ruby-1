/***********************************************************************************************************************
* Name: CM_AccountContactRelationsTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM HCO_HCO Relation platform event 
* TestClass : CM_AccountContactRelationsTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                  07/10/2023          Inbound trigger handler
***********************************************************************************************************************/
trigger CM_AccountContactRelationsTrigger on AccountContactRelation (before insert,before update,after update) {
    UCB_MessageTriggerFactory.createHandler(AccountContactRelation.SObjectType); 
}