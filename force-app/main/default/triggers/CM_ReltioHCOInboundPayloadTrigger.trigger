/***********************************************************************************************************************
* Name: CM_ReltioHCOInboundPayloadTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service to upsert HCO
* TestClass : CM_ReltioHCOInboundPayloadTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  11/12/2023          HCO Inbound trigger handler
***********************************************************************************************************************/
trigger CM_ReltioHCOInboundPayloadTrigger on Reltio_CM_HCO_Inbound_Payload__e (after insert) { 
    UCB_MessageTriggerFactory.createHandler(Reltio_CM_HCO_Inbound_Payload__e.SObjectType);
}