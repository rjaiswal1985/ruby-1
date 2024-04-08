({
    init: function (component, event, helper) {
        let sObjectName = component.get('v.sObjectName');
        let sobjectRecordId = component.get('v.recordId');
        let pageRef = component.get("v.pageReference");
        if(pageRef) {
            this.getSfAddress(component,pageRef,sObjectName,sobjectRecordId);
        } else{
            this.redirectEditRecord(component,sObjectName,sobjectRecordId,'','/lightning/r/'+sObjectName+'/'+sobjectRecordId+'/view?0.source=alohaHeader');
        }
    },
    getSfRedirectURL: function (actionName, sObjectName, objectName, recordId,force__recordId,force__cmpId) {
        let salesforceUrl;
        if (force__recordId) {
            salesforceUrl= '/lightning/cmp/force__dynamicRelatedListViewAll?force__flexipageId=Account_Record_Page&force__cmpId='+force__cmpId+'&force__recordId=';
            salesforceUrl+=force__recordId;
        } else  if(actionName==='view') {
            salesforceUrl= '/lightning/r/'+objectName+'/'+recordId+'/view?0.source=alohaHeader';
        } else {
            salesforceUrl= '/lightning/o/'+objectName+'/list?filterName=Recent&0.source=alohaHeader';
        }
        return salesforceUrl;
    },
    getSfAddress: function (component,pageRef,sObjectName,sobjectRecordId) {
        let base64Context = pageRef.state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        let addressableContext = JSON.parse(window.atob(base64Context));
        let objectName = addressableContext.attributes.objectApiName;
        let recordId = addressableContext.attributes.recordId;
        let actionName = addressableContext.attributes.actionName;
        let force__recordId = addressableContext.state.force__recordId;
        let force__cmpId= addressableContext.state.force__cmpId;
        let salesforceUrl= this.getSfRedirectURL(actionName, sObjectName,objectName, recordId,force__recordId,force__cmpId) ;
        if(sobjectRecordId ||  sObjectName==='Account_Relationship__c') {
            this.redirectEditRecord(component,sObjectName,sobjectRecordId,recordId,salesforceUrl,force__recordId);
        } else {
            this.redirectNewRecord(sObjectName,salesforceUrl);
        }
    },
    redirectNewRecord: function (sObjectName,salesforceUrl) {
        let mdmURL= (sObjectName==='Account') ?$A.get("$Label.c.OrganizationNewURL"):$A.get("$Label.c.PersonNewURL");
        window.open(mdmURL,'_blank');
        window.open(salesforceUrl,'_self');
    },
    redirectEditRecord: function (component,sObjectName,sobjectRecordId,recordId,salesforceUrl,force__recordId) {
        let redirectObject={};
        redirectObject.salesforceUrl = salesforceUrl;
        switch(sObjectName) {
            case 'Account':
                redirectObject.sobjectId=sobjectRecordId;
                redirectObject.FIELDS=['Account.MDM_Id__c','Account.Id'];
                redirectObject.mdmURL= $A.get("$Label.c.OrganizationEditURL");
                component.set('v.redirectObject',redirectObject);
                break;
            case 'Contact':
                redirectObject.sobjectId=sobjectRecordId;
                redirectObject.FIELDS=['Contact.MDM_Id__c','Contact.Id'];
                redirectObject.mdmURL= $A.get("$Label.c.PersonEditURL");
                component.set('v.redirectObject',redirectObject);
                break;
            case 'Account_Relationship__c':
                if(sobjectRecordId) {
                    redirectObject.sobjectId=sobjectRecordId;
                    redirectObject.FIELDS=['Account_Relationship__c.MDM_Id__c','Account_Relationship__c.Id'];
                    redirectObject.mdmURL= $A.get("$Label.c.OrgOrgEditURL");
                    component.set('v.redirectObject',redirectObject);
                } else {
                    redirectObject.sobjectId=recordId?recordId:force__recordId;
                    redirectObject.FIELDS=['Account.MDM_Id__c','Account.Id'];
                    redirectObject.mdmURL= $A.get("$Label.c.OrgOrgNewURL");
                    component.set('v.redirectObject',redirectObject);
                }
                break;
            default:
                this.accountContactRelationScema(component, sobjectRecordId);
                break;
        }
    },
    accountContactRelationScema: function (component,sobjectRecordId) {
        let redirectObject={};
        let action = component.get("c.relationDescription");
        action.setParams({});
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                let responseObj = JSON.parse(response.getReturnValue());
                if(responseObj.updateable) {
                    redirectObject.sobjectId=sobjectRecordId
                    redirectObject.salesforceUrl= '/lightning/r/AccountContactRelation/'+sobjectRecordId+'/view?0.source=alohaHeader';
                    redirectObject.FIELDS=['AccountContactRelation.MDM_Id__c','AccountContactRelation.Id'];
                    redirectObject.mdmURL= $A.get("$Label.c.OrgPersonEditURL");
                    component.set('v.redirectObject',redirectObject);
                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'You dont have edit access to record.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})