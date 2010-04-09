public class TestExecutionExtension {
	private final testcloud1__TestExecution__c testExec;
	public TestExecutionExtension(ApexPages.StandardController controller) { if(controller!=null) this.testExec = (testcloud1__TestExecution__c)controller.getRecord();}

    public String SauceUser {
        get {
            if(testcloud1__TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return testcloud1__TestCloudConfig__c.getInstance().testcloud1__sauce_username__c;
        }
    }
    
    public String SauceAccessKey {
        get {
            if(testcloud1__TestCloudConfig__c.getInstance()==null)
                return null;
            else
                return testcloud1__TestCloudConfig__c.getInstance().testcloud1__sauce_access_key__c;
        }
    }

	public void schedule() {
		if(isSchedulable()) {
			testExec.testcloud1__Phase__c = 'Scheduled';
			update(testExec);
		}			
	}
	
	private boolean isSchedulable() {
		return !testExec.testcloud1__InProgress__c && isInactive();
	}
	
	private boolean isInactive() {
		return ((testExec.testcloud1__Phase__c==null)||(testExec.testcloud1__Phase__c=='Done')||(testExec.testcloud1__Phase__c=='Error'));
	}

	@isTest
	static void TestTestExecutionExtension() {
		TestExecutionExtension sc = new TestExecutionExtension((ApexPages.StandardController)null);
   		if(testcloud1__TestCloudConfig__c.getInstance()==null) {
	   		System.assertEquals(null, sc.SauceUser);
	   		System.assertEquals(null, sc.SauceAccessKey);
   		} else {
	   		System.assertNotEquals(null, sc.SauceUser);
	   		System.assertNotEquals(null, sc.SauceAccessKey);   			
   		}
		
	}
}