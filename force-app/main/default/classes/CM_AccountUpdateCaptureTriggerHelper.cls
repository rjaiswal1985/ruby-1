/***********************************************************************************************************************
* Name: CM_AccountUpdateCaptureTriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for Account data change events
* TestClass : CM_AccountUpdateCaptureTriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   02/04/2024             Helper for Account data change events
***********************************************************************************************************************/
public with sharing class CM_AccountUpdateCaptureTriggerHelper {
    /* Account status inactive */
    final static string INACTIVE_STATUS = 'Inactive';   
    /**
* @description : This method gets the account Ids from changeEvent invokes 
* corresponding account inactive service
* @parameters : list of AccountChangeEvents
*/  
    public static void accountContactRelations(List<AccountChangeEvent> chgEvntLst) {
        
        List<Id> inActiveAcctIDs;
        final List<Contact> contUpdateLst;        
        final Map < String, List<Id> > inactveAccMap = new Map < String, List<Id> > ();
        List<Database.UpsertResult> upsertResults;
        
        for(AccountChangeEvent ace : chgEvntLst) {                        
            if(ace.Status__c == INACTIVE_STATUS) {
                inActiveAcctIDs = new List<Id>();
                inActiveAcctIDs.addAll(ace.ChangeEventHeader.getRecordIds());
                if(!inactveAccMap.containsKey('Account Inactive')) {
                	inactveAccMap.put('Account Inactive',inActiveAcctIDs);    
                } else {
                    inactveAccMap.get('Account Inactive').addAll(inActiveAcctIDs);
                }                               
            }                        
        }
        /*if(!accIds.isEmpty() && accIds.size()!=null) {
            inactveAccMap.put('Account Inactive',accIds);    
        } */
		system.debug('inactveAccMap==>>'+inactveAccMap);        
        contUpdateLst = CM_AccountInactiveService.directRelAccountInactivated(inactveAccMap);                        
        upsertResults = UCB_DMLUtility.upsertRecords(contUpdateLst,false,System.AccessLevel.SYSTEM_MODE); 
        UCB_LoggerService.logger(new UCB_Log('Contact update with Active Account', 'DML Upsert Result', JSON.Serialize(upsertResults)),false);  
        UCB_LoggerService.publishLogs(); 
    }
    /**
* @description : constructor  
*/
    private CM_AccountUpdateCaptureTriggerHelper() {}
}