trigger CRM_OrderEventSubscriber on CRM_Order_Event__e (after insert) {
    UCB_MessageTriggerFactory.createHandler(CRM_Order_Event__e.SObjectType);
}