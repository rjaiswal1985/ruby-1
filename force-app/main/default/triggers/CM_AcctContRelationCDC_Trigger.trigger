/***********************************************************************************************************************
* Name: CM_AcctContRelation_CDC_Trigger
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Trigger fired on Account Data Change 
* TestClass : CM_AcctContRelation_CDC_Trigger
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                  02/04/2024          Account data change event
***********************************************************************************************************************/
trigger CM_AcctContRelationCDC_Trigger on AccountContactRelationChangeEvent (after insert) {
   //UCB_MessageTriggerFactory.createHandler(AccountContactRelationChangeEvent.SObjectType); 
   system.debug('trigger.new==>>'+trigger.new);    
    CM_AcctContRelation_CDC_TriggerHelper.accountContactRelations(trigger.new);
}