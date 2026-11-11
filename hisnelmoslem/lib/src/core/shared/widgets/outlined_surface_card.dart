import 'package:flutter/material.dart';

/// Rounded container with a raised surface color and a thin outline. It stands out
/// from a bottom sheet behind it, where a plain `Card` has almost the same color and
/// disappears.
class OutlinedSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const OutlinedSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
