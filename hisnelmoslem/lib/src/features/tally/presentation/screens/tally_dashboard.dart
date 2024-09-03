import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally_iteration_mode.dart';
import 'package:hisnelmoslem/src/features/tally/data/repository/tally_database_helper.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/pages/tally_counter.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/pages/tally_list.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class Tally extends StatelessWidget {
  const Tally({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TallyBloc(tallyDatabaseHelper, SoundsManagerController())
            ..add(TallyStartEvent()),
      child: BlocBuilder<TallyBloc, TallyState>(
        builder: (context, state) {
          if (state is! TallyLoadedState) {
            return const Loading();
          }
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text("tally".tr),
                centerTitle: true,
                actions: [
                  if (state.activeCounter == null)
                    const SizedBox()
                  else
                    IconButton(
                      splashRadius: 20,
                      onPressed: () async {
                        final DbTally dbTally = state.activeCounter!;
                        final DbTally? result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return TallyDialog(
                              dbTally: dbTally,
                            );
                          },
                        );

                        if (result == null || !context.mounted) return;
                        context
                            .read<TallyBloc>()
                            .add(TallyEditCounterEvent(counter: result));
                      },
                      icon: const Icon(Icons.settings),
                    ),
                  IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      context
                          .read<TallyBloc>()
                          .add(TallyToggleIterationModeEvent());
                    },
                    icon: Icon(
                      switch (state.iterationMode) {
                        TallyIterationMode.circular => Icons.repeat_rounded,
                        TallyIterationMode.shuffle => Icons.shuffle_rounded,
                        TallyIterationMode.none => Icons.repeat_one_rounded,
                      },
                    ),
                  ),
                ],
                bottom: TabBar(
                  tabs: [
                    Tab(
                      child: Text(
                        "active tallly".tr,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "counters".tr,
                      ),
                    ),
                  ],
                ),
              ),
              resizeToAvoidBottomInset: false,
              body: const TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  TallyCounterView(),
                  TallyListView(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
