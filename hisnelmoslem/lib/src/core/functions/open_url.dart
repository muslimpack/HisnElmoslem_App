import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openURL(String url) async {
  final parsed = Uri.parse(url);

  try {
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  } catch (e, st) {
    hisnLogError(e, st, source: 'open_url');
  }
}
