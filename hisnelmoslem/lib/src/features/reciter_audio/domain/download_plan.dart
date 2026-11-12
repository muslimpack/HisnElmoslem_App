import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';

/// What a download of a reciter (or of one title of it) still has to fetch.
class DownloadPlan extends Equatable {
  final Reciter reciter;

  /// Null means every zikr of the reciter.
  final int? titleId;

  /// Files still missing, in play order, without duplicates (zikrs that share a lesson share a file).
  final List<String> pendingUrls;

  /// Files that are already on the phone.
  final int alreadyDownloaded;

  /// Bytes of the missing files the server told us about, and how many sizes it did not tell.
  final int pendingBytes;
  final int unknownSizes;

  const DownloadPlan({
    required this.reciter,
    required this.titleId,
    required this.pendingUrls,
    required this.alreadyDownloaded,
    this.pendingBytes = 0,
    this.unknownSizes = 0,
  });

  int get totalFiles => alreadyDownloaded + pendingUrls.length;
  bool get isEmpty => pendingUrls.isEmpty;

  @override
  List<Object?> get props => [
    reciter,
    titleId,
    pendingUrls,
    alreadyDownloaded,
    pendingBytes,
    unknownSizes,
  ];
}
