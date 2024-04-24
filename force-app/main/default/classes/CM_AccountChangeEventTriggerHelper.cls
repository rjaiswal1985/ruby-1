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
    /**
* @description : From the list of AccountChangeEvents this method gets the account Ids 
* and invokes corresponding service(account inactive)
* @parameters : list of AccountChangeEvents
*/  
    public static void processAccountUpdates(List<AccountChangeEvent> chgEvntLst) {        
        List<Id> acctIDs;             
        final Map < String, List<Id> > accntMap = new Map < String, List<Id> > ();                
        for(AccountChangeEvent ace : chgEvntLst) { 
            Eventbus.ChangeEventHeader header = ace.ChangeEventHeader;
            if(header.changetype == 'UPDATE' && ace.Status__c == INACTIVE_STATUS
              && header.changedFields.contains('Status__c')) {                
                acctIDs = new List<Id>();
                acctIDs.addAll(ace.ChangeEventHeader.getRecordIds());
                if(accntMap.containsKey('Account_Inactive')) {
                    accntMap.get('Account_Inactive').addAll(acctIDs);                      
                } else {
                    accntMap.put('Account_Inactive',acctIDs);
                }                                               
            }
        }

        system.debug('accntMap==>>'+accntMap);        
        if(accntMap!= null && !accntMap.isEmpty() && accntMap.containsKey('Account_Inactive')) {
            CM_AccountInactiveService.accountInactivationProcess(accntMap.get('Account_Inactive'));            
        }                                        
    }
    /**
* @description : constructor  
*/
    private CM_AccountChangeEventTriggerHelper() {}
}