global class TestCloudTest {
    @isTest
    static void testTestExecutionerExecute() {
        TestExecutioner te = new TestExecutioner();
        te.execute(null, new FakeTestExecutionManager());
    }
 
    @isTest
    static void testTestExecutionManagerRun() {
        TestExecutioner te = new TestExecutioner();
        Test__c test = new Test__c();
        test.name = 'Fake Test';
        insert(test); 
        TestExecution__c t = new TestExecution__c();
        t.test__c = test.id;
        t.inProgress__c = true;
        insert(t);
        t = [select name from TestExecution__c where id = :t.id];
        te.run(new FakeTest(), '1', 'abc', t.name, t.name, 'Linux', 'firefox', '3');
    }

    @isTest
    static void testTestExecutionManagerRunWithException() {
        TestExecutioner te = new TestExecutioner();
        Test__c test = new Test__c();
        test.name = 'Fake Test';
        insert(test); 
        TestExecution__c t = new TestExecution__c();
        t.test__c = test.id;
        t.inProgress__c = true;
        insert(t);
        t = [select name from TestExecution__c where id = :t.id];
        try {
            te.run(new FakeTest(true), '1', 'abc', t.name, t.name, 'Linux', 'firefox', '3');
        }catch(selenium1.SeleniumException e) {}
    }
    
    @isTest
    static void testSauceTest() {
        if(TestCloudConfig__c.getInstance()==null)
    		return;
        FakeSauceTest st = new FakeSauceTest();
        st.setUp();
        st.tearDown('abc');        
    }
    
    global class FakeSauceTest extends SauceTest {
        global override ITestStep getStep(integer step) { return null; }
        selenium1.CommandProcessor a = new selenium1.ApexSeleniumTestSuite.FakeCommandProcessor();
        public override selenium1.DefaultSelenium makeSelenium() { return new selenium1.DefaultSelenium(a); }
    }
    
    global class FakeTestExecutionManager implements ITestExecutionManager {
       global void inFuture(String phase, String sessionId, String testName, String testCase, String os, String browser, String version) {}
    }
    
    
    global class FakeTest implements ITest {
        private boolean throwException = false;
        public FakeTest() {
            this(false);
        }

        public FakeTest(boolean throwException) {
            this.throwException  = throwException;
        }
    
        global String setUp() { return 'setUp'; }
        global ITestStep getStep(integer step) { return new FakeTestStep(this.throwException); }
        global void tearDown(String sessionId) { }
        global selenium1.DefaultSelenium getSelenium(String sessionId) { return null;}
    }
    
    global class FakeTestStep implements ITestStep {
        private boolean throwException = false;
        public FakeTestStep(boolean throwException) {
            this.throwException  = throwException;
        }
        global boolean execute(ITest test, TestContext tc) { 
            if(this.throwException) throw new selenium1.SeleniumException();
            return false; 
        }
    } 
   
}