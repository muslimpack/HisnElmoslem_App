import 'package:flutter/material.dart';

class ScrollGlowRemover extends StatelessWidget {
  final Widget child;

  const ScrollGlowRemover({super.key, required this.child})  ;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return true;
      },
      child: child,
    );
  }
}
