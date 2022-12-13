import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/models/fake_haith.dart';
import 'package:hisnelmoslem/app/data/models/zikr_content.dart';
import 'package:hisnelmoslem/app/data/models/zikr_title.dart';
import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmailManager {
  static const String emailOwner = "muslimpack.org@gmail.com";

  static void sendFeedback() {
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

  static void sendEmail({
    required String toMailId,
    required String subject,
    required String body,
  }) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      hisnPrint(e.toString());
    }
  }
}
