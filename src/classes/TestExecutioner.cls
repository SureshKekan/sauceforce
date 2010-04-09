global class TestExecutioner { 
   global void execute(SchedulableContext sc, ITestExecutionManager tem) {
       for(TestExecution__c sem:   [select Test__r.name, name, phase__c, session_id__c, inProgress__c, os__c, browser__c, version__c
        from TestExecution__c where inProgress__c = false and phase__c != 'Done' and phase__c != 'Error' and phase__c != null FOR UPDATE]) {          
           tem.inFuture(sem.phase__c, sem.session_id__c, sem.Test__r.name, sem.name, sem.os__c, sem.browser__c, sem.version__c);
           sem.inProgress__c = true;
           update(sem);
       }
   }
   
   global void run(ITest test, String phase, String sessionId, String testName, String testCase, String os, String browser, String version) {
       System.Exception oe=null;
       String serverLog=null;
   
       try {           
           TestContext tc = new TestContext(sessionId);
           if(phase=='Scheduled')  {  
               sessionId = test.setUp();
               phase = '1';             
           }else if(phase.equalsignorecase('tearDown'))  { 
               test.tearDown(sessionId);
               phase = 'Done';
           }else /* test steps*/  {
               integer ip =  integer.valueOf(phase);  
               ITestStep step = test.getStep(ip);
               if(step!=null) {                 
                    if(step.execute(test, tc))
                        phase = string.valueOf(ip+1);
                    else
                        phase = 'tearDown';
               }  else {
                phase = 'tearDown';
               }                                               
           } 
       } catch(System.Exception e) {           
           oe = e;            
           try { test.tearDown(sessionId); } catch (System.Exception ex) {} // if we fail during tear down just continue
           try { serverLog = getServerLog(sessionId); } catch (System.Exception ex) { serverLog = 'Could not retrieve server log: \n' + ex.getMessage();} // if we fail during tear down just continue              
           phase = 'Error';
       } finally {
           TestExecution__c sem = [select phase__c, session_id__c, inProgress__c, seleniumServerLog__c from TestExecution__c where name = :testCase and inProgress__c = true FOR UPDATE];
           sem.phase__c = phase;
           sem.session_id__c = sessionId;
           sem.inProgress__c = false;
           if (oe!=null) sem.seleniumServerLog__c = oe.getMessage();
           if (serverLog!=null) sem.seleniumServerLog__c += '\n' + serverLog;
           update(sem);
           if (oe!=null) throw oe; 
       }       
   }
   
   private static String getServerLog(String sessionId) {
           HttpRequest req = new HttpRequest();
            String username = TestCloudConfig__c.getInstance().testcloud1__sauce_username__c;                                    
            String password = TestCloudConfig__c.getInstance().testcloud1__sauce_access_key__c;
           
           req.setEndpoint('https://saucelabs.com/rest/' + username + '/jobs/' + sessionId + '/results/selenium-server.log');
           req.setMethod('GET');
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            return res.getBody();                      
   }
   
}