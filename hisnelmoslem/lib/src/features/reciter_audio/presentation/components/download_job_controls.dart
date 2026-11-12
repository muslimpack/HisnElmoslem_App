import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';

/// Progress and the pause, resume, cancel and retry buttons of the job of this reciter.
class DownloadJobControls extends StatelessWidget {
  final ReciterDownloadsState state;
  final ReciterDownloadsCubit downloads;

  const DownloadJobControls({super.key, required this.state, required this.downloads});

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
