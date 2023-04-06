public class ClosedWonOpportunityHelper {
    public static void restrictUser(List<Account>accountList){
        for(Account account : accountList){
            //List<Account>accountOppList = [SELECT ID, Name, (SELECT ID, StageName from Opportunities) from Account WHERE ID in :accountList];
            List <Opportunity>oppList = [SELECT ID, StageName, AccountId from Opportunity WHERE AccountId = :account.id];
            boolean allClosedWon = true;
            for(Opportunity opp : oppList){
                if(opp.StageName != 'Closed Won'){
                    allClosedWon = false;
                    break;
                }
            }
            if(allClosedWon){
                account.id.addError('User cannot delete the account');
            }
            else{
                Delete account;
            }
        }
    }
}