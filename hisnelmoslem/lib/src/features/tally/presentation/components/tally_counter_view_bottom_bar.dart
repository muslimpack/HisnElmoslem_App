import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class TallyCounterViewBottomBar extends StatelessWidget {
  const TallyCounterViewBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_right),
              onPressed: () {
                context.read<TallyBloc>().add(TallyPreviousCounterEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (_) {
                    return YesOrNoDialog(
                      msg: S.of(context).progressDeletedCannotUndo,
                      onYes: () async {
                        context
                            .read<TallyBloc>()
                            .add(TallyResetActiveCounterEvent());
                      },
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                context
                    .read<TallyBloc>()
                    .add(TallyDecreaseActiveCounterEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_left),
              onPressed: () {
                context.read<TallyBloc>().add(TallyNextCounterEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
