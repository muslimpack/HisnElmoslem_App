import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';

ShareAsImageData shareAsImageData = ShareAsImageData();

class ShareAsImageData {
  final box = GetStorage(kAppStorageKey);

  ///
  final String titleTextBoxKey = 'share_image_title_text_color';

  Color get titleTextColor =>
      Color(box.read<int?>(titleTextBoxKey) ?? kShareImageColorsList[4].value);
  Future<void> updateTitleColor(Color color) async {
    await box.write(titleTextBoxKey, color.value);
  }

  ///
  final String bodyTextColorBoxKey = 'share_image_body_text_color';

  Color get bodyTextColor => Color(
        box.read<int?>(bodyTextColorBoxKey) ?? kShareImageColorsList[5].value,
      );

  Future<void> updateTextColor(Color color) async {
    await box.write(bodyTextColorBoxKey, color.value);
  }

  ///
  final String additionalTextColorBoxKey = 'share_image_additional_text_color';

  Color get additionalTextColor => Color(
        box.read<int?>(additionalTextColorBoxKey) ??
            kShareImageColorsList[3].value,
      );
  Future<void> updateAdditionalTextColor(Color color) async {
    await box.write(additionalTextColorBoxKey, color.value);
  }

  ///
  final String backgroundColorBoxKey = 'share_image_background_color';

  Color get backgroundColor => Color(
        box.read<int?>(backgroundColorBoxKey) ?? kShareImageColorsList[7].value,
      );
  Future<void> updateBackgroundColor(Color color) async {
    await box.write(backgroundColorBoxKey, color.value);
  }

  ///
  final String fontSizeBoxKey = 'share_image_font_size';

  double get fontSize => box.read(fontSizeBoxKey) ?? 25;
  Future<void> changFontSize(double value) async {
    await box.write(fontSizeBoxKey, value);
  }

  ///
  final String showFadlBoxKey = 'share_image_show_fadl';

  bool get showFadl => box.read(showFadlBoxKey) ?? true;
  Future<void> updateShowFadl({required bool value}) async {
    await box.write(showFadlBoxKey, value);
  }

  ///
  final String showSourceBoxKey = 'share_image_show_source';

  bool get showSource => box.read(showSourceBoxKey) ?? true;

  Future<void> updateShowSource({required bool value}) async {
    await box.write(showSourceBoxKey, value);
  }

  ///
  final String showZikrIndexBoxKey = 'share_image_show_zikr_index';

  bool get showZikrIndex => box.read(showZikrIndexBoxKey) ?? true;
  Future<void> updateShowZikrIndex({required bool value}) async {
    await box.write(showZikrIndexBoxKey, value);
  }

  ///
  final String removeDiacriticsKey = 'share_image_remove_tashkel';

  bool get removeDiacritics => box.read(removeDiacriticsKey) ?? false;
  Future<void> updateRemoveDiacritics({required bool value}) async {
    await box.write(
      removeDiacriticsKey,
      value,
    );
  }

  ///
  final String imageWidthBoxKey = 'share_image_image_width';

  int get imageWidth => box.read(imageWidthBoxKey) ?? 600;
  Future<void> updateImageWidth({required int value}) async {
    await box.write(imageWidthBoxKey, value);
  }

  ///
  final String imageQualityBoxKey = 'share_image_image_quality';

  double get imageQuality => box.read(imageQualityBoxKey) ?? 2;
  Future<void> updateImageQuality(double value) async {
    await box.write(imageQualityBoxKey, value);
  }

  ///
  final String shareImageSettingsBoxKey = 'share_image_image_settings';

  ShareImageSettings get shareImageSettings {
    final data = box.read<String?>(shareImageSettingsBoxKey);
    if (data == null) {
      return ShareImageSettings(
        titleTextColor: titleTextColor,
        bodyTextColor: bodyTextColor,
        additionalTextColor: additionalTextColor,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        showFadl: showFadl,
        showSource: showSource,
        showZikrIndex: showZikrIndex,
        removeDiacritics: removeDiacritics,
        imageWidth: imageWidth,
        imageQuality: imageQuality,
      );
    }
    return ShareImageSettings.fromJson(data);
  }

  Future<void> updateShareImageSettings(ShareImageSettings settings) async {
    await box.write(
      shareImageSettingsBoxKey,
      settings.toJson(),
    );
  }
}
