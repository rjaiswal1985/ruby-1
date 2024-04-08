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
public class CRM_AssetTriggerHandler_Test {
    
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
        final Profile srvceProfID = [SELECT Id FROM Profile WHERE Name='Baseline Service Profile' Limit 1];
        UCB_TestDataFactory.createSObjectList('User', new Map<String,Object> {
            'Username' => new List<String>{'test123456789@mycompany.dv01','test123456789@mycompany.dv02','test123456789@mycompany.dv03','test123456789@mycompany.dv04'},
                'ProfileId' => new List<Id>{UserInfo.getProfileId(),UserInfo.getProfileId(),UserInfo.getProfileId(),srvceProfID.Id},
                'CommunityNickname' => new List<String>{'testUser01','testUser02','testUser03','testUser04'}},4);
          
        final List<User> userLst1 = [select id,Username from user where Username like '%test123456789@mycompany%'];
        insert new PermissionSetAssignment (
             AssigneeId =userLst1[3].Id,
             PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Service_Base_Permission_Set'][0].Id);    
        update userLst1[3];
        
        System.RunAs(new user(ID = UserInfo.getUserID())) {
            final List<User> userLst = [select id,Username from user where Username like '%test123456789@mycompany%'];
            final List<Account> accLst = UCB_TestDataFactory.createSObjectList('Account',new Map<String,Object>{
                'Name' => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America'},5);   
            
            final List<Order> ordLst = UCB_TestDataFactory.createSObjectList('Order', new Map<String,Object> {
                'AccountId' => new List<ID>{accLst[0].Id,accLst[1].Id,accLst[2].Id},
                    'OwnerId' => new List<ID>{userLst[0].Id,userLst[0].Id,userLst[0].Id},
                        'EffectiveDate'=> new List<Date>{TODAY,TODAY,TODAY},
                            'Status'=> new List<string>{'Draft','Draft','Draft'}},3);    
        }            
        
    }
    /*
* @description : Create Asset, check asset owner updated
*/
    @isTest
    static void createExocadAsset() {
        
        final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
        
        final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
        
        final List<order> ordLst = [select id,ownerid from order where status ='Draft'];
        system.debug('ordLst==>>'+ordLst);
        
        Test.startTest();
        UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
            'AccountId' => new List<ID>{accLst[0].Id,accLst[1].Id,accLst[2].Id},                
                'Order__c' => new List<ID>{ordLst[0].Id,ordLst[1].Id,ordLst[2].Id},                    
                    'Status'=> new List<string>{'Purchased','Purchased','Purchased'}},3); 
        Test.stopTest();
        final List<Asset> assetLst = [select id,ownerid,Order__c from Asset where status ='Purchased']; 
        system.debug('assetLst==>>'+assetLst);
        System.assertEquals(assetLst[0].ownerId, ordLst[0].ownerId,'Asset owner updated');
    }
    /*
* @description : Create Asset, to check Exception
*/
    @isTest
    static void createAsset2() {
        
        final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
        
        final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
        
        final List<order> ordLst = [select id,ownerid from order where status ='Draft'];
        system.debug('ordLst==>>'+ordLst);
        
        Test.startTest();
        try {
            UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {             
                'Order__c' => new List<ID>{ordLst[0].Id,ordLst[0].Id,ordLst[0].Id},                    
                    'Status'=> new List<string>{'Installed','Installed','Installed'}},3); 
        } Catch(Exception excp){
            //system.assert(excp.getMessage().contains('Every asset needs an organization, a person, or both.'),'Excpetion caught');
            system.assert(excp.getMessage().contains('Unable to insert "Asset" records:'),'Excpetion caught');
            //system.assertEquals(excp.getMessage(),'Unable to insert "Asset" records:','Excpetion caught');
        }    
        Test.stopTest();
        final List<Asset> assetLst = [select id,ownerid from Asset where status ='Installed']; 
        system.debug('assetLst==>>'+assetLst);
        System.assertEquals(0, assetLst.size(),'Asset not created');
    }    
    
    /*
* @description : Create Asset, check asset owner updated
*/
    @isTest
    static void platformEventException() {
        try{
        final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
        system.debug('accLst==>>'+accLst);
        final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
        system.debug('no of users==>>'+userLst2.size());
        final List<order> ordLst = [select id,ownerid from order where status ='Draft'];
        system.debug('ordLst==>>'+ordLst);
        final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
                'AccountId' => new List<ID>{accLst[0].Id,accLst[0].Id,accLst[0].Id}, 
                    'Order__c' => new List<ID>{ordLst[0].Id,ordLst[0].Id,ordLst[0].Id},                    
                        'Status'=> new List<string>{'Installed','Installed','Installed'}},3,false); 
        
        List<AccountShare> accShareLst = new List<AccountShare>();
            for(Account acc : accLst){
            	AccountShare accShare= new AccountShare();
                accShare.AccountId = acc.Id;
                accShare.AccountAccessLevel='Read';
                accShare.UserOrGroupId = userLst2[3].Id;
                accShare.RowCause='manual';
                accShare.OpportunityAccessLevel='Read';
                accShareLst.add(accShare);
            } 
        insert accShareLst;    
        Test.startTest();
			//Test.setMock(CRM_AssetService.class, new MockAssetService());
			//UCB_Trigger.TriggerContext trgCtx ;     	              			
        	//CRM_AssetTriggerHandler.afterTrigger(trgCtx);
        	//CRM_AssetTriggerHandler asstTgr = new CRM_AssetTriggerHandler();
            //asstTgr.trgContextStr = 'TestCreateAssetsExcp';
        system.runAs(userLst2[3]){

        	insert asstLst;    
        }
        	
        Test.stopTest();
        } Catch(Exception excp) {
        	system.debug('user access excp==>>'+excp.getMessage());    
        }
		final List<Exception_Handling__c> excpLst = [select id,Module__c from Exception_Handling__c where Module__c	 = 'Asset Owner Update']; 
        system.debug('excpLst==>>'+excpLst);
    }
    
    public class MockAssetService {
        public void publishAssetEvent(List<Asset> assetLst , String trigContext){
        	throw new CustomException('Simulated Exception');    
        }
    }
    public class CustomException extends Exception{}
    
        /*
* @description : check platform event failure callback
*/
    @isTest
    static void exocadAssetPlatformEventFailure() {               
            
    	final List<Account> accLst = [select id,Name,ownerID from Account where name like '%Test%'];
        final List<Order> ordLst = [select id,ownerID from Order where Status= 'Draft'];
        final List<User> userLst2 = [select id,Username from user where Username like '%test123456789@mycompany%'];
            
        final List<Asset> asstLst = UCB_TestDataFactory.createSObjectList('Asset', new Map<String,Object> {
        'Name' => 'Test Asset',
                    'AccountId' => accLst[0].Id,           
                    'Order__c'=> ordLst[0].Id,'Status'=> 'Draft'},30);             
            
       final List<CRM_Asset_Event__e> asstEvntLst = UCB_TestDataFactory.createSObjectList('CRM_Asset_Event__e',new Map<String,Object> {
                'Order_ID__c' => ordLst[1].Id,'Asset_ID__c'=>asstLst[2].Id,'Asset_Event_Type__c'=>'Create_Asset'},5,false); 
       system.debug('asstEvntLst==>>'+asstEvntLst);
            
       //Test.startTest();
        //PlatformEventFailureCallback callbck = new PlatformEventFailureCallback();
       	Database.SaveResult[] sr = EventBus.publish(asstEvntLst);
        //Test.getEventBus().deliver();        
        Test.getEventBus().fail();
       //Test.stopTest(); 
       for (Database.SaveResult sr1 : sr) {
        if (sr1.isSuccess()) {
            System.debug('Successfully enqueued event.');
        } else {
            for(Database.Error err : sr1.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + 
                    err.getMessage());
            }
        }
    }

    }
}