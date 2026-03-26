import AVFoundation
import MediaPlayer
import UIKit

class VolumeButtonObserver: NSObject {

  // ─── Constants ────────────────────────────────────────────────
  private static let midVolume: Float  = 0.5
  private static let volumeKey: String = "outputVolume"

  // ─── State ────────────────────────────────────────────────────
  private var isObserving = false
  private var resetTimer: Timer?
  private var volumeView: MPVolumeView?  // Must be retained

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
    resetTimer?.invalidate()
    resetTimer = nil
    volumeView?.removeFromSuperview()
    volumeView = nil
    AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: Self.volumeKey)
    isObserving = false
  }

  private var isResettingVolume = false

  // ─── KVO ──────────────────────────────────────────────────────

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    guard
      !isResettingVolume,
      keyPath == Self.volumeKey,
      let newVolume = change?[.newKey] as? Float,
      let oldVolume = change?[.oldKey] as? Float,
      abs(newVolume - oldVolume) > 0.01
    else { return }

    if newVolume > oldVolume {
      onEvent("VOLUME_UP_DOWN")
      scheduleRelease(event: "VOLUME_UP_UP")
    } else {
      onEvent("VOLUME_DOWN_DOWN")
      scheduleRelease(event: "VOLUME_DOWN_UP")
    }

    // Reset volume back to mid after a short delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.setVolume(Self.midVolume)
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  private func scheduleRelease(event: String) {
    resetTimer?.invalidate()
    resetTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
      self?.onEvent(event)
    }
  }

  private func setVolume(_ value: Float) {
    guard let slider = volumeView?.subviews.first(where: { $0 is UISlider }) as? UISlider else {
      return
    }
    isResettingVolume = true
    slider.value = value
    
    // Reset the flag after a short delay to allow the system to process the change
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      self?.isResettingVolume = false
    }
  }
}
