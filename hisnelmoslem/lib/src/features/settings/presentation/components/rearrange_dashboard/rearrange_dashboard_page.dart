import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/home/data/data_source/app_dashboard_tabs.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/data/models/app_component.dart';

/// Lets the user drag the home tabs into their preferred order.
class RearrangeDashboardPage extends StatelessWidget {
  const RearrangeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const Loading();
        }
        final isDefaultOrder =
            [
              for (var i = 0; i < state.dashboardArrangement.length; i++) i,
            ].toString() ==
            state.dashboardArrangement.toString();
        final tabs = [for (final index in state.dashboardArrangement) appDashboardTabs[index]];

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(S.of(context).dashboardArrangement),
            actions: [
              IconButton(
                tooltip: S.of(context).dashboardArrangementReset,
                icon: const Icon(Icons.restart_alt_rounded),
                onPressed: isDefaultOrder
                    ? null
                    : () => context.read<HomeBloc>().add(const HomeDashboardResetEvent()),
              ),
            ],
          ),
          body: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            header: DashboardOrderHeader(tabs: tabs),
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              return DashboardTabTile(
                // Stable per tab, not per position, so drag animations follow the tile.
                key: ValueKey(state.dashboardArrangement[index]),
                tab: tabs[index],
                position: index,
              );
            },
            // ignore: deprecated_member_use, onReorderItem needs a newer Flutter than the pinned one.
            onReorder: (oldIndex, newIndex) {
              context.read<HomeBloc>().add(
                HomeDashboardReorderedEvent(oldIndex: oldIndex, newIndex: newIndex),
              );
            },
          ),
        );
      },
    );
  }
}

/// Explains how to reorder and previews the resulting tab order.
class DashboardOrderHeader extends StatelessWidget {
  final List<AppComponent> tabs;
  const DashboardOrderHeader({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.primary.withAlpha(20),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.primary.withAlpha(60)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.swap_vert_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.dashboardArrangementHint)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                s.dashboardArrangementPreview,
                style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tab in tabs)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(tab.icon, size: 16),
                      label: Text(tab.title(context)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One draggable tab row: position badge, icon, name and drag handle.
class DashboardTabTile extends StatelessWidget {
  final AppComponent tab;
  final int position;

  const DashboardTabTile({super.key, required this.tab, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withAlpha(30),
          foregroundColor: theme.colorScheme.primary,
          child: Icon(tab.icon),
        ),
        title: Text(tab.title(context)),
        subtitle: Text("#${position + 1}"),
        trailing: ReorderableDragStartListener(
          index: position,
          child: Tooltip(
            message: S.of(context).dragToReorderTab,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
