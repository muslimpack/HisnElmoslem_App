import 'dart:math' as math;

import 'package:flutter/material.dart';

class SquigglyLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SquigglyLinePainter({this.color = Colors.grey, this.strokeWidth = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);

    const double waveHeight = 5.0;
    const double waveLength = 10.0;
    final double halfHeight = size.height / 2;

    for (double i = 0; i < size.width; i++) {
      path.lineTo(
          i, halfHeight + math.sin(i * math.pi / waveLength) * waveHeight);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SquigglyLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
