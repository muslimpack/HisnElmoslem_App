import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_color_preset.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_color_presets_section.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_action_bar.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_settings_editor.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/select_color_dialog.dart';
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

  testWidgets("a color row opens the picker and applies the chosen hex color", (tester) async {
    await openSheet(tester);

    await tester.tap(find.widgetWithText(ListTile, "Background color"));
    await tester.pumpAndSettle();
    expect(find.byType(SelectColorDialog), findsOneWidget);
    expect(find.text("Current"), findsOneWidget);
    expect(find.text("New"), findsOneWidget);

    await tester.enterText(find.byType(TextField), "FF8800");
    await tester.pump();
    await tester.tap(find.text("Select color"));
    await tester.pumpAndSettle();

    expect(cubit.loaded.shareImageSettings.backgroundColor.toARGB32(), 0xFFFF8800);
    expect(find.byType(SelectColorDialog), findsNothing);
    // Only that color changed.
    expect(cubit.loaded.shareImageSettings.titleTextColor.toARGB32(), isNot(0xFFFF8800));
  });

  testWidgets("cancelling the picker keeps the color", (tester) async {
    await openSheet(tester);
    final before = cubit.loaded.shareImageSettings.titleTextColor;

    await tester.tap(find.widgetWithText(ListTile, "Title color"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), "123456");
    await tester.pump();
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(cubit.loaded.shareImageSettings.titleTextColor, before);
  });

  testWidgets("the rows show each color's hex code", (tester) async {
    await openSheet(tester);
    final settings = cubit.loaded.shareImageSettings;

    expect(find.text(settings.titleTextColor.hexCode), findsOneWidget);
    expect(find.text(settings.backgroundColor.hexCode), findsOneWidget);
  });

  test("hex codes are shown as upper case #RRGGBB", () {
    expect(const Color(0xFF01979F).hexCode, "#01979F");
    expect(const Color(0xFF000000).hexCode, "#000000");
  });

  testWidgets("a ready preset sets the background, title and text colors together", (
    tester,
  ) async {
    await openSheet(tester);
    final preset = kShareColorPresets.firstWhere((p) => p.id == SharePresetId.midnightGold);

    await tester.tap(find.text("Midnight gold"));
    await tester.pump();

    final settings = cubit.loaded.shareImageSettings;
    expect(settings.backgroundColor, preset.background);
    expect(settings.titleTextColor, preset.title);
    expect(settings.additionalTextColor, preset.text);
    // The tile now shows as selected.
    expect(
      find.descendant(
        of: find.ancestor(of: find.text("Midnight gold"), matching: find.byType(SharePresetTile)),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
  });

  test("the zikr source is hidden by default, and a saved choice is kept", () async {
    expect(cubit.repo.shareImageSettings.showSource, isFalse);

    await cubit.updateShowSource(value: true);
    final reopened = ShareAsImageRepo(GetStorage('share_settings_test'));
    expect(reopened.shareImageSettings.showSource, isTrue);
  });

  for (final id in [SharePresetId.charcoalCoral, SharePresetId.skyMorning]) {
    testWidgets("the selected preset ${id.name} is scrolled into view when the sheet opens", (
      tester,
    ) async {
      // These are far along their rows, off screen without scrolling.
      await cubit.applyColorPreset(kShareColorPresets.firstWhere((p) => p.id == id));
      await openSheet(tester);

      final check = find.byIcon(Icons.check_rounded);
      expect(check, findsOneWidget);
      final rect = tester.getRect(check);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(360));
    });
  }

  testWidgets("choosing a preset keeps it in view and reset goes back to the first", (
    tester,
  ) async {
    await openSheet(tester);

    await cubit.applyColorPreset(
      kShareColorPresets.firstWhere((p) => p.id == SharePresetId.skyMorning),
    );
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byIcon(Icons.check_rounded));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(360));

    cubit.resetColors();
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byIcon(Icons.check_rounded));
    expect(first.left, greaterThanOrEqualTo(0));
    expect(first.right, lessThanOrEqualTo(360));
  });

  testWidgets("the image quality can be chosen and shows the width it gives", (tester) async {
    await openSheet(tester);

    final quality = find.widgetWithText(SegmentedButton<ShareExportQuality>, "High");
    await tester.ensureVisible(quality);
    await tester.pump();
    // High is the default: 1.5 x 1080.
    expect(cubit.loaded.shareImageSettings.exportQuality, ShareExportQuality.high);
    expect(find.text("1620 px wide"), findsOneWidget);

    await tester.tap(find.text("Maximum"));
    await tester.pump();
    expect(cubit.loaded.shareImageSettings.exportQuality, ShareExportQuality.max);
    expect(find.text("2160 px wide"), findsOneWidget);

    await tester.tap(find.text("Standard"));
    await tester.pump();
    expect(cubit.loaded.shareImageSettings.exportQuality, ShareExportQuality.standard);
    expect(find.text("1080 px wide"), findsOneWidget);
  });

  testWidgets("light and dark presets are both offered", (tester) async {
    await openSheet(tester);

    expect(find.text("Dark"), findsOneWidget);
    expect(find.text("Light"), findsOneWidget);
    expect(find.text("Parchment"), findsOneWidget);
    expect(find.text("Emerald night"), findsOneWidget);
  });

  testWidgets("content switches change what the image shows", (tester) async {
    await openSheet(tester);
    final before = cubit.loaded.shareImageSettings;

    // The sheet is taller than the screen now; scroll the switches into view.
    final fadl = find.widgetWithText(SwitchListTile, "Show fadl");
    await tester.ensureVisible(fadl);
    await tester.pump();
    await tester.tap(fadl);
    await tester.pump();
    final diacritics = find.widgetWithText(SwitchListTile, "Show Diacritics");
    await tester.ensureVisible(diacritics);
    await tester.pump();
    await tester.tap(diacritics);
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
