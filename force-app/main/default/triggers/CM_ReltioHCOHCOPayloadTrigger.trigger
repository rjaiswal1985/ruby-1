/***********************************************************************************************************************
* Name: CM_ReltioHCOHCOPayloadTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM HCO_HCO Relation platform event 
* TestClass : CM_ReltioHCOHCOPayloadTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                  07/10/2023          Inbound trigger handler
***********************************************************************************************************************/
trigger CM_ReltioHCOHCOPayloadTrigger on Reltio_CM_HCO_HCO_Inbound_Payload__e (after insert) { 
   UCB_MessageTriggerFactory.createHandler(Reltio_CM_HCO_HCO_Inbound_Payload__e.SObjectType);
}