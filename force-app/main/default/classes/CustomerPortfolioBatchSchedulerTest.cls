@isTest
private class CustomerPortfolioBatchSchedulerTest {

    @isTest
    static void testSchedulerExecutesBatch() {
        Test.startTest();
        
        String jobName = 'Test Portfolio Sync';
        String cronExpression = '0 0 10 * * ?';
        System.schedule(jobName, cronExpression, new CustomerPortfolioBatchScheduler());

        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE JobType = 'BatchApex'
        ];
        System.assertEquals(1, jobs.size());
        System.assertEquals('CustomerPortfolioDeleteBatch', jobs[0].ApexClass.Name);
    }
}