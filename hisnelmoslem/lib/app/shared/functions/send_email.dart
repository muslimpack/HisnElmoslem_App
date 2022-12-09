import 'package:hisnelmoslem/app/shared/functions/print.dart';
import 'package:url_launcher/url_launcher.dart';

sendEmail({
  required String toMailId,
  required String subject,
  required String body,
}) async {
  var url = 'mailto:$toMailId?subject=$subject&body=$body';
  try {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    hisnPrint(e.toString());
  }
}
