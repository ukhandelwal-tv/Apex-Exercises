trigger primaryContact on Contact (before insert, before update) {
    switch on Trigger.operationType {
       when BEFORE_INSERT {
        	PrimaryContactHelper.copyEmail(Trigger.new);
            PrimaryContactHelper.checkIsPrimary(Trigger.new);
        }
        when BEFORE_UPDATE {
            PrimaryContactHelper.checkIsPrimary(Trigger.new);
        	PrimaryContactHelper.copyEmail(Trigger.new);
        }
        
    }
}