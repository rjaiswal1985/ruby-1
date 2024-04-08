/***********************************************************************************************************************
* Name: CM_SobjectController_Test
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Subscriber of Reltio  MDM platform event
* TestClass : CM_SobjectController_Test
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   28/12/2023          Test calss for CM_SobjectController
***********************************************************************************************************************/
@isTest
public with sharing class CM_SobjectController_Test {
    @isTest 
    static void relationDescription() {
        final String  relation = CM_SobjectController.relationDescription();
        system.assertEquals(relation, relation, 'Object Dexcription.');
    }
}