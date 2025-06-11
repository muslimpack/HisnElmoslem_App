// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/models/email.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';

class EmailManager {
  static void messageUS() {
    sendEmail(
      email: Email(subject: SX.current.chat, body: ''),
    );
  }

  static void sendMisspelledInZikr({
    required String title,
    required String zikrId,
    required String zikrBody,
  }) {
    sendEmail(
      email: Email(
        subject: SX.current.misspelled,
        body:
            '''
${SX.current.spellingErrorIn}
${SX.current.title}: $title
${SX.current.zikrIndex}: $zikrId
${SX.current.text}: $zikrBody
${SX.current.shouldBe}:

''',
      ),
    );
  }

  static void sendMisspelledInFakeHadith({required DbFakeHaith fakeHaith}) {
    sendEmail(
      email: Email(
        subject: SX.current.misspelled,
        body:
            '''
${SX.current.spellingErrorIn}

${SX.current.subject}: ${SX.current.fakeHadith}

${SX.current.cardIndex}: ${(fakeHaith.id) + 1}

${SX.current.text}: ${fakeHaith.text}

${SX.current.shouldBe}:

''',
      ),
    );
  }

  static Future<void> sendEmail({required Email email}) async {
    final emailToSend = email.copyWith(
      subject: "${SX.current.appTitle} | ${email.subject} | v$kAppVersion",
    );

    final uri = emailToSend.getURI;

    openURL(uri);
  }
}
