@isTest
public class PrimaryContactTest {
    
    @testSetup static void setup() {
        Account account = new Account(
            Name = 'Utkarsh'
        );
        insert account;
        
        Contact contact1 = new Contact(AccountId = account.Id, LastName = 'ABC', isPrimary__c = true);
        Contact contact2 = new Contact(AccountId = account.Id, LastName = 'XYZ', isPrimary__c = true);
        //List<Contact> contactList = new List<Contact>();
        //contactList.add(contact1);
        //contactList.add(contact2);
        //insert contactList;
        
        insert contact1;
        insert contact2;
    }
    
    @isTest static void test() {
        List<Account> accountList = [Select Id, Name, (Select Id, LastName, isPrimary__c from Contacts) from Account];
        
        for (Account account : accountList) {
            System.debug('Account Name : ' + account.Name);
            for (Contact contact : account.Contacts) {
                System.debug('Contact Name : ' + contact.LastName + ', isPrimary__c : ' + contact.isPrimary__c);
            }
        }
    }

}