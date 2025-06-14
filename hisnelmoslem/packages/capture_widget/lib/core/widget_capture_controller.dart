import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CaptureWidgetController {
  final GlobalKey _imageKey;

  CaptureWidgetController({GlobalKey? imageKey})
      : _imageKey = imageKey ?? GlobalKey();

  GlobalKey get imageKey => _imageKey;

  /// Retrieves the image from the widget with the given pixel ratio.
  ///
  /// The [pixelRatio] is the ratio of pixels in the image to the logical pixels
  /// in the widget.
  ///
  /// Returns a [Future] that completes with the captured image as a [ui.Image]
  /// object, or `null` if the widget or its context is not available.
  Future<ui.Image?> getImage(double pixelRatio) async {
    final RenderRepaintBoundary? boundary = _getBoundary();

    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);

    return image;
  }

  /// Retrieves the size of the widget.
  ///
  /// Returns the size of the widget as a [Size] object, or `null` if the widget or its context is not available.
  Size? getWidgetSize() {
    return _getBoundary()?.size;
  }

  RenderRepaintBoundary? _getBoundary() {
    final context = _imageKey.currentContext;
    if (context == null) return null;

    final RenderRepaintBoundary? boundary =
        context.findRenderObject() as RenderRepaintBoundary?;

    return boundary;
  }
}
