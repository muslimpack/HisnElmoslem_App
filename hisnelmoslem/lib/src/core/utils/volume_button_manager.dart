import 'dart:io';

import 'package:flutter/services.dart';

class VolumeButtonManager {
  static MethodChannel channel = const MethodChannel("volume_button_channel");

  void listen({
    Function()? onVolumeUpPressed,
    Function()? onVolumeDownPressed,
    Function()? onVolumeUpReleased,
    Function()? onVolumeDownReleased,
  }) {
    channel.setMethodCallHandler(
      (call) async {
        if (call.method == "volumeBtnPressed") {
          switch (call.arguments) {
            case "VOLUME_UP_DOWN":
              onVolumeUpPressed?.call();

            case "VOLUME_DOWN_DOWN":
              onVolumeUpPressed?.call();

            case "VOLUME_UP_UP":
              onVolumeUpReleased?.call();

            case "VOLUME_DOWN_UP":
              onVolumeDownReleased?.call();
          }
        }
      },
    );
  }

  Future<void> toggleActivation({required bool activate}) async {
    if (Platform.isAndroid) {
      await channel.invokeMethod(
        'activate_volumeBtn',
        activate,
      );
    }
  }

  void dispose() {
    channel.setMethodCallHandler(null);
  }
}
