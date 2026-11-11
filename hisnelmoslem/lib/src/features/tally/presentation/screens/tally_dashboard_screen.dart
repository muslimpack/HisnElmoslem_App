import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/sheets/tally_auto_advance_sheet.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_actions.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_counter_view_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/cubit/tally_audio_cubit.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_counter_view.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/screens/tally_list_view.dart';

class TallyDashboardScreen extends StatelessWidget {
  const TallyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TallyBloc>()..add(TallyStartEvent())),
        BlocProvider(
          create: (context) => TallyAudioCubit(
            tallyBloc: context.read<TallyBloc>(),
            engine: sl(instanceName: kTallyAudioEngine),
            repo: sl(),
            storage: sl(),
          )..init(),
        ),
      ],
      child: BlocListener<TallyAudioCubit, TallyAudioState>(
        listenWhen: (a, b) => b.endedBecause != null && a.endedBecause != b.endedBecause,
        listener: (context, state) {
          final s = S.of(context);
          final message = switch (state.endedBecause) {
            TallyAudioEnd.limitReached => s.tallySessionDone,
            TallyAudioEnd.noRecording => s.tallyNoRecordingToPlay,
            null => null,
          };
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        child: const _TallyDashboardView(),
      ),
    );
  }
}

class _TallyDashboardView extends StatefulWidget {
  const _TallyDashboardView();

  @override
  State<_TallyDashboardView> createState() => _TallyDashboardViewState();
}

class _TallyDashboardViewState extends State<_TallyDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..addListener(_tabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_tabChanged)
      ..dispose();
    super.dispose();
  }

  void _tabChanged() {
    if (!_tabController.indexIsChanging) setState(() {});
  }

  bool get _onCounterTab => _tabController.index == 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallyBloc, TallyState>(
      builder: (context, state) {
        if (state is! TallyLoadedState) {
          return const Loading();
        }
        final s = S.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(s.tally),
            centerTitle: true,
            actions: [
              if (_onCounterTab)
                TextButton.icon(
                  onPressed: () => TallyAutoAdvanceSheet.show(context),
                  icon: Icon(switch (state.iterationMode) {
                    TallyIterationMode.circular => Icons.repeat_rounded,
                    TallyIterationMode.shuffle => Icons.shuffle_rounded,
                    TallyIterationMode.none => Icons.repeat_one_rounded,
                  }),
                  label: Text(
                    state.iterationMode == TallyIterationMode.none
                        ? s.tallyAutoAdvance
                        : state.iterationMode.localeName(context),
                  ),
                )
              else if (state.allCounters.isNotEmpty)
                IconButton(
                  tooltip: s.resetAllCounters,
                  icon: const Icon(Icons.restart_alt_rounded),
                  onPressed: () => TallyActions.resetAll(context),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(child: Text(s.activeTally)),
                Tab(child: Text(s.counters)),
              ],
            ),
          ),
          resizeToAvoidBottomInset: false,
          body: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: const [TallyCounterView(), TallyListView()],
          ),
          floatingActionButton: _onCounterTab
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => TallyActions.add(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.addNewCounter),
                ),
          bottomNavigationBar: _onCounterTab ? const TallyCounterViewBottomBar() : null,
        );
      },
    );
  }
}
