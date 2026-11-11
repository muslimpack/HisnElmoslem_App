import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer.dart';

/// Peeks the home drawer open once, shortly after the screen shows, so users
/// notice that a side menu exists. Does nothing if it was already shown, or if
/// the user opened the drawer first.
class HomeDrawerHint extends StatefulWidget {
  const HomeDrawerHint({
    super.key,
    required this.alreadyShown,
    required this.onShown,
    required this.child,
    this.delay = const Duration(milliseconds: 900),
  });

  final bool alreadyShown;
  final VoidCallback onShown;
  final Duration delay;
  final Widget child;

  @override
  State<HomeDrawerHint> createState() => _HomeDrawerHintState();
}

class _HomeDrawerHintState extends State<HomeDrawerHint> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.alreadyShown) {
      _timer = Timer(widget.delay, _run);
    }
  }

  void _run() {
    if (!mounted) return;
    final controller = HomeDrawerScope.maybeOf(context);
    if (controller == null) return;
    widget.onShown();
    if (!controller.hasInteracted) controller.peek();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
