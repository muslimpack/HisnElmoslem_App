// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/screens/share_as_image.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_card.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/azkar_read_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';

class HomeBookmarkedContentCard extends StatefulWidget {
  final DbContent dbContent;
  final DbTitle dbTitle;
  const HomeBookmarkedContentCard({
    super.key,
    required this.dbContent,
    required this.dbTitle,
  });

  @override
  State<HomeBookmarkedContentCard> createState() =>
      _HomeBookmarkedContentCardState();
}

class _HomeBookmarkedContentCardState extends State<HomeBookmarkedContentCard> {
  late DbContent dbContent;
  @override
  void initState() {
    dbContent = widget.dbContent;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomeBookmarkedContentCard oldWidget) {
    dbContent = widget.dbContent;
    super.didUpdateWidget(oldWidget);
  }

  void decrease() {
    if (dbContent.count > 0) {
      setState(() {
        dbContent = dbContent.copyWith(count: dbContent.count - 1);
      });
    }
  }

  void reset() {
    setState(() {
      dbContent = dbContent.copyWith(count: widget.dbContent.count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _TopBar(cardState: this),
          LinearProgressIndicator(
            value: 1 - (dbContent.count / widget.dbContent.count),
          ),
          InkWell(
            onTap: () {
              decrease();
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              constraints: const BoxConstraints(minHeight: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ZikrContentBuilder(
                    dbContent: dbContent,
                    enableDiacritics: AppData.instance.isDiacriticsEnabled,
                    fontSize: AppData.instance.fontSize * 10,
                  ),
                  if (dbContent.fadl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        dbContent.fadl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppData.instance.fontSize * 10,

                          //fontSize: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          _BottomBar(cardState: this),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.cardState,
  });

  final _HomeBookmarkedContentCardState cardState;

  @override
  Widget build(BuildContext context) {
    final dbContent = cardState.widget.dbContent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(MdiIcons.camera),
          onPressed: () {
            transitionAnimation.circleReval(
              context: Get.context!,
              goToPage: ShareAsImage(
                dbContent: dbContent,
              ),
            );
          },
        ),
        IconButton(
          icon: dbContent.favourite
              ? Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.primary,
                )
              : const Icon(
                  Icons.favorite_border,
                ),
          onPressed: () {
            context.read<HomeBloc>().add(
                  HomeToggleContentBookmarkEvent(
                    content: dbContent,
                    bookmark: false,
                  ),
                );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.copy,
          ),
          onPressed: () async {
            final text = await dbContent.getPlainText();
            await Clipboard.setData(
              ClipboardData(
                text: "$text\n${dbContent.fadl}",
              ),
            );

            getSnackbar(
              message: "copied to clipboard".tr,
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.share,
          ),
          onPressed: () {
            Share.share(
              "${dbContent.content}\n${dbContent.fadl}",
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.report,
            color: Colors.orange,
          ),
          onPressed: () {
            EmailManager.sendMisspelledInZikrWithDbModel(
              dbTitle: cardState.widget.dbTitle,
              dbContent: dbContent,
            );
          },
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.cardState,
  });
  final _HomeBookmarkedContentCardState cardState;
  @override
  Widget build(BuildContext context) {
    final DbTitle dbTitle = cardState.widget.dbTitle;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: IconButton(
                splashRadius: 20,
                onPressed: () async {
                  cardState.reset();
                },
                icon: const Icon(Icons.repeat),
              ),
              onTap: () {
                if (!AppData.instance.isCardReadMode) {
                  transitionAnimation.circleReval(
                    context: Get.context!,
                    goToPage: AzkarReadPage(
                      index: dbTitle.id,
                    ),
                  );
                } else {
                  transitionAnimation.circleReval(
                    context: Get.context!,
                    goToPage: AzkarReadCard(
                      index: dbTitle.id,
                    ),
                  );
                }
              },
              title: Text(
                "${"Go to".tr}: ${dbTitle.name}",
                textAlign: TextAlign.center,
              ),
              trailing: Text(
                cardState.dbContent.count.toString(),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
