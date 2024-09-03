import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:capture_widget/core/widget_capture_controller.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_platform.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/home/data/repository/azkar_database_helper.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_data.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

part 'share_image_state.dart';

class ShareImageCubit extends Cubit<ShareImageState> {
  final ShareAsImageData shareAsImageData;
  TransformationController transformationController =
      TransformationController();

  final CaptureWidgetController captureWidgetController =
      CaptureWidgetController();
  ShareImageCubit(this.shareAsImageData) : super(ShareImageLoadingState());

  FutureOr start(DbContent content) async {
    final ShareImageSettings shareImageSettings =
        shareAsImageData.shareImageSettings;

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
      title =
          (await azkarDatabaseHelper.getTitleById(id: content.titleId)).name;
    } else {
      title = "أحاديث منتشرة لا تصح";
    }
    return title;
  }

  FutureOr updateSettings(ShareImageSettings shareImageSettings) async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    await shareAsImageData.updateShareImageSettings(shareImageSettings);

    emit(
      state.copyWith(shareImageSettings: shareImageSettings),
    );
  }

  Future<void> shareImage() async {
    final state = this.state;
    if (state is! ShareImageLoadedState) return;

    emit(state.copyWith(showLoadingIndicator: true));

    try {
      final double pixelRatio = shareAsImageData.imageQuality;
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

    emit(state.copyWith(showLoadingIndicator: true));
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

  @override
  Future<void> close() {
    transformationController.dispose();
    return super.close();
  }
}
