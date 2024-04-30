/***********************************************************************************************************************
* Name: CM_LoggerInitializationUtil
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Replay the failed events
* TestClass : CM_LoggerInitializationUtil
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Rohit Jaiswal                   20/10/2023          Service class for Reltio Replay failed events
***********************************************************************************************************************/
public with sharing class CM_LoggerInitializationUtil {
    /**
    * Variable name method names 
    * @description : Service calss for the Reltio Reply class    
    */   
    public static void replayService(Exception excp,String className) { 
       UCB_LoggerService.logger(new List<UCB_Log>{new UCB_Log('ReltioPayloadTriggerHandler','errorMessage','Exception cause: '+excp.getcause()+' \n Error type: '+excp.getTypeName()+' \n Line number: '+excp.getLineNumber()+'\n Error message: '+excp.getMessage()+' \n Stack message: '+excp.getStackTraceString())});   
    }
    private CM_LoggerInitializationUtil() {}
}