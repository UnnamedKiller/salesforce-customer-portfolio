/**
* @description Batch to process Customer Portfolios' records creation. When
* a record with Source = 'External' is created, this batch creates records 
* with Source = 'Internal ' to all the roles above in the role hierarchy.
*/
public class CustomerPortfolioUpsertBatch implements Database.Batchable<SObject> {
    
/**
* @description Iniciates the batch. Searches for Customer Portfolio records 
* with Source = 'External' that were created today.
*/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT User__c, Customer__c, External_Id__c 
            FROM Customer_Portfolio__c
            WHERE Source__c = 'External' AND CreatedDate = TODAY
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Customer_Portfolio__c> scope) {
        Set<Id> userIds = new Set<Id>();
        for (Customer_Portfolio__c cp : scope) {
            userIds.add(cp.User__c);
        }
        
        if (userIds.isEmpty()) {
            return;
        }
        Set<Id> superiorUserIds = RoleHierarchyHelper.getSuperiorUserIds(userIds);
        if (superiorUserIds.isEmpty()) {
            return;
        }
        
        Set<String> existingInternalAccess = new Set<String>();
        for (Customer_Portfolio__c existingCp : [
            SELECT User__c, Customer__c FROM Customer_Portfolio__c
            WHERE Source__c = 'Internal' AND User__c IN :superiorUserIds
        ]) {
            existingInternalAccess.add(existingCp.User__c + '-' + existingCp.Customer__c);
        }
        List<Customer_Portfolio__c> internalsToCreate = new List<Customer_Portfolio__c>();
        
        for (Customer_Portfolio__c externalCp : scope) {
            for (Id superiorId : superiorUserIds) {
                String compositeKey = superiorId + '-' + externalCp.Customer__c;
                if (!existingInternalAccess.contains(compositeKey)) {
                    internalsToCreate.add(new Customer_Portfolio__c(
                        User__c = superiorId,
                        Customer__c = externalCp.Customer__c,
                        Source__c = 'Internal',
                        External_Id__c = superiorId + '' + externalCp.Customer__c
                    ));
                    existingInternalAccess.add(compositeKey);
                }
            }
        }
        if (!internalsToCreate.isEmpty()) {
            Database.insert(internalsToCreate, false);
        }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('CustomerPortfolioUpsertBatch ran successfull. Job ID: ' + bc.getJobId());
    }
}