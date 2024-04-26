/***********************************************************************************************************************
* Name: CM_AccountChangeEventTriggerHelper
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
public with sharing class CM_AccountChangeEventTriggerHelper {
    /* Account status inactive */
    final static string INACTIVE_STATUS = 'Inactive'; 
    /* Process name helps to invoke corresponding service */
    final static string ACCOUNT_INACTIVE = 'Account_Inactive'; 
    /**
* @description : From the list of AccountChangeEvents this method gets the account Ids 
* and invokes corresponding service(account inactive)
* @parameters : list of AccountChangeEvents
*/  
    public static void processAccountUpdates(List<AccountChangeEvent> chgEvntLst) {        
        List<Id> acctIDs;             
        final Map < String, Set<Id> > accntMap = new Map < String, Set<Id> > (); 
        Eventbus.ChangeEventHeader header;
        for(AccountChangeEvent ace : chgEvntLst) { 
            //Eventbus.ChangeEventHeader header = ace.ChangeEventHeader;
            header = ace.ChangeEventHeader;
            system.debug('header==>>'+header);
            if(header.changetype == 'UPDATE' && ace.Status__c == INACTIVE_STATUS
              && header.changedFields.contains('Status__c')) {                
                acctIDs = new List<Id>();
                acctIDs.addAll(ace.ChangeEventHeader.getRecordIds());
                if(!accntMap.containsKey(ACCOUNT_INACTIVE)) {                	
                    accntMap.put(ACCOUNT_INACTIVE,new Set<Id>()); 
                }
                accntMap.get(ACCOUNT_INACTIVE).addAll(acctIDs);  
            }
        }

        system.debug('accntMap==>>'+accntMap);        
        if(accntMap!= null && !accntMap.isEmpty() && accntMap.containsKey(ACCOUNT_INACTIVE)) {
            CM_AccountInactiveService.accountInactivationProcess(accntMap.get(ACCOUNT_INACTIVE));            
        }                                        
    }
    /**
* @description : constructor  
*/
    private CM_AccountChangeEventTriggerHelper() {}
}