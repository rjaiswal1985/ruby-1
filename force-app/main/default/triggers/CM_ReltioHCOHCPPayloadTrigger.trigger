/***********************************************************************************************************************
* Name: CM_ReltioHCOHCPPayloadTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio MDM HCO_HCP platform event
* TestClass : CM_ReltioHCOHCPPayloadTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  12/12/2023          Inbound trigger handler
***********************************************************************************************************************/
trigger CM_ReltioHCOHCPPayloadTrigger on Reltio_CM_HCO_HCP_Inbound_Payload__e  (after insert) { 
   UCB_MessageTriggerFactory.createHandler(Reltio_CM_HCO_HCP_Inbound_Payload__e.SObjectType); 
}