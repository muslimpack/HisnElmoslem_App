import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/domain/reciter.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/download_confirm_dialog.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/controller/reciter_downloads_cubit.dart';

/// Starts a download of a reciter (or of one title of it) after the user confirms.
class ReciterDownloadActions {
  const ReciterDownloadActions._();

  /// Builds the plan, asks for confirmation and starts the job in the background.
  /// [titleId] null means the whole reciter.
  static Future<void> download(
    BuildContext context,
    Reciter reciter, {
    int? titleId,
  }) async {
    final cubit = sl<ReciterDownloadsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);

    if (cubit.state.isRunning) {
      messenger.showSnackBar(SnackBar(content: Text(s.audioDownloadAlreadyRunning)));
      return;
    }

    // Reading the sizes takes a moment, so show that something is happening.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
    final navigator = Navigator.of(context, rootNavigator: true);
    final plan = await cubit.buildPlan(reciter, titleId: titleId);
    navigator.pop();

    if (plan.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.audioNothingToDownload)));
      return;
    }
    if (!context.mounted) return;
    if (!await DownloadConfirmDialog.show(context, plan: plan)) return;

    unawaited(cubit.start(plan));
    messenger.showSnackBar(SnackBar(content: Text(s.audioDownloadStarted)));
  }
}
