import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations_en.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_type.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_email_composer.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_sender.dart';

void main() {
  final composer = FeedbackEmailComposer(
    strings: SEn(),
    recipient: 'dev@example.com',
    appVersion: '3.2.01 (31)',
  );

  FeedbackDraft draft({
    FeedbackType type = FeedbackType.bug,
    String message = ' It crashes ',
    bool share = true,
    MisspellingContext? misspelling,
  }) => FeedbackDraft(
    type: type,
    message: message,
    includeDeviceInfo: share,
    misspelling: misspelling,
  );

  test('subject uses a fixed English tag and the version', () {
    expect(
      composer.subject(draft(type: FeedbackType.featureRequest)),
      'Hisn Elmoslem | Feature | v3.2.01 (31)',
    );
  });

  test('message is trimmed and device info is added only with consent', () {
    const info = {'Device': 'Pixel 8', 'Platform': 'Android 15'};
    final shared = composer.compose(draft(), deviceInfo: info, attachmentPath: '/tmp/r.txt');
    expect(shared.body, startsWith('It crashes'));
    expect(shared.body, contains('Device: Pixel 8'));
    expect(shared.body, contains('attached as a file'));
    expect(shared.attachmentPath, '/tmp/r.txt');

    final private = composer.compose(
      draft(share: false),
      deviceInfo: info,
      attachmentPath: '/tmp/r.txt',
    );
    expect(private.body, 'It crashes');
    expect(private.attachmentPath, isNull);
  });

  test('misspelling body has the location, the current text and the correction', () {
    final email = composer.compose(
      draft(
        type: FeedbackType.misspelling,
        message: 'الصحيح',
        share: false,
        misspelling: const MisspellingContext(title: 'Morning', index: 3, currentText: 'خطأ'),
      ),
    );
    expect(email.body, contains('Morning'));
    expect(email.body, contains('3'));
    expect(email.body, contains('خطأ'));
    expect(email.body, endsWith('الصحيح'));
  });

  test('mailto keeps Arabic, newlines and reserved characters intact', () {
    const body = 'مرحبا & #1 ? a+b\nline2';
    final url = MailAppFeedbackSender.mailtoUrl(
      const FeedbackEmail(recipient: 'dev@example.com', subject: 'S | v1', body: body),
    );
    final uri = Uri.parse(url);
    expect(uri.queryParameters['body'], body);
    expect(uri.queryParameters['subject'], 'S | v1');
    expect(url, isNot(contains('+')));
  });
}
