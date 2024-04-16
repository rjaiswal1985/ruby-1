/**
* Name: CM_AccountRelationshipTriggerHelperTest
* Copyright © Align Tech
* Purpose : Test class for CM_AccountRelationshipTriggerHelperTest
* 
*/
/***********************************************************************************************************************
History

VERSION         AUTHOR                          DATE                DETAIL
1.0             Sruthi M                        11/03/2024          Test class for CM_AccountRelationshipTriggerHelper
***********************************************************************************************************************/
@isTest
private class CM_AccountRelationshipTriggerHelperTest {
	@testSetup static void setup() {
		Test.loadData(Customer_Master_Configurations__c.sObjectType, 'CustomerMasterConfigurations');
		UCB_TestDataFactory.createSObjectList('Account', new Map<String, Object>{ 'Name' => 'Test Acc', 'Operating_Units__c' => '4050_Exocad_America' }, 6);
	}
    @isTest 
    static void negativeTestResult() {
        final List<Account> accList= [Select Name,Operating_Units__c from Account Limit 10 ];

		Test.startTest();  

		UCB_TestDataFactory.createSObjectList('Account_Relationship__c', new Map<String, Object>{ 'From_Account__c' => new List<ID>{ accList[0].Id, accList[1].Id, accList[2].Id }, 'To_Account__c' => new List<ID>{ accList[4].Id, accList[5].Id, accList[3].Id } }, 3);

		Test.stopTest();

        final List<Account_Relationship__c> relatiosnhips= [Select Id from Account_Relationship__c Limit 10];
        System.assertEquals(relatiosnhips.size(),3,'Account relationship created');

	}
}