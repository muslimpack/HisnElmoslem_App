// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image_screen.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/repository/zikr_viewer_repo.dart';
import 'package:share_plus/share_plus.dart';

class ZikrShareDialog extends StatefulWidget {
  final int contentId;
  const ZikrShareDialog({super.key, required this.contentId});

  @override
  State<ZikrShareDialog> createState() => _ZikrShareDialogState();
}

class _ZikrShareDialogState extends State<ZikrShareDialog> {
  late final DbContent dbContent;
  String shareText = '';
  bool shareFadl = false;
  bool shareSource = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future _load() async {
    dbContent = await sl<HisnDBHelper>().getContentsByContentId(
      contentId: widget.contentId,
    );

    shareFadl = sl<ZikrViewerRepo>().shareFadl;
    shareSource = sl<ZikrViewerRepo>().shareSource;

    isLoading = false;
    _buildSharedText();
  }

  Future _buildSharedText() async {
    shareText = await sharedText();
    setState(() {});
  }

  Future<String> sharedText() async {
    final StringBuffer sb = StringBuffer();
    final content = await dbContent.getPlainText();
    sb.writeln("$content\n");
    sb.writeln("🔢عدد المرات: ${dbContent.count}\n");
    if (shareFadl && dbContent.fadl.isNotEmpty) {
      sb.writeln("🏆الفضل: ${dbContent.fadl}\n");
    }
    if (shareSource && dbContent.source.isNotEmpty) {
      sb.writeln("📚المصدر:\n${dbContent.source}");
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: AlertDialog(
        scrollable: true,
        title: Text(S.of(context).shareZikr),
        content: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 350),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Text(shareText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      ChoiceChip(
                        selected: shareFadl,
                        label: Text(S.of(context).showFadl),
                        onSelected: (value) async {
                          shareFadl = value;
                          await sl<ZikrViewerRepo>().toggleShareFadl(value);
                          _buildSharedText();
                        },
                      ),
                      ChoiceChip(
                        selected: shareSource,
                        label: Text(S.of(context).showSourceOfZikr),
                        onSelected: (value) async {
                          shareSource = value;
                          await sl<ZikrViewerRepo>().toggleShareSource(value);
                          _buildSharedText();
                        },
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            tooltip: S.of(context).shareAsImage,
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              context.push(ShareAsImageScreen(dbContent: dbContent));
            },
          ),
          IconButton(
            tooltip: S.of(context).copy,
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: shareText));
              if (!context.mounted) return;
              showToast(msg: S.of(context).copiedToClipboard);
            },
          ),
          IconButton(
            tooltip: S.of(context).share,
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share(shareText);
            },
          ),
        ],
      ),
    );
  }
}
