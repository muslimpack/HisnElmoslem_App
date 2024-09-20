import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/bloc/fake_hadith_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class FakeHadithCard extends StatelessWidget {
  final DbFakeHaith fakeHadith;

  const FakeHadithCard({
    super.key,
    required this.fakeHadith,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _TopBar(fakeHadith: fakeHadith),
          const Divider(height: 0),
          InkWell(
            onTap: () {
              context.read<FakeHadithBloc>().add(
                    FakeHadithToggleHadithEvent(
                      fakeHadith: fakeHadith,
                      isRead: !fakeHadith.isRead,
                    ),
                  );
            },
            onLongPress: () {
              final snackBar = SnackBar(
                content: Text(
                  fakeHadith.source,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                action: SnackBarAction(
                  label: S.of(context).copy,
                  onPressed: () async {
                    // Some code to undo the change.
                    await Clipboard.setData(
                      ClipboardData(text: fakeHadith.source),
                    );
                  },
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 150),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text(
                        fakeHadith.text,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: state.fontSize * 10,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TextDivider(),
                      Text(
                        fakeHadith.darga,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: state.fontSize * 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.fakeHadith,
  });

  final DbFakeHaith fakeHadith;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (!fakeHadith.isRead)
          const Icon(
            Icons.check,
          )
        else
          const Icon(
            Icons.checklist,
          ),
        IconButton(
          tooltip: S.of(context).copy,
          icon: const Icon(
            Icons.copy,
          ),
          onPressed: () async {
            context
                .read<FakeHadithBloc>()
                .add(FakeHadithCopyHadithEvent(fakeHadith: fakeHadith));
          },
        ),
        IconButton(
          tooltip: S.of(context).shareAsImage,
          icon: const Icon(Icons.camera_alt_rounded),
          onPressed: () {
            final DbContent dbContent = DbContent(
              id: -1,
              titleId: -1,
              order: fakeHadith.id,
              content: fakeHadith.text,
              fadl: fakeHadith.darga,
              source: fakeHadith.source,
              count: 0,
              favourite: false,
              hokm: "",
              search: "",
            );

            context.push(
              ShareAsImageScreen(dbContent: dbContent),
            );
          },
        ),
        IconButton(
          tooltip: S.of(context).share,
          icon: const Icon(Icons.share),
          onPressed: () {
            context.read<FakeHadithBloc>().add(
                  FakeHadithShareHadithEvent(fakeHadith: fakeHadith),
                );
          },
        ),
        IconButton(
          tooltip: S.of(context).report,
          icon: const Icon(
            Icons.report,
            color: Colors.orange,
          ),
          onPressed: () {
            context.read<FakeHadithBloc>().add(
                  FakeHadithReportHadithEvent(fakeHadith: fakeHadith),
                );
          },
        ),
      ],
    );
  }
}
