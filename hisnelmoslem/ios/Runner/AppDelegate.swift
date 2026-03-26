import UIKit
import Flutter
import AVFoundation
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate {

  private var channel: FlutterMethodChannel?
  private var volumeObserver: VolumeButtonObserver?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    channel = FlutterMethodChannel(
      name: "volume_button_channel",
      binaryMessenger: controller.binaryMessenger
    )

    channel?.setMethodCallHandler { [weak self] call, _ in
      guard let self else { return }
      if call.method == "activate_volumeBtn", let activate = call.arguments as? Bool {
        activate ? self.startObserving() : self.stopObserving()
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func startObserving() {
    stopObserving()
    volumeObserver = VolumeButtonObserver { [weak self] event in
      self?.channel?.invokeMethod("volumeBtnPressed", arguments: event)
    }
    volumeObserver?.startObserving()
  }

  private func stopObserving() {
    volumeObserver?.stopObserving()
    volumeObserver = nil
  }
}