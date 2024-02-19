import 'package:get_storage/get_storage.dart';

class LocalRepo {
  final box = GetStorage();

  LocalRepo._();

  static LocalRepo instance = LocalRepo._();

  String allowNotificationDialogKey = "allowNotificationDialog";
  bool get allowNotificationDialog {
    final value = box.read<bool?>(allowNotificationDialogKey);
    if (value == null) {
      return true;
    } else {
      return value;
    }
  }

  Future allowNotificationDialogChange(bool show) async {
    return box.write(allowNotificationDialogKey, show);
  }
}
