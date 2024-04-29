/***********************************************************************************************************************
* Name: CRM_AssetChangeEventTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger fired on Asset Change Events 
* TestClass : CRM_AssetChangeEventTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                    DATE                DETAIL
* 1.0             Sruthi M                  24/04/2024          Trigger fired on Asset Change Events
***********************************************************************************************************************/
trigger CRM_AssetChangeEventTrigger on AssetChangeEvent (after insert) {
    UCB_MessageTriggerFactory.createHandler(AssetChangeEvent.SObjectType); 
}