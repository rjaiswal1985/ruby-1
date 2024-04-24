/***********************************************************************************************************************
 * Name: CM_ReltioConstants
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio  MDM HCO platform event
 * TestClass : CM_ReltioConstants
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                        11/12/2023          Class having Consonants.
 ***********************************************************************************************************************/
public with sharing class CM_ReltioConstants {
    /* Get all the Replay   record */
    final public Static Map < String, Customer_Master_Configurations__c > PAYLOADSETTING = Customer_Master_Configurations__c.getAll();
    /* String for ATTRIBUTES       */
    public static final String RELTIOHCO = PAYLOADSETTING.get('ReltioHCOService').Constant_value__c;
    /* String for ATTRIBUTES       */
    public static final String RELTIOHCPHCO = PAYLOADSETTING.get('ReltioHCPHCOService').Constant_value__c;
    /* String for ATTRIBUTES       */
    public static final String RELTIOHCOHCO = PAYLOADSETTING.get('ReltioHCOHCOService').Constant_value__c;
    /* String for ATTRIBUTES */
    public static final String RELTIOHCP = PAYLOADSETTING.get('ReltioHCPService').Constant_value__c;
    /* String for VALUE       */
    public static final String STARTOBJECT = PAYLOADSETTING.get('startObjectDetails').Constant_value__c;
    /* String for VALUE       */
    public static final String ENDOBJECT = PAYLOADSETTING.get('endObjectDetails').Constant_value__c;
    /* String for ATTRIBUTES       */
    public static final String ACCCONRELALIONS = 'AccountContactRelationshipService';
    /* String for ATTRIBUTES       */
    public static final String ACCRELALIONSERV = PAYLOADSETTING.get('AccountRelationshipService').Constant_value__c;
    /* String for ATTRIBUTES   */
    public static final String ATTRIBUTES = PAYLOADSETTING.get('attributes').Constant_value__c;
    /* String for the Primary Phone */
    public static final String PRIMARYPHONE = PAYLOADSETTING.get('PRIMARYPHONE').Constant_value__c;
    /* String for the Primary Email */
    public static final String PRIMARYEMAIL = PAYLOADSETTING.get('PRIMARYEMAIL').Constant_value__c;
    /* String for object       */
    public static final String OBJECTSTRING = PAYLOADSETTING.get('object').Constant_value__c;
    /* String for object       */
    public static final String ISAFFILIATED = PAYLOADSETTING.get('ISAFFILIATED').Constant_value__c;
     /* String for object       */
     public static final String ENTITYUPDATED = PAYLOADSETTING.get('ENTITYUPDATED').Constant_value__c;
     /* String for Value       */
     public static final String ASSETCREATED = PAYLOADSETTING.get('ASSETCREATED').Constant_value__c;
     /* String for Value       */
     public static final String ORDERCREATED = PAYLOADSETTING.get('ORDERCREATED').Constant_value__c;
    /* String for VALUE       */
    public static final String VALUE = 'value';
    /* String for VALUE       */
    public static final String MASTER = 'Master';
    /* String for VALUE       */
    public static final String DATESTRING = 'DATE';
    /* String for VALUE       */
    public static final String MDMID = 'MDM_Id__c';
    /* String for VALUE       */
    public static final String URI = 'uri';
    /* String for VALUE       */
    public static final String DOUBLESTRING = 'double';
    /* String for VALUE       */
    public static final String MULTIPICKLIST = 'multipicklist';

    private CM_ReltioConstants() {}
}