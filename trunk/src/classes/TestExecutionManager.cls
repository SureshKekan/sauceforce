/**
*  This class coordinates the execution of the different steps that make up a Test
*  We need to coordinate these steps because they are executed using @future methods
*  The reasoning behind @future is that we need to execute callouts to Sauce Labs
*/
global class TestExecutionManager implements Schedulable, testcloud1.ITestExecutionManager{
      
    static testcloud1.ITest getTest(String testName, String os, String browser, String version) {                          
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
       for(testcloud1__TestExecution__c sem:   [select testcloud1__Test__r.name, name, testcloud1__phase__c, testcloud1__session_id__c, testcloud1__inProgress__c, 
       testcloud1__os__c, testcloud1__browser__c, testcloud1__version__c
        from testcloud1__TestExecution__c where testcloud1__inProgress__c = false and testcloud1__phase__c != 'Done' and testcloud1__phase__c != 'Error' and testcloud1__phase__c != null FOR UPDATE]) {          
           TestExecutionManager.inFuture(sem.testcloud1__phase__c, sem.testcloud1__session_id__c, sem.testcloud1__Test__r.name, sem.name, sem.testcloud1__os__c, sem.testcloud1__browser__c, sem.testcloud1__version__c);
           sem.testcloud1__inProgress__c = true;
           update(sem);
       }   
   }
   
   @future (callout=true)
   global static void inFuture(String phase, String sessionId, String testName, String testCase, String os, String browser, String version) {
       testcloud1.ITest test = TestExecutionManager.getTest(testName, os, browser, version);
       testcloud1.TestExecutioner te = new testcloud1.TestExecutioner();
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