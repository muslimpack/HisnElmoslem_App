import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailManager {
  static const String emailOwner = kOrgEmail;

  static void sendFeedbackEmail() {
    sendEmail(
      toMailId: emailOwner,
      subject: "Hisn ELmoslem App | Rate the app",
      body: '''
$appVersion

${S.current.notes}

${S.current.likeAboutApp}

${S.current.dislikeAboutApp}

${S.current.featuresToBeAdded}

''',
    );
  }

  static void messageUS() {
    sendEmail(
      toMailId: emailOwner,
      subject: "Hisn ELmoslem App | Chat",
      body: '',
    );
  }

  static void sendMisspelledInZikrWithDbModel({
    required DbTitle dbTitle,
    required DbContent dbContent,
  }) {
    sendMisspelledInZikr(
      subject: dbTitle.name,
      cardNumber: dbContent.orderId.toString(),
      text: dbContent.content,
    );
  }

  static void sendMisspelledInZikrWithText({
    required String subject,
    required String cardNumber,
    required String text,
  }) {
    sendMisspelledInZikr(
      cardNumber: cardNumber,
      subject: subject,
      text: text,
    );
  }

  static void sendMisspelledInZikr({
    required String subject,
    required String cardNumber,
    required String text,
  }) {
    sendEmail(
      toMailId: emailOwner,
      subject: S.current.misspelled,
      body: '''
${S.current.spellingErrorIn}
${S.current.title}: $subject
${S.current.zikrIndex}: $cardNumber
${S.current.text}: $text
${S.current.shouldBe}:

''',
    );
  }

  static void sendMisspelledInFakeHadith({
    required DbFakeHaith fakeHaith,
  }) {
    sendEmail(
      toMailId: emailOwner,
      subject: S.current.misspelled,
      body: '''
${S.current.spellingErrorIn}

${S.current.subject}: ${S.current.fakeHadith}

${S.current.cardIndex}: ${(fakeHaith.id) + 1}

${S.current.text}: ${fakeHaith.text}

${S.current.shouldBe}:

''',
    );
  }

  static Future<void> sendEmail({
    required String toMailId,
    required String subject,
    required String body,
  }) async {
    final mailTitle = "$subject | v$appVersion";
    final url = 'mailto:$toMailId?subject=$mailTitle&body=$body';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      hisnPrint(e.toString() + " | " * 88);
    }
  }
}
