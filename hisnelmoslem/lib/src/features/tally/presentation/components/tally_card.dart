import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/data/models/tally.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/dialogs/tally_dialog.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TallyCard extends StatelessWidget {
  final DbTally dbTally;

  const TallyCard({super.key, required this.dbTally});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ar");

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              isThreeLine: true,
              tileColor: dbTally.isActivated
                  ? Theme.of(context).colorScheme.primary.withOpacity(.2)
                  : null,
              onTap: () {
                context
                    .read<TallyBloc>()
                    .add(TallyToggleCounterActivationEvent(counter: dbTally));
              },
              leading: Icon(
                dbTally.isActivated ? Icons.done_all_outlined : null,
                size: 40,
              ),
              title: Text(
                dbTally.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: "uthmanic",
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DateFormat('EEEE - dd-MM-yyyy – kk:mm')
                        .format(dbTally.lastUpdate!),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'edit'.tr,
                        onPressed: () async {
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
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: "delete".tr,
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (_) {
                              return YesOrNoDialog(
                                msg: "This counter will be deleted.".tr,
                                onYes: () async {
                                  context.read<TallyBloc>().add(
                                        TallyDeleteCounterEvent(
                                          counter: dbTally,
                                        ),
                                      );
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Text(
                dbTally.count.toString().toArabicNumber(),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
