@isTest
private class CustomerPortfolioDeleteBatchTest {

    @isTest
    static void testBatchDeletesInternalRecordsOnUndelete() {
        List<UserRole> roles = TestDataFactory.createRoleHierarchy(
            new List<String>{'Test Director Del', 'Test Manager Del', 'Test User Del'}
        );

        User director = TestDataFactory.createUser('d_del', roles[0]);
        User manager = TestDataFactory.createUser('m_del', roles[1]);
        User jrUser = TestDataFactory.createUser('u_del', roles[2]);
        insert new List<User>{director, manager, jrUser};
        
        System.runAs(jrUser) {
            Account acc = TestDataFactory.createAccount('Test Account for Delete');
            insert acc;
            
            Customer_Portfolio__c externalPortfolio = TestDataFactory.createPortfolio(acc.Id, jrUser.Id, 'External');
            Customer_Portfolio__c internalPortfolio1 = TestDataFactory.createPortfolio(acc.Id, manager.Id, 'Internal');
            Customer_Portfolio__c internalPortfolio2 = TestDataFactory.createPortfolio(acc.Id, director.Id, 'Internal');
            insert new List<Customer_Portfolio__c>{externalPortfolio, internalPortfolio1, internalPortfolio2};

            Test.startTest();
                delete externalPortfolio;
                Database.executeBatch(new CustomerPortfolioDeleteBatch());
            Test.stopTest();

            List<Customer_Portfolio__c> remainingInternals = [SELECT Id FROM Customer_Portfolio__c WHERE Source__c = 'Internal'];      
            System.assertEquals(0, remainingInternals.size());
        }
    }
}