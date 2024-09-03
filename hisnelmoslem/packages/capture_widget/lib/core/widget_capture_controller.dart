import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CaptureWidgetController {
  final GlobalKey _imageKey = GlobalKey();

  GlobalKey get imageKey => _imageKey;

  /// Retrieves the image from the widget with the given pixel ratio.
  ///
  /// The [pixelRatio] is the ratio of pixels in the image to the logical pixels
  /// in the widget.
  ///
  /// Returns a [Future] that completes with the captured image as a [ui.Image]
  /// object, or `null` if the widget or its context is not available.
  Future<ui.Image?> getImage(double pixelRatio) async {
    final context = _imageKey.currentContext;
    if (context == null) return null;

    final RenderRepaintBoundary? boundary =
        context.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);

    return image;
  }
}
