import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_remover.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:hisnelmoslem/core/values/new_featuers_list.dart';
import 'package:timelines/timelines.dart';

class AppUpdateNews extends StatelessWidget {
  const AppUpdateNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("updates history".tr),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ScrollGlowRemover(
        child: ListView(
          children: const [
            AppUpdatesHistory(),
          ],
        ),
      ),
    );
  }
}

class InnerTimeline extends StatelessWidget {
  const InnerTimeline({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineTheme.of(context).copyWith(
            nodePosition: 0,
            connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
                  thickness: 2.0,
                ),
            indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
                  size: 10.0,
                  position: 0.5,
                ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: messages.length,
            contentsBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messages[index].toString(),
                    ),
                  ],
                ),
              );
            },
            indicatorBuilder: (_, index) {
              return const OutlinedDotIndicator(borderWidth: 2);
            },
            connectorBuilder: (_, index, ___) => const SolidLineConnector(),
          ),
        ));
  }
}

class AppUpdatesHistory extends StatelessWidget {
  const AppUpdatesHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 12.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: const Color(0xff989898),
            indicatorTheme: const IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: const ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: updateNewFeature.length,
            contentsBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      index == 0
                          ? "${"Current version".tr}: ${updateNewFeature[index][0]}"
                          : updateNewFeature[index][0],
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: 15.0,
                          ),
                    ),
                    InnerTimeline(
                        messages: updateNewFeature[index][1].split("\n")),
                  ],
                ),
              );
            },
            indicatorBuilder: (_, index) {
              if (index == 0) {
                return DotIndicator(
                  color: mainColor,
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 12.0,
                  ),
                );
              } else {
                return const OutlinedDotIndicator(
                  borderWidth: 2.5,
                );
              }
            },
            connectorBuilder: (_, index, ___) => SolidLineConnector(
              color: index == 1 ? mainColor : null,
            ),
          ),
        ),
      ),
    );
  }
}
