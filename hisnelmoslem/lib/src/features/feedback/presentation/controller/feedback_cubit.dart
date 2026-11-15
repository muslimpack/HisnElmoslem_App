import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/device_info_collector.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/error_log_store.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_email_composer.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_sender.dart';

/// What would be shared if the user ticks the device-data box.
class FeedbackPreview extends Equatable {
  final Map<String, String> deviceInfo;

  /// Text of the error file (empty when no error was recorded).
  final String errorsText;

  const FeedbackPreview({required this.deviceInfo, required this.errorsText});

  @override
  List<Object> get props => [deviceInfo, errorsText];
}

enum FeedbackSendResult {
  /// The mail app was opened.
  opened,

  /// No mail app: the caller copies [FeedbackCubit.lastBody] and tells the user.
  noMailApp,
}

class FeedbackState extends Equatable {
  final bool isSending;
  const FeedbackState({this.isSending = false});

  @override
  List<Object> get props => [isSending];
}

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({
    required DeviceInfoCollector collector,
    required ErrorLogStore errorLog,
    required FeedbackSender sender,
    required Future<Directory> Function() tempDir,
    required FeedbackEmailComposer Function(S strings) composerFor,
  }) : _collector = collector,
       _errorLog = errorLog,
       _sender = sender,
       _tempDir = tempDir,
       _composerFor = composerFor,
       super(const FeedbackState());

  final DeviceInfoCollector _collector;
  final ErrorLogStore _errorLog;
  final FeedbackSender _sender;
  final Future<Directory> Function() _tempDir;
  final FeedbackEmailComposer Function(S strings) _composerFor;

  /// Body of the last email, so the UI can copy it when no mail app exists.
  String lastBody = '';

  Future<FeedbackPreview> preview() async {
    final info = await _collector.collect();
    await _errorLog.flush();
    final errors = await _errorLog.reportText(header: 'Recent errors');
    return FeedbackPreview(deviceInfo: info, errorsText: errors);
  }

  Future<FeedbackSendResult> submit(FeedbackDraft draft, S strings) async {
    emit(const FeedbackState(isSending: true));
    try {
      var info = const <String, String>{};
      String? attachment;
      String? inlineErrors;
      if (draft.includeDeviceInfo) {
        info = await _collector.collect();
        final header =
            'Hisn Elmoslem ${info['App version'] ?? ''} | ${DateTime.now().toIso8601String()}';
        final attachable = !_noAttachments;
        if (attachable) {
          attachment = await _errorLog.writeReportFile(header: header, tempDir: await _tempDir());
        } else {
          final text = await _errorLog.reportText(header: header, count: 2);
          // A mailto link has a practical size limit.
          inlineErrors = text.length > 1500 ? '${text.substring(0, 1500)}…' : text;
        }
      }
      final composer = _composerFor(strings);
      final email = composer.compose(
        draft,
        deviceInfo: info,
        attachmentPath: attachment,
        inlineErrors: inlineErrors,
      );
      lastBody = email.body;
      final ok = await _sender.send(email);
      return ok ? FeedbackSendResult.opened : FeedbackSendResult.noMailApp;
    } catch (e, st) {
      hisnLogError(e, st, source: 'feedback_submit');
      return FeedbackSendResult.noMailApp;
    } finally {
      if (!isClosed) emit(const FeedbackState());
    }
  }

  bool get _noAttachments => PlatformExtension.isDesktopOrWeb;
}
