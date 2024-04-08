/**
* Name: CM_AccountOwnerBatchUpdate_Test
* Copyright © Align Tech
* Purpose : Test class for CM_AccountOwnerBatchUpdate
* 
*/
/***********************************************************************************************************************
History

VERSION         AUTHOR                          DATE                DETAIL
1.0             Sruthi M                  11/03/2024             Test class for Account owner batch update  
***********************************************************************************************************************/
@isTest
public class CM_AccountOwnerBatchUpdate_Test {
    /* territory ID */
    final static String TRTY_ID = 'Territory2Id';
    /* Name field */
    final static String NAME_FLD = 'Name'; 
    /* Association cause */
    final static String ASC_CAUSE = 'Territory2Manual';
    /* Account Operating unit */
    final static String OPRTN_UNIT = 'Operating_Units__c';
    /* Account Name */
    final static String ACC_NAME = 'Test Acc';
    /* Sobject type Account  */
    final static String SOBJ_ACC = 'Account';
    
    /**
* @description: testdata set up 
*/     
    @TestSetup
    static void createTestData() {
        
        UCB_TestDataFactory.createSObject('Batch_Jobs_Execution__c',new Map<String,Object>{
            NAME_FLD => 'Account Ownership Batch', 'Batch_Size__c' => 1},true);
        
        UCB_TestDataFactory.createSObjectList('Customer_Master_Configurations__c',new Map<String,Object>{
            NAME_FLD => new List<String> {'invisalign','iTero','exocad'}, 'Priority__c' => new List<Integer>{1,2,3}},3); 
        
        UCB_TestDataFactory.createSObjectList('User', new Map<String,Object> {
            'Username' => new List<String>{'test123456789@mycompany.dv01','test123456789@mycompany.dv02','test123456789@mycompany.dv03','test123456789@mycompany.dv04'},'ProfileId' => new List<Id>{UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId()},
                'CommunityNickname' => new List<String>{'testUser01','testUser02','testUser03','testUser04'}},4);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) { 
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];                        
            
