/***********************************************************************************************************************
* Name: UCB_Log
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Wrapper class to capture logs
* TestClass : UCB_LogTest
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0           Anant Bhosale               15/09/2023          GSF-1139 - Logger Framework
***********************************************************************************************************************/

public with sharing class CM_Log {
    /**
     * @description : property to capture component invoking the log
     */
    @InvocableVariable(label ='Component Name' description='Name of the component making a log' required=true)
    public String mdmId;
    /**
     * @description : property to capture the details
     */
    @InvocableVariable(label ='Message' description='Details to log.' required=true)
    public String message;
    /**
     * @description : property to capture the timestamp this log belongs to.
     */
    @InvocableVariable(label ='timestamp' description='Name of the business timestamp making log.' required=true)
    public String timestamp;
    /**
     * 
     */
    public CM_Log(String timestamp , String mdmId, String message) {
        this.mdmId = mdmId;
        this.message = message;
        this.timestamp = timestamp;
    }
}