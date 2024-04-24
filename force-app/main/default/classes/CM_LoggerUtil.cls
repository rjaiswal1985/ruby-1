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
    public static List<CM_Log> logEvents;
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
            if(!moduleLog.containsKey(log.message)) {
                moduleLog.put(log.message,new List<LOGWRAPPER>());   
            } 
            logger = new LOGWRAPPER();
            eventDetail = mdmId2Event.get(log.mdmId);
            logger.replayID =eventDetail.ReplayId; 
            logger.eventUUId =eventDetail.EventUuid;
            logger.module = module;
            logger.mdmId =log.mdmId; 
            logger.timeStamp =log.timestamp;
            logger.message =log.message;
            moduleLog.get(log.message).add(logger);       
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
            logger.mdmId = mdmId; 
            logger.module = mdmId2parent.get(mdmId); 
            event=mdmId2Event.get(logger.module);
            logger.replayID =event.ReplayId; 
            logger.eventUUId =event.EventUuid; 
            logger.module = module; 
            logger.timeStamp =dmlWrapMap.get(mdmId).timeStamp;
            logger.message =JSON.serialize(dmlWrapMap.get(mdmId));
            moduleLog.add(logger);
        }
        UCB_LoggerService.logger(new UCB_Log(module, 'DML_Log', JSON.serialize(moduleLog)),false);     
    }
    /*Acount Relation wrapper */
    private class LOGWRAPPER {
        /* Map of upserted record */
        String replayID ;
        /* Contact 2 Account Map */
        String eventUUId;
        /* Contact 2 Account Map */
        String timeStamp; 
        /* Contact 2 Account Map */
        String mdmId; 
        /* Contact 2 Account Map */
        String message; 
        /* Contact 2 Account Map */
        String module; 
    }
}