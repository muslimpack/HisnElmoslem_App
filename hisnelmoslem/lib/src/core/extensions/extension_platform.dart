import 'dart:io';

import 'package:flutter/foundation.dart';

extension PlatformExtension on Platform {
  static bool get isDesktop {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  static bool get isDesktopOrWeb {
    return isDesktop || kIsWeb;
  }

  static bool get isPhone {
    return Platform.isAndroid || Platform.isIOS;
  }

  static String? get languageCode {
    final localeName = Platform.localeName;
    final String? languageCode = localeName.split("_").firstOrNull;
    return languageCode;
  }
}
