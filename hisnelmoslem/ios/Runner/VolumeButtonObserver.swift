import AVFoundation
import MediaPlayer
import UIKit
import QuartzCore

class VolumeButtonObserver: NSObject {

  // ─── Constants ────────────────────────────────────────────────
  private static let midVolume: Float  = 0.5
  private static let volumeKey: String = "outputVolume"

  // ─── State ────────────────────────────────────────────────────
  private var isObserving = false
  private var resetTimer: Timer?
  private var volumeView: MPVolumeView?  // Must be retained
  private var initialVolume: Float?
  private var activeDirection: String?

  private let onEvent: (String) -> Void

  // ─── Init ─────────────────────────────────────────────────────
  init(onEvent: @escaping (String) -> Void) {
    self.onEvent = onEvent
  }

  // ─── Lifecycle ────────────────────────────────────────────────

  func startObserving() {
    guard !isObserving else { return }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, options: .mixWithOthers)
      try session.setActive(true)
      initialVolume = session.outputVolume
    } catch {
      print("VolumeButtonObserver: audio session error: \(error)")
      return
    }

    // MPVolumeView must be attached to the window to control volume
    let view = MPVolumeView(frame: CGRect(x: -3000, y: -3000, width: 1, height: 1))
    view.isHidden = false  // Must NOT be hidden for slider to work
    UIApplication.shared.windows.first?.addSubview(view)
    volumeView = view

    AVAudioSession.sharedInstance().addObserver(
      self,
      forKeyPath: Self.volumeKey,
      options: [.new, .old],
      context: nil
    )

    // Delay initial volume set to ensure KVO is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.setVolume(Self.midVolume)
    }

    isObserving = true
  }

  func stopObserving() {
    guard isObserving else { return }
    
    // Stop listening to changes first
    AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Self.volumeKey)
    isObserving = false
    
    // Clear timers
    resetTimer?.invalidate()
    resetTimer = nil
    
    // Restore initial volume only if it's different from current (avoid redundant set)
    if let initial = initialVolume, abs(AVAudioSession.sharedInstance().outputVolume - initial) > 0.01 {
        setVolume(initial)
    }
    
    // Cleanup UI
    volumeView?.removeFromSuperview()
    volumeView = nil
  }

  // ─── KVO ──────────────────────────────────────────────────────

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    guard
      keyPath == Self.volumeKey,
      let newVolume = change?[.newKey] as? Float,
      let oldVolume = change?[.oldKey] as? Float,
      abs(newVolume - oldVolume) > 0.01,
      abs(newVolume - Self.midVolume) > 0.001 // Ignore changes back to/from midVolume (our reset)
    else { return }

    if activeDirection == nil {
      activeDirection = newVolume > oldVolume ? "UP" : "DOWN"
      onEvent("VOLUME_\(activeDirection!)_DOWN")
    }

    // Restart release timer
    resetTimer?.invalidate()
    resetTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      guard let self = self, let dir = self.activeDirection else { return }
      self.onEvent("VOLUME_\(dir)_UP")
      self.activeDirection = nil
    }

    // Reset volume back to mid after a short delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.setVolume(Self.midVolume)
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  private func setVolume(_ value: Float) {
    guard let slider = volumeView?.subviews.first(where: { $0 is UISlider }) as? UISlider else {
      return
    }
    slider.value = value
  }
}
