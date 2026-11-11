import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/dialogs/yes_no_dialog.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/audio_preview/audio_preview_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/zikr_recorder/zikr_recorder_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/audio_preview_tile.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/components/zikr_preview_text.dart';

/// What the user decided in [RecordAudioSheet]. A dismissed sheet returns null.
class RecordAudioResult {
  /// Name of the new recording, or null when the recording was removed.
  final String? fileName;

  const RecordAudioResult.saved(String this.fileName);
  const RecordAudioResult.removed() : fileName = null;

  bool get isRemoval => fileName == null;
}

/// Bottom sheet to record, preview, keep or delete the user's voice for one zikr.
class RecordAudioSheet extends StatelessWidget {
  final String zikrText;

  /// The recording the zikr already has, if any.
  final String? existingFile;

  /// Bundled original audio of a linked zikr (empty when there is none).
  final String originalAudio;

  const RecordAudioSheet({
    super.key,
    required this.zikrText,
    this.existingFile,
    this.originalAudio = "",
  });

  static Future<RecordAudioResult?> show(
    BuildContext context, {
    required String zikrText,
    String? existingFile,
    String originalAudio = "",
  }) {
    return showModalBottomSheet<RecordAudioResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // A take in progress must not be lost by a stray swipe or tap outside.
      isDismissible: false,
      enableDrag: false,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ZikrRecorderCubit>()),
          BlocProvider(create: (_) => sl<AudioPreviewCubit>()),
        ],
        child: RecordAudioSheet(
          zikrText: zikrText,
          existingFile: existingFile,
          originalAudio: originalAudio,
        ),
      ),
    );
  }

  /// Closes the sheet, asking first when a recording would be lost.
  static Future<void> requestClose(BuildContext context) async {
    final recorder = context.read<ZikrRecorderCubit>();
    final navigator = Navigator.of(context);

    if (recorder.state.isRecording || recorder.state.hasTake) {
      final discard = await YesOrNoDialog.show(
        context,
        msg: S.of(context).recordDiscardTitle,
        details: S.of(context).recordDiscardDetails,
      );
      if (discard != true) return;
      await recorder.discard();
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrRecorderCubit, ZikrRecorderState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        final busy = state.isRecording || state.hasTake;

        return PopScope(
          canPop: !busy,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) requestClose(context);
          },
          child: RecordingLifecycleGuard(
            // useSafeArea only covers the top; keep the buttons above the system bar.
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RecordSheetHeader(),
                    const SizedBox(height: 12),
                    RecordZikrCard(text: zikrText),
                    const SizedBox(height: 16),
                    const RecorderPanel(),
                    if (!state.isRecording && !state.hasTake) ...[
                      if (existingFile != null) ...[
                        const SizedBox(height: 16),
                        ExistingRecordingCard(
                          fileName: existingFile!,
                          hasOriginal: originalAudio.isNotEmpty,
                        ),
                      ],
                      if (originalAudio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: AudioPreviewTile(
                              previewKey: "original",
                              label: S.of(context).recordOriginal,
                              asset: originalAudio,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stops a running recording when the app goes to the background, so the microphone
/// is never left open and a half-finished take is kept for the user to review.
class RecordingLifecycleGuard extends StatefulWidget {
  final Widget child;
  const RecordingLifecycleGuard({super.key, required this.child});

  @override
  State<RecordingLifecycleGuard> createState() => _RecordingLifecycleGuardState();
}

class _RecordingLifecycleGuardState extends State<RecordingLifecycleGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      context.read<ZikrRecorderCubit>().stop();
      context.read<AudioPreviewCubit>().stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class RecordSheetHeader extends StatelessWidget {
  const RecordSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            S.of(context).recordSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: S.of(context).cancel,
          onPressed: () => RecordAudioSheet.requestClose(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

/// The text being recited, so the user can read it while recording.
class RecordZikrCard extends StatelessWidget {
  final String text;
  const RecordZikrCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
      ),
      // Long azkar scroll inside the card instead of being cut off.
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.3),
        child: Scrollbar(
          child: SingleChildScrollView(child: ZikrPreviewText.full(content: text)),
        ),
      ),
    );
  }
}

/// Everything about the current take: the record button, timer, hints and review.
class RecorderPanel extends StatelessWidget {
  const RecorderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<ZikrRecorderCubit, ZikrRecorderState>(
      builder: (context, state) {
        if (state.hasTake) {
          return TakeReview(fileName: state.takeFileName!);
        }

        final (message, isError) = switch (state.status) {
          ZikrRecorderStatus.recording => (s.recordHintRecording, false),
          ZikrRecorderStatus.permissionDenied => (s.recordPermissionDenied, true),
          ZikrRecorderStatus.failed => (s.recordFailed, true),
          _ => (s.recordHintIdle, false),
        };
        final maxDuration = context.read<ZikrRecorderCubit>().maxDuration;

        return Column(
          children: [
            RecordButton(isRecording: state.isRecording, level: state.level),
            const SizedBox(height: 8),
            if (state.isRecording)
              Text(
                "${formatClock(state.elapsed)} / ${formatClock(maxDuration)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isError ? theme.colorScheme.error : theme.hintColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Large mic / stop button that grows with the input level while recording.
class RecordButton extends StatelessWidget {
  final bool isRecording;
  final double level;

  const RecordButton({super.key, required this.isRecording, required this.level});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isRecording ? theme.colorScheme.error : theme.colorScheme.primary;

    return SizedBox(
      height: 132,
      width: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: isRecording ? 1 + level * 0.4 : 1,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(40)),
            ),
          ),
          IconButton.filled(
            tooltip: isRecording ? S.of(context).recordStop : S.of(context).recordStart,
            style: IconButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            iconSize: 40,
            padding: const EdgeInsets.all(20),
            onPressed: () {
              final recorder = context.read<ZikrRecorderCubit>();
              if (isRecording) {
                recorder.stop();
              } else {
                context.read<AudioPreviewCubit>().stop();
                recorder.start();
              }
            },
            icon: Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded),
          ),
        ],
      ),
    );
  }
}

/// Listen to the finished take, then keep it or record again.
class TakeReview extends StatelessWidget {
  final String fileName;
  const TakeReview({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AudioPreviewTile(
              previewKey: "take",
              label: s.recordListen,
              fileName: fileName,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AudioPreviewCubit>().stop();
                  context.read<ZikrRecorderCubit>().start();
                },
                icon: const Icon(Icons.mic_rounded),
                label: Text(s.recordAgain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  final file = context.read<ZikrRecorderCubit>().keepTake();
                  if (file != null) {
                    Navigator.pop(context, RecordAudioResult.saved(file));
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(s.recordUse),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The recording the zikr already has, with a delete action.
class ExistingRecordingCard extends StatelessWidget {
  final String fileName;

  /// Whether deleting brings back a bundled original instead of silence.
  final bool hasOriginal;

  const ExistingRecordingCard({super.key, required this.fileName, required this.hasOriginal});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AudioPreviewTile(previewKey: "existing", label: s.recordCurrent, fileName: fileName),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final confirmed = await YesOrNoDialog.show(
                    context,
                    msg: s.recordDeleteConfirmTitle,
                    details: hasOriginal
                        ? s.recordDeleteConfirmOriginal
                        : s.recordDeleteConfirmCustom,
                  );
                  if (confirmed == true) navigator.pop(const RecordAudioResult.removed());
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(s.recordDelete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
