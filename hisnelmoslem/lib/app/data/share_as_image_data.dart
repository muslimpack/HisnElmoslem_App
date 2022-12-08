import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
import 'package:flutter/material.dart';

ShareAsImageData shareAsImageData = ShareAsImageData();

class ShareAsImageData {
  final box = GetStorage();
  //////////////////

  final String titleTextBoxKey = 'share_image_title_text_color';

  Color get titleTextColor =>
      Color(box.read<int?>(titleTextBoxKey) ?? shareAsImageColorsList[4].value);

  final String bodyTextColorBoxKey = 'share_image_body_text_color';

  Color get bodyTextColor => Color(
      box.read<int?>(bodyTextColorBoxKey) ?? shareAsImageColorsList[5].value);

  final String additionalTextColorBoxKey = 'share_image_additional_text_color';

  Color get additionalTextColor =>
      Color(box.read<int?>(additionalTextColorBoxKey) ??
          shareAsImageColorsList[3].value);

  final String backgroundColorBoxKey = 'share_image_background_color';

  Color get backgroundColor => Color(
      box.read<int?>(backgroundColorBoxKey) ?? shareAsImageColorsList[9].value);

  final String fontSizeBoxKey = 'share_image_font_size';

  double get fontSize => box.read(fontSizeBoxKey) ?? 25;

  final String showFadlBoxKey = 'share_image_show_fadl';

  bool get showFadl => box.read(showFadlBoxKey) ?? true;

  final String showSourceBoxKey = 'share_image_show_source';

  bool get showSource => box.read(showSourceBoxKey) ?? true;

  final String showZikrIndexBoxKey = 'share_image_show_zikr_index';

  bool get showZikrIndex => box.read(showZikrIndexBoxKey) ?? true;

  final String fixedFontBoxKey = 'share_image_fixed_font';

  bool get fixedFont => box.read(fixedFontBoxKey) ?? false;

  final String removeTashkelKey = 'share_image_remove_tashkel';

  bool get removeTashkel => box.read(removeTashkelKey) ?? false;

  final String imageWidthBoxKey = 'share_image_image_width';

  int get imageWidth => box.read(imageWidthBoxKey) ?? 600;

  final String imageQualityBoxKey = 'share_image_image_quality';

  double get imageQuality => box.read(imageQualityBoxKey) ?? 2;
  /////////////////////

}
