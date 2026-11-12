import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter_audio_status.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_job_controls.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_download_actions.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_name.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';

/// The titles that have recordings of [reciter]. Each one can be downloaded or deleted, and
/// the whole reciter can be downloaded or deleted from the header.
class ReciterTitlesScreen extends StatefulWidget {
  final Reciter reciter;

  /// The titles to match with the recordings; the bundled database when null (tests give their own).
  final Future<List<DbTitle>> Function()? loadTitles;

  const ReciterTitlesScreen({super.key, required this.reciter, this.loadTitles});

  @override
  State<ReciterTitlesScreen> createState() => _ReciterTitlesScreenState();
}

class _ReciterTitlesScreenState extends State<ReciterTitlesScreen> {
  final repo = sl<ReciterAudioRepo>();
  final downloads = sl<ReciterDownloadsCubit>();

  Reciter get reciter => widget.reciter;

  late bool isSelected = repo.getReciter() == reciter;
  List<DbTitle> titles = const [];
  Map<int, ReciterAudioStatus> statuses = const {};
  bool loaded = false;
  bool _loading = false;
  bool _reloadAgain = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) {
      _reloadAgain = true;
      return;
    }
    _loading = true;
    try {
      final all = await (widget.loadTitles ?? sl<HisnDBHelper>().getAllTitles)();
      final byTitle = await downloads.titleStatuses(reciter);
      if (!mounted) return;
      setState(() {
        titles = all.where((t) => byTitle.containsKey(t.id)).toList();
        statuses = byTitle;
        loaded = true;
      });
    } finally {
      _loading = false;
    }
    if (_reloadAgain && mounted) {
      _reloadAgain = false;
      await _load();
    }
  }

  Future<bool> _confirmDelete(String message) async {
    final s = S.of(context);
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.audioDeleteDownloads),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.delete)),
        ],
      ),
    );
    return agreed ?? false;
  }

  Future<void> _deleteAll() async {
    if (!await _confirmDelete(S.of(context).audioDeleteConfirm(reciter.localizedName(context)))) {
      return;
    }
    await sl<AudioFileStore>().deleteReciter(reciter);
    await _load();
  }

  Future<void> _deleteTitle(DbTitle title) async {
    if (!await _confirmDelete(S.of(context).audioDeleteTitleConfirm(title.name))) return;
    await downloads.deleteTitle(reciter, title.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(reciter.localizedName(context)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocListener<ReciterDownloadsCubit, ReciterDownloadsState>(
        bloc: downloads,
        listenWhen: (a, b) => a.status != b.status || a.doneFiles != b.doneFiles,
        listener: (context, state) => _load(),
        child: !loaded
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: titles.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _Header(
                        reciter: reciter,
                        isSelected: isSelected,
                        total: _total(),
                        downloads: downloads,
                        onUse: () async {
                          await repo.setReciter(reciter);
                          setState(() => isSelected = true);
                        },
                        onDownloadAll: () => ReciterDownloadActions.download(context, reciter),
                        onDeleteAll: _deleteAll,
                      ),
                    );
                  }
                  final title = titles[index - 1];
                  return _TitleTile(
                    title: title,
                    status: statuses[title.id]!,
                    reciter: reciter,
                    downloads: downloads,
                    onDownload: () =>
                        ReciterDownloadActions.download(context, reciter, titleId: title.id),
                    onDelete: () => _deleteTitle(title),
                  );
                },
              ),
      ),
    );
  }

  /// Totals over the titles, counting a lesson shared by two titles once per title.
  ReciterAudioStatus _total() {
    var files = 0;
    var done = 0;
    var bytes = 0;
    for (final s in statuses.values) {
      files += s.totalFiles;
      done += s.downloadedFiles;
      bytes += s.downloadedBytes;
    }
    return ReciterAudioStatus(totalFiles: files, downloadedFiles: done, downloadedBytes: bytes);
  }
}

class _Header extends StatelessWidget {
  final Reciter reciter;
  final bool isSelected;
  final ReciterAudioStatus total;
  final ReciterDownloadsCubit downloads;
  final VoidCallback onUse;
  final VoidCallback onDownloadAll;
  final VoidCallback onDeleteAll;

  const _Header({
    required this.reciter,
    required this.isSelected,
    required this.total,
    required this.downloads,
    required this.onUse,
    required this.onDownloadAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return OutlinedSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reciter.isBundled) Text(s.audioBundledReciterNote, style: theme.textTheme.bodySmall),
          if (total.totalFiles > 0)
            Text(
              s.audioFilesStatus(
                total.downloadedFiles,
                total.totalFiles,
                formatBytes(total.downloadedBytes),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 12),
          if (isSelected)
            Chip(
              avatar: Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
              label: Text(s.audioReciterInUse),
            )
          else
            OutlinedButton.icon(
              onPressed: onUse,
              icon: const Icon(Icons.record_voice_over_rounded),
              label: Text(s.audioUseReciter),
            ),
          const SizedBox(height: 8),
          BlocBuilder<ReciterDownloadsCubit, ReciterDownloadsState>(
            bloc: downloads,
            builder: (context, state) {
              final mine = state.reciter == reciter && state.status != DownloadStatus.idle;
              // A whole-reciter job shows its controls here; a single title shows them on its row.
              if (mine && state.titleId == null) {
                return DownloadJobControls(state: state, downloads: downloads);
              }
              return Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: total.totalFiles == 0 || total.downloadedFiles >= total.totalFiles
                          ? null
                          : onDownloadAll,
                      icon: const Icon(Icons.download_rounded),
                      label: Text(s.audioDownloadAll),
                    ),
                  ),
                  if (total.downloadedFiles > 0) ...[
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: s.audioDeleteAll,
                      onPressed: onDeleteAll,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TitleTile extends StatelessWidget {
  final DbTitle title;
  final ReciterAudioStatus status;
  final Reciter reciter;
  final ReciterDownloadsCubit downloads;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _TitleTile({
    required this.title,
    required this.status,
    required this.reciter,
    required this.downloads,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: BlocBuilder<ReciterDownloadsCubit, ReciterDownloadsState>(
        bloc: downloads,
        builder: (context, state) {
          final running = state.isRunning && state.reciter == reciter && state.titleId == title.id;

          Widget trailing;
          if (running) {
            trailing = SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: s.audioDownloadPause,
                onPressed: downloads.pause,
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(value: state.fileProgress, strokeWidth: 3),
                    ),
                    const Icon(Icons.pause_rounded, size: 16),
                  ],
                ),
              ),
            );
          } else {
            trailing = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!status.isComplete)
                  IconButton(
                    tooltip: s.audioDownloadTooltip,
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_rounded),
                  ),
                if (status.hasDownloads)
                  IconButton(
                    tooltip: s.audioDeleteDownloads,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            );
          }

          return ListTile(
            title: Text(title.name),
            subtitle: Text(
              running
                  ? s.audioDownloading(state.doneFiles, state.totalFiles)
                  : status.isComplete
                  ? '${s.audioTitleDownloaded} · ${formatBytes(status.downloadedBytes)}'
                  : s.audioFilesStatus(
                      status.downloadedFiles,
                      status.totalFiles,
                      formatBytes(status.downloadedBytes),
                    ),
            ),
            leading: Icon(
              status.isComplete ? Icons.check_circle_rounded : Icons.cloud_download_outlined,
              color: status.isComplete ? theme.colorScheme.primary : null,
            ),
            trailing: trailing,
          );
        },
      ),
    );
  }
}
