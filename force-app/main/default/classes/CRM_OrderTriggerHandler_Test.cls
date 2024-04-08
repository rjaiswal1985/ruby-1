/***********************************************************************************************************************
* Name: CRM_OrderTriggerHandler_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on order
* TestClass : CRM_OrderTriggerHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        12/03/2024          Test Class 
***********************************************************************************************************************/
@isTest
public class CRM_OrderTriggerHandler_Test {
    
    /* Association cause */
    final static String ASC_CAUSE = 'Territory2Manual';
    /* Order Effective Date */
    final static Date TODAY = Date.today();
    /* Name field */
    final static String NAME_FLD = 'Name'; 
    
    /**
* @description: testdata set up 
*/     
    @TestSetup
    static void createTestData() {
        
        UCB_TestDataFactory.createSObjectList('User', new Map<String,Object> {
            'Username' => new List<String>{'test123456789@mycompany.dv01','test123456789@mycompany.dv02','test123456789@mycompany.dv03'},'ProfileId' => new List<Id>{UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId()},
                'CommunityNickname' => new List<String>{'testUser01','testUser02','testUser03'}},3);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) { 
            final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];            
            
            final Territory2Model trtyModel = (Territory2Model)UCB_TestDataFactory.createSObject('Territory2Model',new Map<String,Object>{
                'DeveloperName' => 'TestModel',NAME_FLD=>'TestModel'},true);            
            
            final List<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type LIMIT 1];                    
            
            final List<Territory2> terrLst = UCB_TestDataFactory.createSObjectList('Territory2',new Map<String,Object>{
                'DeveloperName' => new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},'Territory2ModelId' => new List<Id>{trtyModel.Id,trtyModel.Id,trtyModel.Id}, NAME_FLD=> new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},
                    'Territory2TypeId'=> new List<Id>{terriType[0].Id,terriType[0].Id,terriType[0].Id},'Business_unit__c' => new List<String>{'exocad','exocad','invisalign'} },3);             
            
            UCB_TestDataFactory.createSObjectList('UserTerritory2Association',new Map<String,Object>{
                'RoleInTerritory2' =>new List<String>{'Primary Owner', 'Primary Owner'},'Territory2ID' =>new List<Id>{terrLst[0].Id, terrLst[1].Id},'UserId'=> new List<Id>{userLst[0].Id,userLst[1].Id} },2);
            
        }            
        
    }
    /*
* @description : Create Order, check owner updated
*/
    @isTest
    static void createOrder() {
        
        final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];            
        system.debug('userLst==>>'+userLst);
        final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account',new Map<String,Object>{
            NAME_FLD => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America'},5);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {                                        
            
            final List<Territory2> terrLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                 
            
            UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                'ObjectID' => new List<Id>{accLst[0].Id,accLst[1].Id,accLst[2].Id,accLst[3].Id,accLst[4].Id} ,
                    'Territory2ID' => new List<Id>{terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id}, 
                        'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},5);                                                                          
        }
        
        Test.startTest();            						                        
        UCB_TestDataFactory.createSObjectList('Order', new Map<String,Object> {
            'AccountId' => new List<ID>{accLst[0].Id,accLst[1].Id,accLst[2].Id},                    
                'EffectiveDate'=> new List<Date>{TODAY,TODAY,TODAY},
                    'Status'=> new List<string>{'Draft','Draft','Draft'}},3);              
        Test.stopTest();
        final list<order> crtdOrdLst = [select id,ownerid,AccountID from order where EffectiveDate=:TODAY AND Status='Draft'];
        system.debug('crtdOrdLst==>>'+crtdOrdLst);
        
        final list<UserTerritory2Association> checkUsrLst = [select id,Territory2ID,UserId,RoleInTerritory2 from UserTerritory2Association 
                                                             where Territory2.DeveloperName='TestExocadAmericas'];
        system.debug('checkUsrLst==>>'+checkUsrLst);
        
        System.assertEquals(crtdOrdLst[0].ownerId, checkUsrLst[0].UserId,'Order owner updated');
        
        final List<EventBusSubscriber> ordEvnSubLst = [SELECT ExternalId, Name, Position, Status, Tip, Type FROM EventBusSubscriber 
                                                       WHERE Topic='CRM_Order_Event__e' AND Type='ApexTrigger']; 
        System.assertNotEquals(0, ordEvnSubLst.size());  
        //System.assert( 1, CRM_OrderService.orderPELst.size(), 'There should be events in the list' );                                         
        
    }
    
    /*
* @description : Create Order check event published
*/    
    @isTest
    static void createOrder2() {         
        final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];            
        system.debug('userLst==>>'+userLst);
        final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account',new Map<String,Object>{
            NAME_FLD => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America'},5);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {                                        
            
            final List<Territory2> terrLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                 
            
            UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                'ObjectID' => new List<Id>{accLst[0].Id,accLst[1].Id,accLst[2].Id,accLst[3].Id,accLst[4].Id} ,
                    'Territory2ID' => new List<Id>{terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id}, 
                        'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},5);                                                                          
        }                                
        Test.startTest();            						                        
        UCB_TestDataFactory.createSObjectList('Order', new Map<String,Object> {
            'AccountId' => new List<ID>{accLst[0].Id,accLst[1].Id,accLst[2].Id}},3);              
        Test.stopTest();
        final list<order> crtdOrdLst = [select id,ownerid,AccountID from order where EffectiveDate=:TODAY AND Status='Draft'];
        system.debug('crtdOrdLst==>>'+crtdOrdLst);
        //System.assertEquals(null, crtdOrdLst.size(),'Order creation failed');
        
    }    
}