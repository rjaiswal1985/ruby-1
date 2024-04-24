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

public with sharing class UCB_Log {
    /**
     * @description : property to capture unique id for the transaction
     */
    @InvocableVariable(label ='Transaction Id' description='Unique Id for the transaction getting logged.' required=false)
    public String txnId;
    /**
     * @description : property to capture component invoking the log
     */
    @InvocableVariable(label ='Component Name' description='Name of the component making a log' required=true)
    public String componentName;
    /**
     * @description : property to capture the details
     */
    @InvocableVariable(label ='Message' description='Details to log.' required=true)
    public String message;
    /**
     * @description : property to capture the module this log belongs to.
     */
    @InvocableVariable(label ='Module' description='Name of the business module making log.' required=true)
    public String module;
    /**
     * 
     */
    public UCB_Log(String module, String componentName, String message) {
        this.componentName = componentName;
        this.message = message;
        this.module = module;
        this.txnId = UCB_TransactionIdUtil.currentTransactionId();
    }
}