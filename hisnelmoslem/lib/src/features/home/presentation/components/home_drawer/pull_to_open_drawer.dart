import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer.dart';

/// Lets a horizontal pager open the [HomeDrawer] when it is pulled past its start edge.
///
/// The pager must use the physics given to [builder]. They clamp at the edges (so the
/// pager reports overscroll instead of stretching) and lock while the drawer follows
/// the finger.
class PullToOpenDrawer extends StatelessWidget {
  const PullToOpenDrawer({super.key, required this.builder});

  final Widget Function(BuildContext context, ScrollPhysics physics) builder;

  @override
  Widget build(BuildContext context) {
    final drawer = HomeDrawerScope.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification &&
            notification.metrics.axis == Axis.horizontal &&
            notification.overscroll < 0 &&
            notification.dragDetails != null &&
            !drawer.isPointerDriven) {
          drawer.startPointerDrag(-notification.overscroll);
        }
        return false;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: drawer.isPointerDriving,
        builder: (context, driving, _) {
          return builder(
            context,
            driving ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
          );
        },
      ),
    );
  }
}
