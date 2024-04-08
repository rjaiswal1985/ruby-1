/***********************************************************************************************************************
* Name: CM_EnterprisePayloadTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM HCO_HCO Relation platform event 
* TestClass : CM_EnterprisePayloadTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                  07/10/2023          Inbound trigger handler
***********************************************************************************************************************/
trigger CM_EnterprisePayloadTrigger on Customer_Master_Enterprise_Payload__e (after insert) {
    UCB_MessageTriggerFactory.createHandler(Customer_Master_Enterprise_Payload__e.SObjectType); 
}