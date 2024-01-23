import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/utils/open_url.dart';
import 'package:hisnelmoslem/src/core/utils/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/dashboard/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/dashboard/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailManager {
  static const String emailOwner = "muslimpack.org@gmail.com";

  static Future<void> sendFeedbackForm() async {
    // Feedback form
    await openURL(
      'https://docs.google.com/forms/d/e/1FAIpQLSclKHlDGE-rwhllyHavhvx9EhFdwqL1kSCZWPPlpGPCn7o4fQ/viewform?usp=sf_link',
    );
  }

  static void sendFeedbackEmail() {
    sendEmail(
      toMailId: emailOwner,
      subject: "Hisn ELmoslem App | Rate the app",
      body: '''
$appVersion

${S.current.notes}

${S.current.i_like_about_this_app}

${S.current.i_do_not_like_about_this_app}

${S.current.features_i_hope_to_be_added}

''',
    );
  }

  static void messageUS() {
    sendEmail(
      toMailId: emailOwner,
      subject: "Hisn ELmoslem App | Chat",
      body: """
$appVersion


""",
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
      subject: S.current.hisn_elmoslem_app_misspelled,
      body: '''
$appVersion

${S.current.there_is_spelling_error_in}
${S.current.title}: $subject
${S.current.zikr_index}: $cardNumber
${S.current.text}: $text
${S.current.it_should_be}:

''',
    );
  }

  static void sendMisspelledInFakeHadith({
    required DbFakeHaith fakeHaith,
  }) {
    sendEmail(
      toMailId: emailOwner,
      subject: S.current.hisn_elmoslem_app_misspelled,
      body: '''
$appVersion

${S.current.there_is_spelling_error_in}

${S.current.subject}: ${S.current.fake_hadith}

${S.current.card_index}: ${(fakeHaith.id) + 1}

${S.current.text}: ${fakeHaith.text}

${S.current.it_should_be}:

''',
    );
  }

  static Future<void> sendEmail({
    required String toMailId,
    required String subject,
    required String body,
  }) async {
    final url = 'mailto:$toMailId?subject=$subject&body=$body';
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
