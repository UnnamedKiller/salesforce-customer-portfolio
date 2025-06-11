/**
 * @description Scheduler to iniciate the Customer Portfolio sync batches jobs.
 */
public class CustomerPortfolioBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<AsyncApexJob> runningJobs = [
            SELECT Id FROM AsyncApexJob 
            WHERE JobType = 'BatchApex' 
            AND Status IN ('Queued', 'Processing')
            AND ApexClass.Name IN ('CustomerPortfolioDeleteBatch', 'CustomerPortfolioUpsertBatch')
        ];
        if (runningJobs.isEmpty()) {
            Database.executeBatch(new CustomerPortfolioDeleteBatch());
        }
    }
}