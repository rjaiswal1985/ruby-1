/***********************************************************************************************************************
* Name: CRM_AssetEventSubcriberHandler_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Handles the triggered events on order
* TestClass : CRM_AssetEventSubcriberHandler_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        18/03/2024          Test Class 
***********************************************************************************************************************/
@isTest
public class CRM_AssetEventSubcriberHandler_Test {
    
    /**
* @description: testdata set up 
*/     
    @TestSetup
    static void createTestData() {       
        final List<User> userLst1 = UCB_TestDataFactory.createSObjectList('User', new Map<String,Object> {
            'Username' => new List<String>{'test123456789@mycompany.dv01','test123456789@mycompany.dv02','test123456789@mycompany.dv03'},'ProfileId' => new List<Id>{UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId()},
                'CommunityNickname' => new List<String>{'testUser01','testUser02','testUser03'}},3);
        
        System.RunAs(new user(ID = UserInfo.getUserID())) { 
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];            
            
            final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account',new Map<String,Object>{
                'Name' => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America','OwnerId'=>userLst2[0].Id},5);   
            
            final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String,Object> {
                'AccountId' =>accLst[0].Id,'OwnerId' => userLst2[0].Id,
                    'EffectiveDate'=>Date.newInstance(2024,03,12),
                    'Status'=> 'Draft'},3);                                               
        }                    
    }    
    
    /*
* @description : Asset trigger handler for after insert
*/
    @isTest
    static void testAssetEventSubscriber() {         
        try{
            
            final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
            final List<Order> ordLst = [select id,ownerID from Order where Status= 'Draft'];
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
            
            final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
                'Name' => 'Test Asset',
                    'AccountId' => accLst[0].Id,           
                    'Order__c'=> ordLst[0].Id,'Status'=> 'Draft'},3);             
            
            final List<CRM_Asset_Event__e> asstEvntLst = UCB_TestDataFactory.createSObjectList('CRM_Asset_Event__e',new Map<String,Object> {
                'Order_ID__c' => ordLst[0].Id,'Asset_ID__c'=>asstLst[0].Id,'Asset_Event_Type__c'=>'Create_Asset'},5,false); 
            system.debug('asstEvntLst==>>'+asstEvntLst);
            
            Test.startTest();
            Database.SaveResult[] sr = EventBus.publish(asstEvntLst);
            Test.stopTest();
            system.debug('save result==>>'+sr);
            for(Database.SaveResult res : sr){
                system.debug('result==>>'+res);
                System.assertEquals(true, res.isSuccess());
            }
            
            ID ordOwnerID = [select id,AccountId,Account.ownerID,ownerId from order Limit 1].ownerID;
            Id accOwnerID = [select id,ownerid from Account limit 1].ownerId;
            system.debug('ordOwnerID==>>'+ordOwnerID);
            system.debug('accOwnerID==>>'+accOwnerID);
            
            
        } Catch(Exception excp) {
            system.debug('Exception==>>'+excp.getMessage());
            system.debug('Exception==>>'+excp.getStackTraceString());    
        }
    }
 
    /*
* @description : Asset trigger handler for after insert
*/
    @isTest
    static void testAssetEventSubscriber2() {         
        try{
            
            final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
            final List<Order> ordLst = [select id,ownerID from Order where Status= 'Draft'];
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
            
            final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
                'Name' => 'Test Asset',
                    'AccountId' => accLst[0].Id,'ownerId' => userLst2[2].Id,         
                    'Order__c'=> ordLst[0].Id,'Status'=> 'Draft'},3);             
            system.debug('asstLst==>>'+asstLst);
            final List<CRM_Asset_Event__e> asstEvntLst = UCB_TestDataFactory.createSObjectList('CRM_Asset_Event__e',new Map<String,Object> {},5,false); 
            system.debug('asstEvntLst==>>'+asstEvntLst);
            
            Test.startTest();
            Database.SaveResult[] sveRslt = EventBus.publish(asstEvntLst);            
            Test.stopTest();
            //system.debug('save result==>>'+sveRslt);
            for(Database.SaveResult res : sveRslt){
                system.debug('result==>>'+res);
                System.assertEquals(false, res.isSuccess());
            }
            
            ID ordOwnerID = [select id,AccountId,Account.ownerID,ownerId from order Limit 1].ownerID;
            Id accOwnerID = [select id,ownerid from Account limit 1].ownerId;
            system.debug('ordOwnerID==>>'+ordOwnerID);
            system.debug('accOwnerID==>>'+accOwnerID);
            
            
        } Catch(Exception excp) {
            system.debug('Exception==>>'+excp.getMessage());
            system.debug('Exception==>>'+excp.getStackTraceString());    
        }
    }
    
    /*
* @description : Asset trigger handler for after insert
*/
    @isTest
    static void testAssetEventSubscriber3() {         
        try{
            
            final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
            final List<Order> ordLst = [select id,ownerID from Order where Status= 'Draft'];
            final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
            
            final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
                'Name' => 'Test Asset',
                    'AccountId' => accLst[0].Id,'ownerId' => userLst2[2].Id,         
                    'Order__c'=> ordLst[0].Id,'Status'=> 'Draft'},3);             
            system.debug('asstLst==>>'+asstLst);
            final List<CRM_Asset_Event__e> asstEvntLst = UCB_TestDataFactory.createSObjectList('CRM_Asset_Event__e',new Map<String,Object> {},5,false); 
            system.debug('asstEvntLst==>>'+asstEvntLst);
            
             FailureAndSuccessCallback cb = new FailureAndSuccessCallback();
            //Test.startTest();
            Database.SaveResult[] sveRslt = EventBus.publish(asstEvntLst,cb);   
            
           
            //Test.stopTest();
             // Fail event 
            // (invoke onFailure and DO NOT deliver event to subscribers)
            Test.getEventBus().fail(); 
            //system.debug('save result==>>'+sveRslt);
            /*for(Database.SaveResult res : sveRslt){
                system.debug('result==>>'+res);
                System.assertEquals(false, res.isSuccess());
            }
            */
            ID ordOwnerID = [select id,AccountId,Account.ownerID,ownerId from order Limit 1].ownerID;
            Id accOwnerID = [select id,ownerid from Account limit 1].ownerId;
            system.debug('ordOwnerID==>>'+ordOwnerID);
            system.debug('accOwnerID==>>'+accOwnerID);
            
            
        } Catch(Exception excp) {
            system.debug('Exception==>>'+excp.getMessage());
            system.debug('Exception==>>'+excp.getStackTraceString());    
        }
    }    
}