            UCB_TestDataFactory.createSObject('Territory2Model',new Map<String,Object>{
                'DeveloperName' => 'TestModel',NAME_FLD=>'TestModel'},true);            
            final List<Territory2Model> trtyModel = [select id,DeveloperName from Territory2Model 
                                                     where DeveloperName = 'TestModel'];
            final List<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type LIMIT 1];                    
            
            UCB_TestDataFactory.createSObjectList('Territory2',new Map<String,Object>{
                'DeveloperName' => new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica','Testxyz'},
                    'Territory2ModelId' => new List<Id>{trtyModel[0].Id,trtyModel[0].Id,trtyModel[0].Id,trtyModel[0].Id}, 
                        NAME_FLD=> new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica','Testxyz'},
                            'Territory2TypeId'=> new List<Id>{terriType[0].Id,terriType[0].Id,terriType[0].Id,terriType[0].Id},
                                'Business_unit__c' => new List<String>{'exocad','exocad','invisalign','invisalign'} },4);             
            
            final List<Territory2> trtyLst = [SELECT id,DeveloperName from Territory2 where DeveloperName like '%Test%' ];
            
            UCB_TestDataFactory.createSObjectList('UserTerritory2Association',new Map<String,Object>{
                'RoleInTerritory2' =>new List<String>{'Primary Owner', 'Associate Territory Manager','Primary Owner','Associate Territory Manager'},
                    TRTY_ID =>new List<Id>{trtyLst[0].Id, trtyLst[1].Id,trtyLst[2].Id,trtyLst[2].Id},
                        'UserId'=> new List<Id>{userLst2[0].Id,userLst2[1].Id,userLst2[2].Id,userLst2[3].Id} },4);            
            
        }            
    }
           
    /**
* @description: Accounts with one territory assigned
* check owner updated with territory primary owner
*/    
    @isTest
    static void accBatchExecutionTest() {                            
        
        final List<Account> accLst1 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4050_Exocad_America'},5);            
        final List<Account> accLst2 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4020_Exocad_Gmbh'},5);        
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {                                                                                                                                      
            final List<Territory2> trtyLst = [select id,DeveloperName,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                          
            UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                'ObjectID' => new List<Id>{accLst1[0].Id,accLst1[1].Id,accLst1[2].Id,accLst1[3].Id,accLst1[4].Id,accLst2[1].id} ,
                    TRTY_ID => new List<Id>{trtyLst[0].Id,trtyLst[0].Id,trtyLst[0].Id,trtyLst[0].Id,trtyLst[0].Id,trtyLst[1].Id}, 
                        'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},6);            
        }        
        Test.startTest();
        final CM_AccountOwnerBatchUpdate accntBatch = new CM_AccountOwnerBatchUpdate();
        Database.executeBatch(accntBatch);             
        Test.stopTest();
        
        final List<UserTerritory2Association> excdUsrLst = [select Id,Territory2ID,Territory2.DeveloperName,RoleInTerritory2,UserId from UserTerritory2Association where Territory2.DeveloperName = 'TestExocadAmericas'];     
        final List<Account> excdAccLst = [select id,ownerId from Account where Operating_Units__c = '4050_Exocad_America'];
        System.assertEquals(excdUsrLst[0].UserId,excdAccLst[1].ownerId,'Account owner updated');                            
    }
    
    /**
*@description Accounts with 2 territorys assigned
*Check Account owner is updated with high precedence territoty owner
*/           
    @isTest
    static void accBatchExecutionTest2() {        
        
        final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];
        
        final Batch_Jobs_Execution__c batchSettings = [select id,name,Process_last_hours__c from Batch_Jobs_Execution__c where name='Account Ownership Batch'];          
        batchSettings.Process_last_hours__c = 1;
        update batchSettings;            
        
        final List<Account> accLst1 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4050_Exocad_America','OwnerId'=>userLst[3].Id},2);                        
        
        final List<Account> accLst2 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4020_Exocad_Gmbh','OwnerId'=>userLst[3].Id},2);                        
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {
            
            final List<Territory2> trtyLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                                                                                         
            
            UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                'ObjectID' => new List<Id>{accLst1[1].id,accLst2[1].id,accLst1[1].id }, TRTY_ID => new List<Id>{trtyLst[0].Id,trtyLst[1].Id,trtyLst[2].Id}, 'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},3);                 
        }                                                                                                                                           
        Test.startTest();
        final CM_AccountOwnerBatchUpdate accntBatch = new CM_AccountOwnerBatchUpdate();
        Database.executeBatch(accntBatch);             
        Test.stopTest();
        final List<UserTerritory2Association> excdUsrLst = [select Id,Territory2ID,Territory2.DeveloperName,RoleInTerritory2,UserId from UserTerritory2Association
                                                            where Territory2.DeveloperName = 'TestInvisalignAmerica' AND RoleInTerritory2 = 'Primary Owner'];             
        
        final List<Account> excdAccLst = [select id,ownerId from Account where Operating_Units__c = '4050_Exocad_America'];        
        
        System.assertEquals(excdUsrLst[0].UserId,excdAccLst[1].ownerId,'Account owner updated');         
        
    }
    
    /**
*@description Account with territory owner
*Check Account owner is updated 
*/           
    @isTest
    static void accBatchExecutionTest3() {        
        
        final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];
        
        final Batch_Jobs_Execution__c batchSettings = [select id,name,Process_last_hours__c from Batch_Jobs_Execution__c where name='Account Ownership Batch'];          
        batchSettings.Process_last_hours__c = 1;
        update batchSettings;            
        
        final List<Customer_Master_Configurations__c> buPriority = [select id,name,Priority__c from Customer_Master_Configurations__c where Priority__c!=null];                               
        buPriority[0].name = 'Test1';
        buPriority[1].name = 'Test2';
        buPriority[2].name = 'Test3';
        update buPriority;
        
        final List<Account> accLst1 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4050_Exocad_America','OwnerId'=>userLst[3].Id},2);                                      
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {
            
            final List<Territory2> terrLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                                     
            
            //final List<UserTerritory2Association> userTerrLst = [select id,RoleInTerritory2,Territory2ID,UserId from UserTerritory2Association where Territory2.DeveloperName like 'Test%'];                                
            
            UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                'ObjectID' => new List<Id>{accLst1[0].id,accLst1[0].id,accLst1[1].id}, 
                    TRTY_ID => new List<Id>{terrLst[3].Id,terrLst[0].Id,terrLst[0].Id}, 
                        'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},3);            
        }                                                                                                                                           
        Test.startTest();
        final CM_AccountOwnerBatchUpdate accntBatch = new CM_AccountOwnerBatchUpdate();
        Database.executeBatch(accntBatch);             
        Test.stopTest();
        final List<UserTerritory2Association> excdUsrLst = [select Id,Territory2ID,Territory2.DeveloperName,RoleInTerritory2,UserId from UserTerritory2Association
                                                            where Territory2.DeveloperName = 'TestExocadAmericas' AND RoleInTerritory2 = 'Primary Owner'];                     
        final List<Account> excdAccLst = [select id,ownerId from Account where Operating_Units__c = '4050_Exocad_America'];               
        System.assertNotEquals(excdUsrLst[0].UserId,excdAccLst[0].ownerId,'Account owner updated');         
        
    }

    /**
* @description: Accounts batch update with batchsize 100
*/    
    @isTest
    static void accBatchExecBatchSizeTest() {                            
        try{        
        final List<Account> accLst1 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4050_Exocad_America'},50);            
        final List<Account> accLst2 = UCB_TestDataFactory.createSObjectList(SOBJ_ACC,new Map<String,Object>{
            NAME_FLD => ACC_NAME, OPRTN_UNIT => '4020_Exocad_Gmbh'},50);        
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {                                                                                                                                      
            final List<Territory2> trtyLst = [select id,DeveloperName,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                          
            final List<ObjectTerritory2Association> objTrtyLst = new List<ObjectTerritory2Association>();
            for(Account acc : accLst1){
                ObjectTerritory2Association objTrtyAss = (ObjectTerritory2Association)UCB_TestDataFactory.createSObject('ObjectTerritory2Association', new Map<String,Object> {
                    'ObjectID' => acc.Id,TRTY_ID => trtyLst[0].Id,'AssociationCause'=> ASC_CAUSE},false);                                
                objTrtyLst.add(objTrtyAss);
            }
            for(Account acc : accLst1){
                ObjectTerritory2Association objTrtyAss = (ObjectTerritory2Association)UCB_TestDataFactory.createSObject('ObjectTerritory2Association', new Map<String,Object> {
                    'ObjectID' => acc.Id,TRTY_ID => trtyLst[1].Id,'AssociationCause'=> ASC_CAUSE },false);                               
                objTrtyLst.add(objTrtyAss);
            }	
            insert objTrtyLst;           
        }        
        Test.startTest();
        final CM_AccountOwnerBatchUpdate accntBatch = new CM_AccountOwnerBatchUpdate();
        Database.executeBatch(accntBatch,100);             
        Test.stopTest();
        
        final List<UserTerritory2Association> excdUsrLst = [select Id,Territory2ID,Territory2.DeveloperName,RoleInTerritory2,UserId from UserTerritory2Association where Territory2.DeveloperName = 'TestExocadAmericas'];     
        final List<Account> excdAccLst = [select id,ownerId from Account where Operating_Units__c = '4050_Exocad_America'];
        System.assertEquals(excdUsrLst[0].UserId,excdAccLst[1].ownerId,'Account owner updated');
        } Catch(Exception excp){
            system.debug('excp==>>'+excp.getMessage());
            system.debug('excp stack trace==>>'+excp.getstacktraceString());
        }
        
    }    
    
}