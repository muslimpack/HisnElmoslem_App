import 'package:flutter_email_sender/flutter_email_sender.dart' as sender;
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands a composed email to the user's mail app.
abstract class FeedbackSender {
  /// Returns false when no mail app could be opened.
  Future<bool> send(FeedbackEmail email);
}

class MailAppFeedbackSender implements FeedbackSender {
  const MailAppFeedbackSender();

  @override
  Future<bool> send(FeedbackEmail email) async {
    // Attachments are only possible through the native mail intent (mobile).
    if (!PlatformExtension.isDesktopOrWeb) {
      try {
        await sender.FlutterEmailSender.send(
          sender.Email(
            subject: email.subject,
            body: email.body,
            recipients: [email.recipient],
            attachmentPaths: [if (email.attachmentPath != null) email.attachmentPath!],
          ),
        );
        return true;
      } catch (e, st) {
        hisnLogError(e, st, source: 'feedback_send');
      }
    }
    return _sendMailto(email);
  }

  Future<bool> _sendMailto(FeedbackEmail email) async {
    try {
      final uri = Uri.parse(mailtoUrl(email));
      return await launchUrl(uri);
    } catch (e, st) {
      hisnLogError(e, st, source: 'feedback_mailto');
      return false;
    }
  }

  /// `mailto:` with every part percent-encoded (spaces as %20, not `+`; Arabic, newlines,
  /// `&`, `#`, `?` and `+` in the text stay intact).
  static String mailtoUrl(FeedbackEmail email) {
    final subject = Uri.encodeComponent(email.subject);
    final body = Uri.encodeComponent(email.body);
    return 'mailto:${email.recipient}?subject=$subject&body=$body';
  }
}
