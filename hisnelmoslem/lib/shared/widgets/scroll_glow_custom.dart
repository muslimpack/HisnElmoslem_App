import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';

class ScrollGlowCustom extends StatelessWidget {
  final Widget child;
  final AxisDirection axisDirection;

  const ScrollGlowCustom({
    Key? key,
    required this.child,
    this.axisDirection = AxisDirection.down,
  }) : super(key: key);

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
