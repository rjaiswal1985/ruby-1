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
* 1.0           Anant Bhosale               15/09/2023          GSF-1139 - Logger Framework
***********************************************************************************************************************/
public with sharing class UCB_LoggerService {
    /**
     * @description : property to capture sequence of log
     */
    private static Integer sequence;
    /**
     * @description : property to capture list of logEvents
     */
    private static List<UCB_Exception__e> logEvents;
    /**
     * @desciption : initialiser block to instantiate the list of events
     */
    static {
        logEvents = new List<UCB_Exception__e>();
        sequence = 0;
    }
    /**
     * @description : private constructor to avoid creating instance of the class
     */
    @testVisible
    private UCB_LoggerService() {
    }
    /**
     * @description : method to make log in flows
     */
    @InvocableMethod
    public static void logger(List<UCB_Log> logs) {
        for(UCB_Log log:logs) {
            logEvents.add(createLogEvent(log));
        }  
        publishLogs();
    }
    /**
     * @description : method to make logs
     */
    public static void logger(UCB_Log log,Boolean publish) {
        logEvents.add(createLogEvent(log));
        if(publish) {
            publishLogs();
        }
    }
    /**
     * @description : method to publish the plaform events.
     */
    public static void publishLogs() {
        if(logEvents.isEmpty()==false) {
            EventBus.publish(logEvents);
            logEvents.clear();
        }
    }
    /**
     * @description : method to create log event from wrapper
     */
    private static UCB_Exception__e createLogEvent(UCB_Log log) {
        final UCB_Exception__e logEvent = new UCB_Exception__e();
        logEvent.Type__c='Log';
        logEvent.Module__c = log.module;
        logEvent.Transaction_Id__c = log.txnId;
        logEvent.Additional_Info_JSON__c = log.message;
        logEvent.Component_Name__c = log.componentName;
        logEvent.Sequence__c = ++sequence;
        return logEvent; 
    }
}