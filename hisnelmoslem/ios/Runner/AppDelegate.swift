import UIKit
import Flutter
import AVFoundation
import MediaPlayer
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    // MARK: - Properties

    private var methodChannel: FlutterMethodChannel?
    private var volumeObserver: VolumeButtonObserver?

    // MARK: - App lifecycle

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        setupVolumeChannel()
        setupNotificationDelegate()
        registerForLifecycleNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Setup

    private func setupVolumeChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            assertionFailure("Root view controller is not a FlutterViewController")
            return
        }

        let channel = FlutterMethodChannel(
            name: "volume_button_channel",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }

            switch call.method {
            case "activate_volumeBtn":
                guard let activate = call.arguments as? Bool else {
                    result(FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "Expected Bool argument",
                        details: nil
                    ))
                    return
                }
                activate ? self.startObserving() : self.stopObserving()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        methodChannel = channel
    }

    private func setupNotificationDelegate() {
        // FlutterAppDelegate already conforms to UNUserNotificationCenterDelegate;
        // no cast needed — just assign self directly.
        UNUserNotificationCenter.current().delegate = self
    }

    private func registerForLifecycleNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Lifecycle notifications

    @objc private func appDidEnterBackground() {
        // Pause observation while backgrounded to avoid spurious KVO events
        // from the system reclaiming the audio session.
        stopObserving()
    }

    @objc private func appWillEnterForeground() {
        // Let Flutter decide whether to re-activate; no automatic restart here.
        // If your UX needs auto-resume, call startObserving() and notify Flutter.
    }

    // MARK: - Volume observation

    private func startObserving() {
        stopObserving() // Idempotent teardown before re-creating

        volumeObserver = VolumeButtonObserver { [weak self] event in
            // Always dispatch to main — Flutter channel calls must be on the main thread.
            DispatchQueue.main.async {
                self?.methodChannel?.invokeMethod("volumeBtnPressed", arguments: event)
            }
        }
        volumeObserver?.startObserving()
    }

    private func stopObserving() {
        volumeObserver?.stopObserving()
        volumeObserver = nil
    }

    // MARK: - UNUserNotificationCenterDelegate

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}