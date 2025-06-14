import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:capture_widget/core/widget_capture_controller.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/shareable_image_card_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_const.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'share_image_state.dart';

class ShareImageCubit extends Cubit<ShareImageState> {
  final ShareAsImageRepo shareAsImageRepo;
  TransformationController transformationController =
      TransformationController();

  final CaptureWidgetController captureWidgetController =
      CaptureWidgetController();
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
    final ShareImageSettings shareImageSettings =
        shareAsImageRepo.shareImageSettings;

    final baseTitle = await _getTitle(content);

    final settings = const ShareableImageCardSettings.defaultSettings()
        .copyWith(wordsCountPerSize: 120);

    final String proccessedText = content.content;
    final charsPerChunk = charPer1080(
      settings.wordsCountPerSize,
      proccessedText,
    );

    final List<TextRange> splittedMatnRanges = splitStringIntoChunksRange(
      proccessedText,
      charsPerChunk,
    );

    imageKeys = List.generate(
      splittedMatnRanges.length,
      (index) => GlobalKey(),
    );
    emit(
      ShareImageLoadedState(
        content: content,
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
    final DbTitle title;
    if (content.titleId >= 0) {
      title = await sl<HisnDBHelper>().getTitleById(id: content.titleId);
    } else {
      title = const DbTitle(
        id: -1,
        name: "أحاديث منتشرة لا تصح",
        freq: "",
        favourite: false,
        order: -1,
      );
    }
    return title;
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

    _updateSettings(
      state.shareImageSettings.copyWith(additionalTextColor: color),
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

  /// MARK: Font EVENTS
  Future<void> _changFontSize(double value) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    final double tempValue = value.clamp(10, 70);
    _updateSettings(state.shareImageSettings.copyWith(fontSize: tempValue));
  }

  void increaseFontSize() {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;
    _changFontSize(state.shareImageSettings.fontSize + 1);
  }

  void decreaseFontSize() {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;
    _changFontSize(state.shareImageSettings.fontSize - 1);
  }

  void resetFontSize() {
    _changFontSize(25);
  }

  /// MARK: General EVENTS
  Future<void> updateImageQuality(double value) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(imageQuality: value));
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

  Future<void> updateShowZikrIndex({required bool value}) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(showZikrIndex: value));
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

  Future<void> updateImageWidth({required int value}) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    _updateSettings(state.shareImageSettings.copyWith(imageWidth: value));
  }

  void fitImageToScreen(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Size imageSize = captureWidgetController.getWidgetSize() ?? Size.zero;

    if (imageSize == Size.zero) return;

    // Calculate the scale factors for both width and height
    final double widthScale =
        screenSize.width / shareAsImageRepo.shareImageImageWidth;
    final double heightScale = screenSize.height / imageSize.height;

    // Choose the smaller scale to ensure the image fits within the screen
    final double scale = widthScale < heightScale ? widthScale : heightScale;

    // Create the fitMatrix with the uniform scale
    final Matrix4 fitMatrix = Matrix4.diagonal3Values(scale, scale, scale);

    // Center the image horizontally and vertically
    fitMatrix[12] = (screenSize.width - imageSize.width * scale) / 2;
    fitMatrix[13] = (screenSize.height - imageSize.height * scale) / 2;

    // Apply the transformation
    transformationController.value = fitMatrix;
  }

  /// MARK: Save Image

  Future<void> shareImage() async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    emit(state.copyWith(showLoadingIndicator: true));
    const double pixelRatio = 2;

    final List<ByteData> filesData = [];
    final List<String> filesName = [];

    try {
      final captureWidgetController = CaptureWidgetController(
        imageKey: imageKeys[state.activeIndex],
      );
      final image = await captureWidgetController.getImage(pixelRatio);

      final byteData = await image?.toByteData(format: ImageByteFormat.png);

      if (byteData == null) return;

      final fileName = _getHadithOutputFileName(
        state.content,
        state.activeIndex,
        state.splittedMatn.length,
      );

      filesData.add(byteData);
      filesName.add(fileName);

      if (PlatformExtension.isDesktop) {
        await _saveDesktop(filesData, fileName: filesName);
      } else {
        await _savePhone(filesData);
      }
    } catch (e) {
      hisnPrint(e.toString());
    }

    emit(state.copyWith(showLoadingIndicator: false));
  }

  String _getHadithOutputFileName(DbContent zikr, int index, int length) {
    return _getOutputFileName("Hisn-${zikr.id}_${index + 1}_of_$length");
  }

  String _getOutputFileName(String outputFileName) {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final fileName = "$outputFileName-$timestamp.png";
    return fileName;
  }

  Future _saveDesktop(
    List<ByteData> filesData, {
    required List<String> fileName,
  }) async {
    final String? dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Please select an output file:',
    );

    if (dir == null) return;

    for (var i = 0; i < filesData.length; i++) {
      final Uint8List uint8List = filesData[i].buffer.asUint8List();
      final File file = File(path.join(dir, fileName[i]));
      await file.writeAsBytes(uint8List);
    }
  }

  Future _savePhone(List<ByteData> filesData) async {
    final tempDir = await getTemporaryDirectory();

    final List<XFile> xFiles = [];
    for (int i = 0; i < filesData.length; i++) {
      final File file = await File(
        '${tempDir.path}/SharedImage$i.png',
      ).create();
      await file.writeAsBytes(filesData[i].buffer.asUint8List());
      xFiles.add(XFile(file.path));
    }
    // print file size
    // hisnPrint(await objectSize(xFiles));

    await SharePlus.instance.share(ShareParams(files: xFiles));

    for (final file in xFiles) {
      await File(file.path).delete();
    }
  }

  /// **************************

  @override
  Future<void> close() {
    transformationController.dispose();
    return super.close();
  }

  Future<int> objectSize(List<XFile> xFiles) async {
    int totalSize = 0;
    for (int i = 0; i < xFiles.length; i++) {
      totalSize += await xFiles[i].length();
    }
    return totalSize;
  }
}
