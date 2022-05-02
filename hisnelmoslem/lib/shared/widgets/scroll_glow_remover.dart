import 'package:flutter/material.dart';

class ScrollGlowRemover extends StatelessWidget {
  final Widget child;
  const ScrollGlowRemover({Key? key, required this.child}) : super(key: key);

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
