/***********************************************************************************************************************
* Name: CRM_OrderEventSubcriberHandler_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on order
* TestClass : CRM_OrderEventSubcriberHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        12/03/2024          Test Class 
***********************************************************************************************************************/
@isTest
public class CRM_OrderEventSubcriberHandler_Test {
    
    /**
* @description: testdata set up 
*/     
    @TestSetup
    static void createTestData() {
        
        final List<User> userLst = UCB_TestDataFactory.createSObjectList('User', new Map<String,Object> {
            'Username' => new List<String>{'test123456789@mycompany.dv01','test123456789@mycompany.dv02','test123456789@mycompany.dv03'},'ProfileId' => new List<Id>{UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId()},
                'CommunityNickname' => new List<String>{'testUser01','testUser02','testUser03'}},3);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) { 
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];            
            
            final Territory2Model terrModel = (Territory2Model)UCB_TestDataFactory.createSObject('Territory2Model',new Map<String,Object>{
                'DeveloperName' => 'TestModel','Name'=>'TestModel'},true);            
            
            final List<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type LIMIT 1];                    
            
            final List<Territory2> terrLst = UCB_TestDataFactory.createSObjectList('Territory2',new Map<String,Object>{
                'DeveloperName' => new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},'Territory2ModelId' => new List<Id>{terrModel.Id,terrModel.Id,terrModel.Id}, 'Name'=> new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},
                    'Territory2TypeId'=> new List<Id>{terriType[0].Id,terriType[0].Id,terriType[0].Id},'Business_unit__c' => new List<String>{'exocad','exocad','invisalign'} },3);             
            
            final List<UserTerritory2Association> userTerrLst = UCB_TestDataFactory.createSObjectList('UserTerritory2Association',new Map<String,Object>{
                'RoleInTerritory2' =>new List<String>{'Primary Owner', 'Primary Owner'},'Territory2ID' =>new List<Id>{terrLst[0].Id, terrLst[1].Id},'UserId'=> new List<Id>{userLst2[0].Id,userLst2[1].Id} },2);
            
        }            
        
    }
    
    /*
* @description : Order trigger handler for after insert
*/
    @isTest
    static void testOrderEventSubscriber() {         
        try{
            
            final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];            
            system.debug('userLst==>>'+userLst);
            final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account',new Map<String,Object>{
                'Name' => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America'},5);
            system.debug('accLst==>>'+accLst);
                        
            System.RunAs(new user(ID = UserInfo.getUserID())) {                                        
                
                final List<Territory2> terrLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                 
                
                final List<ObjectTerritory2Association> terrObjLst = UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                    'ObjectID' => new List<Id>{accLst[0].Id,accLst[1].Id,accLst[2].Id,accLst[3].Id,accLst[4].Id} ,
                        'Territory2ID' => new List<Id>{terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id}, 
                            'AssociationCause'=> new List<String>{'Territory2Manual','Territory2Manual','Territory2Manual','Territory2Manual','Territory2Manual'}},5);                                                                          
                system.debug('terrObjLst==>>'+terrObjLst);
            }  
            final List<EventBusSubscriber> subcbrLst = [SELECT Name, Position, Retries, LastError FROM EventBusSubscriber 								
							WHERE Topic='CRM_Order_Event__e' AND Type='ApexTrigger'];
            system.debug('subcbrLst==>>'+subcbrLst);
            Test.startTest();            
            final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String,Object> {
                'AccountId' => new List<ID>{accLst[0].Id,accLst[1].Id,accLst[2].Id},
                    'OwnerId' => new List<ID>{userLst[2].Id,userLst[2].Id,userLst[2].Id},
                        'EffectiveDate'=> new List<Date>{Date.newInstance(2024,03,12),Date.newInstance(2024,03,12),Date.newInstance(2024,03,12)},
                            'Status'=> new List<string>{'Draft','Draft','Draft'}},3); 
                         
            Test.stopTest();            
			final List<Order> ordUpdtLst = [select Id,ownerId from Order where Status='Draft'];
            system.debug('ordUpdtLst==>>'+ordUpdtLst);
                       
            
        } Catch(Exception excp) {
            system.debug('Exception==>>'+excp.getMessage());
            system.debug('Exception==>>'+excp.getStackTraceString());    
        }
    }
    static void createOrder2() {         
        try{
            Account acc = (Account)UCB_TestDataFactory.createSObject('Account',new Map<String,Object> {
                'Description' => 'Test'},true); 
            system.debug('acc==>>'+acc);
            
            Order ord = (Order)UCB_TestDataFactory.createSObject('Order',new Map<String,Object> {
                'EffectiveDate'=> Date.newInstance(2024,03,12), 'Status'=>'Draft'},true); 
            system.debug('ord==>>'+ord);
        } Catch(Exception excp) {
            system.debug('Exception==>>'+excp.getMessage());
            system.debug('Exception==>>'+excp.getStackTraceString());    
        }
    }    
}