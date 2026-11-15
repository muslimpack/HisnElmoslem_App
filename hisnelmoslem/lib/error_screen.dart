import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/app.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/components/feedback_sheet.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const ErrorScreen({super.key, required this.details});

  /// The error is already in the local error log (see `_setUpErrorCapture`), so the bug report
  /// sheet attaches it when the user agrees to share device data.
  void _report(BuildContext context) {
    final target = App.navigatorKey.currentContext ?? context;
    FeedbackSheet.show(target);
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
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _report(context),
                      icon: const Icon(Icons.bug_report_outlined),
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
