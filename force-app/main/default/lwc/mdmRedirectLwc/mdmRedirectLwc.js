import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
export default class GetRecordLWC extends LightningElement {
  @api redirectObject;
  data;
  error;
  @wire(getRecord, { recordId: '$redirectObject.sobjectId', fields: '$redirectObject.FIELDS', modes: ['View'] })
  wiredRecord({ error, data }) {
      if (data) {
        let cusProfileURL = this.redirectObject.mdmURL.replace('MDM_Id',data.fields.MDM_Id__c.value).replace('crossWalk_Id',data.fields.Id.value);
        window.open(cusProfileURL,'_blank');
        window.open(this.redirectObject.salesforceUrl,'_self');
      } else if (error) {
          this.error = error;
      }
  }
}