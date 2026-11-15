import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects NON-SENSITIVE facts that help to reproduce a problem.
///
/// Deliberately left out: device identifiers (Android ID, serial, IDFV), accounts, location,
/// network info, the user's own azkar, and file paths.
abstract class DeviceInfoCollector {
  /// Ordered label -> value pairs, shown to the user before they agree to share them.
  Future<Map<String, String>> collect();
}

class PlatformDeviceInfoCollector implements DeviceInfoCollector {
  PlatformDeviceInfoCollector({
    required this.packageInfo,
    required this.appLanguage,
    required this.appSettings,
    DeviceInfoPlugin? plugin,
  }) : _plugin = plugin ?? DeviceInfoPlugin();

  final PackageInfo Function() packageInfo;
  final String Function() appLanguage;

  /// App toggles that influence behaviour (sound, vibration, ...), already as text.
  final Map<String, String> Function() appSettings;
  final DeviceInfoPlugin _plugin;

  @override
  Future<Map<String, String>> collect() async {
    final info = <String, String>{};
    try {
      final app = packageInfo();
      info['App version'] = '${app.version} (${app.buildNumber})';
      info['App package'] = app.packageName;
    } catch (e) {
      hisnPrint(e);
    }

    info.addAll(await _platformInfo());

    final view = PlatformDispatcher.instance.views.firstOrNull;
    if (view != null) {
      final size = view.physicalSize;
      info['Screen'] =
          '${size.width.round()}x${size.height.round()} @${view.devicePixelRatio.toStringAsFixed(2)}x';
    }
    final dispatcher = PlatformDispatcher.instance;
    info['Device language'] = dispatcher.locale.toLanguageTag();
    info['App language'] = appLanguage();
    info['System theme'] = dispatcher.platformBrightness.name;
    info['Text scale'] = dispatcher.textScaleFactor.toStringAsFixed(2);
    info['Time zone'] = DateTime.now().timeZoneName;

    try {
      info.addAll(appSettings());
    } catch (e) {
      hisnPrint(e);
    }
    return info;
  }

  Future<Map<String, String>> _platformInfo() async {
    try {
      if (Platform.isAndroid) {
        final a = await _plugin.androidInfo;
        return {
          'Platform': 'Android ${a.version.release} (SDK ${a.version.sdkInt})',
          'Device': '${a.manufacturer} ${a.model}',
          'Physical device': '${a.isPhysicalDevice}',
        };
      }
      if (Platform.isIOS) {
        final i = await _plugin.iosInfo;
        return {
          'Platform': 'iOS ${i.systemVersion}',
          'Device': i.utsname.machine,
          'Physical device': '${i.isPhysicalDevice}',
        };
      }
      if (Platform.isWindows) {
        final w = await _plugin.windowsInfo;
        return {
          'Platform': '${w.productName} ${w.displayVersion}',
          'Build': '${w.buildNumber}',
        };
      }
    } catch (e) {
      hisnPrint(e);
    }
    return {'Platform': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'};
  }
}
