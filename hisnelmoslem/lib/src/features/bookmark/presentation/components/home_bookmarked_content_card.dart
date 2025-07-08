// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/components/zikr_toggle_favorite_icon_button.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/effects_manager.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_share_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_zikr_body.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/screens/zikr_viewer_screen.dart';

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
      sl<EffectsManager>().playPraiseEffects();
      if (dbContent.count == 1) {
        sl<EffectsManager>().playZikrEffects();
      }

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
              constraints: const BoxConstraints(minHeight: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ZikrViewerZikrBody(dbContent: dbContent)],
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
  const _TopBar({required this.cardState});

  final _HomeBookmarkedContentCardState cardState;

  @override
  Widget build(BuildContext context) {
    final dbContent = cardState.widget.dbContent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ZikrToggleFavoriteIconButton(dbContent: dbContent),
        IconButton(
          tooltip: S.of(context).share,
          icon: const Icon(Icons.share),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ZikrShareDialog(contentId: dbContent.id);
              },
            );
          },
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.cardState});
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
                tooltip: S.of(context).resetZikr,
                onPressed: () {
                  cardState.reset();
                },
                icon: const Icon(Icons.repeat),
              ),
              onTap: () {
                context.push(ZikrViewerScreen(index: dbTitle.id));
              },
              title: Text(
                "${S.of(context).goTo}: ${dbTitle.name}",
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
