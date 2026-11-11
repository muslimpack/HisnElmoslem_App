import 'package:equatable/equatable.dart';

enum CustomItemKind {
  /// Points to a [CustomZikr].
  custom,

  /// Points to a zikr of the bundled Hisn al-Muslim database.
  original;

  static CustomItemKind fromName(String name) {
    return CustomItemKind.values.where((e) => e.name == name).firstOrNull ?? CustomItemKind.custom;
  }
}

/// Copy of an original zikr's text, kept so the item survives if the bundled
/// content changes or disappears in a future database version.
class ZikrSnapshot extends Equatable {
  final String content;
  final String source;
  final String fadl;
  final String hokm;

  const ZikrSnapshot({
    required this.content,
    this.source = "",
    this.fadl = "",
    this.hokm = "",
  });

  @override
  List<Object> get props => [content, source, fadl, hokm];
}

/// A row linking a zikr (custom or original) to a custom title.
class CustomTitleItem extends Equatable {
  final int id;
  final int titleId;
  final CustomItemKind kind;

  /// Custom zikr id when [kind] is custom, original content id otherwise.
  final int refId;
  final int sortOrder;
  final int count;

  /// Only set for [CustomItemKind.original].
  final ZikrSnapshot? snapshot;

  /// Name of the user's recording (see `CustomAudioStorage`). When set it is played
  /// instead of the original zikr's bundled audio.
  final String? audioFile;

  const CustomTitleItem({
    this.id = 0,
    this.titleId = 0,
    required this.kind,
    required this.refId,
    this.sortOrder = 0,
    this.count = 1,
    this.snapshot,
    this.audioFile,
  });

  bool get hasUserAudio => audioFile != null && audioFile!.isNotEmpty;

  /// [audioFile] keeps its value when omitted; pass [clearAudio] to remove it.
  CustomTitleItem copyWith({
    int? id,
    int? titleId,
    int? sortOrder,
    int? count,
    ZikrSnapshot? snapshot,
    String? audioFile,
    bool clearAudio = false,
  }) {
    return CustomTitleItem(
      id: id ?? this.id,
      titleId: titleId ?? this.titleId,
      kind: kind,
      refId: refId,
      sortOrder: sortOrder ?? this.sortOrder,
      count: count ?? this.count,
      snapshot: snapshot ?? this.snapshot,
      audioFile: clearAudio ? null : (audioFile ?? this.audioFile),
    );
  }

  @override
  List<Object?> get props => [id, titleId, kind, refId, sortOrder, count, snapshot, audioFile];
}

/// A [CustomTitleItem] together with the text that should be displayed for it.
class ResolvedTitleItem extends Equatable {
  final CustomTitleItem item;
  final String content;
  final String source;
  final String fadl;
  final String hokm;

  /// Audio file name; only for original zikrs that resolve live.
  final String audio;

  /// True when the original zikr could not be found and the saved copy is shown.
  final bool isFromSnapshot;

  const ResolvedTitleItem({
    required this.item,
    required this.content,
    this.source = "",
    this.fadl = "",
    this.hokm = "",
    this.audio = "",
    this.isFromSnapshot = false,
  });

  @override
  List<Object> get props => [item, content, source, fadl, hokm, audio, isFromSnapshot];
}
