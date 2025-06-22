import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/models/editor_result.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_editor.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class TallyListViewBottomBar extends StatelessWidget {
  const TallyListViewBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              tooltip: S.of(context).addNewCounter,
              icon: const Icon(Icons.add),
              onPressed: () async {
                final EditorResult<DbTally>? result =
                    await showTallyEditorDialog(context: context);

                if (result == null || !context.mounted) return;

                context.read<TallyBloc>().add(
                  TallyAddCounterEvent(counter: result.value),
                );
              },
            ),
            IconButton(
              tooltip: S.of(context).resetAllCounters,
              icon: const Icon(Icons.restart_alt),
              onPressed: () async {
                final bool? confirm = await showDialog(
                  context: context,
                  builder: (_) {
                    return YesOrNoDialog(msg: S.of(context).resetAllCounters);
                  },
                );

                if (confirm == null || !confirm || !context.mounted) {
                  return;
                }
                context.read<TallyBloc>().add(TallyResetAllCountersEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
