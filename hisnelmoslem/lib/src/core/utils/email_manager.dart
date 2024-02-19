import 'package:get/get.dart';
import "package:hisnelmoslem/app/data/models/models.dart";
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
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

${"notes".tr}

${"I like about this app:".tr}

${"I don't like about this app:".tr}

${"Features I hope to be added:".tr}

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
      subject: "Hisn ELmoslem App | Misspelled".tr,
      body: '''
${"There is a spelling error in".tr}
${"Title".tr}: $subject
${"Zikr Index".tr}: $cardNumber
${"Text".tr}: $text
${"It should be:".tr}:

''',
    );
  }

  static void sendMisspelledInFakeHadith({
    required DbFakeHaith fakeHaith,
  }) {
    sendEmail(
      toMailId: emailOwner,
      subject: "Hisn ELmoslem App | Misspelled".tr,
      body: '''
${"There is a spelling error in".tr}

${"Subject".tr}: ${"fake hadith".tr}

${"Card index".tr}: ${(fakeHaith.id) + 1}

${"Text".tr}: ${fakeHaith.text}

${"It should be:".tr}:

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
