/***********************************************************************************************************************
* Name: CRM_AssetTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger on Asset object
* TestClass : CRM_AssetTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/03/2024          Trigger on Asset
***********************************************************************************************************************/
trigger CRM_AssetTrigger on Asset (after insert, after update) {    
    UCB_MessageTriggerFactory.createHandler(Asset.SObjectType); 
}