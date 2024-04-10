/***********************************************************************************************************************
* Name: CM_AccountInactiveService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Helper for CM_AccountDataCaptureTrigger
* TestClass : CM_AccountUpdateCaptureService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   04/04/2024             Account Inactivation Service class
***********************************************************************************************************************/
public with sharing class CM_AccountInactiveService {
        
    public static List<Contact> updteContwithActiveAccnt(Map<String,List<Id>> accMap) {
        
        final List<Contact> contUpdateLst;
		final List<Id> accIds; 
        final List<Contact> conOwnerLst;
        final List<Contact> conNonOwnerLst;
        final List<Contact> conLst;
        final Set<Id> conOwnrSet;
        String lastRelAccount;
        String lastRelOwnerAccount;
        
        for(String str : accMap.keySet()) {
            if(str == 'Account Inactive') {
            	accIds = accMap.get(str);		    
            }            
        }
        
        conOwnerLst = [Select Id,
                           (Select accountId,Relationship_Type__c from AccountContactRelations where Relationship_Type__c='Owner' order by startdate asc LIMIT 1)
                           from Contact where AccountId IN :accIds  WITH SECURITY_ENFORCED ]; 
        for(Contact cont : conOwnerLst) {
            for(AccountContactRelation accConRel : cont.AccountContactRelations) {
                conOwnrSet.add(accConRel.AccountID);
            }    
        }            
       
        conNonOwnerLst = [Select Id,
                           (Select accountId,Relationship_Type__c from AccountContactRelations order by startdate asc LIMIT 1)
                           from Contact where AccountId IN :accIds  WITH SECURITY_ENFORCED ];    
       
       for(Contact con : conNonOwnerLst) {
            for(AccountContactRelation accConRel : con.AccountContactRelations) {
                if(!conOwnrSet.contains(accConRel.AccountID)) {
                	conLst.add(con);    
                }
            }    
        }
        conLst.addAll(conOwnerLst);
        for(Contact con : conLst) {
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
            //cont.accountId = String.isempty(lastRelOwnerAccount)?lastRelAccount:lastRelOwnerAccount;
            //contactmap.put(con.Id,cont);
            contUpdateLst.add(cont);
            system.debug('contUpdateLst==>>'+contUpdateLst);
     	}
        return contUpdateLst;
        /* system.debug('@contactmap@'+contactmap);
		system.debug('@accConRelation@'+accConRelation);
		upsertMap.put('Contact',contactmap);
		CM_DMLSaveResult.upsertRecords(upsertMap, false); 
        UCB_DMLUtility.updateRecords(contUpdateLst,false); */ 
    }    
    private CM_AccountInactiveService() {}
}