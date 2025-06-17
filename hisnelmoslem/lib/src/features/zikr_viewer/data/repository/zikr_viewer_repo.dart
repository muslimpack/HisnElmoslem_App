import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/core/functions/print.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_session.dart';

class ZikrViewerRepo {
  final GetStorage box;

  ZikrViewerRepo(this.box);

  ///MARK: Zikr Viewer sessoion
  static const String _lastSessionPrefixKey = "zikrViewerlastSession_";
  String sessionKey(int titleId) => "$_lastSessionPrefixKey$titleId";

  /// Map of {contentId: count}
  ZikrSession? getLastSession(int titleId) {
    final String? data = box.read(sessionKey(titleId));
    if (data == null) return null;

    try {
      hisnPrint(data);
      return ZikrSession.fromJson(data);
    } catch (e) {
      hisnPrint(e.toString());
    }
    return null;
  }

  /// Map of {contentId: count}
  Future saveSession(int titleId, ZikrSession session) async {
    await box.write(sessionKey(titleId), session.toJson());
  }

  Future resetSession(int titleId) async {
    await box.write(sessionKey(titleId), null);
  }

  ///MARK: Zikr Share settings

  ///
  static const String _shareFadlKey = "shareFadl";
  bool get shareFadl => box.read<bool?>(_shareFadlKey) ?? true;
  Future toggleShareFadl(bool value) => box.write(_shareFadlKey, value);

  ///
  static const String _shareSourceKey = "shareSource";
  bool get shareSource => box.read<bool?>(_shareSourceKey) ?? true;
  Future toggleShareSource(bool value) => box.write(_shareSourceKey, value);

  ///MARK: Enable Disable the ability to restore session
  static const String _allowZikrSessionRestorationKey =
      "allowZikrSessionRestoration";
  bool get allowZikrSessionRestoration =>
      box.read<bool?>(_allowZikrSessionRestorationKey) ?? true;
  Future toggleAllowZikrSessionRestoration(bool value) =>
      box.write(_allowZikrSessionRestorationKey, value);
}
