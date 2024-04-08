/***********************************************************************************************************************
 * Name: CM_ReltioHandlerService
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Subscriber of Reltio  MDM HCO platform event
 * TestClass : CM_ReltioHandlerService
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Sruthi M                   11/12/2023          Class invoked from the Subscriber of the Reltio MDM HCO platform event
 ***********************************************************************************************************************/
public with sharing class CM_ReltioHandlerService {
    /**
     * @description : Method to get fieldmappings metadata  
     */
    public Static Map < String, SobjectData> metadataRecords(String relatioProcess) {
        final Map < String, SobjectData > process2Metadata = new Map < String, SobjectData > ();
        Map < Integer, DML_Orchestrator__mdt > dmlMaps;
        Map < String, List < Reltio_Field_Mapping__mdt >> sObj2CusMetadata;
        Map < String, String > srceFld2TargField;
        SobjectData objData;
        final List<String> processList = new List<String>{relatioProcess};
        if(relatioProcess == CM_ReltioConstants.RELTIOHCOPHCO) {
            processList.add(CM_ReltioConstants.RELTIOHCO);   
        } else if(relatioProcess == CM_ReltioConstants.RELTIOHCPHCO) {
            processList.add(CM_ReltioConstants.RELTIOHCO);  
            processList.add(CM_ReltioConstants.RELTIOHCP); 
        } 

        for (Reltio_CM_Process__mdt process: [SELECT DeveloperName, (Select DeveloperName,Source_Parameter__c, Source_Field__c, Source_Object__c,  Target_Field__r.QualifiedApiName, 
                Target_Field__r.DataType, Target_Object__r.QualifiedApiName FROM Reltio_Field_Mapping__r) , 
                (SELECT Ranking__c, External_ID__r.QualifiedApiName, SObject__r.QualifiedApiName FROM Reltio_DML_Orchestrator__r) 
                from Reltio_CM_Process__mdt  where developerName=:processList WITH SECURITY_ENFORCED ]) {
            dmlMaps = new Map < Integer, DML_Orchestrator__mdt > ();
            sObj2CusMetadata = new Map < String, List < Reltio_Field_Mapping__mdt >> ();
            srceFld2TargField = new Map < String, String > ();
            for (Reltio_Field_Mapping__mdt fldMapping: process.Reltio_Field_Mapping__r) {
                if (!sObj2CusMetadata.containsKey(fldMapping.Source_Object__c)) {
                    sObj2CusMetadata.put(fldMapping.Source_Object__c, new List < Reltio_Field_Mapping__mdt > ());
                }
                sObj2CusMetadata.get(fldMapping.Source_Object__c).add(fldMapping);
                srceFld2TargField.put(fldMapping.Source_Object__c, fldMapping.Target_Object__r.QualifiedApiName);
            }
            for (DML_Orchestrator__mdt dmlOrchestrator: process.Reltio_DML_Orchestrator__r) {
                dmlMaps.put((Integer) dmlOrchestrator.Ranking__c, dmlOrchestrator);
            }
            objData = new SobjectData();
            objData.sObj2CusMetadata = sObj2CusMetadata;
            objData.srceFld2TargField = srceFld2TargField;
            objData.dmlMaps = dmlMaps;
            process2Metadata.put(process.developerName, objData);
        }
        return process2Metadata;
    }
    /**  
     * @description : Prepare address street
     */
    public static String addressLine(String accountStreet,String addressLine,Boolean isAddressLine1) {
        String addressStreet;
        if( isAddressLine1) {
            if(!String.isEmpty(addressLine) ) {
                addressStreet= addressLine ;
            }
        } else {
            addressStreet= accountStreet;
            if(!String.isEmpty(addressLine)) {
                addressStreet=accountStreet +  '\n' + addressLine ;
            }
        }
        return addressStreet;
    }
    /**  
     * @description : Merges the data from multiple sobject maps in case of multiple services invoked
     * @parameters : resultmap from object service class & upsertmap from handlerclass
     */
    public Static  Map < String, Map < String, Sobject >> upsertSobjectMap(Map < String, Map < String, Sobject >> resultMap, Map < String, Map < String, Sobject >> upsertMap) {
        for (String str: resultMap.keyset()) {
            if (upsertMap == null || !upsertMap.containsKey(str)) {
                upsertMap.put(str, new map < String, SObject > ());
            }
            upsertMap.get(str).putAll(resultMap.get(str));
        }
        return upsertMap;
    }
    /**
     * @description : Field mappping class
     */
    public class SobjectData {
        /* List of Field Mapping record */
        public Map < String, List < Reltio_Field_Mapping__mdt >> sObj2CusMetadata;
        /* List of Field Mapping record */
        public Map < Integer, DML_Orchestrator__mdt > dmlMaps;
        /*  map of source to target field*/
        public Map < String, String > srceFld2TargField;
    }
    private CM_ReltioHandlerService() {}
}