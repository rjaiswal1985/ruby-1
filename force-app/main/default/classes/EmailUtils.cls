/***********************************************************************************************************************
* Name: EmailUtils
* Copyright © Align Tech
* ========================================================================================================================
* Purpose: Emails to send on batch update
* TestClass : EmailUtils
* ========================================================================================================================
* History
*
* VERSION         AUTHOR                          DATE                DETAIL
* 1.0             Sruthi M                        26/02/2024          Class invoked from batch jobs to send emails.
***********************************************************************************************************************/
    public with sharing class EmailUtils {
        /**
        * @description : This method sends email notifications from Apex
        * @parameters : toAddress, email subject, email body
        */           
       public static void sendApexEmailNotification(String[] toAddresses, String subject, String body) {
           Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
           email.setToAddresses(toAddresses);
           email.setSubject(subject);
           email.setPlainTextBody(body);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
       }
        /**
        * @description : This method sends email with details of batch job
        * @parameters : batchjobId, job name
        */         
       public static void sendBatchCompletionNotification(String batchJobId,  Batch_Jobs_Execution__c batchJobSettings) {  
            final AsyncApexJob asyncJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                           FROM AsyncApexJob WHERE Id = :batchJobId WITH SECURITY_ENFORCED];
    
            final String Subject = batchJobSettings.name + asyncJob.Status;
            final String mailBody = 'The batch Apex job processed ' + asyncJob.TotalJobItems + ' batches with ' + asyncJob.NumberOfErrors + ' failures.';
            final List<String> toaddress = new List<String>{ string.valueOf(batchJobSettings.get('Recipient_email_address__c')) };             
            sendApexEmailNotification(toAddress,subject,mailBody);
       }
       
   }