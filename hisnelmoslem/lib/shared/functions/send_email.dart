import 'package:hisnelmoslem/shared/functions/print.dart';
import 'package:url_launcher/url_launcher_string.dart';

sendEmail(
    {required String toMailId,
    required String subject,
    required String body}) async {
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
