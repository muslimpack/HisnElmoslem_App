import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/mappers/resolved_item_mapper.dart';

void main() {
  const item = CustomTitleItem(id: 4, kind: CustomItemKind.custom, refId: 9, audioFile: "a.m4a");

  test("viewer content carries the recording path and counts as playable", () {
    final content = const ResolvedTitleItem(
      item: item,
      content: "text",
    ).toViewerContent(customTitleId: 1, order: 0, userAudioPath: "/rec/a.m4a");

    expect(content.userAudioPath, "/rec/a.m4a");
    expect(content.audio, isEmpty);
    expect(content.hasPlayableAudio, isTrue);
  });

  test("without a recording or bundled audio there is nothing to play", () {
    final content = const ResolvedTitleItem(
      item: item,
      content: "text",
    ).toViewerContent(customTitleId: 1, order: 0);

    expect(content.hasPlayableAudio, isFalse);
  });

  test("bundled audio is still playable and the recording takes precedence", () {
    final content = const ResolvedTitleItem(
      item: item,
      content: "text",
      audio: "x.mp3",
    ).toViewerContent(customTitleId: 1, order: 0, userAudioPath: "/rec/a.m4a");

    expect(content.hasPlayableAudio, isTrue);
    expect(content.audio, "x.mp3");
    expect(content.userAudioPath, isNotEmpty);
  });
}
