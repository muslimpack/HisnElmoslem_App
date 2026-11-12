import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer.dart';

/// A rounded, tappable menu entry. Closes the drawer after [onTap] runs.
class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Extra start padding, for entries nested under a group.
  final double indent;

  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12 + indent, 2, 12, 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: colorScheme.secondaryContainer.withValues(alpha: 0.35),
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        onTap: () {
          onTap();
          HomeDrawerScope.maybeOf(context)?.close();
        },
      ),
    );
  }
}

/// A small heading that groups menu entries.
class DrawerSectionLabel extends StatelessWidget {
  final String label;

  const DrawerSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 16, 28, 6),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Fades and slides its child in while the drawer opens; [order] staggers the entries.
class DrawerReveal extends StatelessWidget {
  final int order;
  final Widget child;

  const DrawerReveal({super.key, required this.order, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = HomeDrawerScope.maybeOf(context);
    if (controller == null || controller.isPermanent) return child;

    final start = (order * 0.05).clamp(0.0, 0.45);
    final curved = CurvedAnimation(
      parent: controller.animation,
      curve: Interval(start, (start + 0.55).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(-24 * (1 - curved.value) * controller.direction, 0),
            child: child,
          ),
        );
      },
    );
  }
}
