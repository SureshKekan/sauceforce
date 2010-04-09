trigger resetExecution on testcloud1__TestExecution__c (before insert, before update) {
    for(testcloud1__TestExecution__c te: Trigger.new) {
        if ((te.testcloud1__phase__c!=null) && (te.testcloud1__phase__c.equalsIgnoreCase('Scheduled')))
            te.testcloud1__seleniumserverlog__c = null;
    }
}