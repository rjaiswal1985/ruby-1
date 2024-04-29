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
    final static Date TODAY = Date.today();
    /**
* @description: testdata set up
*/
    @TestSetup
    static void createTestData(){

        UCB_TestDataFactory.createSObjectList('User', new Map<String, Object>{ 'Username' => new List<String>{ 'test123456789@mycompany.dv01', 'test123456789@mycompany.dv02', 'test123456789@mycompany.dv03', 'test123456789@mycompany.dv04' }, 'ProfileId' => new List<Id>{ UserInfo.getProfileId(), UserInfo.getProfileId(), UserInfo.getProfileId(),  UserInfo.getProfileId() }, 'CommunityNickname' => new List<String>{ 'testUser01', 'testUser02', 'testUser03', 'testUser04' } }, 4);
                    
        final List<User> userLst = [select id, Username
                                        from user
                                        where Username like '%test123456789@mycompany%'];
        /*UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 
            'Name' => new List<String>{ 'Test Acc1', 'Test Acc2','Test Acc3','Test Acc4','Test Acc5'},
                'Operating_Units__c' => new List<String>{'4050_Exocad_America','4050_Exocad_America','4050_Exocad_America',
                    '4050_Exocad_America','4050_Exocad_America'} }, 5);*/
        
            UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 
            'Name' => 'Test Acc',
                'Operating_Units__c' => '4050_Exocad_America',
                'Status__c' => 'Active'}, 20);
            
            final List<Account> accLst = [select id,name from Account where name like'Test Acc%'];
            system.debug('accLst==>>'+accLst);
        	system.debug('accLst==>>'+accLst.size());
        
        for(Account acc : accLst) {
           UCB_TestDataFactory.createSObjectList('Contact', new Map<String, Object>{ 
            'FirstName' => 'Test',
                'LastName' =>  'Cont', 
                'Status__c' => 'Active',
                'AccountID' => acc.Id},1); 
        }
         final List<Contact> conLst = [select id,firstname,lastname from Contact where name like'Test Cont%'];  
        system.debug('conLst==>>'+conLst);
        system.debug('conLst==>>'+conLst.size());

        	
        final List<AccountContactRelation> accConRel = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst];
        system.debug('accConRel==>>'+accConRel);
        final List<AccountContactRelation> accConRelLst2 = new List<AccountContactRelation>();
        for(AccountContactRelation accCon: accConRel) {
            accCon.Relationship_Type__c = 'Member';
            accCon.Status__c = 'Active';
            accCon.StartDate = TODAY-10;
            accConRelLst2.add(accCon);
        }
        update accConRelLst2;
        system.debug('accConRelLst2==>>'+accConRelLst2);
        final List<AccountContactRelation> accConRel2 = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst];
        system.debug('accConRel2==>>'+accConRel2);
        
        UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 
            'Name' => 'Test Acc2',
                'Operating_Units__c' => '4050_Exocad_America','Status__c' => 'Active'}, 1);
       final List<Account> accLst2 = [select id,name from Account where name like'Test Acc2%'];
            system.debug('accLst2==>>'+accLst);
        for(Contact con : conLst) {
             UCB_TestDataFactory.createSObjectList('AccountContactRelation', new Map<String, Object>{ 
            'AccountId' => accLst2[0].Id,
                'ContactId' => con.Id,
                     'Status__c' =>  'Active', 
                         'Relationship_Type__c' => 'Owner'}, 1);
        }
        final List<AccountContactRelation> accConRel3 = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c,StartDate
                                                        from AccountContactRelation where AccountId IN:accLst OR AccountId IN:accLst2];
        system.debug('accConRel3==>>'+accConRel3);
        final List<AccountContactRelation> accConRel4 = new List<AccountContactRelation>();
        for(AccountContactRelation accCon : accConRel3) {
          accCon.StartDate = Today-1; 
            accConRel4.add(accCon);
        }
        update accConRel4;
        
                	/*UCB_TestDataFactory.createSObjectList('Contact', new Map<String, Object>{ 
            'FirstName' => new List<String>{ 'Test', 'Test','Test','Test','Test'},
                'LastName' => new List<String>{ 'Cont1', 'Cont2','Cont3','Cont4','Cont5'},
                'AccountID' => new List<String>{accLst[0].Id,accLst[1].Id,accLst[2].Id,
                    accLst[3].Id,accLst[4].Id} }, 5); */
        	
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
    }
    
    /*
* @description : inactivate direct account
*/
   /* @isTest
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
        

    } */

@isTest
    static void acctContRelInactivation(){

        final List<Account> accLst = [select id,name from Account where name like'Test Acc%'];
        final List<Contact> conLst = [select id,FirstName from Contact where FirstName like'Test%'];
        
		system.debug('all accLst ==>>'+accLst.size());
        
        final List<AccountContactRelation> accConRel = [select AccountId,ContactId,isDirect,Relationship_Type__c, Status__c
                                                        from AccountContactRelation where AccountId IN:accLst AND Relationship_Type__c = 'Member'];

        //system.debug('accConRel==>>'+accConRel);
        system.debug('size of accConRel ==>> '+accConRel.size());
        final List<AccountContactRelation> accConRel2 = new List<AccountContactRelation>();
        set<Id> checkQuerySet = new Set<Id>();
        for(AccountContactRelation accCon : accConRel ) {
            system.debug('RelationshipType==>>'+accCon.Relationship_Type__c);
            system.debug('status==>>'+accCon.Status__c);
            system.debug('isDirect==>>'+accCon.isDirect);
        	//accCon.Status__c = 'Inactive'; 
            checkQuerySet.add(accCon.Id);
            accConRel2.add(accCon);            
        }
        system.debug('checkQuerySet==>>'+checkQuerySet);
        set<Id> directContSet = new set<Id>();
        final Map<Id, Contact> contMap = new Map<ID, Contact>([SELECT Id,Status__c FROM Contact
                                                           where Id IN(select contactId from
                                                           AccountContactRelation where Id IN:checkQuerySet AND isDirect = true)                                                                                    
                                                          AND Status__c='Active' WITH SECURITY_ENFORCED]);
        system.debug('contMap==>>'+contMap);
        
        for(AccountContactRelation accConRell : [Select Id,AccountId,ContactID
                            from AccountContactRelation where ID IN :checkQuerySet AND isDirect = true 
                                                AND Contact.Status__c='Active' WITH SECURITY_ENFORCED]) {                            		                              
        	directContSet.add(accConRell.ContactID);                                                                             
        }
        system.debug('directContSet==>>'+directContSet);
        Test.startTest();
        //update accConRel2;
        Test.stopTest();

    } 
            
}