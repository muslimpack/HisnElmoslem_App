import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/home/data/data_source/app_dashboard_tabs.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/home_appbar.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/side_menu/side_menu.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/screens/home_search_screen.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_dashboard_screen.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController tabController;
  final themeCubit = sl<ThemeCubit>();
  late Brightness _brightness;
  @override
  void initState() {
    tabController = TabController(vsync: this, length: appDashboardTabs.length);
    WidgetsBinding.instance.addObserver(this);
    _brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_brightness != brightness) {
      sl<ThemeCubit>().changeDeviceBrightness(brightness);
      _brightness = brightness;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
                      return [HomeAppBar(tabController: tabController)];
                    },
                body:
                    state.isSearching &
                        context.watch<SearchCubit>().state.searchText.isNotEmpty
                    ? const HomeSearchScreen()
                    : TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: tabController,
                        children: List.generate(appDashboardTabs.length, (
                          index,
                        ) {
                          return appDashboardTabs[state
                                  .dashboardArrangement[index]]
                              .widget;
                        }),
                      ),
              ),

              floatingActionButton: FloatingActionButton(
                tooltip: S.of(context).tally,
                child: Icon(MdiIcons.counter, size: 35),
                onPressed: () {
                  context.push(const TallyDashboardScreen());
                },
              ),
            );
          },
        );
      },
    );
  }
}
