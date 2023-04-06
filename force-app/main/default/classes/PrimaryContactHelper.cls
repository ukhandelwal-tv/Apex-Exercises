public class PrimaryContactHelper {
    
    
    //Exercise 5 (i)
    public static void checkIsPrimary(List<Contact> contactList) {
        List<Id> accountIdList = new List<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact contact : contactList) {
            if (contact.isPrimary__c) {
            	accountIdList.add(contact.AccountId);
                contactMap.put(contact.AccountId, contact);
            }
        }
        
        List<Account> accountList = [Select Id, Name, (Select Id, isPrimary__c from Contacts) from Account where Id in :accountIdList];
        system.debug('accountList : '+ accountList);
        for (Account account : accountList) {
            Integer primaryAvailable = 0;
            for (Contact contact : account.Contacts) {
                if (contact.isPrimary__c) {
                    primaryAvailable++;
                }
            }
            if (primaryAvailable >1 && contactMap.containsKey(account.Id)) {
                contactMap.get(account.Id).addError('Primary Contact Already Exists');
            }
            
        }
    }
    
    
    //Exercise 5 (ii)
    public static void copyEmail(List<Contact> contactList){
        List<Id> accountIdList = new List<Id>();
        Map<Id,String> mapList=new Map<Id,String>();
        for(Contact conList:contactList)
        {
            
            if(conList.IsPrimary__c && conList.Email!=null)
            {
                accountIdList.add(conList.AccountId);
                mapList.put(conList.AccountId,conList.Email);
            }
        }
        List<Account> parentAccount = [Select Id, ParentId from Account where ParentId != null and Id IN :accountIdList];
        Map<Id,String> ParentEmail= new Map<Id,String>();
        List<Id> parentIdList = new List<Id>();
        for(Account acc : parentAccount)
        {
            ParentEmail.put(acc.ParentId, mapList.get(acc.Id));
            parentIdList.add(acc.ParentId);
        }
        
        List<Account> accountContact=[Select Id, (Select Id, IsPrimary__c,Email from Contacts) from Account where Id IN :parentIdList];
        List<Contact> updateEmailList = new List<Contact>();
        for(Account main : accountContact)
        {
            for(Contact con : main.Contacts)
            {
                if(con.IsPrimary__c)
                {
                    con.Email=ParentEmail.get(main.Id);
                }
                updateEmailList.add(con);
            }
        }
        update updateEmailList;
          
    }
    
    
    //Exercise 5 (iii)
    public static void countContacts(List<Contact> contactList){
        List <ID> accountID = new List <ID>();
       
        for(Contact con : contactList){
            accountID.add(con.AccountId);
        }
        
        AggregateResult[] countCon  = [SELECT Account.Id , count(Id) from Contact  group by Account.Id having Account.ID in :accountID];
        Map<Id, Integer>accountMap = new Map<Id, Integer>();
        for(AggregateResult result : countCon){
            accountMap.put((ID)result.get('Id'), (Integer)result.get('expr0'));
        } 
        List<Account>accountList = [SELECT Id, Contact_Count__c from Account Where Id in :accountMap.keyset()];
        for(Account account : accountList){
             account.Contact_Count__c = accountMap.get(account.Id);       
        }
        update accountList;
    }

}