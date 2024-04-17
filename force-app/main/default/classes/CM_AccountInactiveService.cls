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
    /* Account status inactive */
    final static string ACCOUNT_INACTIVE = 'Account Inactive';
    /* Process to Associate Contact with Account */
    final static string ASSC_CONT_ACCT = 'Associate ContAcct'; 
    /* Null Value */
    final static string NULL_VALUE = null;  
    /* Relation Type Owner */
    final static string RELATED_OWNER = 'Owner'; 
    
    /**
* @description : This method gets details of account service to invoke 
* and account Ids from changeEvent 
* @parameters : Map of account service and account IDs
*/  
    public static List<Contact> getContwithActiveAccnt(Map<String,List<Id>> accMap) {        
        final List<Contact> contUpdateLst = new List<Contact>();
        final Map<Id,Id> conAccMap = new Map<Id,Id>();
        final List<Id> accIds; 		         
        final List<Contact> conLst = new List<Contact>();        
        final Set<Id> conNonOwnrSet = new Set<Id>();        
        Contact contRec;
        
        for(String str : accMap.keySet()) {
            if(str == ACCOUNT_INACTIVE || str == ASSC_CONT_ACCT) {
                accIds = accMap.get(str);		    
            }            
        }
        
        for(Contact cont : [Select Id,
                            (Select accountId,Relationship_Type__c from AccountContactRelations where Relationship_Type__c='Owner'
                             AND Account.Status__c='Active' order by startdate asc LIMIT 1) from Contact
                            where AccountId IN :accIds  WITH SECURITY_ENFORCED ]) { 
                                /* for(AccountContactRelation reltn : cont.AccountContactRelations) {
                                    if(reltn.Relationship_Type__c == RELATED_OWNER) {
                                        conOwnrSet.add(cont.Id);
                                        conLst.add(cont);
                                        conAccMap.put(cont.Id,reltn.AccountId);
                                    }    
                                } */ 
                                if(cont.AccountContactRelations.size() == 1) {
                                	conAccMap.put(cont.Id,cont.AccountContactRelations[0].AccountId);    
                                }
                                else{
                                	conNonOwnrSet.add(cont.Id);    
                                }
                            }  
        system.debug('conNonOwnrSet==>>'+conNonOwnrSet);
        system.debug('conAccMap==>>'+conAccMap);
        if(!conNonOwnrSet.isEmpty() && conNonOwnrSet.size() != null) {
        for(Contact con: [Select Id,
                          (Select accountId,Relationship_Type__c from AccountContactRelations order by startdate asc LIMIT 1)
                          from Contact where AccountId IN :accIds AND ID NOT IN:conAccMap.keySet() WITH SECURITY_ENFORCED] ) {       
                              for(AccountContactRelation rels : con.AccountContactRelations) {
                                  conAccMap.put(con.Id,rels.AccountID);
                                  conLst.add(con);
                              }	               
                          }
        }   
        system.debug('conNonOwnrSet==>>'+conNonOwnrSet);
        system.debug('conAccMap==>>'+conAccMap);
        //for(Contact con: conLst) {
        for(Id conId: conAccMap.keySet()) {
            contRec = new Contact();
            contRec.Id = conId;
            contRec.accountId = NULL_VALUE;
            contRec.accountId = conAccMap.get(conId);
            contUpdateLst.add(contRec);
        }                              
        return contUpdateLst;
    }
    
    /**
* @description : constructor  
*/  
    private CM_AccountInactiveService() {}
}