/**
*  Represents what a Test should be: a setup step, a teardown step, and steps in between
*/
global interface ITest {
    String setUp();
    ITestStep getStep(integer step);
    void tearDown(String sessionId);
    selenium1.DefaultSelenium getSelenium(String sessionId);
}