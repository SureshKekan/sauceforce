trigger resetExecution on TestExecution__c (before insert, before update) {
    for(TestExecution__c te: Trigger.new) {
        if ((te.phase__c!=null) && (te.phase__c.equalsIgnoreCase('Scheduled')))
            te.seleniumserverlog__c = null;
    }
}