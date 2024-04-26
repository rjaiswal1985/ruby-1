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
    /**
     * @description : property to capture list of logEvents
     */
    private static List<CM_Log> logEvents;
    /**
     * @desciption : initialiser block to instantiate the list of events
     */
    static {
        logEvents = new List<CM_Log>(); 
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
    public static void logger(CM_Log log) {
        logEvents.add(log);
    }
    /**
     * @description : method to make logs
     */
    public static void publishLogs(String module,Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event) {
        final Map<String,List<LOGWRAPPER>> moduleLog = new Map<String,List<LOGWRAPPER>>();
        LOGWRAPPER logger ;
        CM_ReltioHandlerService.EVENTDETAILS eventDetail;        
        for(CM_Log log : logEvents) {
            if(!moduleLog.containsKey(log.loggerKey)) {
                moduleLog.put(log.loggerKey,new List<LOGWRAPPER>());   
            } 
            logger = new LOGWRAPPER();
            if(mdmId2Event.containskey(log.mdmId)) {
                eventDetail = mdmId2Event.get(log.mdmId);
                logger.Replay_ID =eventDetail.ReplayId; 
                logger.EventUUId =eventDetail.EventUuid;
            }
            logger.Sucess = true;
            logger.Logger_Type = log.logtype;
            logger.Process_Name = module;
            logger.MDMId =log.mdmId; 
            logger.Parent_MDMId = log.mdmId; 
            logger.UTC_Timestamp =log.timestamp;
            logger.message =log.message;
            moduleLog.get(log.loggerKey).add(logger);       
        }
        for(String log: moduleLog.keySet()) {
            UCB_LoggerService.logger(new UCB_Log(module, log, JSON.serialize(moduleLog.get(log))),false);
        }         
    }
    /**
     * @description : method to make logs
     */
    public static void dmlLogger(String module,Map<String,CM_ReltioHandlerService.EVENTDETAILS> mdmId2Event,Map <String,CM_DMLSaveResult.DMLWrapper> dmlWrapMap,Map<String,String> mdmId2parent) {
        final List<LOGWRAPPER> moduleLog = new List<LOGWRAPPER>();
        
        CM_ReltioHandlerService.EVENTDETAILS event ;
        LOGWRAPPER logger; 
        for(String mdmId: dmlWrapMap.keyset()) {
            logger = new LOGWRAPPER();
            logger.MDMId = mdmId; 
            logger.Parent_MDMId = mdmId2parent.get(mdmId); 
            logger.Sucess = dmlWrapMap.get(mdmId).isDMLSucess;
            logger.Internal_Id=dmlWrapMap.get(mdmId).salesforceId;
            event=mdmId2Event.get(logger.parent_MDMId);
            logger.Replay_ID =event.ReplayId; 
            logger.EventUUId =event.EventUuid; 
            logger.Process_Name = module; 
            logger.Sobject_Name=dmlWrapMap.get(mdmId).sobject_Name;
            logger.UTC_Timestamp =dmlWrapMap.get(mdmId).timeStamp;
            logger.message =JSON.serialize(dmlWrapMap.get(mdmId));
            logger.Logger_Type ='debug';
            moduleLog.add(logger);
        }
        UCB_LoggerService.logger(new UCB_Log(module, 'DML_Log', JSON.serialize(moduleLog)),false);     
    }
    /*Acount Relation wrapper */
    private class LOGWRAPPER {
        /* Map of upserted record */
        String Replay_ID ;
        /* Contact 2 Account Map */
        String EventUUId;
        /* Contact 2 Account Map */
        String UTC_Timestamp; 
        /* Contact 2 Account Map */
        String Logger_Type; 
        /* Contact 2 Account Map */
        String MDMId; 
        /* Contact 2 Account Map */
        String Message; 
        /* Contact 2 Account Map */
        String Parent_MDMId; 
        /* Contact 2 Account Map */
        String Process_Name; 
         /* Contact 2 Account Map */
        String Internal_Id; 
        /* Contact 2 Account Map */
        Boolean Sucess;
        /* Contact 2 Account Map */
        String Sobject_Name;
    }
}