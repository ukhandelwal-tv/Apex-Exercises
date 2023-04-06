public class EmployerAndConsultants {
    
     //Exercise 3 (i)
    public static List<String> NameOfConsultants(ID AccountID){
        List<Hiring__c> listOfHiring = [SELECT Consultant__r.Name FROM Hiring__c 
                                             WHERE Employer__r.ID = :AccountID ];
        List<String>listOfConsultants = new List<String>();
        for(Hiring__c h : listOfHiring){
            listOfConsultants.add(h.Consultant__r.Name);
         
        }
        return listOfConsultants;
    }
    
    //Exercise 3 (ii)
    public static map<Account, Set<Id>> ConsultantsID(){
        
        Map<Account, Set<Id>> mapOfConsultants = new Map<Account, Set<Id>>();
        List <Account> accountList = [SELECT Id, (select consultant__c from Hirings__r) from Account];
        Set<Id> consultantIDSet;
        for(Account a : accountList){
            consultantIDSet = new Set<Id>();
            for(Hiring__c h : a.Hirings__r){
                consultantIdSet.add(h.Consultant__c);
            }
            mapOfConsultants.put(a, consultantIdSet);
        }
        for(Account acc:mapOfConsultants.keySet()){
            system.debug(mapOfConsultants.get(acc));
        }
        return mapOfConsultants;
    }

}