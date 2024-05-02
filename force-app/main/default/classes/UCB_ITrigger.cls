public interface UCB_ITrigger {
    /**
    * This  is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    *
    */
    void bulkBefore(UCB_Trigger.TriggerContext trgCtx);

    /**
     * This is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    void bulkAfter(UCB_Trigger.TriggerContext trgCtx);

    /**
     * This is called for business logic execution of BEFORE trigger.
     */
    void beforeTrigger(UCB_Trigger.TriggerContext trgCtx);

    /**
     * This is called for business logic execution of AFTER trigger.
     */
    void afterTrigger(UCB_Trigger.TriggerContext trgCtx);

    /**
     * This is called once all records have been processed by the trigger. Use this
     * to accomplish any final operations such as creation or updates of other records.
     */
    void andFinally(UCB_Trigger.TriggerContext trgCtx);
}