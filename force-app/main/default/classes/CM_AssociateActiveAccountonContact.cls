/***********************************************************************************************************************
* Name: CM_AssociateActiveAccountonContact
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Associates Active Account on Contact when Direct related Account is inactivated
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
    public static void updateContwithActiveAccnt(Set<Id> recIdSet, String processName) {        
        final List<Contact> contUpdateLst = new List<Contact>();
        List<Database.UpsertResult> upsertResults;
        Contact contToUpdate; 
        List<Contact> contOwnerLst;
        List<Contact> contRelMembersLst;
        Boolean acctInactivation = false;
        Boolean acctContRelInactivation = false;
        
        String queryString1 = 'Select Id,AccountId,(Select accountId,contactId,Relationship_Type__c from AccountContactRelations where ';
        String ownerWhereClause = 'Relationship_Type__c=\'Owner\' AND ';
        String queryString2 = 'Account.Status__c=\'Active\' AND Status__c = \'Active\' order by startdate asc LIMIT 1)';
        string accntWhereClause;
        String acctContWhereClause;
        string finalQuery;
        
        if(processName == 'Account_Inactivation') {
            acctInactivation = true;
        	accntWhereClause = ' from Contact where AccountID IN:recIdSet WITH SECURITY_ENFORCED ';             
        }
        
        if(processName == 'Acct_Cont_Inactivation') {
            acctContRelInactivation = true;
        	acctContWhereClause = 'from Contact where ID IN:recIdSet WITH SECURITY_ENFORCED ';             
        }
        
        if(accntWhereClause!=null) {
        	finalQuery = queryString1+ownerWhereClause+queryString2+accntWhereClause;    
        }
        
        if(acctContWhereClause!=null) {
        	finalQuery = queryString1+ownerWhereClause+queryString2+acctContWhereClause;    
        }
        
        system.debug('owner query==>>'+finalQuery);
        contOwnerLst = Database.query(finalQuery);
        
        system.debug('contOwnerLst==>>'+contOwnerLst);
        system.debug('recIdSet==>>'+recIdSet);
        
        for(Contact cont : contOwnerLst) {
        	if(cont.AccountContactRelations.size() == RELATIONS_COUNT) { 
                system.debug('owner list==>>'+cont.AccountContactRelations);
                if(acctInactivation) {
                	recIdSet.remove(cont.AccountId);    
                }
                if(acctContRelInactivation) {
                	recIdSet.remove(cont.Id);    
                }
                
                system.debug('contToUpdate==>>'+contToUpdate);                
                contToUpdate = instantiateContwithAcct(cont.AccountContactRelations[0]);
                contUpdateLst.add(contToUpdate); 
                system.debug('contToUpdate==>>'+contToUpdate);
                system.debug('contUpdateLst==>>'+contUpdateLst);                
            } 
        }  
        
        system.debug('recIdSet==>>'+recIdSet);
        
        if(recIdSet != null && !recIdSet.isEmpty()) {
            finalQuery = null;
            if(acctInactivation) {
                finalQuery = queryString1+queryString2+accntWhereClause;    
            }
            if(acctContRelInactivation) {
                finalQuery = queryString1+queryString2+acctContWhereClause;    
            }
            
            system.debug('member query ==>>'+finalQuery);
            contRelMembersLst = Database.Query(finalQuery);
            
            system.debug('contRelMembersLst==>>'+contRelMembersLst);
            for(Contact con: contRelMembersLst) {
            system.debug('related member==>>'+con);
            	for(AccountContactRelation rels : con.AccountContactRelations) {                	
                    system.debug('rels==>>'+rels);                    
                    
                    contToUpdate = instantiateContwithAcct(con.AccountContactRelations[0]);                
                	contUpdateLst.add(contToUpdate);
                    system.debug('contToUpdate==>>'+contToUpdate);
                	system.debug('contUpdateLst==>>'+contUpdateLst);
                }	               
            }
        }                   
        system.debug('contUpdateLst==>>'+contUpdateLst);
        upsertResults = UCB_DMLUtility.upsertRecords(contUpdateLst,false,System.AccessLevel.SYSTEM_MODE); 
        UCB_LoggerService.logger(new UCB_Log('Contact update with Active Account', 'DML Upsert Result', JSON.Serialize(upsertResults)),false);  
        UCB_LoggerService.publishLogs();         
    }
    /**
* @description : associate contact with active accountID
* @Parameters : accountcontactrelation record
*/     
    public static Contact instantiateContwithAcct(AccountContactRelation accConRel) {    	
    	Contact conRec = new Contact(Id = accConRel.ContactId,AccountId = accConRel.AccountId);                       
        system.debug('contact instantiated==>>'+conRec);
        return conRec;        
    }
    /**
* @description : constructor  
*/  
    private CM_AssociateActiveAccountonContact() {}
}