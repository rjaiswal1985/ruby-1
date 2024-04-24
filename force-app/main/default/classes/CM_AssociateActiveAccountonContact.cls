/***********************************************************************************************************************
* Name: CM_AssociateActiveAccountonContact
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Associates Account on Contact when Direct related account is inactivated
* TestClass : CM_AssociateActiveAccountonContact_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   17/04/2024             Associates AccountContact when direct account is made inactive
***********************************************************************************************************************/
public with sharing class CM_AssociateActiveAccountonContact {
    /* Null Value */
    final static string NULL_VALUE = null;
    /* Count of no of relations */
    final static Integer RELATIONS_COUNT = 1;  
    
    /**
* @description : This method updates contact with Active account
* when direct account is deactivated, based on the accountcontact relation 
* @parameters : Set of contact IDs
*/  
    public static void updateContwithActiveAccnt(Set<Id> contIdSet) {        
        final List<Contact> contUpdateLst = new List<Contact>();
        final Map<Id,Id> conAccMap = new Map<Id,Id>();               
        final Set<Id> OtherRelContIds = new Set<Id>(); 
        List<Database.UpsertResult> upsertResults;
        Contact contRec;       
        system.debug('contIdSet==>>'+contIdSet);
        for(Contact cont : [Select Id,
                            (Select accountId,Relationship_Type__c from AccountContactRelations where Relationship_Type__c='Owner'
                             AND Account.Status__c='Active' AND Status__c = 'Active' order by startdate asc LIMIT 1) from Contact
                            where ID IN :contIdSet WITH SECURITY_ENFORCED ]) { 
        	if(cont.AccountContactRelations.size() == RELATIONS_COUNT) {
            	//conAccMap.put(cont.Id,cont.AccountContactRelations[0].AccountId); 
                contIdSet.remove(cont.Id);
                system.debug('contRec==>>'+contRec);
                contRec = instantiateContwithAcct(cont.AccountContactRelations[0].AccountId,cont); //send accConRec to instantiate               
                contUpdateLst.add(contRec); 
                system.debug('contRec==>>'+contRec);
                system.debug('contUpdateLst==>>'+contUpdateLst);                
            } 
        }  
        
        
        /*for(Id conId : conAccMap.keySet()) {
            if(contIdSet.contains(conId)) {
            	contIdSet.remove(conId);    
            }
        }*/
        //contIdSet.removeAll(conAccMap.keySet());
        system.debug('contIdSet==>>'+contIdSet);
        
        if(contIdSet != null && !contIdSet.isEmpty()) {            
            for(Contact con: [Select Id,
                              (Select accountId,Relationship_Type__c from AccountContactRelations                               
                               where Account.Status__c='Active' AND Status__c = 'Active' 
                               order by startdate asc LIMIT 1)
                              from Contact where ID IN:contIdSet WITH SECURITY_ENFORCED] ) {
                                  system.debug('related member==>>'+con);
            	for(AccountContactRelation rels : con.AccountContactRelations) {                	
                    system.debug('rels==>>'+rels);                    
                    contRec = instantiateContwithAcct(con.AccountContactRelations[0].AccountId,con);                
                	contUpdateLst.add(contRec);
                    system.debug('contRec==>>'+contRec);
                	system.debug('contUpdateLst==>>'+contUpdateLst);
                }	               
            }
        }   
        
        system.debug('conAccMap==>>'+conAccMap);
        
       /* for(Id conId: conAccMap.keySet()) {        	
            contRec = new Contact();
            contRec.Id = conId;            
            contRec.accountId = conAccMap.get(conId);
            contUpdateLst.add(contRec);            
        } */
        system.debug('contUpdateLst==>>'+contUpdateLst);
        upsertResults = UCB_DMLUtility.upsertRecords(contUpdateLst,false,System.AccessLevel.SYSTEM_MODE); 
        UCB_LoggerService.logger(new UCB_Log('Contact update with Active Account', 'DML Upsert Result', JSON.Serialize(upsertResults)),false);  
        UCB_LoggerService.publishLogs();         
    }
    
    public static Contact instantiateContwithAcct(Id accntId, Contact cont) {    	
    	Contact con = new Contact(Id=cont.Id,AccountID=accntId);
        //cont.AccountId = accntId;                
        system.debug('contact instantiated==>>'+con);
        return con;
    }
    /**
* @description : constructor  
*/  
    private CM_AssociateActiveAccountonContact() {}
}