public with sharing class CM_LoggerUtil {
    /**
     * 
     */
    private static final Integer FIELD_LIMIT = 100;
    /**
     * 
     */
    private static CM_Log logWrapper;
    /** 
     * 
    */
    private static List<Map<Object,Object>> logDetails;
    /**
     * 
     */
    static {
        logDetails = new List<Map<Object,Object>>();
    }
    public static void logger(CM_Log log,Boolean publishNow) {
        if(logWrapper==null) {
            logWrapper = log;
        }
        if(publishNow) {
            logDetails.add(log.details);
            publishLogs();
        } else {
            logger(log);
        }
    }
    /**
     * 
     */
    public static void logger(CM_Log log) {
        if(logWrapper == null) {
            logWrapper = log;
            logDetails.add(log.details);
        } else {
            if(splitLogs(log.details)) {
                System.debug('--! Finalised Log '+finaliseLog());
                UCB_LoggerService.logger(new List<UCB_Log>{finaliseLog()});
                clearHistory();
                logWrapper = log;
                logDetails.add(log.details);
            } else {
                logDetails.add(log.details);
                System.debug('---! Added to List '+logDetails);
            }
        }
    }
    public static void publishLogs() {
        UCB_LoggerService.logger(finaliseLog(),true);
        clearHistory();
    }
    /**
     * 
     */
    private static Boolean splitLogs(Map<Object,Object> details) {
        final Integer previousLogSize = JSON.serialize(logDetails).length();
        final Integer curentLogSize = JSON.serialize(details).length();
		System.debug('---! Previous '+previousLogSize);
		System.debug('---! curentLogSize '+curentLogSize);
        return FIELD_LIMIT <= (previousLogSize+curentLogSize);
    }
    /** 
     *
    */
    private static void clearHistory() {
        logDetails.clear();
        logWrapper=null;
    }
    /**
     * 
     */
    private static UCB_Log finaliseLog() {
        logWrapper.ucbLog.message = JSON.serialize(logDetails);
        return logWrapper.ucbLog;
    }
}