/**
*  This class coordinates the execution of the different steps that make up a Test
*  We need to coordinate these steps because they are executed using @future methods
*  The reasoning behind @future is that we need to execute callouts to Sauce Labs
*/
global class TestExecutionManager implements Schedulable, ITestExecutionManager{
      
    static ITest getTest(String testName, String os, String browser, String version) {                          
    /** This method provides the mapping between the Test as a record in salesforce.com
        and the test as an executable unit in salesforce.com. Use the following patern
        to make sure your tests are scheduled and executed correctly:
    
        if(testName.equalsIgnoreCase('Test Demo'))
            return new TestDemo(os, browser, version);  
         else
    */
             return null;
    }       
   
   global void execute(SchedulableContext sc) {   
       for(TestExecution__c sem:   [select Test__r.name, name, phase__c, session_id__c, inProgress__c, 
       os__c, browser__c, version__c
        from TestExecution__c where inProgress__c = false and phase__c != 'Done' and phase__c != 'Error' and phase__c != null FOR UPDATE]) {          
           TestExecutionManager.inFuture(sem.phase__c, sem.session_id__c, sem.Test__r.name, sem.name, sem.os__c, sem.browser__c, sem.version__c);
           sem.inProgress__c = true;
           update(sem);
       }   
   }
   
   @future (callout=true)
   global static void inFuture(String phase, String sessionId, String testName, String testCase, String os, String browser, String version) {
       ITest test = TestExecutionManager.getTest(testName, os, browser, version);
       TestExecutioner te = new TestExecutioner();
       te.run(test, phase, sessionId, testName, testCase, os, browser, version);       
   }
    
      
   public static void schedule() {
       TestExecutionManager s = new TestExecutionManager();
       integer minute = Datetime.now().minute();
       for(integer i=0;i<5;i++) {
           integer nextMinute = Math.mod((minute + i), 60);
           system.schedule('Test Execution Manager ' + i, '0 ' + nextMinute + ' * * * ?', s);
           system.schedule('Test Execution Manager ' + i + '.5', '30 ' + nextMinute + ' * * * ?', s);           
       }

   }
   
   public static void unschedule() {
 		for(CronTrigger ct: [select id from CronTrigger]) {
 			System.abortJob(ct.id);
 		}   		
   }    
}