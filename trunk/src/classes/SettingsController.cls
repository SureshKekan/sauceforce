public  class SettingsController {
	public void scheduleExecutionManager() {
		TestExecutionManager.schedule();		
	}
	
	public void cancelExecutionManager() {
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://na7.salesforce.com/ui/setup/apex/batch/ScheduleBatchApexPage?job_name=Test+Execution+Manager+1.5&delID=08eA00000008P6L&setupid=ScheduledJobs');
		req.setMethod('GET');
		req.setHeader('Cookie', 'sid=' + UserInfo.getSessionId());
		Http http = new Http();
		HttpResponse res = http.send(req);		
	}
}