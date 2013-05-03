/**
* abstract implementation of a test that is going to run on sauce labs
*/
global abstract class SauceTest implements ITest{
    
    global SauceTest (String os, String browser, String version) {
        this.os = os;
        this.browser = browser;
        this.version = version;
    }    
                
    global String setUp() {
        selenium1.DefaultSelenium s = makeSelenium();        
        String sessionId = s.start();
        login(s);
        return sessionId;                    
    }

    global abstract ITestStep getStep(integer step);

    global void tearDown(String sessionId) {
        selenium1.DefaultSelenium s = getSelenium(sessionId);        
        s.stop();       
    }

    global selenium1.DefaultSelenium getSelenium(String sessionId) {
        selenium1.DefaultSelenium s = makeSelenium();
        s.start(sessionId);
        return s;                           
    }

    public void login(selenium1.DefaultSelenium s) {
        s.open('/');
        s.type('username', TestCloudConfig__c.getInstance().username__c);
        s.type('password', TestCloudConfig__c.getInstance().password__c);
        s.clickAndWait('css=input.loginButton');    
    }
        
    public virtual selenium1.DefaultSelenium makeSelenium() {
        selenium1.DefaultSelenium s = new selenium1.DefaultSelenium(TestCloudConfig__c.getInstance().sfdc_login_url__c
        , TestCloudConfig__c.getInstance().selenium_proxy_url__c, TestCloudConfig__c.getInstance().selenium_proxy_port__c.intValue(), 
        getConnectionString());
        return s;
    }

    public SauceTest () {
        this('Linux', 'firefox', '3.');
    }

    private String getConnectionString() {
       return '{\"username\": \"' + TestCloudConfig__c.getInstance().sauce_username__c + 
       '\", \"access-key\": \"' + TestCloudConfig__c.getInstance().sauce_access_key__c + 
       '\", \"os\": \"' + os + '\", \"browser\": \"' + browser + '\", \"browser-version\": \"' + version + '\", \"max-duration\": \"300\"}';
    }

    private String os;
    private String browser;
    private String version;

}