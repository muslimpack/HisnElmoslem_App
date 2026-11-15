import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';

/// Builds the subject and body of a feedback email. Pure, so it is easy to test.
class FeedbackEmailComposer {
  const FeedbackEmailComposer({
    required this.strings,
    required this.recipient,
    required this.appVersion,
  });

  final S strings;
  final String recipient;

  /// e.g. `3.2.01 (31)`.
  final String appVersion;

  /// `Hisn Elmoslem | Bug | v3.2.01 (31)`: the tag stays English for inbox filters.
  String subject(FeedbackDraft draft) => 'Hisn Elmoslem | ${draft.type.tag} | v$appVersion';

  /// [deviceInfo] is only used when the draft agreed to share it.
  /// [errorsAttached] says a file with recent errors goes with the email;
  /// [inlineErrors] is used instead when attachments are not possible.
  FeedbackEmail compose(
    FeedbackDraft draft, {
    Map<String, String> deviceInfo = const {},
    String? attachmentPath,
    String? inlineErrors,
  }) {
    final message = draft.message.trim();
    final misspelling = draft.misspelling;
    final b = StringBuffer();
    if (misspelling == null) {
      b.writeln(message);
    } else {
      b.writeln('${strings.feedbackBodyDetails}:');
      if (misspelling.isFakeHadith) {
        b
          ..writeln('${strings.subject}: ${strings.fakeHadith}')
          ..writeln('${strings.cardIndex}: ${misspelling.index}');
      } else {
        b
          ..writeln('${strings.title}: ${misspelling.title}')
          ..writeln('${strings.zikrIndex}: ${misspelling.index}');
      }
      b
        ..writeln('${strings.text}: ${misspelling.currentText}')
        ..writeln()
        ..writeln('${strings.shouldBe}: $message');
    }
    return _finish(draft, b.toString(), deviceInfo, attachmentPath, inlineErrors);
  }

  FeedbackEmail _finish(
    FeedbackDraft draft,
    String body,
    Map<String, String> deviceInfo,
    String? attachmentPath,
    String? inlineErrors,
  ) {
    final b = StringBuffer(body.trimRight())..writeln();
    if (draft.includeDeviceInfo) {
      if (deviceInfo.isNotEmpty) {
        b
          ..writeln()
          ..writeln('--- ${strings.feedbackDeviceInfoSection} ---');
        deviceInfo.forEach((k, v) => b.writeln('$k: $v'));
      }
      if (attachmentPath != null) {
        b
          ..writeln()
          ..writeln(strings.feedbackBodyErrorsAttached);
      } else if (inlineErrors != null && inlineErrors.isNotEmpty) {
        b
          ..writeln()
          ..writeln('--- ${strings.feedbackErrorsInline} ---')
          ..writeln(inlineErrors);
      }
    }
    return FeedbackEmail(
      recipient: recipient,
      subject: subject(draft),
      body: b.toString().trimRight(),
      attachmentPath: draft.includeDeviceInfo ? attachmentPath : null,
    );
  }
}
