import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/data/models/local_notification_manager.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/original_zikr_source.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/repositories/custom_azkar_repo_impl.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_alarm_scheduler.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_title_editor/custom_title_editor_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_zikr_picker/custom_zikr_picker_cubit.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/screens/custom_title_editor_screen.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _NoOriginals implements OriginalZikrSource {
  @override
  Future<List<DbContent>> getContentsByIds(List<int> ids) async => [];

  @override
  Future<List<DbContent>> getContentsByTitleId(int titleId) async => [];

  @override
  Future<List<DbContent>> search(String text, SearchType type, {required int limit}) async => [];
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late CustomAzkarDBHelper helper;
  late CustomAzkarRepoImpl repo;
  late LocalCustomAudioStorage storage;
  final sl = GetIt.instance;

  setUp(() {
    helper = CustomAzkarDBHelper(pathOverride: inMemoryDatabasePath);
    storage = LocalCustomAudioStorage(directoryOverride: Directory.systemTemp.createTempSync('ed'));
    repo = CustomAzkarRepoImpl(helper, _NoOriginals());
    sl
      ..registerFactory(() => CustomTitleEditorBloc(repo, storage))
      ..registerFactory(() => CustomZikrPickerCubit(repo, _NoOriginals()));
  });

  tearDown(() async {
    await sl.reset();
  });

  /// Real async work (sqflite) needs the real event loop, not the fake test clock.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump();
  }

  testWidgets("create a title from scratch, reorder-ready item, change count and save", (
    tester,
  ) async {
    const draft = CustomZikr(content: "سبحان الله", defaultCount: 3);
    final zikrId = (await tester.runAsync(() => repo.saveZikr(draft)))!;
    final zikr = draft.copyWith(id: zikrId);

    final titlesBloc = CustomTitlesBloc(
      repo,
      CustomAlarmScheduler(LocalNotificationManager(), repo),
    );
    addTearDown(titlesBloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: titlesBloc,
        child: MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CustomTitleEditorScreen()),
                ),
                child: const Text("open"),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text("open"));
    await tester.pump();
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));

    // Empty draft shows the hint and the add button.
    expect(find.text("Add at least one zikr to this title"), findsOneWidget);
    expect(find.text("Add zikr"), findsOneWidget);

    // Name the title and add the zikr to the draft (the add-sheet is tested via its bloc event).
    await tester.enterText(find.byType(TextField).first, "Morning");
    final editor = tester.element(find.byType(CustomTitleEditorView)).read<CustomTitleEditorBloc>();
    editor.add(CustomTitleEditorCustomZikrsAddedEvent([zikr]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("سبحان الله"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);

    await tester.tap(find.byTooltip("Increase"));
    await tester.pump();
    expect(find.text("4"), findsOneWidget);

    await tester.tap(find.text("Save"));
    await tester.pump();
    await settle(tester);
    await tester.pumpAndSettle();

    // Editor closed and the data is stored.
    expect(find.byType(CustomTitleEditorView), findsNothing);
    final titles = (await tester.runAsync(repo.getTitles))!;
    expect(titles.single.name, "Morning");
    final items = (await tester.runAsync(() => repo.getResolvedItems(titles.single.id)))!;
    expect(items.single.item.count, 4);
    await settle(tester); // let the list refresh finish before the db is closed
    await tester.runAsync(helper.close);
  });

  testWidgets("saving without a name shows the validation message", (tester) async {
    final titlesBloc = CustomTitlesBloc(
      repo,
      CustomAlarmScheduler(LocalNotificationManager(), repo),
    );
    addTearDown(titlesBloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: titlesBloc,
        child: const MaterialApp(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: CustomTitleEditorScreen(),
        ),
      ),
    );
    await tester.pump();
    await settle(tester);

    await tester.tap(find.text("Save"));
    await tester.pump();
    await settle(tester);

    expect(find.text("Please enter a title name"), findsOneWidget);
    await settle(tester); // let the list refresh finish before the db is closed
    await tester.runAsync(helper.close);
  });
}
