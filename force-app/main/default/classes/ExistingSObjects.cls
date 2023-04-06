public class ExistingSObjects {
    public static List<String> returnSObjects(){
        List<String> SObjectList = new List<String>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().values()){
            String name = objTyp.getDescribe().getName();
            SobjectList.add(name);
        }
        return SObjectList;
    }
}