trigger CRM_AssetEventSubscriber on CRM_Asset_Event__e (after insert) {
    UCB_MessageTriggerFactory.createHandler(CRM_Asset_Event__e.SObjectType);
}