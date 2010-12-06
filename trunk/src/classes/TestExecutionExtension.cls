public class TestExecutionExtension {
	private final TestExecution__c testExec;
	public TestExecutionExtension(ApexPages.StandardController controller) { if(controller!=null) this.testExec = (TestExecution__c)controller.getRecord();}

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

	public void schedule() {
		if(isSchedulable()) {
			testExec.Phase__c = 'Scheduled';
			update(testExec);
		}			
	}
	
	private boolean isSchedulable() {
		return !testExec.InProgress__c && isInactive();
	}
	
	private boolean isInactive() {
		return ((testExec.Phase__c==null)||(testExec.Phase__c=='Done')||(testExec.Phase__c=='Error'));
	}

	@isTest
	static void TestTestExecutionExtension() {
		TestExecutionExtension sc = new TestExecutionExtension((ApexPages.StandardController)null);
   		if(TestCloudConfig__c.getInstance()==null) {
	   		System.assertEquals(null, sc.SauceUser);
	   		System.assertEquals(null, sc.SauceAccessKey);
   		} else {
	   		System.assertNotEquals(null, sc.SauceUser);
	   		System.assertNotEquals(null, sc.SauceAccessKey);   			
   		}
		
	}
}