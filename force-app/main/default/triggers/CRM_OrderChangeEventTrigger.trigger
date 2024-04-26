/***********************************************************************************************************************
* Name: CRM_OrderChangeEventTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger fired on Order Change Events 
* TestClass : CRM_OrderChangeEventTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  24/04/2024          Trigger fired on Order Change Events
***********************************************************************************************************************/
trigger CRM_OrderChangeEventTrigger on OrderChangeEvent (after insert) {
    UCB_MessageTriggerFactory.createHandler(AccountChangeEvent.SObjectType); 
}