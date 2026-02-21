import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

class SX {
  static late final S _s;
  // ignore: use_setters_to_change_properties
  static void init(S s) {
    _s = s;
  }

  static String get appName => _s.appTitle;

  static S get current {
    final context = App.navigatorKey.currentState?.context;
    if (context == null) {
      return _s;
    }

    return S.of(context);
  }
}
