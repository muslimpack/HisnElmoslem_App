import 'package:capture_widget/core/widget_capture_controller.dart';
import 'package:flutter/cupertino.dart';

class CaptureWidget extends StatelessWidget {
  final Widget child;
  final CaptureWidgetController controller;

  const CaptureWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.imageKey,
      child: child,
    );
  }
}
