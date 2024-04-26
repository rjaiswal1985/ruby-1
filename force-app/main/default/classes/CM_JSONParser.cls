/***********************************************************************************************************************
 * Name: CM_JSONParser
 * Copyright © Align Tech
 * ========================================================================================================================
 * Purpose: Handles inputjson data from the platform event
 * TestClass : CM_JSONParser
 * ========================================================================================================================
 * History
 *
 * VERSION         AUTHOR                          DATE                DETAIL
 * 1.0             Rohit Jaiswal                   20/10/2023          JSON Parser to handle platform event data
 ***********************************************************************************************************************/
public with sharing class CM_JSONParser {
    /*********Map of MD Ids  */
    private static Map<String,String> mdmId2parent;
     /**
     * @description : parses the JSON returns sobject data
     */
    public static CM_ReltioHandlerService.JSPARSER objectJsonParser(String inputJson, CM_ReltioHandlerService.SobjectData sobjectData) {
        final CM_ReltioHandlerService.JSPARSER parser= new CM_ReltioHandlerService.JSPARSER();
        CM_LoggerUtil.logger(new CM_Log('JsonParser','Info',String.valueof(Datetime.now()), 'Deserialization started.', inputJson));
        final Map<String, Object> requestObject = (Map<String, Object>)(JSON.deserializeUntyped(inputJson));
        final Map<String, Object> objectJson = (Map<String, Object>)requestObject.get(CM_ReltioConstants.OBJECTSTRING);
        final String masterRecordId=(String)objectJson.get('mdmId');
        final CM_ReltioHandlerService.ATTRIBUTEPARSER attriParser = attibuteParsers(objectJson, sobjectData,masterRecordId);
        parser.key2value = attriParser.key2value;
        parser.apiType=(String)requestObject.get('type');
        parser.mdmId2parent = attriParser.mdmId2parent;  
        parser.masterRecordId = masterRecordId;    
        CM_LoggerUtil.logger(new CM_Log('JsonParserCompleted','Info',String.valueof(Datetime.now()), masterRecordId, 'Deserialization completed.'));  
        return parser;
    }
    /**
     * @description : Method to parse attributes data in JSON & map object fields using custom metadata
     */
    public static CM_ReltioHandlerService.ATTRIBUTEPARSER attibuteParsers(Map<String, Object> objectJson, CM_ReltioHandlerService.SobjectData sobjectData,String masterRecordId ) {
        final CM_ReltioHandlerService.ATTRIBUTEPARSER attriParser = new CM_ReltioHandlerService.ATTRIBUTEPARSER();
        final Map<String, List<Reltio_Field_Mapping__mdt>> sObj2CusMetadata = sobjectData.sObj2CusMetadata;
        final Map<String, String> srceFld2TargField = sobjectData.srceFld2TargField;
        Map<String, Map<String, Object>> outputObject = new Map<String, Map<String, Object>>();
        final Map<String, Map<String, Map<String, Object>>> key2value = new Map<String, Map<String, Map<String, Object>>>();
        final Map<String, Object> attributeJson = (Map<String, Object>)objectJson.get(CM_ReltioConstants.ATTRIBUTES);
        String targetField;
        mdmId2parent= new Map<String,String>();
        for (String type : sObj2CusMetadata.keyset()) {
            targetField = srceFld2TargField.get(type);
            outputObject = new Map<String, Map<String, Object>>();
            if (type == CM_ReltioConstants.MASTER) {
                outputObject = getParentObject(objectJson, attributeJson, sObj2CusMetadata.get(CM_ReltioConstants.MASTER),masterRecordId);
            } else if (attributeJson.containsKey(type) ) {
                outputObject = getCustomObject(attributeJson, type, sObj2CusMetadata.get(type),masterRecordId );                
            }  
            if (!outputObject.isEmpty() && !String.isEmpty(targetField)) {                
                if (!key2value.containsKey(targetField)) {
                    key2value.put(targetField, new Map<String, Map<String, Object>>());
                }
                key2value.get(targetField).putall(outputObject);
            }
        } 
        attriParser.mdmId2parent=mdmId2parent;
        attriParser.key2value=key2value;
        return attriParser;
    }

    /**
     * @description : Method to parse JSON to get ParentObject data based on the service
     */
    private static Map<String, Map<String, Object>> getParentObject(Map<String, Object> objectJson, Map<String, Object> attributeJson, List<Reltio_Field_Mapping__mdt> sObj2CusMetadata,String masterRecordId) {
        final Map<String, Map<String, Object>> outputObject = new Map<String, Map<String, Object>>();
        final Map<String, Object> field2value = new Map<String, Object>();
        String fieldKey;
        for (Reltio_Field_Mapping__mdt mapping : sObj2CusMetadata) {
            fieldKey = String.isEmpty(mapping.Target_Field__c) ? mapping.Source_Parameter__c: mapping.Target_Field__r.QualifiedApiName;
            field2value.put(fieldKey, mapping.Source_Field__c== CM_ReltioConstants.OBJECTSTRING ? getObjectValue(objectJson ,mapping):getParseValues(attributeJson, mapping));
        }
        mdmId2parent.put((String) field2value.get(CM_ReltioConstants.MDMID),masterRecordId);
        outputObject.put((String) field2value.get(CM_ReltioConstants.MDMID), field2value);
        return outputObject;
    }

    /**
     * @description : Method to parse JSON to get ChildObjects data based on the service
     */
    private static Map<String, Map<String, Object>> getCustomObject(Map<String, Object> attributeJson, String type, List<Reltio_Field_Mapping__mdt> sObj2CusMetadata,String masterRecordId) {
        final Map<String, Map<String, Object>> outputObject = new Map<String, Map<String, Object>>();
        Map<String, Object> field2value;
        for (Object childRecord : getObjectMap(attributeJson, type, 'value')) {
            field2value = new Map<String, Object>();
            for (Reltio_Field_Mapping__mdt mapping : sObj2CusMetadata) {
                field2value.put(mapping.Target_Field__r.QualifiedApiName, getParseValues((Map<String, Object>)childRecord, mapping));
            }
            mdmId2parent.put((String) field2value.get(CM_ReltioConstants.MDMID),masterRecordId);
            outputObject.put((String) field2value.get(CM_ReltioConstants.MDMID), field2value);
        }
        return outputObject;
    }

    /**
     * @description : Method to get field mappings from custom metadata
     */
    private static Object getParseValues(Map<String, Object> inputJson, Reltio_Field_Mapping__mdt mapping) {
        List<Object> returnValues = new List<Object>();
        if (mapping.Source_Field__c == null) {
            returnValues.add(mapping.Source_Object__c);
        } else if (mapping.Target_Field__r.DataType==CM_ReltioConstants.MULTIPICKLIST) {
            returnValues = multiSelectPicklist(inputJson, mapping);
        } else {
            returnValues = objectValue(inputJson, mapping);  
        }
        String returnString;
        if (returnValues != null && !returnValues.isEmpty()) {
            returnString = String.join(returnValues, ';');
            
        }
        Object objectValue = returnString;
        if (!String.isEmpty(returnString)) {            
            if (mapping.Source_Parameter__c == CM_ReltioConstants.URI) {
                objectValue = returnString.substringBetween(mapping.Source_Object__c + '/', '/'); 
            } else {
                objectValue = formattedData(returnString,mapping.Target_Field__r.DataType);
            }
        }
        return objectValue;
    }

    /**
     * @description : Method to get sobject field data from JSON
     */
    private static List<Object> getObjectMap(Map<String, Object> childMap, String sourceField, String sourceParameter) {
        final List<Object> returnValues = new List<Object>();
        Object objectValue;
        if (childMap != null && childMap.containskey(sourceField)) {
            Map<String, Object> objectMap;
            for (Object obj : (List<Object>)childMap.get(sourceField)) {
                objectMap = (Map<String, Object>)obj;
                objectValue = objectMap.get(sourceParameter);
                if (!String.isEmpty(String.valueOf(objectValue))) {
                    returnValues.add(objectValue);
                }
            }
        }
        return returnValues;
    }
     /**
     * @description : Method to get multi-select picklist
     */
    private static List<Object> objectValue(Map<String, Object> inputJson, Reltio_Field_Mapping__mdt mapping) {
        final List<Object> returnValues = new List<Object>();
        String inputField;
        final List<String> inputFields = mapping.Source_Field__c.split(';');
        Map<String, Object> jsonObject = inputJson;
        for (Integer fieldCount = 0; fieldCount < inputFields.size(); fieldCount++) {
            inputField = inputFields[fieldCount];
            if(jsonObject.containsKey(inputField)) {
                if (fieldCount < inputFields.size() - 1) {
                    jsonObject = (Map<String, Object>)getObjectMap(jsonObject, inputField, 'value')[0];
                } else {
                    returnValues.addall(getObjectMap(jsonObject, inputField, mapping.Source_Parameter__c));
                }     
            }           
        }    
        return returnValues;
    }
    /**
     * @description : Method to get multi-select picklist
     */
    private static List<Object> multiSelectPicklist(Map<String, Object> inputJson, Reltio_Field_Mapping__mdt mapping) {
        final List<Object> returnValues = new List<Object>();   
        final List<String> inputFields = mapping.Source_Field__c.split(';');
        final String parentField= inputFields[0];        
        if (inputJson.containskey(parentField)) {
            Map<String, Object> jsonObject = inputJson;
            final String objectField= inputFields[1];
            for (Object childRecord: (List<Object> ) inputJson.get(parentField)) {              
                jsonObject = (Map < String, Object > ) childRecord;
                jsonObject = (Map < String, Object > ) jsonObject.get(CM_ReltioConstants.VALUE);
                returnValues.addall(getObjectMap(jsonObject, objectField, mapping.Source_Parameter__c));
            }
        }
        return returnValues;
    }

    /**
     * @description : Method to get sobject field data from JSON
     */
    private static Object formattedData(String returnString, String dataType) {
        Object objectValue;
        switch on dataType {
            when 'date' {		 
                objectValue = Date.valueOf(returnString);
            }	
            when 'double' {		 
                objectValue = Decimal.valueOf(returnString);
            }
            when 'datetime' {		 
                objectValue = Datetime.newinstance(Long.valueOf(returnString));
            }
            when else {		   
                objectValue = returnString;
            }
        }
        return objectValue;
    }

    /**
     * @description : Method to get sobject type from JSON
     */
    private static Object getObjectValue(Map<String, Object> jsonMap, Reltio_Field_Mapping__mdt mapping) {
        final String inputField  = mapping.Source_Parameter__c;
        final String returnString = String.valueof(jsonMap.get(inputField));
        return inputField == CM_ReltioConstants.STARTOBJECT || inputField == CM_ReltioConstants.ENDOBJECT ? jsonMap.get(inputField)  : returnString.contains('/')? returnString.substringAfterLast('/'):formattedData(returnString,mapping.Target_Field__r.DataType);
    }
    private CM_JSONParser() {}
}