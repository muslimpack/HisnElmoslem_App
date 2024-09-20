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
import 'package:hisnelmoslem/src/features/home/data/repository/hisn_db_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_const.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_repo.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'share_image_state.dart';

class ShareImageCubit extends Cubit<ShareImageState> {
  final ShareAsImageRepo shareAsImageRepo;
  TransformationController transformationController =
      TransformationController();

  final CaptureWidgetController captureWidgetController =
      CaptureWidgetController();
  ShareImageCubit(this.shareAsImageRepo) : super(ShareImageLoadingState());

  FutureOr start(DbContent content) async {
    final ShareImageSettings shareImageSettings =
        shareAsImageRepo.shareImageSettings;

    final baseTitle = await _getTitle(content);

    emit(
      ShareImageLoadedState(
        content: content,
        title: baseTitle,
        shareImageSettings: shareImageSettings,
        showLoadingIndicator: false,
      ),
    );
  }

  FutureOr<String> _getTitle(DbContent content) async {
    final String title;
    if (content.titleId >= 0) {
      title = (await sl<HisnDBHelper>().getTitleById(id: content.titleId)).name;
    } else {
      title = "أحاديث منتشرة لا تصح";
    }
    return title;
  }

  /// MARK: ** EVENTS **

  FutureOr _updateSettings(ShareImageSettings shareImageSettings) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    await shareAsImageRepo.updateShareImageSettings(shareImageSettings);

    emit(
      state.copyWith(shareImageSettings: shareImageSettings),
    );
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

    _updateSettings(
      state.shareImageSettings.copyWith(
        imageWidth: value,
      ),
    );
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

    try {
      final double pixelRatio = state.shareImageSettings.imageQuality;
      final image = await captureWidgetController.getImage(pixelRatio);
      final byteData = await image?.toByteData(format: ImageByteFormat.png);

      if (PlatformExtension.isDesktop) {
        await _saveDesktop(byteData);
      } else {
        await _savePhone(byteData);
      }
    } catch (e) {
      hisnPrint(e.toString());
    }

    emit(state.copyWith(showLoadingIndicator: false));
  }

  Future _saveDesktop(ByteData? byteData) async {
    if (byteData == null) return;

    final Uint8List uint8List = byteData.buffer.asUint8List();

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'HisnElmoslemSharedImage-$timestamp.png',
    );

    if (outputFile == null) return;
    if (!outputFile.endsWith(".png")) {
      outputFile += ".png";
    }

    hisnPrint(outputFile);

    final File file = File(outputFile);
    await file.writeAsBytes(uint8List);
  }

  Future _savePhone(ByteData? byteData) async {
    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();

    final File file =
        await File('${tempDir.path}/hisnElmoslemSharedImage.png').create();
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await Share.shareXFiles([XFile(file.path)]);

    await file.delete();
  }

  /// **************************

  @override
  Future<void> close() {
    transformationController.dispose();
    return super.close();
  }
}
