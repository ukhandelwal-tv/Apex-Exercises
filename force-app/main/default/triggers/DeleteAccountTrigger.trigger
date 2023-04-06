trigger DeleteAccountTrigger on Account (before delete) {
    switch on Trigger.operationType {
        when BEFORE_DELETE {
        	//ClosedWonOpportunityHelper.restrictUser(Trigger.new);
        }
    }
}