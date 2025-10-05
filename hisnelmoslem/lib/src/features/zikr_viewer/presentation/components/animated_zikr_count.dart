import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';

class AnimatedZikrCounter extends StatelessWidget {
  final int count;
  final TextStyle? style;

  const AnimatedZikrCounter({super.key, required this.count, this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Combined fade + scale animation
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        count.toArabicNumber(),
        key: ValueKey<int>(count),
        style:
            style ??
            Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
