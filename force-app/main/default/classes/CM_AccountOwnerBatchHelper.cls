/***********************************************************************************************************************************
* Name: CM_AccountOwnerBatchHelper
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Batch class to update account owner with territory primary owner
* TestClass : CM_AccountOwnerBatchUpdate
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                   06/02/2024              Helper calss for  update account owner
************************************************************************************************************************************/
public without sharing class CM_AccountOwnerBatchHelper {  
    /* territory primary owner */
    final static String PRIMARY_OWNER = 'Primary Owner';
    /* No of business units */
    final static Integer BUSINESS_UNITS = 1;
    
    /**
* @description : returns account with owner details
*/
    public static List<Account> getAccountOwner(List<Account> accList, Map<String,Customer_Master_Configurations__c> lobSettingMap) {
        final List<Account> accUpdateLst;
        final Map<Account, Id> accTerrMap = getAccTerritory(accList,lobSettingMap);        
        final Map<Id, Id> terrMngrMap = getTerritoryUser(accTerrMap.values());        
        accUpdateLst = updateAccountOwner(accTerrMap,terrMngrMap);            
        return accUpdateLst;
    }  
    /**
* @description : returns query 
*/
    public static string prepareQuery() {
        String query;
        final Integer lastModifiedTime = Integer.valueof(Batch_Jobs_Execution__c.getValues('Account Ownership Batch').Process_last_hours__c);     
        if (lastModifiedTime == null) {
            query = ' SELECT Id,Name,ownerId,Line_of_Business__c,(SELECT Territory2.Name,ObjectId,Territory2Id,Territory2.Business_unit__c FROM ObjectTerritory2Associations) from Account ';
        } else {            
            final Datetime myDateTime = datetime.now().addHours(-1 * lastModifiedTime); 
            final String formattedDate = myDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');           
            query = ' SELECT Id,Name,ownerId,Line_of_Business__c,(SELECT Territory2.Name,ObjectId,Territory2Id,Territory2.Business_unit__c FROM ObjectTerritory2Associations) from Account where createdDate >'+ formattedDate;
        }        
        return query;
    }
    /**
* @description : returns account & territory map
* @params : list of account Ids, custom setting with priority of business unit
*/
    private static Map<Account, Id>  getAccTerritory(List<Account> accList, Map<String,Customer_Master_Configurations__c> lobSettingMap) {
        String territyBU;
        final Map<Account, Id> accTerrMap = new Map<Account, Id>();        
        Map<String, String> territoryMap;                
        for (Account acc : accList) {                
            if(acc.ObjectTerritory2Associations.size() == BUSINESS_UNITS) {                
                accTerrMap.put(acc, acc.ObjectTerritory2Associations[0].Territory2.Id);                    
            } else if(acc.ObjectTerritory2Associations.size() > BUSINESS_UNITS) {                
                territoryMap = new Map<String, String>();
                for (ObjectTerritory2Association objTerr : acc.ObjectTerritory2Associations) {                    
                    territoryMap.put(objTerr.Territory2.Business_unit__c, objTerr.Territory2.Id);                        
                }                
                territyBU = getHighPrecedence(territoryMap.keySet(), lobSettingMap);				                
                accTerrMap.put(acc, territoryMap.get(territyBU));                           
            } 
        }        	
        return accTerrMap;         
    }
    /**
* @description : returns the territory primary owner details
* @params : list of territory Ids
*/
    private static Map<Id, Id> getTerritoryUser(List<Id> territoryIds) {
        final Map<Id, Id> terrMngrMap = new Map<Id, Id>();               
        for (UserTerritory2Association userTerr : [SELECT Id, UserId, user.Name, Territory2.Name, Territory2Id, Territory2.Business_unit__c, RoleInTerritory2
                                                   FROM UserTerritory2Association
                                                   where Territory2Id IN: territoryIds AND IsActive = true AND RoleInTerritory2 = :PRIMARY_OWNER  WITH SECURITY_ENFORCED]) {
                                                       terrMngrMap.put(userTerr.Territory2Id, userTerr.UserId);
                                                   }
        return terrMngrMap;         
    }
    /**
* @description : returns the business unit value with high priority
*/
    private static List<Account> updateAccountOwner(Map<Account, Id> accTerrMap,Map<Id, Id> terrMngrMap) {
        Account toBeUpdateAcc;
        final List<Account> accUpdateLst = new List<Account>();
        for (Account acc : accTerrMap.keyset()) {
            if (terrMngrMap.containskey(accTerrMap.get(acc)) && acc.ownerId != terrMngrMap.get(accTerrMap.get(acc))) {
                toBeUpdateAcc = new Account();
                toBeUpdateAcc.Id= acc.Id;
                toBeUpdateAcc.ownerId = terrMngrMap.get(accTerrMap.get(acc));
                accUpdateLst.add(toBeUpdateAcc);
            }
        }        
        return accUpdateLst;
    }
    /**
* @description : returns the business unit value with high priority
*/
    public static string getHighPrecedence(Set<String> businessUnit, Map<String,Customer_Master_Configurations__c> lobSettingMap) {
        Decimal highestValue = 0;
        Decimal mapVal;
        String highValUnit;
        for (String str : businessUnit) {            
            if (lobSettingMap.containsKey(str)) {                                 
                mapVal = lobSettingMap.get(str).Priority__c;                
            }            
            if (highestValue == 0 || mapVal < highestValue) {
                highestValue = mapVal;
                highValUnit = str;
            }
        }                
        highestValue=mapVal+highestValue;        
        return highValUnit;
    }
    /**
* @description : constructor
*/
    private CM_AccountOwnerBatchHelper() {} 
}