// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';

class DbContent extends Equatable {
  final int id;
  final String content;
  final int titleId;
  final int order;
  final int count;
  final String fadl;
  final String source;
  final String search;
  final String hokm;
  final String audio;
  final bool hasAudio;

  /// Remote recordings per reciter slug (`contents.audio_urls`). A zikr that spans several
  /// lessons has more than one url, to be played in order.
  final Map<String, List<String>> audioUrls;

  /// False when the remote recordings must not be used for this zikr (it is only a piece of a
  /// lesson, or the recording says another wording). The bundled [audio] is not affected.
  final bool audioRemoteOk;

  /// Set when this content is a zikr authored by the user (custom azkar).
  final int? customZikrId;

  /// Absolute path of a recording made by the user. When set it is played instead
  /// of the bundled [audio].
  final String userAudioPath;

  const DbContent({
    required this.id,
    required this.content,
    required this.titleId,
    required this.order,
    required this.count,
    required this.fadl,
    required this.source,
    required this.search,
    required this.hokm,
    required this.audio,
    required this.hasAudio,
    this.audioUrls = const {},
    this.audioRemoteOk = false,
    this.customZikrId,
    this.userAudioPath = "",
  });

  /// True when there is something to play: the user's recording, bundled audio or a remote
  /// recording of some reciter.
  bool get hasPlayableAudio =>
      userAudioPath.isNotEmpty || audio.isNotEmpty || (audioRemoteOk && audioUrls.isNotEmpty);

  DbContent copyWith({
    int? id,
    String? content,
    int? titleId,
    int? order,
    int? count,
    String? fadl,
    String? source,
    String? search,
    String? hokm,
    String? audio,
  }) {
    return DbContent(
      id: id ?? this.id,
      content: content ?? this.content,
      titleId: titleId ?? this.titleId,
      order: order ?? this.order,
      count: count ?? this.count,
      fadl: fadl ?? this.fadl,
      source: source ?? this.source,
      search: search ?? this.search,
      hokm: hokm ?? this.hokm,
      audio: audio ?? this.audio,
      hasAudio: hasAudio,
      audioUrls: audioUrls,
      audioRemoteOk: audioRemoteOk,
      customZikrId: customZikrId,
      userAudioPath: userAudioPath,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      content,
      titleId,
      order,
      count,
      fadl,
      source,
      search,
      hokm,
      audio,
      audioUrls,
      audioRemoteOk,
      customZikrId,
      userAudioPath,
    ];
  }

  factory DbContent.fromMap(Map<String, dynamic> map) {
    final String? audio = map['audio'] as String?;
    return DbContent(
      id: map['id'] as int,
      content: map['content'] as String,
      titleId: map['titleId'] as int,
      order: map['order'] as int,
      count: map['count'] as int,
      search: (map['search'] as String?) ?? "",
      source: (map['source'] as String?) ?? "",
      fadl: (map['fadl'] as String?) ?? "",
      hokm: (map['hokm'] as String?) ?? "",
      audio: audio ?? "",
      hasAudio: audio != null,
      audioUrls: parseAudioUrls(map['audio_urls']),
      audioRemoteOk: map['audio_remote_ok'] == 1,
    );
  }

  /// Parses `{"reciter": "url" | ["url", ...]}`; anything malformed gives an empty map.
  static Map<String, List<String>> parseAudioUrls(Object? raw) {
    if (raw is! String || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final result = <String, List<String>>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        final List<String> urls = switch (value) {
          final String url => [url],
          final List<dynamic> list => list.whereType<String>().toList(),
          _ => const [],
        };
        if (urls.isNotEmpty) result['${entry.key}'] = urls;
      }
      return result;
    } catch (_) {
      return const {};
    }
  }
}

extension DbContentExtension on DbContent {
  Future<String> sharedText() async {
    final StringBuffer sb = StringBuffer();
    final content = await getPlainText();
    sb.writeln("$content\n");
    sb.writeln("🔢عدد المرات: $count\n");
    if (fadl.isNotEmpty) sb.writeln("🏆الفضل: $fadl\n");
    if (source.isNotEmpty) sb.writeln("📚المصدر:\n$source");
    return sb.toString();
  }
}
