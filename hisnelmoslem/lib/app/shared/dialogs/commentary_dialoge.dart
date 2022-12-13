import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/data/models/commentary.dart';
import 'package:hisnelmoslem/app/shared/widgets/loading.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/core/values/constant.dart';

Future<dynamic> showCommentaryDialoge({
  required BuildContext context,
  required int contentId,
}) async {
  // show the dialog
  return await showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return CommentaryDialoge(
        contentId: contentId,
      );
    },
  );
}

class CommentaryDialoge extends StatefulWidget {
  final int contentId;
  const CommentaryDialoge({super.key, required this.contentId});

  @override
  State<CommentaryDialoge> createState() => _CommentaryDialogeState();
}

class _CommentaryDialogeState extends State<CommentaryDialoge> {
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
                    )),
              ),
              body: ScrollGlowCustom(
                axisDirection: AxisDirection.right,
                child: TabBarView(children: [
                  CommentaryPageView(
                    text: commentary!.hadith,
                  ),
                  CommentaryPageView(
                    text: commentary!.benefit,
                  ),
                  CommentaryPageView(
                    text: commentary!.sharh,
                  ),
                ]),
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
