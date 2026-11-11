import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer_controller.dart';

/// Gives the widgets under [HomeDrawer] access to its [HomeDrawerController].
class HomeDrawerScope extends InheritedWidget {
  const HomeDrawerScope({
    super.key,
    required this.controller,
    required this.isPermanent,
    required super.child,
  });

  final HomeDrawerController controller;
  final bool isPermanent;

  static HomeDrawerController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeDrawerScope>()?.controller;
  }

  static HomeDrawerController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No HomeDrawerScope found in context');
    return controller!;
  }

  /// Whether the menu is a permanent side panel (so there is nothing to open).
  static bool isPermanentOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeDrawerScope>()?.isPermanent ?? false;
  }

  @override
  bool updateShouldNotify(HomeDrawerScope oldWidget) => isPermanent != oldWidget.isPermanent;
}

/// A side menu that slides the main screen aside (and scales it a little).
///
/// On wide windows ([permanentBreakpoint]) the menu is a permanent panel next to the content.
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({
    super.key,
    required this.menu,
    required this.child,
    this.slideWidth = 280,
    this.permanentBreakpoint = 900,
    this.permanentWidth = 300,
  });

  final Widget menu;
  final Widget child;
  final double slideWidth;
  final double permanentBreakpoint;
  final double permanentWidth;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late final HomeDrawerController _controller;

  /// Keeps the content's state when the layout switches between overlay and panel.
  final GlobalKey _contentKey = GlobalKey();

  /// Receives the Esc key while the drawer is open.
  final FocusNode _focusNode = FocusNode(debugLabel: 'HomeDrawer', skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _animation =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 320),
          reverseDuration: const Duration(milliseconds: 260),
        )..addStatusListener((status) {
          // Make sure Esc reaches us even if nothing inside the screen has focus.
          if (status == AnimationStatus.forward && !_focusNode.hasFocus) _focusNode.requestFocus();
          setState(() {});
        });
    _controller = HomeDrawerController(animation: _animation, slideWidth: widget.slideWidth);
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    _controller.direction = isRtl ? -1 : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final permanent = constraints.maxWidth >= widget.permanentBreakpoint;
        _controller.isPermanent = permanent;
        if (permanent && _animation.value != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _animation.value = 0;
          });
        }

        final content = KeyedSubtree(
          key: _contentKey,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _controller.pointerDown,
            onPointerMove: _controller.pointerMove,
            onPointerUp: (_) => _controller.pointerEnd(),
            onPointerCancel: (_) => _controller.pointerEnd(),
            child: widget.child,
          ),
        );

        return HomeDrawerScope(
          controller: _controller,
          isPermanent: permanent,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape &&
                  !permanent &&
                  !_controller.isClosed) {
                _controller.close();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: PopScope(
              canPop: permanent || _animation.status == AnimationStatus.dismissed,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _controller.close();
              },
              child: permanent ? _buildPanel(context, content) : _buildOverlay(context, content),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context, Widget content) {
    return Row(
      children: [
        SizedBox(
          width: widget.permanentWidth,
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: widget.menu,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context, Widget content) {
    final theme = Theme.of(context);
    final controller = _controller;
    final animation = _animation;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The menu sits behind the main screen.
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final closed = animation.value == 0;
              return ExcludeSemantics(
                excluding: closed,
                child: IgnorePointer(ignoring: closed, child: child),
              );
            },
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: widget.slideWidth,
                // Swiping the menu toward the closed side closes the drawer, following the finger.
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    controller.dragUpdate(details.delta.dx * controller.direction);
                  },
                  onHorizontalDragEnd: (details) {
                    controller.settle(details.velocity.pixelsPerSecond.dx * controller.direction);
                  },
                  child: Material(type: MaterialType.transparency, child: widget.menu),
                ),
              ),
            ),
          ),
          // The main screen slides, scales and gets rounded corners as the drawer opens.
          AnimatedBuilder(
            animation: animation,
            child: content,
            builder: (context, child) {
              final v = animation.value;
              final radius = BorderRadius.circular(24 * v);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.translationValues(
                  controller.direction * widget.slideWidth * v,
                  0,
                  0,
                )..scaleByDouble(1 - 0.08 * v, 1 - 0.08 * v, 1, 1),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.28 * v),
                        blurRadius: 28 * v,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        child!,
                        if (v > 0) _Scrim(controller: controller, opacity: v),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Covers the main screen while the drawer is open: tap or drag to close it.
class _Scrim extends StatelessWidget {
  const _Scrim({required this.controller, required this.opacity});

  final HomeDrawerController controller;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).closeMenu,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.close,
        onHorizontalDragUpdate: (details) {
          controller.dragUpdate(details.delta.dx * controller.direction);
        },
        onHorizontalDragEnd: (details) {
          controller.settle(details.velocity.pixelsPerSecond.dx * controller.direction);
        },
        child: ColoredBox(color: Colors.black.withValues(alpha: 0.12 * opacity)),
      ),
    );
  }
}
