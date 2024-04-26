import {LightningElement, wire, api, track } from 'lwc';
import { getRelatedListRecords} from 'lightning/uiRelatedListApi';
import OrgPersonEditURL from '@salesforce/label/c.OrgPersonEditURL';
import OrgPersonNewURL from '@salesforce/label/c.OrgPersonNewURL';
import relationDescription from '@salesforce/apex/CM_SobjectController.relationDescription';
export default class AccountContactRelationsRelatedList extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isAccount;
    @api title;
    @track isCreatable;
    @track isUpdatable;
    @track actions;
    @track viewAllUrl;
    @track recordHome;
    @track recordHomeURL;
    @track recordName;
    @track recordUrl;
    @track accountColumns;
    @track contactColumns;
    isPerson;
    recordMDMId;
    hasRecords;
    records;

    @wire(relationDescription) wiredAccountsWithContacts({
        data
    }) {
        if (data) {
            this.relationshipColumns(data);
        }
    }
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'AccountContactRelations',
        fields: ['AccountContactRelation.MDM_Id__c',
        'AccountContactRelation.Id',
        'AccountContactRelation.Status__c',
        'AccountContactRelation.Roles',
        'AccountContactRelation.Relationship_Type__c',
        'AccountContactRelation.Contact.Email',
        'AccountContactRelation.Contact.Phone',
        'AccountContactRelation.Contact.MDM_Id__c',
        'AccountContactRelation.Contact.Name',
        'AccountContactRelation.Contact.Id',
        'AccountContactRelation.Contact.Status__c',
        'AccountContactRelation.Account.MDM_Id__c',
        'AccountContactRelation.Account.Status__c',
        'AccountContactRelation.Account.Phone',
        'AccountContactRelation.Account.Company_Email__c',
        'AccountContactRelation.Account.Id',
        'AccountContactRelation.Account.Name'
        ]
    }) listInfo({
        data
    }) {
        if (data) {
            this.relationshipData(data);
        }
    }
    relationshipColumns(data) {
        this.actions = [];        
        let accountColumns = [];
        let contactColumns = [];
        const parsedObj = JSON.parse(data);
        this.isCreatable = parsedObj.createable;
        this.isUpdatable = parsedObj.updateable;
        this.actions = [{
            label: 'View Relationship',
            name: 'view'
        }];
        if (parsedObj.updateable) {
            this.actions.push({
                label: 'Edit Relationship',
                name: 'edit'
            });
        }        
        accountColumns = [{
            label: 'Person'+' Name',
            fieldName: 'recordLink',
            type: 'url',
            hideDefaultActions: true,
            typeAttributes: {
                label: {
                    fieldName: 'recordName'
                },
                target: '_self'
            }
        },
        {
            label: 'Role',
            fieldName: 'Roles',
            hideDefaultActions: true
        },
        {
            label: 'Relationship Type',
            fieldName: 'Relationship_Type__c',
            hideDefaultActions: true
        },
        {
            label: 'Person'+' Status',
            fieldName: 'Status__c',
            hideDefaultActions: true
        },
        {
            label: 'Email',
            fieldName: 'Email',
            hideDefaultActions: true
        },
        {
            label: 'Phone',
            fieldName: 'Phone',
            hideDefaultActions: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.actions
            }
        } ];
        contactColumns = [{
            label: 'Organization '+' Name',
            fieldName: 'recordLink',
            type: 'url',
            hideDefaultActions: true,
            typeAttributes: {
                label: {
                    fieldName: 'recordName'
                },
                target: '_self'
            }
        },
        {
            label: 'Role',
            fieldName: 'Roles',
            hideDefaultActions: true
        },
        {
            label: 'Relationship Type',
            fieldName: 'Relationship_Type__c',
            hideDefaultActions: true
        },
        {
            label: 'Organization '+' Status',
            fieldName: 'Status__c',
            hideDefaultActions: true
        },
        {
            label: 'Email',
            fieldName: 'Email',
            hideDefaultActions: true
        },
        {
            label: 'Phone',
            fieldName: 'Phone',
            hideDefaultActions: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: this.actions
            }
        } ];
        this.accountColumns=accountColumns;
        this.contactColumns=contactColumns;
    }
    relationshipData(data) {
        let tempRecords = [];
        let dataCount = 0;
        let obj;
        let objectApiName = this.recordId.startsWith("001")?'Account':'Contact';
        let recordName;
        let recordMDMId;
        for (let i = 0; i < data.records.length; i++) {
            obj = data.records[i];
            let tempRecord = {};
            tempRecord.Id = obj.fields.Id.value;
            tempRecord.MDM_Id__c = obj.fields.MDM_Id__c.value;
            tempRecord.Relationship_Type__c = obj.fields.Relationship_Type__c.value;
            tempRecord.Roles = obj.fields.Roles.value;
            tempRecord.RoleName ='Role';
            tempRecord.RelationName ='Relationship Type';
            tempRecord.StatusName =objectApiName === 'Account' ? 'Person Status': 'Organization Status' ;

            tempRecord = objectApiName === 'Account' ? this.accountObject(tempRecord,obj) : this.contactObject(tempRecord,obj) ;
            tempRecord.record = JSON.stringify(tempRecord);
            tempRecords.push(tempRecord);

            recordName = this.getObjectData(obj,objectApiName === 'Account'?'Account':'Contact','Name');
            recordMDMId = this.getObjectData(obj,objectApiName === 'Account'?'Account':'Contact','MDM_Id__c');

            dataCount++;
            if (this.objectApiName && dataCount === 3) {
                break;
            }
        }
        this.recordName = recordName;
        this.recordMDMId= recordMDMId;
        this.isPerson =  objectApiName === 'Contact';
        this.hasRecords = data.count > 0;
        this.records = tempRecords;
        this.viewAllUrl = '/lightning/cmp/c__RelatedAccConRelations?force__recordId=' + this.recordId;
        this.title = 'Related ' + (objectApiName === 'Account' ? 'Persons' : 'Organizations') + ' (' + data.count + ')';
        this.recordHome = objectApiName === 'Account' ?'Organization' :'Person';
        this.recordHomeURL = '/lightning/o/'+objectApiName+'/list?filterName=Recent&0.source=alohaHeader';
        this.recordUrl = '/lightning/r/'+objectApiName+'/'+this.recordId+'/view?0.source=alohaHeader';
    }
    accountObject(tempRecord,obj) {
        tempRecord.recordName = this.getObjectData(obj,'Contact','Name');
        tempRecord.recordId = this.getObjectData(obj,'Contact','Id');
        tempRecord.Status__c = this.getObjectData(obj,'Contact','Status__c');
        tempRecord.Email = this.getObjectData(obj,'Contact','Email');
        tempRecord.Phone = this.getObjectData(obj,'Contact','Phone');
        tempRecord.recordLink = '/' + tempRecord.recordId;
        return tempRecord;
    }
    contactObject(tempRecord,obj) {
        tempRecord.recordName = this.getObjectData(obj,'Account','Name');
        tempRecord.recordId = this.getObjectData(obj,'Account','Id');
        tempRecord.Status__c = this.getObjectData(obj,'Account','Status__c');
        tempRecord.Email = this.getObjectData(obj,'Account','Company_Email__c');
        tempRecord.Phone = this.getObjectData(obj,'Account','Phone');
        tempRecord.recordLink = '/' + tempRecord.recordId;
        return tempRecord;
    }
    getObjectData(obj,objectName,fieldName){
        return obj.fields[objectName].value.fields[fieldName].value;
    }
    handleRowAction(event) {
        const actionName = event.detail.value?event.detail.value:event.detail.action.name;
        const row = event.detail.row?event.detail.row:JSON.parse(event.currentTarget.dataset.id);
        switch (actionName) {
            case 'view':
                window.open('/lightning/r/AccountContactRelation/' + row.Id + '/view?0.source=alohaHeader', '_self');
                break;
            case 'edit':
                window.open(OrgPersonEditURL.replace('MDM_Id',row.MDM_Id__c).replace('crossWalk_Id',row.Id), '_blank');
                break;
            default:
        }
    }
    handleActionsMenuSelect(event) {
        let objectId= this.recordId.startsWith("001")?'orgId':'personId';
        let profileURl = OrgPersonNewURL.replace('MDM_Id',this.recordMDMId).replace('crossWalk_Id',this.recordId).replace('objectId',objectId);
        window.open(profileURl, '_blank');
    }
}