import 'package:get/get.dart';

class HandleRepeatType {
  String getNameToPutInDatabase({required String chosenValue}) {
    /* switch (chosenValue) {
      case "daily".tr:
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
    }*/
    if (chosenValue == "daily".tr) {
      return "Daily";
    } else if (chosenValue == "every saturday".tr) {
      return "AtSaturday";
    } else if (chosenValue == "every sunday".tr) {
      return "AtSunday";
    } else if (chosenValue == "every monday".tr) {
      return "AtMonday";
    } else if (chosenValue == "every tuesday".tr) {
      return "AtTuesday";
    } else if (chosenValue == "every wednesday".tr) {
      return "AtWednesday";
    } else if (chosenValue == "every thursday".tr) {
      return "AtThursday";
    } else if (chosenValue == "every Friday".tr) {
      return "AtFriday";
    } else {
      return "Daily";
    }
  }

  String getNameToUser({required String chosenValue}) {
    switch (chosenValue) {
      case "Daily":
        return "daily".tr;
      case "AtSaturday":
        return "every saturday".tr;
      case "AtSunday":
        return "every sunday".tr;
      case "AtMonday":
        return "every monday".tr;
      case "AtTuesday":
        return "every tuesday".tr;
      case "AtWednesday":
        return "every wednesday".tr;
      case "AtThursday":
        return "every thursday".tr;
      case "AtFriday":
        return "every Friday".tr;
      default:
        return "daily".tr;
    }
  }
}
