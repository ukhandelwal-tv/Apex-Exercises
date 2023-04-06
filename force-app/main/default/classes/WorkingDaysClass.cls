public class WorkingDaysClass {
    public static Integer calculateWorkingDays(Date startDate, Date endDate){
        Integer d = startDate.daysBetween(endDate);
        DateTime dt1 = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
       
        Integer workingDays = 0;
        for(Integer i=0; i<d; i++){
            DateTime currDate = dt1.addDays(i);
            if(currDate.format('EEEE') != 'Sunday' && currDate.format('EEEE') != 'Saturday'){
                workingDays++;
            }
            //System.debug(currDate.format('EEEE'));
        }
        return workingDays;
    }
}