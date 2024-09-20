import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/commentary_db_helper.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/commentary.dart';

Future<dynamic> showCommentaryDialog({
  required BuildContext context,
  required int contentId,
}) async {
  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return CommentaryDialog(
        contentId: contentId,
      );
    },
  );
}

class CommentaryDialog extends StatefulWidget {
  final int contentId;
  const CommentaryDialog({super.key, required this.contentId});

  @override
  State<CommentaryDialog> createState() => _CommentaryDialogState();
}

class _CommentaryDialogState extends State<CommentaryDialog> {
  bool isLoading = true;
  late Commentary? commentary;

  Future<void> getData() async {
    final data = await sl<CommentaryDBHelper>()
        .getCommentaryByContentId(contentId: widget.contentId);
    commentary = data;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  S.of(context).commentarySharh,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size(0, 48),
                  child: TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          S.of(context).commentaryHadith,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          S.of(context).commentaryBenefit,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          S.of(context).commentarySharh,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  CommentaryPageView(
                    text: commentary!.hadith,
                  ),
                  CommentaryPageView(
                    text: commentary!.benefit,
                  ),
                  CommentaryPageView(
                    text: commentary!.sharh,
                  ),
                ],
              ),
            ),
          );
  }
}

class CommentaryPageView extends StatelessWidget {
  final String text;
  const CommentaryPageView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                text,
                style: TextStyle(
                  fontSize: state.fontSize * 10,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
