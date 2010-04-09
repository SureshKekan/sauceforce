/**
*  Saves test context that is restored when test steps are scheduled in future
*/
global class TestContext {
    public TestContext(String sessionId) {
        this.sessionId = sessionId; 
    }
    global String sessionId{ get; set; }
}