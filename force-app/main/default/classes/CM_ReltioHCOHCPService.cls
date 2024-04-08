/***********************************************************************************************************************
* Name: CM_ReltioHCOHCPService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service class handles Account Contact Relationship, service which is invoked from platform event trigger handler
* TestClass : CM_ReltioHCOHCPService
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023         Account Contact Relationship service class 
***********************************************************************************************************************/
public with sharing class CM_ReltioHCOHCPService {
    /* type of Asset event */
    final static string ACCOUNTSTRING = 'Account';
    /**
    * @description : Method to parses input json and get Account Contact relationship data     
    * @Parameters : input json, process name from platfrom event
    */
    public static AccountRelation upsertHCOHCPService(String inputJson, Map<String,CM_ReltioHandlerService.SobjectData> process2Metadata) {
        final AccountRelation accRelation = new AccountRelation();
        Map<String,Map<String,Sobject>> upsertNewMap = new  Map<String,Map<String,Sobject>>();
        Map<String,Map<String,Sobject>> returnMap = new  Map<String,Map<String,Sobject>>();

        Map<String,Map<String,Map<String,Object>>> key2value =  CM_JSONParser.objectJsonParsers(inputJson,process2Metadata.get(CM_ReltioConstants.RELTIOHCPHCO));   
        final CM_AccountContactRelationshipService.AccountRelation accRelationship = CM_AccountContactRelationshipService.upsertAccountRelationship(key2value.get('AccountContactRelation'));        
        upsertNewMap= CM_ReltioHandlerService.upsertSobjectMap(accRelationship.resultMap,upsertNewMap);
 
        key2value = CM_JSONParser.attibuteParsers(accRelationship.endObjectDetails,process2Metadata.get(CM_ReltioConstants.RELTIOHCO) );
        returnMap = CM_ReltioHCOService.upsertHCOSelector(key2value);
        upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(returnMap,upsertNewMap);


        key2value = CM_JSONParser.attibuteParsers(accRelationship.startObjDetails,process2Metadata.get(CM_ReltioConstants.RELTIOHCP) );
        returnMap = CM_ReltioHCPService.upsertHCPSelector(key2value);
        upsertNewMap = CM_ReltioHandlerService.upsertSobjectMap(returnMap,upsertNewMap); 
        
        accRelation.upsertNewMap = upsertNewMap;
        accRelation.contact2Account = accRelationship.contact2Account;
        return accRelation;
    }
    public  static Map<String, Map < String, Sobject >> getOldHCOHCPMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordIds = upsertNewMap.get(ACCOUNTSTRING).keyset();
        final Set<String> relationIds = upsertNewMap.get('AccountContactRelation').keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put(ACCOUNTSTRING,new Map <String, Sobject>());  
        upsertOldMap.put('Organization_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('Organization_E_Invoice__c',new Map <String, Sobject>());  
        upsertOldMap.put('AccountContactRelation',new Map <String, Sobject>()); 
        for(Account acc : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_Communications__r),
                        (Select Id,MDM_Id__c,Account__r.MDM_Id__c,TimeStamp_Decimal__c from Organization_E_Invoices__r),
                        (Select Id,MDM_Id__c,Contact.MDM_Id__c,Account.MDM_Id__c,TimeStamp_Decimal__c from AccountContactRelations where AccountContact_Id__c=:relationIds) 
                        from Account where MDM_Id__c = :recordIds with SECURITY_ENFORCED]) {
            upsertOldMap.get(ACCOUNTSTRING).put(acc.MDM_Id__c,acc);
            for(Organization_Communication__c communication: acc.Organization_Communications__r) {
                upsertOldMap.get('Organization_Communication__c').put(communication.MDM_Id__c,communication);  
            }
            for(Organization_E_Invoice__c invoice: acc.Organization_E_Invoices__r) {
                upsertOldMap.get('Organization_E_Invoice__c').put(invoice.MDM_Id__c,invoice); 
            }
            for(AccountContactRelation relationship: acc.AccountContactRelations) {
                upsertOldMap.get('AccountContactRelation').put(relationship.Account.MDM_Id__c+relationship.Contact.MDM_Id__c,relationship); 
            }
        }
        return upsertOldMap;
    }
    public  static Map<String, Map < String, Sobject >> getOldContactMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordIds = upsertNewMap.get('Contact').keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put('Contact',new Map <String, Sobject>());  
        upsertOldMap.put('Educational_Detail__c',new Map <String, Sobject>());  
        upsertOldMap.put('Person_Communication__c',new Map <String, Sobject>());  
        upsertOldMap.put('License_Information__c',new Map <String, Sobject>()); 
        for(Contact con : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,Account.MDM_Id__c,
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Educational_Details__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Person_Communications__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from License_Informations__r) 
            from Contact where MDM_Id__c = :recordIds with SECURITY_ENFORCED]) {
            upsertOldMap.get('Contact').put(con.MDM_Id__c,con);
            for(Educational_Detail__c education : con.Educational_Details__r) {
                upsertOldMap.get('Educational_Detail__c').put(education.MDM_Id__c,education);  
            }
            for(Person_Communication__c communication: con.Person_Communications__r) {
                upsertOldMap.get('Person_Communication__c').put(communication.MDM_Id__c,communication); 
            }
            for(License_Information__c licence: con.License_Informations__r) {
                upsertOldMap.get('License_Information__c').put(licence.MDM_Id__c,licence); 
            }
        }
        return upsertOldMap;
    }
    public static Map<String,Sobject> upsertContacttMap(List<Contact> contactNewList,Map<String,String> conwithAccount,Map<String,  String> contact2Account) {
        final Map<String,Sobject> contactMap = new Map<String,Sobject>();
        for(Contact con : contactNewList) {
            if(!conwithAccount.containsKey(con.MDM_Id__c) && contact2Account.containsKey(con.MDM_Id__c)) {
                con.Account = new account(MDM_Id__c =contact2Account.get(con.MDM_Id__c));
                contactMap.put(con.MDM_Id__c,con);    
            } 
        }         
        return contactMap;
    }
    public static Map<String,String> conwithAccount(List<Contact> contactOldList) {
        final Map<String,String> conwithAccount = new Map<String,String>();
        for(Contact con : contactOldList) {
            if(con.AccountId!=null ) {
                conwithAccount.put(con.MDM_Id__c,con.Account.MDM_Id__c);   
            }
        }   
        return conwithAccount;
    }
    /*Acount Relation wrapper */
    public class AccountRelation {
        /* Map of upserted record */
        public Map<String,Map<String,Sobject>> upsertNewMap;
        /* Contact 2 Account Map */
        public Map<String,  String> contact2Account ;
    }
    private CM_ReltioHCOHCPService() {}
}