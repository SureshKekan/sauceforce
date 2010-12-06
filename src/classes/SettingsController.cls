public  class SettingsController {

    private static final String INSTANCE = 'na7';
    
    public List<String> settingsCheck {
        get {
            List<String> problems = new List<String>();
            // 1. check sauce related custom settings
            if((TestCloudConfig__c.getInstance()==null)
            || (TestCloudConfig__c.getInstance().sauce_username__c==null)
            || (TestCloudConfig__c.getInstance().sauce_access_key__c==null)
            || (TestCloudConfig__c.getInstance().selenium_proxy_url__c==null)
            || (TestCloudConfig__c.getInstance().selenium_proxy_port__c==null))
                problems.add('PROBLEM: Sauce settings not found. Check the values for your SauceLabs Accounts in the Custom Settings setup.');

            // 2. check salesforce custom settings
            if((TestCloudConfig__c.getInstance()==null)
            || (TestCloudConfig__c.getInstance().SFDC_Login_URL__c==null)
            || (TestCloudConfig__c.getInstance().Username__c==null)
            || (TestCloudConfig__c.getInstance().Password__c==null))
                problems.add('PROBLEM: Salesforce settings not found. Check the values for your Salesforce test org in the Custom Settings setup.');

            // 3. Execution Manager
            integer scheduler = [select count() from CronTrigger];
            if(scheduler==0)
                problems.add('PROBLEM: The Execution Manager is NOT running. Go to the \'Execution Manager\' section to start it.');

            // 4. Remote Sites Settings
            if((TestCloudConfig__c.getInstance()!=null)
            && (TestCloudConfig__c.getInstance().sauce_username__c!=null)
            && (TestCloudConfig__c.getInstance().sauce_access_key__c!=null)
            && (TestCloudConfig__c.getInstance().selenium_proxy_url__c!=null)
            && (TestCloudConfig__c.getInstance().SFDC_Login_URL__c!=null)
            && (TestCloudConfig__c.getInstance().Username__c!=null)
            && (TestCloudConfig__c.getInstance().Password__c!=null)){            
                TestSauceForce t = new TestSauceForce('purposedly invalid os','firefox','3');
                try {
                    selenium1.DefaultSelenium s = t.getSelenium(null);
                    s.start();  
                    s.stop();
                } catch (Exception e) {
                    if(!e.getMessage().equalsIgnoreCase('ERROR: Unsupported OS/browser/version combo'))
                        problems.add('PROBLEM: Remote sites are probably not configured: ' + e.getMessage());
                }                      
            }
            
                
            if(problems.size()==0)
                problems.add('The org is correctly configured to start running tests.');
            return problems;
        }
    }
        
    static public void cancelExecutionManager() {
        // TODO how do we figure out the name  of the scheduled jobs? hardcoding it for now
        for(integer i=0;i<5;i++) {
            deleteJob('Test+Execution+Manager+' + i);
            deleteJob('Test+Execution+Manager+' + i + '.5');
        }
    }
    
    static private void deleteJob(String jobName) {
        // TODO hack alert: no way to programatically cancel the jobs as of winter '10. Hack url to delete it for now
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://' + INSTANCE + '.salesforce.com/ui/setup/apex/batch/ScheduleBatchApexPage?job_name=' + jobName + '&delID=08eA00000008P6L');
        req.setMethod('GET');
        // TODO make this run from visualforce, we need a salesforce.com session id not a force.com one. Make users run from System Log for now
        req.setHeader('Cookie', 'sid=' + UserInfo.getSessionId());
                
        Http http = new Http();
        HttpResponse res = http.send(req);      
    
    }
    
    public void scheduleExecutionManager() {
        TestExecutionManager.schedule();        
    }

    public void unscheduleExecutionManager() {
        TestExecutionManager.unschedule();        
    }
    
    public boolean isScheduled {
    	get {
    		return [select count() from crontrigger] > 0;
    	}
    }
    
    public String SauceUser {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().sauce_username__c;
        }
    }
    
    public String SauceAccessKey {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().sauce_access_key__c;
        }
    }

    public String SauceSeleniumProxy {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().selenium_proxy_url__c;
        }
    }

    public String SauceSeleniumPort {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else {
                decimal port = TestCloudConfig__c.getInstance().selenium_proxy_port__c;
                if (port==null)
                    return null;
                else
                    return String.valueOf(port.intValue());
            }
        }
    }
    
    public String SalesoforceLoginUrl {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().SFDC_Login_URL__c;
        }
    }

    public String SalesoforceTestOrgUsername {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().Username__c;
        }
    }

    public String SalesoforceTestOrgPassword {
        get {
            if(TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return TestCloudConfig__c.getInstance().Password__c;
        }
    }
    
    private static void writeDefaults() {
    	TestCloudConfig__c config = new TestCloudConfig__c(setupOwnerId = System.Userinfo.getUserId());
		config.username__c = 'yn@sauce.org';
		config.password__c = 'test1234';
		config.sfdc_login_url__c = 'http://login.salesforce.com';
		
		config.selenium_proxy_url__c = 'rc.saucelabs.com';
		config.selenium_proxy_port__c = 7444;
		
		config.sauce_username__c = 'luisdmaya';
		config.sauce_access_key__c = '14539675-e267-4264-9471-2ebc284fffb5';
		
		insert config;    	
    }
    
}