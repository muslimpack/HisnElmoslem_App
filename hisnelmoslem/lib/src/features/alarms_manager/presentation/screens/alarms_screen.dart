import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/components/alarm_card.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        if (state is! AlarmsLoadedState) {
          return const Loading();
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              S.of(context).remindersManager,
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: state.alarms.isEmpty
              ? Empty(
                  isImage: false,
                  icon: Icons.alarm_add_rounded,
                  title: S.of(context).noRemindersFound,
                  description: S.of(context).noAlarmSetForAnyZikr,
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return AlarmCard(
                      dbAlarm: state.alarms[index],
                    );
                  },
                  itemCount: state.alarms.length,
                ),
        );
      },
    );
  }
}
