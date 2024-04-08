public with sharing class AccountTriggerHandler_check {
    
    public static void afterInsert(List<Account> accLst){
        set<Id> accIds = new set<Id>();
    
       for(Account acc : accLst){
           system.debug('acc==>'+acc);
           accIds.add(acc.ID);
       }
       Map<Id,List<Id>> accntTerrMap = new Map<Id,List<Id>>();
       for(ObjectTerritory2Association terrAccnt : [SELECT Id, ObjectId, Territory2Id from ObjectTerritory2Association where ObjectId IN:accIds ]){
            system.debug('terrAccnt==>'+terrAccnt);
            if(!accntTerrMap.containsKey(terrAccnt.Territory2Id)){
                accntTerrMap.put(terrAccnt.Territory2Id, new List<Id>());
            }
            accntTerrMap.get(terrAccnt.Territory2Id).add(terrAccnt.ObjectId);
             system.debug('accntTerrMap==>'+accntTerrMap);
            
        }
    }
    
    public static void beforeInsert(List<Account> accLst){
       for(Account acc : accLst){
           system.debug('acc==>'+acc);
       }
    }

}