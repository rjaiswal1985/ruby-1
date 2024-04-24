/***********************************************************************************************************************
* Name: CM_AccountUpdateCaptureTrigger_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Test class for account change event - account inactivation
* TestClass : CM_AccountUpdateCaptureTrigger_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        17/04/2024          Test Class
***********************************************************************************************************************/
@isTest
public class CM_AccountUpdateCaptureTrigger_Test{

    /* Name field */
    final static String NAME_FLD = 'Name';
    /**
* @description: testdata set up
*/
    @TestSetup
    static void createTestData(){

        UCB_TestDataFactory.createSObjectList('User', new Map<String, Object>{ 'Username' => new List<String>{ 'test123456789@mycompany.dv01', 'test123456789@mycompany.dv02', 'test123456789@mycompany.dv03', 'test123456789@mycompany.dv04' }, 'ProfileId' => new List<Id>{ UserInfo.getProfileId(), UserInfo.getProfileId(), UserInfo.getProfileId(),  UserInfo.getProfileId() }, 'CommunityNickname' => new List<String>{ 'testUser01', 'testUser02', 'testUser03', 'testUser04' } }, 4);
                    
        final List<User> userLst = [select id, Username
                                        from user
                                        where Username like '%test123456789@mycompany%'];
        UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 
            'Name' => new List<String>{ 'Test Acc1', 'Test Acc2','Test Acc3','Test Acc4','Test Acc5'},
                'Operating_Units__c' => new List<String>{'4050_Exocad_America','4050_Exocad_America','4050_Exocad_America',
                    '4050_Exocad_America','4050_Exocad_America'} }, 5);
            
            final List<Account> accLst = [select id,name from Account where name like'Test Acc%'];
            system.debug('accLst==>>'+accLst);
           	
        	UCB_TestDataFactory.createSObjectList('Contact', new Map<String, Object>{ 
            'FirstName' => new List<String>{ 'Test', 'Test','Test','Test','Test'},
                'LastName' => new List<String>{ 'Cont1', 'Cont2','Cont3','Cont4','Cont5'},
                'AccountID' => new List<String>{accLst[0].Id,accLst[1].Id,accLst[2].Id,
                    accLst[3].Id,accLst[4].Id} }, 5); 
        	
        	 /*final List<Contact> conLst = UCB_TestDataFactory.createSObjectList('Contact', new Map<String, Object>{ 
            'FirstName' => new List<String>{ 'Test', 'Test','Test','Test','Test'},
                'LastName' => new List<String>{ 'Cont1', 'Cont2','Cont3','Cont4','Cont5'}}, 5,false);      	        	
        	        
        	UCB_TestDataFactory.SObjectManager sObjManager = new UCB_TestDataFactory.SObjectManager('Case');
        	sObjManager.setChildParentRelationship(conLst,accLst,'Account');*/   
        
        	
        	/*UCB_TestDataFactory.('AccountContactRelation', new Map<String, Object>{ 
            'AccountId' => new List<String>{accLst[0].Id, accLst[1].Id,accLst[2].Id,accLst[3].Id,accLst[4].Id},
                'ContactId' => new List<String>{ conLst[0].Id, conLst[1].Id,conLst[2].Id,conLst[3].Id,conLst[4].Id},
                     'Status__c' => new List<String>{ 'Active', 'Active', 'Active', 'Active', createSObjectList'Active'},
                         'Relationship_Type__c' => new List<String>{ 'Member', 'Member', 'Member', 'Member', 'Member'}
            }, 5);*/
        	
        	final List<AccountContactRelation> accConRel = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst];
             system.debug('accConRel==>>'+accConRel);
        final List<AccountContactRelation> accConRelLst2 = new List<AccountContactRelation>();
        for(AccountContactRelation accCon: accConRel) {
            accCon.Relationship_Type__c = 'Member';
            accCon.Status__c = 'Active';
            accConRelLst2.add(accCon);
        }
        update accConRelLst2;
        system.debug('accConRelLst2==>>'+accConRelLst2);
        final List<AccountContactRelation> accConRel2 = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst];
        system.debug('accConRel2==>>'+accConRel2);
    }
    
    /*
* @description : inactivate direct account
*/
    @isTest
    static void accountInactivation(){

        final List<Account> accLst = [select id,name from Account where name like'Test Acc%'];
        final List<Contact> conLst = [select id,FirstName from Contact where FirstName like'Test%'];
        
        conLst[1].AccountID = accLst[0].Id;
        update conLst[1];
        
        final List<AccountContactRelation> accConRel = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst];
        system.debug('accLst==>>'+accLst);
        system.debug('conLst==>>'+conLst);
        system.debug('accConRel==>>'+accConRel);
        

    }

            
}