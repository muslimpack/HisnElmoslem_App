import AVFoundation
import MediaPlayer
import UIKit

/// Intercepts physical volume button presses without changing the audible volume.
///
/// Strategy: park system volume at 0.5, detect any KVO delta as a button press,
/// then immediately re-centre. Emits "VOLUME_UP_DOWN" / "VOLUME_UP_UP" (and DOWN
/// variants) so the caller can distinguish press and release.
final class VolumeButtonObserver: NSObject {

    // MARK: - Constants

    private static let midVolume: Float = 0.5
    private static let volumeKey         = "outputVolume"
    private static let resetDelay: TimeInterval  = 0.2   // re-centre after button press
    private static let releaseDelay: TimeInterval = 0.5  // fire *_UP after no new press

    // MARK: - State

    private var isObserving       = false
    private var releaseTimer: Timer?
    private var activeDirection: String?
    private var initialVolume: Float = VolumeButtonObserver.midVolume

    /// Invisible MPVolumeView — must be in the window hierarchy for its slider
    /// to actually change system volume.
    private weak var volumeViewRef: MPVolumeView?

    private let onEvent: (String) -> Void

    // MARK: - Init

    init(onEvent: @escaping (String) -> Void) {
        self.onEvent = onEvent
    }

    deinit {
        // Safety net — ensures KVO is always unregistered.
        if isObserving {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Self.volumeKey)
        }
    }

    // MARK: - Lifecycle

    func startObserving() {
        guard !isObserving else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print("VolumeButtonObserver: audio session error — \(error)")
            return
        }

        initialVolume = session.outputVolume

        // MPVolumeView must be visible (not hidden) and attached to a window.
        let view = MPVolumeView(frame: CGRect(x: -3_000, y: -3_000, width: 1, height: 1))
        view.isHidden = false
        view.alpha = 0.01   // practically invisible, but still "rendered"
        attachToKeyWindow(view)
        volumeViewRef = view

        session.addObserver(
            self,
            forKeyPath: Self.volumeKey,
            options: [.new, .old],
            context: nil
        )

        isObserving = true

        // Defer the initial centre so KVO is fully registered first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.setVolume(Self.midVolume)
        }
    }

    func stopObserving() {
        guard isObserving else { return }

        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Self.volumeKey)
        isObserving = false

        cancelReleaseTimer()
        activeDirection = nil

        // Restore user's original volume.
        let current = AVAudioSession.sharedInstance().outputVolume
        if abs(current - initialVolume) > 0.02 {
            setVolume(initialVolume)
        }

        // volumeViewRef is weak; remove from superview via the reference before it's gone.
        volumeViewRef?.removeFromSuperview()
        volumeViewRef = nil
    }

    // MARK: - KVO

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard
            keyPath == Self.volumeKey,
            let newVolume = change?[.newKey] as? Float,
            let oldVolume = change?[.oldKey] as? Float
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        let delta = newVolume - oldVolume

        // Ignore our own re-centring writes.
        guard abs(delta) > 0.02,
              abs(newVolume - Self.midVolume) > 0.001
        else { return }

        // Determine direction on the first event in a sequence.
        if activeDirection == nil {
            activeDirection = delta > 0 ? "UP" : "DOWN"
            onEvent("VOLUME_\(activeDirection!)_DOWN")
        }

        // Restart the release timer each time the button is still held.
        scheduleReleaseTimer()

        // Re-centre volume after a brief moment so the next press is detectable.
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.resetDelay) { [weak self] in
            guard let self, self.isObserving else { return }
            self.setVolume(Self.midVolume)
        }
    }

    // MARK: - Private helpers

    private func scheduleReleaseTimer() {
        cancelReleaseTimer()
        releaseTimer = Timer.scheduledTimer(
            withTimeInterval: Self.releaseDelay,
            repeats: false
        ) { [weak self] _ in
            guard let self, let dir = self.activeDirection else { return }
            self.activeDirection = nil
            self.onEvent("VOLUME_\(dir)_UP")
        }
    }

    private func cancelReleaseTimer() {
        releaseTimer?.invalidate()
        releaseTimer = nil
    }

    private func setVolume(_ value: Float) {
        // MPVolumeView's UISlider is the only documented way to change system
        // volume programmatically without showing the system HUD.
        guard
            let slider = volumeViewRef?
                .subviews
                .first(where: { $0 is UISlider }) as? UISlider
        else { return }

        DispatchQueue.main.async {
            slider.value = value
        }
    }

    /// Attaches `view` to the key window using the scene-based API (iOS 13+)
    /// with a fallback to the legacy `windows` property.
    private func attachToKeyWindow(_ view: UIView) {
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            let window = windowScene?.windows.first(where: \.isKeyWindow)
                      ?? windowScene?.windows.first
            window?.addSubview(view)
        } else {
            UIApplication.shared.keyWindow?.addSubview(view)
        }
    }
}