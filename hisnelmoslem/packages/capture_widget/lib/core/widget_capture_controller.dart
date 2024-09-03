import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CaptureWidgetController {
  final GlobalKey _imageKey = GlobalKey();

  GlobalKey get imageKey => _imageKey;

  Future<ui.Image?> getImage(double pixelRatio) async {
    final context = _imageKey.currentContext;
    if (context == null) return null;

    final RenderRepaintBoundary? boundary =
        context.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);

    return image;
  }

  Future<ByteData?> getBuffer(ui.Image image, ImageByteFormat format) async {
    final byteData = await image.toByteData(format: format);
    return byteData;
  }
}
