/***********************************************************************************************************************
* Name: CM_ScheduleAccountOwnerBatchUpdate
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Schedules account owner update batch job
* TestClass : CM_ScheduleAccountOwnerBatchUpdate
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        13/02/2024          scheduler to update account owner batch job
***********************************************************************************************************************/
public without sharing class CM_ScheduleAccountOwnerBatchUpdate implements Schedulable {
    /**
 	* @description : This Schedules BatchAccountOwnerUpdate.
 	*/
     public void execute(SchedulableContext schCon) { 
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;
        try {
        	database.executebatch(new CM_AccountOwnerBatchUpdate(),Integer.valueOf(Batch_Jobs_Execution__c.getInstance('Account Ownership Batch').Batch_size__c)); 
            UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log('Schedule Account Owner Update Batch', 'CM_ScheduleAccountOwnerBatchUpdate', 'Updated Account Owner')});
            UCB_LoggerService.publishLogs();   
        } Catch(Exception excp) {
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Scheduled Account Owner Update Batch';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);            
        }
    }
}