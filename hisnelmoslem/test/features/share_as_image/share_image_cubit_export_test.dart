import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

/// A cubit that starts loaded, with [pages] pages and the keys of their pictures.
class _ExportCubit extends ShareImageCubit {
  _ExportCubit(super.repo, {required int pages}) {
    imageKeys = List.generate(pages, (_) => GlobalKey());
    emit(
      ShareImageLoadedState(
        content: const DbContent(
          id: 7,
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
        shareImageSettings: shareAsImageRepo.shareImageSettings,
        showLoadingIndicator: false,
        title: const DbTitle(id: 1, name: "t", freq: "", order: 1),
        splittedMatn: [for (var i = 0; i < pages; i++) TextRange(start: i, end: i + 1)],
        settings: const ShareableImageCardSettings.defaultSettings(),
        activeIndex: 0,
      ),
    );
  }

  ShareImageLoadedState get loaded => state as ShareImageLoadedState;
}

/// Width and height from the PNG header.
({int width, int height}) pngSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  expect(bytes.sublist(1, 4), [0x50, 0x4E, 0x47], reason: "PNG signature");
  return (width: data.getUint32(16), height: data.getUint32(20));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ExportCubit cubit;

  setUpAll(() async {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.createTempSync('share_export_test').path,
    );
    // Toasts are shown through a plugin; accept them.
    messenger.setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (call) async => true,
    );
    await GetStorage.init('share_export_test');
    // Strings outside widgets (toasts) come from here, as in the app.
    SX.init(await S.delegate.load(const Locale('en')));
  });

  setUp(() async {
    await GetStorage('share_export_test').erase();
  });

  tearDown(() => cubit.close());

  /// A screen of [pages] pictures of the given size, driven like the real one.
  Future<void> pumpPages(
    WidgetTester tester, {
    required int pages,
    Size size = const Size(100, 200),
  }) async {
    cubit = _ExportCubit(ShareAsImageRepo(GetStorage('share_export_test')), pages: pages);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageView.builder(
            controller: cubit.pageController,
            itemCount: pages,
            itemBuilder: (context, index) => Center(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: cubit.imageKeys[index],
                  child: ColoredBox(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: SizedBox(width: size.width, height: size.height),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Runs [action] while frames are pumped and real async work (encoding) can finish.
  Future<T> drive<T>(WidgetTester tester, Future<T> Function() action) async {
    T? result;
    Object? error;
    var done = false;
    action().then(
      (value) {
        result = value;
        done = true;
      },
      onError: (Object e) {
        error = e;
        done = true;
      },
    );

    for (var i = 0; i < 400 && !done; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(done, isTrue, reason: "the export did not finish");
    if (error != null) throw error!;
    return result as T;
  }

  testWidgets("every page of a split zikr is exported, in order, with its own name", (
    tester,
  ) async {
    await pumpPages(tester, pages: 3);

    final files = await drive(tester, cubit.captureImages);

    expect(files.length, 3);
    expect(files[0].name, contains("Hisn-7_1_of_3-"));
    expect(files[2].name, contains("Hisn-7_3_of_3-"));
    for (final file in files) {
      expect(file.name, endsWith(".png"));
      expect(pngSize(file.bytes), isNotNull);
    }
    // The three pictures have different colors, so they are really different pages.
    expect(files[0].bytes, isNot(files[1].bytes));
  });

  testWidgets("the picture is as wide as the quality says", (tester) async {
    await pumpPages(tester, pages: 1, size: const Size(100, 100));

    for (final (quality, width) in [
      (ShareExportQuality.standard, 100),
      (ShareExportQuality.high, 150),
      (ShareExportQuality.max, 200),
    ]) {
      await cubit.updateExportQuality(quality);
      final files = await drive(tester, cubit.captureImages);

      expect(pngSize(files.single.bytes).width, width, reason: quality.name);
    }
  });

  testWidgets("a tall card is made smaller so it stays within the size limit", (tester) async {
    await pumpPages(tester, pages: 1, size: const Size(100, 6000));
    await cubit.updateExportQuality(ShareExportQuality.max);

    final files = await drive(tester, cubit.captureImages);
    final size = pngSize(files.single.bytes);

    expect(size.height, lessThanOrEqualTo(4096));
    expect(size.height, greaterThan(4000));
    // The shape is kept.
    expect(size.height / size.width, closeTo(60, 1));
  });

  testWidgets("the page that was showing is shown again after exporting all pages", (
    tester,
  ) async {
    await pumpPages(tester, pages: 3);
    cubit.pageController.jumpToPage(1);
    await tester.pump();
    cubit.onPageChanged(1);

    await drive(tester, cubit.captureImages);
    await tester.pump();

    expect(cubit.pageController.page?.round(), 1);
  });

  testWidgets("a failed export shows no stuck loading bar and can be retried", (tester) async {
    // The pictures are not on screen, so capturing fails.
    cubit = _ExportCubit(ShareAsImageRepo(GetStorage('share_export_test')), pages: 1);
    // Toasts need the BotToast overlay, as in the app.
    await tester.pumpWidget(MaterialApp(builder: BotToastInit(), home: const SizedBox()));

    await drive(tester, cubit.saveToGallery);

    expect(cubit.loaded.showLoadingIndicator, isFalse);
    // The user is told, not left guessing.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Something went wrong!"), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // let the toast go away

    // Not left in a state that blocks the next attempt.
    await drive(tester, cubit.saveToGallery);
    expect(cubit.loaded.showLoadingIndicator, isFalse);
    await tester.pump(const Duration(seconds: 5)); // the second toast goes away too
  });
}
