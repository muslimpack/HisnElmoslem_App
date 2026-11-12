import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_state.dart';

/// A small floating pill, above every screen, that shows a download running in the background:
/// progress, pause and resume. Tapping it opens the download center. It also reports the end of
/// a download, and stays while some files failed so they can be retried.
class DownloadActivityPill extends StatefulWidget {
  final ReciterDownloadsCubit downloads;
  final VoidCallback onTap;

  const DownloadActivityPill({super.key, required this.downloads, required this.onTap});

  @override
  State<DownloadActivityPill> createState() => _DownloadActivityPillState();
}

class _DownloadActivityPillState extends State<DownloadActivityPill> {
  bool _dismissed = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onState(ReciterDownloadsState state) {
    _hideTimer?.cancel();
    if (state.status == DownloadStatus.completed && state.failedUrls.isEmpty) {
      // A finished download disappears by itself.
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _dismissed = true);
      });
    } else if (_dismissed && state.status != DownloadStatus.idle) {
      setState(() => _dismissed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReciterDownloadsCubit, ReciterDownloadsState>(
      bloc: widget.downloads,
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == DownloadStatus.running) _dismissed = false;
        _onState(state);
      },
      builder: (context, state) {
        final visible =
            !_dismissed &&
            (state.status == DownloadStatus.running ||
                state.status == DownloadStatus.paused ||
                state.status == DownloadStatus.completed);

        return Positioned(
          top: MediaQuery.paddingOf(context).top + 6,
          left: 12,
          right: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: visible
                ? Align(
                    key: const ValueKey('pill'),
                    alignment: Alignment.topCenter,
                    child: _PillBody(
                      state: state,
                      downloads: widget.downloads,
                      onTap: widget.onTap,
                      onClose: () => setState(() => _dismissed = true),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('none')),
          ),
        );
      },
    );
  }
}

class _PillBody extends StatelessWidget {
  final ReciterDownloadsState state;
  final ReciterDownloadsCubit downloads;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _PillBody({
    required this.state,
    required this.downloads,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final failed = state.failedUrls.length;

    final running = state.isRunning;
    final paused = state.status == DownloadStatus.paused;
    final text = running
        ? s.audioDownloading(state.doneFiles, state.totalFiles)
        : paused
        ? s.audioDownloadPaused(state.doneFiles, state.totalFiles)
        : failed > 0
        ? s.audioDownloadFailedFiles(failed)
        : s.audioDownloadDone;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Material(
        color: colors.inverseSurface,
        elevation: 6,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: running || paused
                      ? CircularProgressIndicator(
                          value: running && state.totalFiles == 0 ? null : state.fileProgress,
                          strokeWidth: 3,
                          color: colors.onInverseSurface,
                          backgroundColor: colors.onInverseSurface.withAlpha(60),
                        )
                      : Icon(
                          failed > 0 ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                          size: 22,
                          color: colors.onInverseSurface,
                        ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.onInverseSurface),
                  ),
                ),
                // No tooltips here: the pill lives above the navigator, where there is no Overlay.
                if (running)
                  Semantics(
                    button: true,
                    label: s.audioDownloadPause,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      color: colors.onInverseSurface,
                      onPressed: downloads.pause,
                      icon: const Icon(Icons.pause_rounded),
                    ),
                  )
                else if (paused || failed > 0)
                  Semantics(
                    button: true,
                    label: paused ? s.audioDownloadResume : s.audioDownloadRetry,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      color: colors.onInverseSurface,
                      onPressed: downloads.resume,
                      icon: Icon(paused ? Icons.play_arrow_rounded : Icons.refresh_rounded),
                    ),
                  )
                else
                  const SizedBox(width: 8),
                if (!running)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    color: colors.onInverseSurface,
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
