import 'package:flutter/material.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

class ScrollGlowCustom extends StatelessWidget {
  final Widget child;
  final AxisDirection axisDirection;

  const ScrollGlowCustom({
    super.key,
    required this.child,
    this.axisDirection = AxisDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        axisDirection: axisDirection,
        color: scrollEndColor,
        child: child,
      ),
    );
  }
}
