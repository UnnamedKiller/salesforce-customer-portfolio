@isTest
private class CustomerPortfolioUpsertBatchTest {
    
    @isTest
    static void testBatchCreatesInternalRecords() {
        List<UserRole> roles = TestDataFactory.createRoleHierarchy(new List<String>{'Director Upsert', 'Manager Upsert', 'User Upsert'});
        User director = TestDataFactory.createUser('d_upsert', roles[0]);
        User manager = TestDataFactory.createUser('m_upsert', roles[1]);
        User jrUser = TestDataFactory.createUser('u_upsert', roles[2]);
        insert new List<User>{director, manager, jrUser};
            
            System.runAs(jrUser) {
                Account acc = TestDataFactory.createAccount('Test Account for Upsert');
                insert acc;
                
                Test.startTest();
                Customer_Portfolio__c externalPortfolio = TestDataFactory.createPortfolio(acc.Id, jrUser.Id, 'External');
                insert externalPortfolio;
                
                Database.executeBatch(new CustomerPortfolioUpsertBatch());
                Test.stopTest();
                
                List<Customer_Portfolio__c> createdInternals = [SELECT Id FROM Customer_Portfolio__c WHERE Source__c = 'Internal'];
                System.assertEquals(2, createdInternals.size());
            }
    }
    
    @isTest
    static void testBatchDoesNotCreateDuplicates() {
        List<UserRole> roles = TestDataFactory.createRoleHierarchy(new List<String>{'Director NoDup', 'Manager NoDup', 'User NoDup'});
        User director = TestDataFactory.createUser('d_nodup', roles[0]);
        User manager = TestDataFactory.createUser('m_nodup', roles[1]);
        User jrUser = TestDataFactory.createUser('u_nodup', roles[2]);
        insert new List<User>{director, manager, jrUser};
            
            System.runAs(jrUser) {
                Account acc = TestDataFactory.createAccount('Test Account for No-Dup');
                insert acc;
                
                Customer_Portfolio__c existingManagerPortfolio = TestDataFactory.createPortfolio(acc.Id, manager.Id, 'Internal');
                insert existingManagerPortfolio;
                
                Test.startTest();
                Customer_Portfolio__c externalPortfolio = TestDataFactory.createPortfolio(acc.Id, jrUser.Id, 'External');
                insert externalPortfolio;
                
                Database.executeBatch(new CustomerPortfolioUpsertBatch());
                Test.stopTest();
                
                List<Customer_Portfolio__c> createdInternals = [SELECT Id FROM Customer_Portfolio__c WHERE Source__c = 'Internal'];
                System.assertEquals(2, createdInternals.size());
            }
    }
}