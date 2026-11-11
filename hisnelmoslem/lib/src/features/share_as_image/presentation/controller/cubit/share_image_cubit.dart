import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:capture_widget/core/widget_capture_controller.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/extensions/localization_extesion.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/core/functions/show_toast.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/repositories/custom_azkar_repo.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_color_preset.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_export_quality.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_const.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/services/share_image_export.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/custom_title_source.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content_extension.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_kind.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'share_image_state.dart';

class ShareImageCubit extends Cubit<ShareImageState> {
  final ShareAsImageRepo shareAsImageRepo;
  final PageController pageController = PageController();
  late final List<GlobalKey> imageKeys;

  ShareImageCubit(this.shareAsImageRepo) : super(ShareImageLoadingState());

  Future onPageChanged(int index) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    emit(state.copyWith(activeIndex: index));
  }

  ///MARK: Split
  int charPer1080(int standardLength, String text) {
    if (text.length < standardLength) {
      return standardLength;
    }

    final chunkCount = (text.split(" ").length / standardLength).ceil();

    final charLength = text.split(" ").length ~/ chunkCount;
    final overflowChars = text.split(" ").length % chunkCount;
    final result = charLength + overflowChars;

    return result + 2;
  }

  List<TextRange> splitStringIntoChunksRange(String text, int wordsPerChunk) {
    // Handle edge cases
    if (text.isEmpty || wordsPerChunk <= 0) {
      return [];
    }

    final List<String> words = text.split(' ');
    final List<TextRange> chunkIndices = [];

    int chunkStart = 0;
    int wordCount = 0;
    int currentPos = 0;

    for (int i = 0; i < words.length; i++) {
      // Get the word's start and end indices in the text
      final String word = words[i];
      final int wordStart = text.indexOf(word, currentPos);
      final int wordEnd = wordStart + word.length;

      if (wordCount < wordsPerChunk) {
        // Add the word to the current chunk
        wordCount++;
        currentPos = wordEnd;
      }

      // If the chunk reaches the word limit, finalize it
      if (wordCount == wordsPerChunk || i == words.length - 1) {
        chunkIndices.add(TextRange(start: chunkStart, end: wordEnd));

        // Start a new chunk
        chunkStart = wordEnd + 1; // Skip the space
        wordCount = 0;
      }
    }

    return chunkIndices;
  }

  FutureOr start(DbContent content) async {
    final ShareImageSettings shareImageSettings = shareAsImageRepo.shareImageSettings;
    final isContainsQuranText = content.content.contains("QuranText");
    late final DbContent content2Set;
    if (isContainsQuranText) {
      content2Set = content.copyWith(content: await content.getPlainText());
    } else {
      content2Set = content;
    }

    final baseTitle = await _getTitle(content2Set);

    final settings = const ShareableImageCardSettings.defaultSettings().copyWith(
      wordsCountPerSize: 120,
    );

    final String proccessedText = content2Set.content;
    final charsPerChunk = charPer1080(settings.wordsCountPerSize, proccessedText);

    final List<TextRange> splittedMatnRanges = splitStringIntoChunksRange(
      proccessedText,
      charsPerChunk,
    );

    imageKeys = List.generate(splittedMatnRanges.length, (index) => GlobalKey());
    emit(
      ShareImageLoadedState(
        content: content2Set,
        title: baseTitle,
        shareImageSettings: shareImageSettings,
        showLoadingIndicator: false,
        settings: settings.copyWith(wordsCountPerSize: charsPerChunk),
        splittedMatn: splittedMatnRanges,
        activeIndex: 0,
      ),
    );
  }

  FutureOr<DbTitle> _getTitle(DbContent content) async {
    switch (content.kind) {
      case ZikrKind.hisn:
        return sl<HisnDBHelper>().getTitleById(id: content.titleId);
      case ZikrKind.custom:
        final customTitle = await sl<CustomAzkarRepo>().getTitle(content.customTitleId);
        return DbTitle(id: content.titleId, name: customTitle?.name ?? "", freq: "", order: -1);
      case ZikrKind.fakeHadith:
        return const DbTitle(
          id: ZikrKind.fakeHadithTitleId,
          name: "أحاديث منتشرة لا تصح",
          freq: "",
          order: -1,
        );
    }
  }

  /// MARK: ** EVENTS **

  FutureOr _updateSettings(ShareImageSettings shareImageSettings) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    await shareAsImageRepo.updateShareImageSettings(shareImageSettings);

    emit(state.copyWith(shareImageSettings: shareImageSettings));
  }

  /// MARK: Colors EVENTS

  Future<void> updateTextColor(Color color) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(bodyTextColor: color));
  }

  Future<void> updateTitleColor(Color color) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(titleTextColor: color));
  }

  Future<void> updateBackgroundColor(Color color) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(backgroundColor: color));
  }

  Future<void> updateAdditionalTextColor(Color color) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(additionalTextColor: color));
  }

  /// Applies a ready-made set of colors with a single write.
  Future<void> applyColorPreset(ShareColorPreset preset) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    await _updateSettings(
      state.shareImageSettings.copyWith(
        backgroundColor: preset.background,
        titleTextColor: preset.title,
        additionalTextColor: preset.text,
        bodyTextColor: preset.text,
      ),
    );
  }

  void resetColors() {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(
      state.shareImageSettings.copyWith(
        titleTextColor: kShareImageTitleTextColor,
        bodyTextColor: kShareImageBodyTextColor,
        additionalTextColor: kShareImageAdditionalTextColor,
        backgroundColor: kShareImageBackgroundColor,
      ),
    );
  }

  /// MARK: General EVENTS
  Future<void> updateExportQuality(ShareExportQuality value) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    await _updateSettings(state.shareImageSettings.copyWith(exportQuality: value));
  }

  Future<void> uodateShowFadl({required bool value}) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(showFadl: value));
  }

  Future<void> updateShowSource({required bool value}) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(showSource: value));
  }

  Future<void> toggleRemoveDiacritics() async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(
      state.shareImageSettings.copyWith(
        removeDiacritics: !state.shareImageSettings.removeDiacritics,
      ),
    );
  }

  /// MARK: Export

  /// Brings a page on screen and waits until it is painted. Only the visible page of
  /// the [PageView] is built, so a page has to be shown to be captured.
  Future<void> _showPage(int index) async {
    if (!pageController.hasClients) return;

    pageController.jumpToPage(index);
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Captures every page of the zikr as a PNG at the chosen quality. A zikr that was
  /// split into several images is exported as all of them, so no part is left behind.
  Future<List<ExportedShareImage>> captureImages() async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return const [];

    final pageCount = state.splittedMatn.length;
    final originalPage = state.activeIndex;
    final now = DateTime.now();
    final files = <ExportedShareImage>[];

    try {
      for (var page = 0; page < pageCount; page++) {
        if (pageCount > 1) await _showPage(page);

        final controller = CaptureWidgetController(imageKey: imageKeys[page]);
        final size = controller.getWidgetSize();
        if (size == null) throw StateError("Page $page is not on screen");

        final pixelRatio = ShareImageExport.pixelRatio(
          state.shareImageSettings.exportQuality,
          size,
        );
        final image = await controller.getImage(pixelRatio);
        if (image == null) throw StateError("Page $page could not be captured");

        try {
          final data = await image.toByteData(format: ImageByteFormat.png);
          if (data == null) throw StateError("Page $page could not be encoded");

          files.add(
            ExportedShareImage(
              name: ShareImageExport.fileName(
                zikrId: state.content.id,
                pageIndex: page,
                pageCount: pageCount,
                time: now,
              ),
              bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            ),
          );
        } finally {
          // The picture lives in native memory; do not wait for the garbage collector.
          image.dispose();
        }
      }
    } finally {
      if (pageCount > 1) await _showPage(originalPage);
    }

    return files;
  }

  /// Runs [action] behind the loading bar. Every failure is shown to the user, and the
  /// bar always goes away.
  Future<void> _export(Future<void> Function() action) async {
    final state = this.state;
    if (state is! ShareImageLoadedState || state.showLoadingIndicator) return;

    emit(state.copyWith(showLoadingIndicator: true));
    try {
      await action();
    } catch (e) {
      hisnPrint(e.toString());
      showToast(msg: SX.current.errorOccurred, type: ToastType.error);
    } finally {
      // Pages were switched while capturing, so build on the state as it is now.
      final current = this.state;
      if (!isClosed && current is ShareImageLoadedState) {
        emit(current.copyWith(showLoadingIndicator: false));
      }
    }
  }

  Future<void> shareImage(BuildContext context) async {
    // Where the share sheet points to (iPad); read before anything is awaited.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    await _export(() async {
      final files = await captureImages();
      if (files.isEmpty) throw StateError("Nothing was captured");

      if (PlatformExtension.isDesktop) {
        await _saveToFolder(files);
      } else {
        await _shareFiles(files, origin);
      }
    });
  }

  Future<void> saveToGallery() async {
    await _export(() async {
      if (PlatformExtension.isDesktop) {
        // Desktops have no photo gallery: ask for a folder instead.
        await _saveToFolder(await captureImages());
        return;
      }

      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        showToast(msg: SX.current.galleryPermissionRequired, type: ToastType.error);
        return;
      }

      final files = await captureImages();
      if (files.isEmpty) throw StateError("Nothing was captured");

      for (final file in files) {
        await Gal.putImageBytes(file.bytes, name: path.basenameWithoutExtension(file.name));
      }
      showToast(msg: SX.current.imageSavedSuccessfully, type: ToastType.success);
    });
  }

  Future<void> _saveToFolder(List<ExportedShareImage> files) async {
    final String? dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Please select an output file:',
    );
    if (dir == null) return;

    for (final file in files) {
      await File(path.join(dir, file.name)).writeAsBytes(file.bytes);
    }
    showToast(msg: SX.current.imageSavedSuccessfully, type: ToastType.success);
  }

  Future<void> _shareFiles(List<ExportedShareImage> files, Rect? origin) async {
    // Its own folder, so the files can be removed whatever happens.
    final folder = Directory(path.join((await getTemporaryDirectory()).path, "share_image"));
    await folder.create(recursive: true);

    try {
      final xFiles = <XFile>[];
      for (final file in files) {
        final target = File(path.join(folder.path, file.name));
        await target.writeAsBytes(file.bytes);
        xFiles.add(XFile(target.path, mimeType: "image/png", name: file.name));
      }

      await SharePlus.instance.share(ShareParams(files: xFiles, sharePositionOrigin: origin));
    } finally {
      if (await folder.exists()) await folder.delete(recursive: true);
    }
  }

  /// **************************

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}

/// A finished picture of one page, ready to be shared or saved.
class ExportedShareImage {
  final String name;
  final Uint8List bytes;

  const ExportedShareImage({required this.name, required this.bytes});
}
