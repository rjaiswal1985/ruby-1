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
            
           UCB_TestDataFactory.createSObjectList('Contact', new Map<String, Object>{ 
            'FirstName' => new List<String>{ 'Test', 'Test','Test','Test','Test'},
                'LastName' => new List<String>{ 'Cont1', 'Cont2','Cont3','Cont4','Cont5'},
                'AccountID' => new List<String>{accLst[0].Id,accLst[1].Id,accLst[2].Id,
                    accLst[3].Id,accLst[4].Id} }, 5);  
                   
        
    }
    
    /*
* @description : inactivate direct account
*/
    @isTest
    static void accountInactivation(){

        final List<Account> accLst = [select id,name from Account where name like'Test Acc%'];
        
        final List<AccountContactRelation> accConRel = [select AccountId,ContactId,isDirect
                                                        from AccountContactRelation where AccountId IN:accLst];
        
        system.debug('accConRel==>>'+accConRel);
        

    }

            
}