import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';

class AnimatedZikrProgressCounter extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const AnimatedZikrProgressCounter({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

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
        "${(currentIndex + 1).toArabicNumber()} : ${totalCount.toArabicNumber()}",
        key: ValueKey<int>(currentIndex),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
