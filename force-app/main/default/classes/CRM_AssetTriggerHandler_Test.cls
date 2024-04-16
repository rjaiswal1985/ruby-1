/***********************************************************************************************************************
* Name: CRM_AssetTriggerHandler_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on Asset
* TestClass : CRM_AssetTriggerHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        12/03/2024          Test Class
***********************************************************************************************************************/
@isTest
public class CRM_AssetTriggerHandler_Test{
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
    static void createTestData(){
        final Profile srvceProfID = [SELECT Id
                                     FROM Profile
                                     WHERE Name = 'Baseline Service Profile'
                                     Limit 1];
        UCB_TestDataFactory.createSObjectList('User', new Map<String, Object>{ 'Username' => new List<String>{ 'test123456789@mycompany.dv01', 'test123456789@mycompany.dv02', 'test123456789@mycompany.dv03', 'test123456789@mycompany.dv04' }, 'ProfileId' => new List<Id>{ UserInfo.getProfileId(), UserInfo.getProfileId(), UserInfo.getProfileId(), srvceProfID.Id }, 'CommunityNickname' => new List<String>{ 'testUser01', 'testUser02', 'testUser03', 'testUser04' } }, 4);
        
        final List<User> userLst1 = [select id, Username
                                     from user
                                     where Username like '%test123456789@mycompany%'];
        insert new PermissionSetAssignment(
            AssigneeId = userLst1[3].Id, 
            PermissionSetId = [SELECT Id
                               FROM PermissionSet
                               WHERE Name = 'Service_Base_Permission_Set'][0].Id
        );
        update userLst1[3];
        
        System.RunAs(new user(
            ID = UserInfo.getUserID()
        )){
            Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
            final List<User> userLst = [select id, Username
                                        from user
                                        where Username like '%test123456789@mycompany%'];
            //final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 'Name' => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America' }, 5);
            
            //final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String, Object>{ 'AccountId' => new List<ID>{ accLst[0].Id, accLst[1].Id, accLst[2].Id }, 'OwnerId' => new List<ID>{ userLst[0].Id, userLst[0].Id, userLst[0].Id }, 'EffectiveDate' => new List<Date>{ TODAY, TODAY, TODAY }, 'Status' => new List<string>{ 'Draft', 'Draft', 'Draft' } }, 3);
            
            final Territory2Model trtyModel = (Territory2Model)UCB_TestDataFactory.createSObject('Territory2Model',new Map<String,Object>{
                'DeveloperName' => 'TestModel',NAME_FLD=>'TestModel'},true);            
            
            final List<Territory2Type> terriType = [SELECT id, DeveloperName from Territory2Type LIMIT 1];                    
            
            final List<Territory2> terrLst = UCB_TestDataFactory.createSObjectList('Territory2',new Map<String,Object>{
                'DeveloperName' => new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},'Territory2ModelId' => new List<Id>{trtyModel.Id,trtyModel.Id,trtyModel.Id}, NAME_FLD=> new List<String>{'TestExocadAmericas','TestExocadGmbh','TestInvisalignAmerica'},
                    'Territory2TypeId'=> new List<Id>{terriType[0].Id,terriType[0].Id,terriType[0].Id},'Business_unit__c' => new List<String>{'exocad','exocad','invisalign'} },3);             
            
            UCB_TestDataFactory.createSObjectList('UserTerritory2Association',new Map<String,Object>{
                'RoleInTerritory2' =>new List<String>{'Primary Owner', 'Primary Owner'},'Territory2ID' =>new List<Id>{terrLst[0].Id, terrLst[1].Id},'UserId'=> new List<Id>{userLst[0].Id,userLst[3].Id} },2);
            
        }
    }
    
    /*
* @description : Create Asset, check asset owner updated
*/
    @isTest
    static void createExocadAsset(){
        final List<User> userLst = [select id, Username
                                    from user
                                    where Username like '%test123456789@mycompany%'];
        final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 'Name' => 'Test Acc', 
            'Operating_Units__c' => '4050_Exocad_America',
            'OwnerId' => userLst[0].Id }, 5);
        
        final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String, Object>{ 'AccountId' => new List<ID>{ accLst[0].Id, accLst[1].Id, accLst[2].Id }, 
            'OwnerId' => new List<ID>{ userLst[0].Id, userLst[0].Id, userLst[0].Id }, 
                'EffectiveDate' => new List<Date>{ TODAY, TODAY, TODAY }, 
                    'Status' => new List<string>{ 'Draft', 'Draft', 'Draft' } }, 3);
        
        
        
        /*final List<order> ordLst = [select id, ownerid
from order
where status = 'Draft'];*/
        system.debug('ordLst==>>' + ordLst);
        
        Test.startTest();
        
        UCB_TestDataFactory.createSObjectList('Asset', new Map<String, Object>{ 'AccountId' => new List<ID>{ accLst[0].Id, accLst[1].Id, accLst[2].Id }, 
            'Order__c' => new List<ID>{ ordLst[0].Id, ordLst[1].Id, ordLst[2].Id }, 
                'Status' => new List<string>{ 'Purchased', 'Purchased', 'Purchased' } }, 3);
        
        Test.stopTest();
        final List<Asset> assetLst = [select id, ownerid, Order__c
                                      from Asset
                                      where status = 'Purchased'];
        system.debug('assetLst==>>' + assetLst);
        System.assertEquals(assetLst[0].ownerId, ordLst[0].ownerId,'Asset owner updated');
    }
    
    /*
* @description : Create Asset, check asset owner updated
*/
    @isTest
    static void platformEventException(){     
            final List<User> userLst = [select id, Username
                                        from user
                                        where Username like '%test123456789@mycompany%'];
            system.debug('userLst==>>'+userLst);
            
            final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 'Name' => 'Test Acc', 
                'Operating_Units__c' => '4050_Exocad_America',
                'OwnerId' => userLst[3].Id }, 5);
            system.debug('accLst==>>'+accLst);
            
            final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String, Object>{ 'AccountId' => new List<ID>{ accLst[0].Id, accLst[1].Id, accLst[2].Id }, 
                'OwnerId' => new List<ID>{ userLst[3].Id, userLst[3].Id, userLst[3].Id }, 
                    'EffectiveDate' => new List<Date>{ TODAY, TODAY, TODAY }, 
                        'Status' => new List<string>{ 'Draft', 'Draft', 'Draft' } }, 3);
            
            system.debug('ordLst==>>'+ordLst);    
            
            System.RunAs(new user(ID = UserInfo.getUserID())) {                                        
                
                final List<Territory2> terrLst = [select id,DeveloperName,Territory2TypeId,Business_unit__c from Territory2 where DeveloperName like 'Test%'];                 
                
                UCB_TestDataFactory.createSObjectList('ObjectTerritory2Association',new Map<String,Object>{
                    'ObjectID' => new List<Id>{accLst[0].Id,accLst[1].Id,accLst[2].Id,accLst[3].Id,accLst[4].Id} ,
                        'Territory2ID' => new List<Id>{terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id,terrLst[0].Id}, 
                            'AssociationCause'=> new List<String>{ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE,ASC_CAUSE}},5);                                                                          
            }
            final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String, Object>{ 'AccountId' => new List<ID>{ accLst[0].Id, accLst[0].Id, accLst[0].Id }, 
                'Order__c' => new List<ID>{ ordLst[0].Id, ordLst[0].Id, ordLst[0].Id }, 
                    'Status' => new List<string>{ 'Installed', 'Installed', 'Installed' } }, 3, false);
            
            Test.startTest();
            system.runAs(userLst[3]){
                insert asstLst;
            }
            List<Asset> asstLst2 = [select id,ownerId from Asset where Status='Installed'];
            system.debug('asstLst2==>>'+asstLst2);
            Test.stopTest();
         final List<Exception_Handling__c> excpLst = [select id,Module__c from Exception_Handling__c where Module__c = 'Asset Owner Update']; 
         system.debug('excpLst==>>'+excpLst); 
         Assert.areEqual(excpLst.size(),1,'Exception thrown');
    }
            
}