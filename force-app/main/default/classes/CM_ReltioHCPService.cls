/***********************************************************************************************************************
 * Name: CM_ReltioHCPService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Service class handles Contact Creation, Service invoked from platform event trigger handler
 * TestClass : CM_ReltioHCPService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   07/11/2023          Contact Creation Service 
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHCPService {
    /* Contact String */
    final static string CONTACTSTRING = 'Contact';
    /* Contact Communication String */
    final static string PERCOMMUNICATION = 'Person_Communication__c';
    /* Education Detail String */
    final static string EDUDETAILS = 'Educational_Detail__c';
    /* Education Detail String */
    final static string LICINFORMATION = 'License_Information__c';
    /**    
     * @description :  Method to parse input json and get Contact data
     * Parameters : input json, process name from platfrom event
     */
    public static CM_ReltioHandlerService.OBJECTPARSER upsertHCPServices(String inputJson, Map < String, CM_ReltioHandlerService.SobjectData > process2Metadata) {        
        final CM_ReltioHandlerService.JSPARSER parser = CM_JSONParser.objectJsonParser(inputJson, process2Metadata.get(CM_ReltioConstants.RELTIOHCP));
        final CM_ReltioHandlerService.OBJECTPARSER objParser = new CM_ReltioHandlerService.OBJECTPARSER() ;
        objParser.resultMap=upsertHCPSelector(parser.key2value);
        objParser.apiType=parser.apiType;
        return objParser;
    }

    /**     
     * @description : Retrieves data of Contact and related sobjects
     */
    public static Map < String, Map < String, Sobject >> upsertHCPSelector(Map < String, Map < String, Map < String, Object >>> key2value) {
        final Map < String, Map < String, Sobject >> resultMap = new Map < String, Map < String, Sobject >> ();
        Contact contact = CM_ContactService.upsertContact(key2value.get(CONTACTSTRING));
        Map < String, Person_Communication__c > commInfoMap = new Map < String, Person_Communication__c > ();
        final Map < String, Contact > contactMap = new Map < String, Contact > ();

        //person communication information
        if (key2value.containsKey(PERCOMMUNICATION)) {
            commInfoMap = CM_PersonCommunicationService.upsertHCPcommunicationInfo(key2value.get(PERCOMMUNICATION), contact);
            resultMap.put(PERCOMMUNICATION, commInfoMap);
        }

        if (key2value.containsKey(EDUDETAILS)) {
            final Map < String, Educational_Detail__c > hcpEduMap = CM_EducationalDetailsService.upsertEducationalDetails(key2value.get(EDUDETAILS), contact);
            resultMap.put(EDUDETAILS, hcpEduMap);
        }

        if (key2value.containsKey(LICINFORMATION)) {
            final Map < String, License_Information__c > hcpLicenseInfoMap = CM_LicenseInformationService.upsertLicenseInformationDetails(key2value.get(LICINFORMATION), contact);
            resultMap.put(LICINFORMATION, hcpLicenseInfoMap);
        }

        //update phone and email in the contact from Communication Information
        contact = getContactList(contact, commInfoMap.values());
        contactMap.put(contact.MDM_Id__c, contact);
        resultMap.put(CONTACTSTRING, contactMap);
        return resultMap;
    }
    /**     
     * @description : Populates Contact primary phone, email
     */
    private static contact getContactList(Contact contact, List < Person_Communication__c > personInfoList) {
        for (Person_Communication__c hcpInfo: personInfoList) {
            if (hcpInfo.Subtype__c == CM_ReltioConstants.PRIMARYPHONE) {
                contact.Phone = hcpInfo.value__c;
            }
            if (hcpInfo.Subtype__c == CM_ReltioConstants.PRIMARYEMAIL) {
                contact.Email = hcpInfo.value__c;
            }
        }
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_1__c,true);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_2__c,false);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_3__c,false);
        contact.MailingStreet = CM_ReltioHandlerService.addressLine(contact.MailingStreet,contact.Address_Line_4__c,false);

        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s,contact.Native_Address_Line_1__c,true);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_2__c,false);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_3__c,false);
        contact.Native_Address__Street__s  = CM_ReltioHandlerService.addressLine(contact.Native_Address__Street__s ,contact.Native_Address_Line_4__c,false);
        return contact;
    }
    /**    
 * @description :  Method to get the Old Contact Map
 * Parameters : Map of new Records
 */
    public  static Map<String, Map < String, Sobject >> getOldContactMap(Map <String, Map < String, Sobject >> upsertNewMap) {
        final Set<String> recordId = upsertNewMap.get(CONTACTSTRING).keyset();
        final Map <String, Map < String, Sobject >> upsertOldMap = new Map < String, Map < String, Sobject >> ();
        upsertOldMap.put(CONTACTSTRING,new Map <String, Sobject>());  
        upsertOldMap.put(EDUDETAILS,new Map <String, Sobject>());  
        upsertOldMap.put(PERCOMMUNICATION,new Map <String, Sobject>());  
        upsertOldMap.put(LICINFORMATION,new Map <String, Sobject>()); 
        for(Contact con : [Select Id,MDM_Id__c,TimeStamp_Decimal__c,Account.MDM_Id__c,
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Educational_Details__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from Person_Communications__r),
            (Select Id,MDM_Id__c,Contact__r.MDM_Id__c,TimeStamp_Decimal__c from License_Informations__r) 
            from Contact where MDM_Id__c = :recordId with SECURITY_ENFORCED]) {
            upsertOldMap.get(CONTACTSTRING).put(con.MDM_Id__c,con);
            for(Educational_Detail__c education : con.Educational_Details__r) {
                upsertOldMap.get(EDUDETAILS).put(education.MDM_Id__c,education);  
            }
            for(Person_Communication__c communication: con.Person_Communications__r) {
                upsertOldMap.get(PERCOMMUNICATION).put(communication.MDM_Id__c,communication); 
            }
            for(License_Information__c licence: con.License_Informations__r) {
                upsertOldMap.get(LICINFORMATION).put(licence.MDM_Id__c,licence); 
            }
        }
        return upsertOldMap;
    }
    private CM_ReltioHCPService() {}
}