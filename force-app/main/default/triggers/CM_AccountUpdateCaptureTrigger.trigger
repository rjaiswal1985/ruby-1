/***********************************************************************************************************************
* Name: CM_AccountUpdateCaptureTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger fired on Account Data Change 
* TestClass : CM_AccountUpdateCaptureTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  02/04/2024          Account data change event
***********************************************************************************************************************/
trigger CM_AccountUpdateCaptureTrigger on AccountChangeEvent (after insert) {
    UCB_MessageTriggerFactory.createHandler(AccountChangeEvent.SObjectType); 
}