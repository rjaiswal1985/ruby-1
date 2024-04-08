/***********************************************************************************************************************
* Name: CRM_OrderTrigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger on Order object
* TestClass : CRM_orderTrigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/02/2024          Trigger on order
***********************************************************************************************************************/
trigger CRM_OrderTrigger on Order (after insert,after update) {    
    UCB_MessageTriggerFactory.createHandler(Order.SObjectType); 
}