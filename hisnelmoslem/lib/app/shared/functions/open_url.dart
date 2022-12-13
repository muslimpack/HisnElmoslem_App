import 'package:url_launcher/url_launcher.dart';

openURL(String url) async {
  final customURL = url;
  final parsed = Uri.parse(customURL);
  if (await canLaunchUrl(parsed)) {
    await launchUrl(parsed);
  } else {
    throw 'Could not launch $url';
  }
}
