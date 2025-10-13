import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_datetime.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:path_provider/path_provider.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const ErrorScreen({super.key, required this.details});

  Future<void> emailTheError(BuildContext context, FlutterErrorDetails error) async {
    // get receiver
    const String emailReceiver = kOrgEmail;
    try {
      final String fullErrorDetails = generateErrorReport(error);

      final String errorReportFilePath = await writeToTextFile(fullErrorDetails);
      final Email email = Email(
        body: 'حدث خطأ غير متوقع أثناء استخدام التطبيق.',
        subject: 'حصن المسلم | خلل في الأداء | ${appVersion()}',
        recipients: [emailReceiver],
        attachmentPaths: [errorReportFilePath],
      );
      await FlutterEmailSender.send(email);
    } catch (e) {
      hisnPrint(e.toString());
      openURL('mailto:$emailReceiver');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorEmailAppOpen),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String generateErrorReport(FlutterErrorDetails error) {
    final lineBreaker = '\n${'-' * 40}\n';
    final StringBuffer buffer = StringBuffer();

    ///
    buffer.writeln(DateTime.now().humanize);
    buffer.writeln(lineBreaker);

    ///
    buffer.writeln('App Version: ${appVersion()}');
    buffer.writeln('Operating System: ${Platform.operatingSystem}');
    buffer.writeln(lineBreaker);

    ///
    buffer.writeln('The exception was:\n');
    buffer.writeln(error.exception);
    buffer.writeln(lineBreaker);

    ///
    buffer.writeln('Stack Trace:\n');
    buffer.writeln(error.stack);

    return buffer.toString();
  }

  Future<String> writeToTextFile(String text) async {
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/ErrorReport.txt');
    await file.writeAsString(text);
    return file.path;
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Text(errorMessage, style: const TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => emailTheError(context, details),
                      icon: const Icon(Icons.email),
                      label: Text(S.of(context).sendEmail),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(context, errorMessage),
                    icon: const Icon(Icons.copy),
                    label: Text(S.of(context).copy),
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
