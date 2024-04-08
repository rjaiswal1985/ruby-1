/***********************************************************************************************************************
* Name: CM_ReltioHCPInboundPayloadTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service to upsert HCP
* TestClass : CM_ReltioHCPInboundPayloadTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  11/12/2023          HCP Inbound trigger handler
***********************************************************************************************************************/
trigger CM_ReltioHCPInboundPayloadTrigger on Reltio_CM_HCP_Inbound_Payload__e (after insert) { 
    UCB_MessageTriggerFactory.createHandler(Reltio_CM_HCP_Inbound_Payload__e.SObjectType);
}