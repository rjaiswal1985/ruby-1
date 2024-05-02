/***********************************************************************************************************************
* Name: UCB_LoggerService
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Service to log the transactions
* TestClass : UCB_LoggerServiceTest
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   22/04/2024          GSF-1139 - Logger Framework
***********************************************************************************************************************/
public with sharing class CM_LoggerUtil {
    /* Get all the Replay   record */
    final public Static Map <String,UCB_Logger__c > LOGGERMAP = new Map <String,UCB_Logger__c >();
    /**
     * @description : property to capture list of logEvents
     */
    private static List<CM_Log> logEvents;
    /**
     * @description : property to capture list of logEvents
     */
    private static List<LOGWRAPPER> loggerList;
    /**
     * @description : property to capture list of logEvents
     */
    private static Map<String,List<LOGWRAPPER>> moduleLog;
    /**
     * @desciption : initialiser block to instantiate the list of events
     */
    static {
        logEvents = new List<CM_Log>(); 
        loggerList = new List<LOGWRAPPER>();
        moduleLog = new Map<String,List<LOGWRAPPER>>();
    }
    /**
     * @description : private constructor to avoid creating instance of the class
     */
    @testVisible
    private CM_LoggerUtil() {
    }
     /**
     * @description : method to make logs
     */
    public static void jsonLogger(CM_Log log) {
        final LOGWRAPPER logger = new LOGWRAPPER();
        logger.SFPE_Replay_Id =log.logType; 
        logger.SFPE_EventId =log.mdmId;
        logger.Logger_Type = 'Info';
        logger.Process_Name = log.loggerKey;
        logger.MDMId =''; 
        logger.Parent_MDMId = ''; 
        logger.UTC_Timestamp =String.valueof(Datetime.now());
        logger.message ='';
        logger.Request =log.message;
        logger.Response ='';
        logger.Sobject_Name ='';
        logger.Response ='';
        logger.Parent_Sobject_Name ='';
        logger.Source='Salesforce';
        moduleLog.put('JsonParser',new List<LOGWRAPPER>{logger}); 
    }
    /**
     * @description : method to make logs
     */
    public static void logger(CM_Log log) {
        if(!moduleLog.containsKey(log.loggerKey)) {
            moduleLog.put(log.loggerKey,new List<LOGWRAPPER>());   
        } 
        final LOGWRAPPER logger = new LOGWRAPPER();
        logger.Logger_Type = log.logtype;
        logger.MDMId =log.mdmId; 
        logger.Parent_MDMId = log.mdmId; 
        logger.UTC_Timestamp =String.valueof(Datetime.now());
        logger.message =log.message;
        logger.Source='Salesforce';
        moduleLog.get(log.loggerKey).add(logger); 
    }
    /**
     * @description : method to make logs
     */
    public static void publishLogger(String module,Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event,Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap,Map<String,String> mdmId2parent) {
        for(UCB_Logger__c log: UCB_Logger__c.getAll().values()) {
            LOGGERMAP.put(log.Process__c+log.Logger_Type__c,log);
        }
        LOGWRAPPER logger ;
        CM_ReltioHandlerService.EVENTDETAILS eventDetail;        
        final Map<String,String> mdm2SfId = new Map<String,String>(); 
        CM_DMLSaveResult.DMLWrapper dmlWrap;     
        for(String mdmId: dmlWrapMap.keyset()) {
            dmlWrap = dmlWrapMap.get(mdmId);
            mdm2SfId.put(mdmId,dmlWrap.salesforceId);
        }
        for(String mdmId: dmlWrapMap.keyset()) {
            logger = new LOGWRAPPER();
            dmlWrap = dmlWrapMap.get(mdmId);
            logger.MDMId = mdmId; 
            logger.Parent_MDMId = mdmId2parent.get(mdmId); 
            logger.Internal_Id=dmlWrap.salesforceId;
            logger.Parent_Internal_Id = mdm2SfId.get(logger.Parent_MDMId);
            logger.Parent_Sobject_Name = logger.Parent_Internal_Id.getSObjectType().getDescribe().getName();
            logger.Request =dmlWrap.request;
            logger.Response = dmlWrap.response;
            eventDetail=mdmId2Event.get(logger.parent_MDMId);
            logger.SFPE_Replay_Id =eventDetail.ReplayId; 
            logger.SFPE_EventId =eventDetail.EventUuid; 
            logger.Process_Name = module; 
            logger.Sobject_Name=dmlWrap.sobjectName;
            logger.UTC_Timestamp =String.valueof(Datetime.now());
            logger.Message =dmlWrap.message;
            logger.Logger_Type ='Info';
            logger.Source='Salesforce';
            if(!moduleLog.containsKey('DML_log')) {
                moduleLog.put('DML_log',new List<LOGWRAPPER>());   
            } 
            moduleLog.get('DML_log').add(logger);  
        }
        for(String logType: moduleLog.keySet()) {
            for(LOGWRAPPER log : moduleLog.get(logType)) {
                if(mdmId2Event.containskey(log.mdmId)) {
                    eventDetail = mdmId2Event.get(log.mdmId);
                    log.SFPE_Replay_Id =eventDetail.replayID; 
                    log.SFPE_EventId =eventDetail.eventUUId;
                    log.Process_Name = module;
                }
            }
            if(LOGGERMAP.containskey(module+logType) && LOGGERMAP.get(module+logType).Publish__c) {
                UCB_LoggerService.logger(new UCB_Log(module, logType, JSON.serialize(moduleLog.get(logType))),false);
            }
        }    
        UCB_LoggerService.publishLogs(); 
    }
    /*Acount Relation wrapper */
    private class LOGWRAPPER {
        /* Process Name */
        String Process_Name; 
        /* TimeStamp */
        String UTC_Timestamp; 
        /* Request */        
        String Request; 
        /* Response */
        String Response; 
        /* Message */
        String Message;
        /* Logger Type */
        String Logger_Type; 
        /* Parent MDM Id */
        String Parent_MDMId;        
        /* MDM Id */
        String MDMId; 
        /* SF Internal ID */
        String Internal_Id;
        /* SF parent Internal Id */
        Id Parent_Internal_Id;
        /* Sobject Name */
        String Sobject_Name;
        /* Parent Sobject Name*/
        String Parent_Sobject_Name;
        /* Salesforce replay Id */
        String SFPE_Replay_Id ;
        /* Salesforce Event Id */
        String SFPE_EventId; 
        /* Source */
        String Source;        
    }
}