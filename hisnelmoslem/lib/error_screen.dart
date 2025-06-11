import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const ErrorScreen({super.key, required this.details});

  Future<void> _sendEmail(BuildContext context, String errorMessage) async {
    const String subject = 'حصن المسلم | خلل في الأداء | $kAppVersion';
    final String body = 'حدث الخطأ التالي:\n\n$errorMessage\n\n';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: kOrgEmail,
      query: Uri.encodeFull('subject=$subject&body=$body'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorEmailAppOpen),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).copiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = details.exceptionAsString();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 80),
              Text(
                S.of(context).errorOccurred,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context, errorMessage),
                    icon: const Icon(Icons.copy),
                    label: Text(S.of(context).copy),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _sendEmail(context, errorMessage),
                    icon: const Icon(Icons.email),
                    label: Text(S.of(context).sendEmail),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
