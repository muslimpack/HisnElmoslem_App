// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/home/data/data_source/app_dashboard_tabs.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_drawer/home_drawer.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeAppBar extends StatelessWidget {
  final TabController tabController;
  const HomeAppBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }
        final isPermanentMenu = HomeDrawerScope.isPermanentOf(context);
        return SliverAppBar(
          automaticallyImplyLeading: false,
          leading: state.isSearching
              ? IconButton(
                  tooltip: S.of(context).close,
                  padding: EdgeInsets.zero,
                  icon: Icon(MdiIcons.close),
                  onPressed: () {
                    context.read<HomeBloc>().add(
                      const HomeToggleSearchEvent(isSearching: false),
                    );
                  },
                )
              : isPermanentMenu
              ? null
              : IconButton(
                  tooltip: S.of(context).menu,
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => HomeDrawerScope.of(context).toggle(),
                ),

          pinned: true,
          floating: true,
          snap: true,
          bottom: PreferredSize(
            preferredSize: const Size(0, 48),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              tabs: List.generate(appDashboardTabs.length, (index) {
                return Tab(
                  child: Text(
                    appDashboardTabs[state.dashboardArrangement[index]].title(
                      context,
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            if (!state.isSearching) ...[
              IconButton(
                tooltip: S.of(context).search,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search),
                onPressed: () {
                  context.read<HomeBloc>().add(
                    const HomeToggleSearchEvent(isSearching: true),
                  );
                },
              ),
              IconButton(
                tooltip: S.of(context).settings,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings_rounded),
                onPressed: () => context.push(const SettingsScreen()),
              ),
            ],
          ],
        );
      },
    );
  }
}
