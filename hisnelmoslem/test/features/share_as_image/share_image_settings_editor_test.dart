import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_action_bar.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_settings_editor.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// Starts in the loaded state, without the title lookup `start` needs.
class _LoadedShareCubit extends ShareImageCubit {
  _LoadedShareCubit(super.repo) {
    emit(
      ShareImageLoadedState(
        content: const DbContent(
          id: 1,
          content: "سبحان الله",
          titleId: 1,
          order: 1,
          count: 1,
          fadl: "",
          source: "",
          search: "",
          hokm: "",
          audio: "",
          hasAudio: false,
        ),
        shareImageSettings: repo.shareImageSettings,
        showLoadingIndicator: false,
        title: const DbTitle(id: 1, name: "t", freq: "", order: 1),
        splittedMatn: const [TextRange(start: 0, end: 10)],
        settings: const ShareableImageCardSettings.defaultSettings(),
        activeIndex: 0,
      ),
    );
  }

  ShareAsImageRepo get repo => shareAsImageRepo;
  ShareImageLoadedState get loaded => state as ShareImageLoadedState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _LoadedShareCubit cubit;

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('share_settings_test').path,
    );
    await GetStorage.init('share_settings_test');
  });

  setUp(() async {
    await GetStorage('share_settings_test').erase();
    cubit = _LoadedShareCubit(ShareAsImageRepo(GetStorage('share_settings_test')));
  });

  tearDown(() => cubit.close());

  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: BlocProvider<ShareImageCubit>.value(
          value: cubit,
          child: Scaffold(
            bottomNavigationBar: const ShareImageActionBar(),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ShareImageSettingsEditor.show(context),
                child: const Text("open"),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
  }

  testWidgets("the palette colors the chosen target", (tester) async {
    await openSheet(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, "Background color"));
    await tester.pump();
    // Second swatch of the palette.
    await tester.tap(find.byType(ColorDot).at(3 + 1)); // 3 chip avatars come first
    await tester.pump();

    expect(cubit.loaded.shareImageSettings.backgroundColor, kShareImageColorsList[1]);
    expect(cubit.loaded.shareImageSettings.titleTextColor, isNot(kShareImageColorsList[1]));
  });

  testWidgets("content switches change what the image shows", (tester) async {
    await openSheet(tester);
    final before = cubit.loaded.shareImageSettings;

    await tester.tap(find.widgetWithText(SwitchListTile, "Show fadl"));
    await tester.pump();
    await tester.tap(find.widgetWithText(SwitchListTile, "Show Diacritics"));
    await tester.pump();

    expect(cubit.loaded.shareImageSettings.showFadl, !before.showFadl);
    expect(cubit.loaded.shareImageSettings.removeDiacritics, !before.removeDiacritics);
  });

  testWidgets("reset brings the default colors back", (tester) async {
    await openSheet(tester);
    await cubit.updateBackgroundColor(Colors.amber);
    await tester.pump();

    await tester.tap(find.text("Reset"));
    await tester.pump();

    expect(cubit.loaded.shareImageSettings.backgroundColor, isNot(Colors.amber));
  });

  testWidgets("the action bar offers share, customize and save", (tester) async {
    await openSheet(tester);
    // Dismiss the sheet.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, "Share"), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, "Customize"), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, "Save"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
