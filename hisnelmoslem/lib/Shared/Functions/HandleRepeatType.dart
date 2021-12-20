class HandleRepeatType
{
 String  getNameToPutInDatabase({required String chosenValue})
 {
   switch (chosenValue) {
     case "يوميا":
       return "Daily";
     case "كل سبت":
       return "AtSaturday";
     case "كل أحد":
       return "AtSunday";
     case "كل إثنين":
       return "AtMonday";
     case "كل ثلاثاء":
       return "AtTuesday";
     case "كل أربعاء":
       return "AtWednesday";
     case "كل خميس":
       return "AtThursday";
     case "كل جمعة":
       return "AtFriday";
     default:
       return "Daily";
   }
 }

 String getNameToUser({required String chosenValue})
 {
   switch (chosenValue) {
     case "Daily":
       return "يوميا";
     case "AtSaturday":
       return "كل سبت";
     case "AtSunday":
       return "كل أحد";
     case "AtMonday":
       return "كل إثنين";
     case "AtTuesday":
       return "كل ثلاثاء";
     case "AtWednesday":
       return "كل أربعاء";
     case "AtThursday":
       return "كل خميس";
     case "AtFriday":
       return "كل جمعة";
     default:
       return "يوميا";
   }
 }



}