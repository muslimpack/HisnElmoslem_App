import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';

Future<dynamic> showCommentaryDialog({
  required BuildContext context,
  required int contentId,
}) async {
  // show the dialog
  return showDialog(
    barrierDismissible: true,
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
    await azkarDatabaseHelper
        .getCommentaryByContentId(contentId: widget.contentId)
        .then((value) {
      commentary = value;
      setState(() {
        isLoading = false;
      });
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
                  "Commentary sharh".tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size(0, 48),
                  child: TabBar(
                    indicatorColor: mainColor,
                    tabs: [
                      Tab(
                        child: Text(
                          "Commentary hadith".tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Commentary Benefit".tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Commentary sharh".tr,
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
        Padding(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            text,
            style: TextStyle(fontSize: appData.fontSize * 10),
          ),
        ),
      ],
    );
  }
}
