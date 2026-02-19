import 'package:flutter/material.dart';

class DrawerCard extends StatelessWidget {
  final Widget? child;

  const DrawerCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox();
  }
}

class DrawerDivider extends StatelessWidget {
  const DrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 4);
  }
}
