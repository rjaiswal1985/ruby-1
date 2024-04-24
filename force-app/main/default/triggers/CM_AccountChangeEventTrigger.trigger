/***********************************************************************************************************************
* Name: CM_AccountChangeEventTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger fired on Account Data Change 
* TestClass : CM_AccountChangeEventTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  02/04/2024          Trigger fired on Account Data Change
***********************************************************************************************************************/
trigger CM_AccountChangeEventTrigger on AccountChangeEvent (after insert) {
    UCB_MessageTriggerFactory.createHandler(AccountChangeEvent.SObjectType); 
}