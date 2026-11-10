import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';

enum VolumeButtonEvent {
  volumeUpDown,
  volumeDownDown,
  volumeUpUp,
  volumeDownUp,
}

class VolumeButtonManager {
  static final VolumeButtonManager _instance = VolumeButtonManager._internal();

  factory VolumeButtonManager() {
    return _instance;
  }

  VolumeButtonManager._internal() {
    channel.setMethodCallHandler(
      (call) async {
        if (call.method == "volumeBtnPressed") {
          switch (call.arguments) {
            case "VOLUME_UP_DOWN":
              _streamController.add(VolumeButtonEvent.volumeUpDown);

            case "VOLUME_DOWN_DOWN":
              _streamController.add(VolumeButtonEvent.volumeDownDown);

            case "VOLUME_UP_UP":
              _streamController.add(VolumeButtonEvent.volumeUpUp);

            case "VOLUME_DOWN_UP":
              _streamController.add(VolumeButtonEvent.volumeDownUp);
          }
        }
      },
    );
  }

  static MethodChannel channel = const MethodChannel("volume_button_channel");

  final StreamController<VolumeButtonEvent> _streamController =
      StreamController<VolumeButtonEvent>.broadcast();

  Stream<VolumeButtonEvent> get stream => _streamController.stream;

  Future<void> toggleActivation({required bool activate}) async {
    // The native volume-button channel only exists on Android/iOS.
    if (PlatformExtension.isDesktopOrWeb) return;

    try {
      await channel.invokeMethod(
        'activate_volumeBtn',
        activate,
      );
    } on MissingPluginException {
      // Platform without a native implementation; nothing to toggle.
    }
  }

  void dispose() {
    toggleActivation(activate: false);
  }
}
