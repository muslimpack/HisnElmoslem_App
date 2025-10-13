import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';

class AnimatedZikrCounter extends StatelessWidget {
  final int count;
  final TextStyle? style;

  const AnimatedZikrCounter({super.key, required this.count, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      count.toArabicNumber(),
      key: ValueKey<int>(count),
      style:
          style ??
          Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
