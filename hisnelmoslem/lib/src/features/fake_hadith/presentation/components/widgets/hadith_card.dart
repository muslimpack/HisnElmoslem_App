import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/bloc/fake_hadith_bloc.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class HadithCard extends StatelessWidget {
  final DbFakeHaith fakeHadith;

  const HadithCard({
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
      children: [
        Expanded(
          child: !fakeHadith.isRead
              ? const Icon(
                  Icons.check,
                )
              : const Icon(
                  Icons.checklist,
                ),
        ),
        Expanded(
          child: IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.copy,
            ),
            onPressed: () async {
              context
                  .read<FakeHadithBloc>()
                  .add(FakeHadithCopyHadithEvent(fakeHadith: fakeHadith));
            },
          ),
        ),
        Expanded(
          child: IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: () {
              final DbContent dbContent = DbContent(
                id: -1,
                titleId: -1,
                orderId: fakeHadith.id,
                content: fakeHadith.text,
                fadl: fakeHadith.darga,
                source: fakeHadith.source,
                count: 0,
                favourite: false,
              );

              transitionAnimation.circleReval(
                context: context,
                goToPage: ShareAsImage(dbContent: dbContent),
              );
            },
          ),
        ),
        Expanded(
          child: IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.share),
            onPressed: () {
              context.read<FakeHadithBloc>().add(
                    FakeHadithShareHadithEvent(fakeHadith: fakeHadith),
                  );
            },
          ),
        ),
        Expanded(
          child: IconButton(
            splashRadius: 20,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.report),
            onPressed: () {
              context.read<FakeHadithBloc>().add(
                    FakeHadithReportHadithEvent(fakeHadith: fakeHadith),
                  );
            },
          ),
        ),
      ],
    );
  }
}
