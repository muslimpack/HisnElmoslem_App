import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// Drives the home side menu.
///
/// [animation] goes from 0 (closed) to 1 (fully open). Everything that moves the
/// drawer (the menu button, a drag from the first tab, a drag on the dimmed
/// screen, the first-run hint) goes through this object.
class HomeDrawerController {
  HomeDrawerController({required AnimationController animation, required this.slideWidth})
    : _animation = animation;

  final AnimationController _animation;

  /// How far (logical pixels) the main screen slides when fully open.
  final double slideWidth;

  /// Set by the drawer widget: `1` for left-to-right, `-1` for right-to-left.
  double direction = 1;

  /// True when the menu is shown as a permanent side panel (wide windows).
  bool isPermanent = false;

  /// True while a drag that started as an overscroll of the tabs is running.
  /// The tabs lock their scrolling during it.
  final ValueNotifier<bool> isPointerDriving = ValueNotifier(false);

  /// Distance (fraction of [slideWidth]) past which a slow release opens the drawer.
  static const double openThreshold = 0.4;
  static const double _flingVelocity = 700;
  static const double _peekWidth = 72;

  Animation<double> get animation => _animation;
  double get value => _animation.value;
  bool get isClosed => _animation.status == AnimationStatus.dismissed;

  /// True once the user did something with the drawer (used by the hint).
  bool hasInteracted = false;

  int _peekToken = 0;
  bool _pastThreshold = false;
  bool _pointerDriven = false;
  VelocityTracker? _tracker;

  Future<void> open() {
    if (isPermanent) return Future.value();
    hasInteracted = true;
    _peekToken++;
    return _animation.animateTo(1, curve: Curves.easeOutCubic);
  }

  Future<void> close() {
    _peekToken++;
    if (_animation.value == 0) return Future.value();
    return _animation.animateBack(0, curve: Curves.easeInCubic);
  }

  Future<void> toggle() {
    final opening =
        _animation.status == AnimationStatus.dismissed ||
        _animation.status == AnimationStatus.reverse;
    return opening ? open() : close();
  }

  /// Moves the drawer by [delta] logical pixels, positive meaning "more open".
  void dragUpdate(double delta) {
    if (isPermanent) return;
    hasInteracted = true;
    _peekToken++;
    _animation.stop();
    _animation.value = (_animation.value + delta / slideWidth).clamp(0.0, 1.0);
    final past = _animation.value >= openThreshold;
    if (past != _pastThreshold) {
      _pastThreshold = past;
      HapticFeedback.selectionClick();
    }
  }

  /// Finishes a drag. [velocity] is in logical pixels per second, positive meaning "opening".
  Future<void> settle(double velocity) {
    if (velocity.abs() > _flingVelocity) {
      return velocity > 0 ? open() : close();
    }
    return _animation.value >= openThreshold ? open() : close();
  }

  /// Opens the drawer a little and closes it again, to show that it exists.
  Future<void> peek() async {
    if (isPermanent || !isClosed) return;
    final token = ++_peekToken;
    await _animation.animateTo(
      _peekWidth / slideWidth,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
    if (token != _peekToken) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (token != _peekToken) return;
    await _animation.animateBack(
      0,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
  }

  // MARK: pointer driven drag (started by an overscroll of the first tab)

  bool get isPointerDriven => _pointerDriven;

  /// Called when the tabs report an overscroll at their start edge. From here
  /// on the raw pointer events move the drawer, because the tabs stop scrolling.
  void startPointerDrag(double delta) {
    if (isPermanent || _pointerDriven) return;
    _pointerDriven = true;
    isPointerDriving.value = true;
    dragUpdate(delta);
  }

  void pointerDown(PointerDownEvent event) {
    _tracker = VelocityTracker.withKind(event.kind)..addPosition(event.timeStamp, event.position);
  }

  void pointerMove(PointerMoveEvent event) {
    _tracker?.addPosition(event.timeStamp, event.position);
    if (_pointerDriven) dragUpdate(event.delta.dx * direction);
  }

  void pointerEnd() {
    final tracker = _tracker;
    _tracker = null;
    if (!_pointerDriven) return;
    _pointerDriven = false;
    isPointerDriving.value = false;
    final velocity = tracker?.getVelocity().pixelsPerSecond.dx ?? 0;
    settle(velocity * direction);
  }

  void dispose() {
    isPointerDriving.dispose();
  }
}
