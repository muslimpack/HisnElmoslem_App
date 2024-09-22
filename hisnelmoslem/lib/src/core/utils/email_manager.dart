// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/models/email.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';

class EmailManager {
  static void messageUS() {
    sendEmail(
      email: Email(
        subject: S.current.chat,
        body: '',
      ),
    );
  }

  static void sendMisspelledInZikr({
    required String title,
    required String zikrId,
    required String zikrBody,
  }) {
    sendEmail(
      email: Email(
        subject: S.current.misspelled,
        body: '''
${S.current.spellingErrorIn}
${S.current.title}: $title
${S.current.zikrIndex}: $zikrId
${S.current.text}: $zikrBody
${S.current.shouldBe}:

''',
      ),
    );
  }

  static void sendMisspelledInFakeHadith({
    required DbFakeHaith fakeHaith,
  }) {
    sendEmail(
      email: Email(
        subject: S.current.misspelled,
        body: '''
${S.current.spellingErrorIn}

${S.current.subject}: ${S.current.fakeHadith}

${S.current.cardIndex}: ${(fakeHaith.id) + 1}

${S.current.text}: ${fakeHaith.text}

${S.current.shouldBe}:

''',
      ),
    );
  }

  static Future<void> sendEmail({
    required Email email,
  }) async {
    final emailToSend = email.copyWith(
      subject: "${S.current.appTitle} | ${email.subject} | v$kAppVersion",
    );

    final uri = emailToSend.getURI;

    openURL(uri);
  }
}
