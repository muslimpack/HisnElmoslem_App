import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/data_source/app_dashboard_tabs.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_appbar.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/side_menu.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/screens/home_search_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const Loading();
        }
        return Scaffold(
          body: ZoomDrawer(
            isRtl: Bidi.isRtlLanguage(
              Localizations.localeOf(context).languageCode,
            ),
            controller: sl<HomeBloc>().zoomDrawerController,
            menuBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            menuScreen: const SideMenu(),
            mainScreen: const DashboardScreen(),
            borderRadius: 24.0,
            showShadow: true,
            angle: 0.0,
            drawerShadowsBackgroundColor: Theme.of(context).colorScheme.primary,
            slideWidth: 270,
          ),
        );
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  @override
  void initState() {
    tabController = TabController(vsync: this, length: appDashboardTabs.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is! HomeLoadedState) {
              return const Loading();
            }
            return Scaffold(
              body: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                floatHeaderSlivers: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    HomeAppBar(tabController: tabController),
                  ];
                },
                body: state.isSearching &
                        context.watch<SearchCubit>().state.searchText.isNotEmpty
                    ? const HomeSearchScreen()
                    : TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: tabController,
                        children: [
                          ...List.generate(
                            appDashboardTabs.length,
                            (index) {
                              return appDashboardTabs[
                                      state.dashboardArrangement[index]]
                                  .widget;
                            },
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
