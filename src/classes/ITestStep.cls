/**
*  Represents the code that will run when the TestExecutionManager schedules a test
*/
global interface ITestStep {
    // return true if this is not last step
    boolean execute(ITest test, TestContext tc);
}