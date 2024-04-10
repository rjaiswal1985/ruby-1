/***********************************************************************************************************************
* Name: CM_AccountUpdateCaptureTriggerHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for CM_AccountDataCaptureTrigger
* TestClass : CM_AccountUpdateCaptureTriggerHelper
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   02/04/2024             Helper for CRM Enterprise events
***********************************************************************************************************************/
public with sharing class CM_AccountUpdateCaptureTriggerHelper {
    
    public static void accountContactRelations(List<Account> accLst) {
        
        //final Map < String, Map < String, Sobject >> upsertMap = new Map < String, Map < String, Sobject >> ();
        final List<Id> accIds = new List<Id>();
        final List<Contact> contUpdateLst;
        final Map < String, List<Id> > inactveAccMap = new Map < String, List<Id> > ();
        for(Account acc : accLst) {
            if(acc.Status__c == 'Inactive'){
            	accIds.add(acc.Id);    
            }            
        }
        if(!accIds.isEmpty() && accIds.size()!=null) {
        	inactveAccMap.put('Account Inactive',accIds);    
        }
        
        contUpdateLst = CM_AccountInactiveService.updteContwithActiveAccnt(inactveAccMap);
		UCB_DMLUtility.updateRecords(contUpdateLst,false);
    }
    private CM_AccountUpdateCaptureTriggerHelper() {}
}