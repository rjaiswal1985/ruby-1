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
        final Map < String, Sobject > contactmap = new Map < String, Sobject > ();
        for(Account acc : accLst) {
            if(acc.Status__c == 'Inactive'){
            	accIds.add(acc.Id);    
            }
            
        }
        String lastRelAccount;
        String lastRelOwnerAccount;
        for(Contact con : [Select Id,
                           (Select accountId,Relationship_Type__c from AccountContactRelations order by startdate asc)
                           from Contact where AccountId = :accIds  WITH SECURITY_ENFORCED ]) {
            system.debug('con==>>'+con);                   
			lastRelAccount=null;
            lastRelOwnerAccount= null;
          	Contact cont = new Contact();
            cont.Id = con.Id;
            cont.accountId = null;
            for(AccountContactRelation relation : con.AccountContactRelations){
            	if(String.isempty(lastRelAccount)){
                	lastRelAccount=relation.accountId;    
                }
                if(relation.Relationship_Type__c=='Owner' && String.isEmpty(lastRelOwnerAccount)) { 
                	lastRelOwnerAccount=relation.accountId;  
                }
            }
            cont.accountId = String.isempty(lastRelAccount)?lastRelAccount:lastRelAccount;
            //contactmap.put(con.Id,cont);
            contUpdateLst.add(cont);
            system.debug('contUpdateLst==>>'+contUpdateLst);
     	}
        /* system.debug('@contactmap@'+contactmap);
		system.debug('@accConRelation@'+accConRelation);
		upsertMap.put('Contact',contactmap);
		CM_DMLSaveResult.upsertRecords(upsertMap, false); */
        UCB_DMLUtility.updateRecords(contUpdateLst,false);  
    }
    private CM_AccountUpdateCaptureTriggerHelper() {}
}