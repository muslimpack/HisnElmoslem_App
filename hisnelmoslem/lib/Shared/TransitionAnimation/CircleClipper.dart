import 'package:flutter/material.dart';

class CircleRevealClipper extends CustomClipper<Path> {
  final center;
  final radius;

  CircleRevealClipper({this.center, this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(radius: radius, center: center));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}