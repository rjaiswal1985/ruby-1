/***********************************************************************************************************************************
* Name: CM_AccountOwnerBatchUpdate
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Batch class to update account owner with territory primary owner
* TestClass : CM_AccountOwnerBatchUpdate
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   06/02/2024           Batch class to update account owner with territory primary owner
************************************************************************************************************************************/
public class CM_AccountOwnerBatchUpdate implements Database.Batchable<sObject> {
    /* query records */
    String query = null;  
    /* LOB custom Setting */
    final Map<String,Customer_Master_Configurations__c> lobSettingMap = Customer_Master_Configurations__c.getAll();
    /**
* @description : returns query results - accounts with objectTerritory2Associations
*/
    public Database.Querylocator start(Database.BatchableContext batchContxt) {   
        query=CM_AccountOwnerBatchHelper.prepareQuery();
        return Database.getQuerylocator(query);
    }
    /**
* @description : updates the account owner with territory primary owner
*/
    public void execute(Database.BatchableContext batchContxt, list<Account> scope) {
        final List<UCB_CustomExceptionWrapper> excpLst;
        final UCB_CustomExceptionWrapper custExcp;
        try {
            final List<Sobject> accUpdateLst=CM_AccountOwnerBatchHelper.getAccountOwner(scope,lobSettingMap);
            List <Database.SaveResult> updateResult;
            if (accUpdateLst != null && !accUpdateLst.isEmpty()) {                
                updateResult = UCB_DMLUtility.updateRecords(accUpdateLst,false);
                //UCB_LoggerService.logger(new UCB_Log('Account Owner Update Batch', 'DML Upsert Result', JSON.Serialize(updateResult)),false);
                //UCB_LoggerService.publishLogs();
            }    
        } Catch(Exception excp) {
            custExcp = new UCB_CustomExceptionWrapper();
            excpLst = new List<UCB_CustomExceptionWrapper>();
            custExcp.module = 'Account Owner Update Batch';
            custExcp.exceptn =  excp;                       
            excpLst.add(custExcp);            
            UCB_ExceptionService.logException(excpLst);              
        }
        
    }
    /**
* @description : send emails
*/
    public void finish(Database.BatchableContext batchContxt) {
        
    }
    
}