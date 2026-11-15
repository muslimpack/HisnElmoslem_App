import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_draft.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_type.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/device_info_collector.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/error_log_store.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_email_composer.dart';
import 'package:hisnelmoslem/src/features/feedback/data/services/feedback_sender.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/components/feedback_sheet.dart';
import 'package:hisnelmoslem/src/features/feedback/presentation/controller/feedback_cubit.dart';

class _FakeCollector implements DeviceInfoCollector {
  @override
  Future<Map<String, String>> collect() async => {'Device': 'Test Phone'};
}

class _FakeSender implements FeedbackSender {
  final sent = <FeedbackEmail>[];

  @override
  Future<bool> send(FeedbackEmail email) async {
    sent.add(email);
    return true;
  }
}

void main() {
  late _FakeSender sender;
  late Directory dir;

  setUp(() {
    sender = _FakeSender();
    dir = Directory.systemTemp.createTempSync('feedback_sheet_test');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> pump(WidgetTester tester, {MisspellingContext? misspelling}) async {
    final cubit = FeedbackCubit(
      collector: _FakeCollector(),
      errorLog: ErrorLogStore(() async => dir),
      sender: sender,
      tempDir: () async => dir,
      composerFor: (s) =>
          FeedbackEmailComposer(strings: s, recipient: 'dev@example.com', appVersion: '1 (1)'),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: FeedbackSheet(
              initialType: misspelling != null ? FeedbackType.misspelling : FeedbackType.bug,
              misspelling: misspelling,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty message is refused and nothing is sent', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Please write a message first'), findsOneWidget);
    expect(sender.sent, isEmpty);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(sender.sent, isEmpty);
  });

  testWidgets('shows the type dropdown for contact but not for a misspelling', (tester) async {
    await pump(tester);
    expect(find.byType(DropdownButtonFormField<FeedbackType>), findsOneWidget);

    await pump(
      tester,
      misspelling: const MisspellingContext(title: 'T', index: 1, currentText: 'text'),
    );
    expect(find.byType(DropdownButtonFormField<FeedbackType>), findsNothing);
    expect(find.text('text'), findsOneWidget);
  });

  testWidgets('"What will be shared?" lists the collected device data', (tester) async {
    await pump(tester);
    await tester.tap(find.text('What will be shared?'));
    // The preview reads the error log from disk: alternate real delays and pumps.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Data that will be shared'), findsOneWidget);
    expect(find.textContaining('Test Phone', findRichText: true), findsOneWidget);
  });

  testWidgets('sends the message, leaving device info out when the box is unticked', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), 'Hello there');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(sender.sent, hasLength(1));
    expect(sender.sent.single.body, 'Hello there');
    expect(sender.sent.single.subject, 'Hisn Elmoslem | Bug | v1 (1)');
  });
}
