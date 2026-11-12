import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/outlined_surface_card.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/byte_format.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter_audio_status.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_name.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/screens/reciter_titles_screen.dart';

/// Lists the reciters. Tapping one opens its titles, where recordings are downloaded or deleted.
class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  final repo = sl<ReciterAudioRepo>();
  final downloads = sl<ReciterDownloadsCubit>();

  late Reciter selected = repo.getReciter();
  late bool allowStream = repo.getAllowStream();
  final Map<String, ReciterAudioStatus> statuses = {};
  bool _loading = false;
  bool _reloadAgain = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// One load at a time; a change that arrives meanwhile triggers one more load.
  Future<void> _load() async {
    if (_loading) {
      _reloadAgain = true;
      return;
    }
    _loading = true;
    try {
      for (final reciter in Reciter.all) {
        final status = await downloads.statusOf(reciter);
        if (!mounted) return;
        setState(() => statuses[reciter.slug] = status);
      }
    } finally {
      _loading = false;
    }
    if (_reloadAgain && mounted) {
      _reloadAgain = false;
      await _load();
    }
  }

  Future<void> _open(Reciter reciter) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReciterTitlesScreen(reciter: reciter)),
    );
    if (!mounted) return;
    setState(() => selected = repo.getReciter());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(s.downloadCenter),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocListener<ReciterDownloadsCubit, ReciterDownloadsState>(
        bloc: downloads,
        listenWhen: (a, b) => a.status != b.status || a.doneFiles != b.doneFiles,
        listener: (context, state) => _load(),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(s.downloadCenterDesc, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            for (final reciter in Reciter.all) ...[
              _ReciterCard(
                reciter: reciter,
                selected: reciter == selected,
                status: statuses[reciter.slug],
                downloads: downloads,
                onTap: () => _open(reciter),
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

class _ReciterCard extends StatelessWidget {
  final Reciter reciter;
  final bool selected;
  final ReciterAudioStatus? status;
  final ReciterDownloadsCubit downloads;
  final VoidCallback onTap;

  const _ReciterCard({
    required this.reciter,
    required this.selected,
    required this.status,
    required this.downloads,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final status = this.status;

    return OutlinedSurfaceCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withAlpha(30),
                    foregroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.record_voice_over_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reciter.localizedName(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selected)
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  s.audioReciterInUse,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (reciter.isBundled)
                          Text(s.audioBundledReciterNote, style: theme.textTheme.bodySmall),
                        if (status != null && status.totalFiles > 0)
                          Text(
                            s.audioFilesStatus(
                              status.downloadedFiles,
                              status.totalFiles,
                              formatBytes(status.downloadedBytes),
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              BlocBuilder<ReciterDownloadsCubit, ReciterDownloadsState>(
                bloc: downloads,
                builder: (context, state) {
                  final mine = state.reciter == reciter && state.isRunning;
                  if (!mine) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: state.fileProgress),
                        const SizedBox(height: 4),
                        Text(
                          s.audioDownloading(state.doneFiles, state.totalFiles),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
