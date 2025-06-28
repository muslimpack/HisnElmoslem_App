import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get humanize {
    return DateFormat(kDateTimeHumanFormat).format(this);
  }
}
