import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/audio_file_store.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter_audio_status.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_download_actions.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_name.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';

/// Choose the reciter, download a whole reciter and decide whether recordings may be streamed.
class ReciterAudioSheet extends StatefulWidget {
  const ReciterAudioSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const SafeArea(top: false, child: ReciterAudioSheet()),
    );
  }

  @override
  State<ReciterAudioSheet> createState() => _ReciterAudioSheetState();
}

class _ReciterAudioSheetState extends State<ReciterAudioSheet> {
  final repo = sl<ReciterAudioRepo>();
  final downloads = sl<ReciterDownloadsCubit>();

  late Reciter selected = repo.getReciter();
  late bool allowStream = repo.getAllowStream();
  final Map<String, ReciterAudioStatus> statuses = {};

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    for (final reciter in Reciter.all) {
      final status = await downloads.statusOf(reciter);
      if (!mounted) return;
      setState(() => statuses[reciter.slug] = status);
    }
  }

  Future<void> _delete(Reciter reciter) async {
    final s = S.of(context);
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.audioDeleteDownloads),
        content: Text(s.audioDeleteConfirm(reciter.localizedName(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.delete)),
        ],
      ),
    );
    if (agreed != true) return;
    await sl<AudioFileStore>().deleteReciter(reciter);
    await _loadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<ReciterDownloadsCubit, ReciterDownloadsState>(
      bloc: downloads,
      // A job that ended, paused or was cancelled changed what is on the phone.
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) => _loadStatuses(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(s.audioReciterSheetTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final reciter in Reciter.all) ...[
              ReciterTile(
                reciter: reciter,
                selected: reciter == selected,
                status: statuses[reciter.slug],
                downloads: downloads,
                onSelect: () async {
                  await repo.setReciter(reciter);
                  setState(() => selected = reciter);
                },
                onDownload: () => ReciterDownloadActions.download(context, reciter),
                onDelete: () => _delete(reciter),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedSurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchListTile(
                value: allowStream,
                title: Text(s.audioAllowStream),
                subtitle: Text(s.audioAllowStreamDesc),
                onChanged: (value) async {
                  await repo.setAllowStream(value);
                  setState(() => allowStream = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One reciter: selection, what is on the phone, and the download controls.
class ReciterTile extends StatelessWidget {
  final Reciter reciter;
  final bool selected;
  final ReciterAudioStatus? status;
  final ReciterDownloadsCubit downloads;
  final VoidCallback onSelect;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const ReciterTile({
    super.key,
    required this.reciter,
    required this.selected,
    required this.status,
    required this.downloads,
    required this.onSelect,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final status = this.status;

    return OutlinedSurfaceCard(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            onTap: onSelect,
            leading: Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? theme.colorScheme.primary : null,
            ),
            title: Text(
              reciter.localizedName(context),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              [
                if (reciter.isBundled) s.audioBundledReciterNote,
                if (status != null && status.totalFiles > 0)
                  s.audioFilesStatus(
                    status.downloadedFiles,
                    status.totalFiles,
                    formatBytes(status.downloadedBytes),
                  ),
              ].join('\n'),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: BlocBuilder<ReciterDownloadsCubit, ReciterDownloadsState>(
              bloc: downloads,
              builder: (context, state) {
                final mine = state.reciter == reciter && state.status != DownloadStatus.idle;
                if (mine && state.titleId == null) {
                  return _JobControls(state: state, downloads: downloads);
                }
                return Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: status == null || status.isComplete ? null : onDownload,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(s.audioDownloadAll),
                      ),
                    ),
                    if (status != null && status.hasDownloads) ...[
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        tooltip: s.audioDeleteDownloads,
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress and the pause, resume, cancel and retry buttons of the job of this reciter.
class _JobControls extends StatelessWidget {
  final ReciterDownloadsState state;
  final ReciterDownloadsCubit downloads;

  const _JobControls({required this.state, required this.downloads});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final running = state.isRunning;
    final paused = state.status == DownloadStatus.paused;
    final failed = state.failedUrls.length;

    final label = switch (state.status) {
      DownloadStatus.running => s.audioDownloading(state.doneFiles, state.totalFiles),
      DownloadStatus.paused => s.audioDownloadPaused(state.doneFiles, state.totalFiles),
      _ => failed > 0 ? s.audioDownloadFailedFiles(failed) : s.audioDownloadDone,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (running || paused) LinearProgressIndicator(value: state.fileProgress),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.bodySmall),
        Wrap(
          spacing: 8,
          children: [
            if (running)
              TextButton.icon(
                onPressed: downloads.pause,
                icon: const Icon(Icons.pause_rounded),
                label: Text(s.audioDownloadPause),
              ),
            if (paused)
              TextButton.icon(
                onPressed: downloads.resume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(s.audioDownloadResume),
              ),
            if (!running && !paused && failed > 0)
              TextButton.icon(
                onPressed: downloads.resume,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(s.audioDownloadRetry),
              ),
            if (running || paused)
              TextButton(onPressed: downloads.cancel, child: Text(s.cancel))
            else
              TextButton(onPressed: downloads.cancel, child: const Icon(Icons.close_rounded)),
          ],
        ),
      ],
    );
  }
}
