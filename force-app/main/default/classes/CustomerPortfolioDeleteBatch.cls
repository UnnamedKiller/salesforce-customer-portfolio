/**
* @description Batch to process the Custom Portfolio deletion. When a
* record with Source = 'External' is deleted, this batch searches for
* corresponding records with Source = 'Internal' in the role hierarchy .
*/
public class CustomerPortfolioDeleteBatch implements Database.Batchable<SObject> {
/**
* @description Iniciates the batch. Searches for Customer Portfolio records 
* with Source = 'External' that were deleted recently.
*/    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime startTimeWindow = Datetime.now().addHours(-3);    
        String query = 'SELECT User__c, Customer__c FROM Customer_Portfolio__c ' +
            'WHERE Source__c = \'External\' AND IsDeleted = true AND LastModifiedDate >= :startTimeWindow' +
            ' ALL ROWS';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Customer_Portfolio__c> scope) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for (Customer_Portfolio__c cp : scope) {
            userIds.add(cp.User__c);
            accountIds.add(cp.Customer__c);
        }
        if (userIds.isEmpty()) {
            return;
        }
        
        Set<Id> superiorUserIds = RoleHierarchyHelper.getSuperiorUserIds(userIds);
        if (superiorUserIds.isEmpty()) {
            return;
        }
        List<Customer_Portfolio__c> internalsToDelete = [
            SELECT Id FROM Customer_Portfolio__c
            WHERE Source__c = 'Internal'
            AND Customer__c IN :accountIds
            AND User__c IN :superiorUserIds
        ];
        
        if (!internalsToDelete.isEmpty()) {
            Database.delete(internalsToDelete, false);
        }
    }
public void finish(Database.BatchableContext bc) {
    System.debug('CustomerPortfolioDeleteBatch succeeded. Job ID: ' + bc.getJobId());
    if (!Test.isRunningTest()) {
         Database.executeBatch(new CustomerPortfolioUpsertBatch());
         System.debug('Starting the Upsert Batch');
    }
}
}