import 'dart:ui';

import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/models/share_image_settings.dart';
import 'package:hisnelmoslem/src/features/share_as_image/data/repository/share_as_image_const.dart';

class ShareAsImageRepo {
  final GetStorage box;

  ShareAsImageRepo(this.box);

  ///MARK: Colors

  static const String _shareImageTitleTextBoxKey =
      'share_image_title_text_color';

  Color get shareImageTitleTextColor => Color(
        box.read<int?>(_shareImageTitleTextBoxKey) ??
            kShareImageTitleTextColor.value,
      );
  Future<void> shareImageUpdateTitleColor(Color color) async {
    await box.write(_shareImageTitleTextBoxKey, color.value);
  }

  ///
  static const String _shareImageBodyTextColorBoxKey =
      'share_image_body_text_color';

  Color get shareImageBodyTextColor => Color(
        box.read<int?>(_shareImageBodyTextColorBoxKey) ??
            kShareImageBodyTextColor.value,
      );

  Future<void> shareImageUpdateTextColor(Color color) async {
    await box.write(_shareImageBodyTextColorBoxKey, color.value);
  }

  ///
  static const String _shareImageAdditionalTextColorBoxKey =
      'share_image_additional_text_color';

  Color get shareImageAdditionalTextColor => Color(
        box.read<int?>(_shareImageAdditionalTextColorBoxKey) ??
            kShareImageAdditionalTextColor.value,
      );
  Future<void> updateAdditionalTextColor(Color color) async {
    await box.write(_shareImageAdditionalTextColorBoxKey, color.value);
  }

  ///
  static const String _shareImageBackgroundColorBoxKey =
      'share_image_background_color';

  Color get shareImageBackgroundColor => Color(
        box.read<int?>(_shareImageBackgroundColorBoxKey) ??
            kShareImageBackgroundColor.value,
      );
  Future<void> updateBackgroundColor(Color color) async {
    await box.write(_shareImageBackgroundColorBoxKey, color.value);
  }

  ///MARK: Font

  ///
  static const String _shareImageFontSizeBoxKey = 'share_image_font_size';

  double get shareImageFontSize => box.read(_shareImageFontSizeBoxKey) ?? 25;
  Future<void> shareImageChangFontSize(double value) async {
    await box.write(_shareImageFontSizeBoxKey, value);
  }

  ///MARK: Show Hide

  ///
  static const String _shareImageShowFadlBoxKey = 'share_image_show_fadl';

  bool get shareImageShowFadl => box.read(_shareImageShowFadlBoxKey) ?? true;
  Future<void> shareImageUpdateShowFadl({required bool value}) async {
    await box.write(_shareImageShowFadlBoxKey, value);
  }

  ///
  static const String _shareImageShowSourceBoxKey = 'share_image_show_source';

  bool get shareImageShowSource =>
      box.read(_shareImageShowSourceBoxKey) ?? true;

  Future<void> shareImageUpdateShowSource({required bool value}) async {
    await box.write(_shareImageShowSourceBoxKey, value);
  }

  ///
  static const String _shareImageShowZikrIndexBoxKey =
      'share_image_show_zikr_index';

  bool get shareImageShowZikrIndex =>
      box.read(_shareImageShowZikrIndexBoxKey) ?? false;
  Future<void> shareImageUpdateShowZikrIndex({required bool value}) async {
    await box.write(_shareImageShowZikrIndexBoxKey, value);
  }

  ///MARK: Text

  ///
  static const String _shareImageRemoveDiacriticsKey =
      'share_image_remove_tashkel';

  bool get shareImageRemoveDiacritics =>
      box.read(_shareImageRemoveDiacriticsKey) ?? false;
  Future<void> shareImageUpdateRemoveDiacritics({required bool value}) async {
    await box.write(
      _shareImageRemoveDiacriticsKey,
      value,
    );
  }

  ///
  static const String _shareImageImageWidthBoxKey = 'share_image_image_width';

  int get shareImageImageWidth => box.read(_shareImageImageWidthBoxKey) ?? 600;
  Future<void> shareImageUpdateImageWidth({required int value}) async {
    await box.write(_shareImageImageWidthBoxKey, value);
  }

  ///
  static const String _shareImageImageQualityBoxKey =
      'share_image_image_quality';

  double get shareImageImageQuality =>
      box.read(_shareImageImageQualityBoxKey) ?? 2;
  Future<void> shareImageUpdateImageQuality(double value) async {
    await box.write(_shareImageImageQualityBoxKey, value);
  }

  ///
  static const String _shareImageSettingsBoxKey = 'share_image_image_settings';

  ShareImageSettings get shareImageSettings {
    final data = box.read<String?>(_shareImageSettingsBoxKey);
    if (data == null) {
      return ShareImageSettings(
        titleTextColor: shareImageTitleTextColor,
        bodyTextColor: shareImageBodyTextColor,
        additionalTextColor: shareImageAdditionalTextColor,
        backgroundColor: shareImageBackgroundColor,
        fontSize: shareImageFontSize,
        showFadl: shareImageShowFadl,
        showSource: shareImageShowSource,
        showZikrIndex: shareImageShowZikrIndex,
        removeDiacritics: shareImageRemoveDiacritics,
        imageWidth: shareImageImageWidth,
        imageQuality: shareImageImageQuality,
      );
    }
    return ShareImageSettings.fromJson(data);
  }

  Future<void> updateShareImageSettings(ShareImageSettings settings) async {
    await box.write(
      _shareImageSettingsBoxKey,
      settings.toJson(),
    );
  }
}
