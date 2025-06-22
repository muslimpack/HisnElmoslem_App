import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_editor.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_counter_view_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_list_view_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_counter_view.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_list_view.dart';

class TallyDashboardScreen extends StatefulWidget {
  const TallyDashboardScreen({super.key});

  @override
  State<TallyDashboardScreen> createState() => _TallyDashboardScreenState();
}

class _TallyDashboardScreenState extends State<TallyDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;
  @override
  void initState() {
    _tabController = TabController(
      initialIndex: _tabIndex,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      _tabChanged(_tabController.index);
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _tabChanged(int index) {
    if (index == _tabIndex) return;
    hisnPrint(_tabController.index);
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TallyBloc>()..add(TallyStartEvent()),
      child: BlocBuilder<TallyBloc, TallyState>(
        builder: (context, state) {
          if (state is! TallyLoadedState) {
            return const Loading();
          }
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).tally),
                centerTitle: true,
                actions: [
                  if (state.activeCounter == null)
                    const SizedBox()
                  else
                    IconButton(
                      tooltip: S.of(context).edit,
                      onPressed: () async {
                        final DbTally dbTally = state.activeCounter!;
                        final EditorResult<DbTally>? result =
                            await showTallyEditorDialog(
                              context: context,
                              dbTally: dbTally,
                            );

                        if (result == null || !context.mounted) return;
                        switch (result.action) {
                          case EditorActionEnum.edit:
                            context.read<TallyBloc>().add(
                              TallyEditCounterEvent(counter: result.value),
                            );
                          case EditorActionEnum.delete:
                            context.read<TallyBloc>().add(
                              TallyDeleteCounterEvent(counter: result.value),
                            );
                          default:
                        }
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  IconButton(
                    tooltip: state.iterationMode.localeName(context),
                    onPressed: () {
                      context.read<TallyBloc>().add(
                        TallyToggleIterationModeEvent(),
                      );
                    },
                    icon: Icon(switch (state.iterationMode) {
                      TallyIterationMode.circular => Icons.repeat_rounded,
                      TallyIterationMode.shuffle => Icons.shuffle_rounded,
                      TallyIterationMode.none => Icons.repeat_one_rounded,
                    }),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,

                  tabs: [
                    Tab(child: Text(S.of(context).activeTally)),
                    Tab(child: Text(S.of(context).counters)),
                  ],
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: const [TallyCounterView(), TallyListView()],
              ),
              bottomNavigationBar: _tabIndex == 0
                  ? const TallyCounterViewBottomBar()
                  : const TallyListViewBottomBar(),
            ),
          );
        },
      ),
    );
  }
}
