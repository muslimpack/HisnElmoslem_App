// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/values/app_dashboard.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/home_search_box.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ScreenAppBar extends StatelessWidget {
  final TabController tabController;
  const ScreenAppBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }
        return SliverAppBar(
          leading: !state.isSearching
              ? Padding(
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                )
              : IconButton(
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  icon: Icon(MdiIcons.close),
                  onPressed: () {
                    context
                        .read<HomeBloc>()
                        .add(const HomeToggleSearchEvent(isSearching: false));
                  },
                ),
          title: !state.isSearching ? null : const HomeSearchBox(),
          pinned: true,
          floating: true,
          snap: true,
          bottom: state.isSearching &
                  context.watch<SearchCubit>().state.searchText.isNotEmpty
              ? null
              : PreferredSize(
                  preferredSize: const Size(0, 48),
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: [
                      ...List.generate(
                        appDashboardItem.length,
                        (index) {
                          return Tab(
                            child: Text(
                              appDashboardItem[
                                      state.dashboardArrangement[index]]
                                  .title,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          actions: [
            if (!state.isSearching) ...[
              IconButton(
                splashRadius: 20,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search),
                onPressed: () {
                  context
                      .read<HomeBloc>()
                      .add(const HomeToggleSearchEvent(isSearching: true));
                },
              ),
              IconButton(
                splashRadius: 20,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.vertical_split_rounded),
                onPressed: () {
                  sl<HomeBloc>().add(const HomeToggleDrawerEvent());
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
