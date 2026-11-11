import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/datasources/custom_azkar_db_helper.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/repositories/custom_azkar_repo_impl.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/data/services/custom_audio_storage.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_title_item.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/domain/entities/custom_zikr.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_title_editor/custom_title_editor_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'custom_azkar_repo_test.dart' show FakeOriginalSource, original;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory dir;
  late LocalCustomAudioStorage storage;
  late CustomAzkarDBHelper helper;
  late CustomAzkarRepoImpl repo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('custom_audio_test');
    storage = LocalCustomAudioStorage(directoryOverride: dir);
    helper = CustomAzkarDBHelper(pathOverride: inMemoryDatabasePath);
    repo = CustomAzkarRepoImpl(
      helper,
      FakeOriginalSource({1: original(1, 10, "alpha")}),
      audioStorage: storage,
    );
  });

  tearDown(() async {
    await helper.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  Future<String> record(String name) async {
    File(await storage.pathFor(name)).writeAsBytesSync([1, 2, 3]);
    return name;
  }

  test("recording name is stored on the item and survives a save", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine"));
    final file = await record("a.m4a");
    final id = await repo.createTitle(const CustomTitle(name: "T"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, audioFile: file),
    ]);

    var resolved = await repo.getResolvedItems(id);
    expect(resolved.single.item.audioFile, file);
    expect(resolved.single.item.hasUserAudio, isTrue);

    // Saving from the editor replaces item rows; the file name must carry over.
    await repo.updateTitle(CustomTitle(id: id, name: "T"), [resolved.single.item]);
    resolved = await repo.getResolvedItems(id);
    expect(resolved.single.item.audioFile, file);
    expect(await storage.exists(file), isTrue);
  });

  test("a linked original item can carry its own recording", () async {
    final file = await record("o.m4a");
    final item = (await repo.itemFromOriginalZikr(1))!.copyWith(audioFile: file);
    final id = await repo.createTitle(const CustomTitle(name: "T"), [item]);

    final resolved = (await repo.getResolvedItems(id)).single;
    expect(resolved.item.audioFile, file);
  });

  test("removing the recording from the draft deletes the file on save", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine"));
    final file = await record("b.m4a");
    final id = await repo.createTitle(const CustomTitle(name: "T"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, audioFile: file),
    ]);
    final item = (await repo.getResolvedItems(id)).single.item;

    await repo.updateTitle(CustomTitle(id: id, name: "T"), [item.copyWith(clearAudio: true)]);

    expect((await repo.getResolvedItems(id)).single.item.audioFile, isNull);
    expect(await storage.exists(file), isFalse);
  });

  test("deleting a title or a zikr deletes its recordings", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine"));
    final f1 = await record("c.m4a");
    final f2 = await record("d.m4a");
    final t1 = await repo.createTitle(const CustomTitle(name: "T1"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, audioFile: f1),
    ]);
    await repo.createTitle(const CustomTitle(name: "T2"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId, audioFile: f2),
    ]);

    await repo.deleteTitle(t1);
    expect(await storage.exists(f1), isFalse);
    expect(await storage.exists(f2), isTrue);

    await repo.deleteZikr(zikrId);
    expect(await storage.exists(f2), isFalse);
  });

  test("setItemAudio replaces and clears, removing the old file", () async {
    final zikrId = await repo.saveZikr(const CustomZikr(content: "mine"));
    final id = await repo.createTitle(const CustomTitle(name: "T"), [
      CustomTitleItem(kind: CustomItemKind.custom, refId: zikrId),
    ]);
    final itemId = (await repo.getResolvedItems(id)).single.item.id;

    final first = await record("e.m4a");
    await repo.setItemAudio(itemId, first);
    expect((await repo.getResolvedItems(id)).single.item.audioFile, first);

    final second = await record("f.m4a");
    await repo.setItemAudio(itemId, second);
    expect(await storage.exists(first), isFalse);
    expect(await storage.exists(second), isTrue);

    await repo.setItemAudio(itemId, null);
    expect((await repo.getResolvedItems(id)).single.item.hasUserAudio, isFalse);
    expect(await storage.exists(second), isFalse);
  });

  group("editor draft", () {
    late CustomTitleEditorBloc editor;

    Future<CustomTitleEditorLoadedState> loadedWithOneZikr() async {
      final zikr = await repo.saveZikr(const CustomZikr(content: "mine"));
      final id = await repo.createTitle(const CustomTitle(name: "T"), [
        CustomTitleItem(kind: CustomItemKind.custom, refId: zikr),
      ]);
      editor = CustomTitleEditorBloc(repo, storage)..add(CustomTitleEditorStartEvent(titleId: id));
      return editor.stream
          .firstWhere((s) => s is CustomTitleEditorLoadedState)
          .then(
            (s) => s as CustomTitleEditorLoadedState,
          );
    }

    test("a take survives deleting a library zikr while the editor is open", () async {
      final s = await loadedWithOneZikr();
      final file = await record("take.m4a");
      editor.add(
        CustomTitleEditorItemAudioChangedEvent(uid: s.entries.single.uid, audioFile: file),
      );
      await editor.stream.firstWhere(
        (s) => s is CustomTitleEditorLoadedState && s.entries.single.resolved.item.hasUserAudio,
      );

      // Any repo mutation sweeps unreferenced files; the draft take is only pinned.
      await repo.deleteZikr(await repo.saveZikr(const CustomZikr(content: "other")));

      expect(await storage.exists(file), isTrue);
      await editor.close();
    });

    test("leaving without saving deletes takes but keeps saved recordings", () async {
      final s = await loadedWithOneZikr();
      final uid = s.entries.single.uid;
      final saved = await record("saved.m4a");
      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: saved));
      editor.add(const CustomTitleEditorSaveEvent());
      await editor.stream.firstWhere((s) => s is CustomTitleEditorLoadedState && s.saved);

      final unsaved = await record("unsaved.m4a");
      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: unsaved));
      await editor.stream.firstWhere(
        (s) =>
            s is CustomTitleEditorLoadedState &&
            s.entries.single.resolved.item.audioFile == unsaved,
      );

      await editor.close();

      expect(await storage.exists(saved), isTrue);
      expect(await storage.exists(unsaved), isFalse);
    });

    test("re-recording in the same session deletes the replaced take at once", () async {
      final s = await loadedWithOneZikr();
      final uid = s.entries.single.uid;
      final first = await record("t1.m4a");
      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: first));
      final second = await record("t2.m4a");
      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: second));
      await editor.stream.firstWhere(
        (s) =>
            s is CustomTitleEditorLoadedState && s.entries.single.resolved.item.audioFile == second,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(await storage.exists(first), isFalse);
      expect(await storage.exists(second), isTrue);
      await editor.close();
    });

    test("removing a saved recording keeps the file until the title is saved", () async {
      final s = await loadedWithOneZikr();
      final uid = s.entries.single.uid;
      final saved = await record("keep.m4a");
      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: saved));
      editor.add(const CustomTitleEditorSaveEvent());
      await editor.stream.firstWhere((s) => s is CustomTitleEditorLoadedState && s.saved);

      editor.add(CustomTitleEditorItemAudioChangedEvent(uid: uid, audioFile: null));
      await editor.stream.firstWhere(
        (s) => s is CustomTitleEditorLoadedState && !s.entries.single.resolved.item.hasUserAudio,
      );
      expect(await storage.exists(saved), isTrue);

      editor.add(const CustomTitleEditorSaveEvent());
      await editor.stream.firstWhere(
        (s) => s is CustomTitleEditorLoadedState && s.saved && !s.isSaving,
      );
      expect(await storage.exists(saved), isFalse);
      await editor.close();
    });
  });

  test("storage never resolves outside its folder", () async {
    final path = await storage.pathFor("../../evil.m4a");
    expect(File(path).parent.path, dir.path);
  });
}
