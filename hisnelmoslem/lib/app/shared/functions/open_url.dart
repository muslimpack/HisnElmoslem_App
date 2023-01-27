import 'package:url_launcher/url_launcher.dart';

Future<void> openURL(String url) async {
  final customURL = url;
  final parsed = Uri.parse(customURL);
  try {
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed);
    }
  } catch (_) {}
}
