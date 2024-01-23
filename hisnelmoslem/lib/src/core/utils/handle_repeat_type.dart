import 'package:hisnelmoslem/generated/l10n.dart';

class HandleRepeatType {
  String getNameToPutInDatabase({required String chosenValue}) {
    if (chosenValue == S.current.daily) {
      return "Daily";
    } else if (chosenValue == S.current.every_saturday) {
      return "AtSaturday";
    } else if (chosenValue == S.current.every_sunday) {
      return "AtSunday";
    } else if (chosenValue == S.current.every_monday) {
      return "AtMonday";
    } else if (chosenValue == S.current.every_tuesday) {
      return "AtTuesday";
    } else if (chosenValue == S.current.every_wednesday) {
      return "AtWednesday";
    } else if (chosenValue == S.current.every_thursday) {
      return "AtThursday";
    } else if (chosenValue == S.current.every_friday) {
      return "AtFriday";
    } else {
      return "Daily";
    }
  }

  String getNameToUser({required String chosenValue}) {
    switch (chosenValue) {
      case "Daily":
        return S.current.daily;
      case "AtSaturday":
        return S.current.every_saturday;
      case "AtSunday":
        return S.current.every_sunday;
      case "AtMonday":
        return S.current.every_monday;
      case "AtTuesday":
        return S.current.every_tuesday;
      case "AtWednesday":
        return S.current.every_wednesday;
      case "AtThursday":
        return S.current.every_thursday;
      case "AtFriday":
        return S.current.every_friday;
      default:
        return S.current.daily;
    }
  }
}
