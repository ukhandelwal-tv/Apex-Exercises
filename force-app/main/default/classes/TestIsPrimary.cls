@isTest
public class TestIsPrimary {
    @isTest static void testMethod2(){
        Account ac1 = new Account(Name = 'Account 1');
        Account ac2 = new Account(Name = 'Account 2');
        insert ac1;
        insert ac2;
         
        Contact con1 = new Contact(LastName='con1', isPrimary__c=false, AccountId=ac1.Id);
        insert con1;
        Contact con2 = new Contact(LastName='con2', isPrimary__c=true, AccountId=ac1.Id);
        insert con2;
        
        Contact con3 = new Contact(LastName='con3', isPrimary__c=false, AccountId=ac2.Id);
        insert con3;
        Contact con4 = new Contact(LastName='con4', isPrimary__c=true, AccountId=ac2.Id);
        insert con4;
        
        con3.isPrimary__c = true;
        try{
            update con3;
        }catch(Exception e){
            system.assertEquals(true, e.getMessage().contains('Primary Contact Already Exists'));
        }  
    }
    
    @istest public static void testMethod1(){
        Account ac11 = new Account(Name = 'Account 11');
        insert ac11;
        Account ac22 = new Account(Name = 'Account 22' );
        insert ac22;
        ac22.ParentID = ac11.Id;
        update ac22; 
        
        Contact con11 = new Contact(LastName='con11', isPrimary__c=true, AccountId=ac11.Id, Email='test11@gmail.com');
        insert con11;
        Contact con22 = new Contact(LastName='con22', isPrimary__c=true, AccountId=ac22.Id, Email='test22@gmail.com');
        insert con22;
        
    }
    
}