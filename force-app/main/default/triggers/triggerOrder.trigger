trigger triggerOrder on Order (after update) {
    switch on Trigger.operationType {
       when AFTER_UPDATE {
           OrderToAssetHelper.CreateAssetRecord(Trigger.new, Trigger.oldMap);
           OrderToAssetHelper.updateAssetStatus(Trigger.new, Trigger.oldMap);
           OrderToAssetHelper.createUserRecord(Trigger.new, Trigger.oldMap);
           OrderToAssetHelper.checkDripCampaign(Trigger.new, Trigger.oldMap);
        }
    }
}