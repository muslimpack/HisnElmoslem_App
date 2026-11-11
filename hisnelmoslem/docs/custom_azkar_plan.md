# Implementation Plan: Custom Azkar (user-defined titles & zikrs)

Ticket context: T-002 (users keep asking for extra adhkar). The app's policy is to ship only Hisn al-Muslim content, so this feature lets users add their own *without touching* the bundled `hisn_elmoslem.db`.

## 1. Requirements → decisions

| Requirement | Decision |
|---|---|
| Never modify original DB | New standalone SQLite file `custom_azkar.db`. Original content is only **referenced** (by content id), never copied or written. |
| Create title from scratch or from an existing one | "Create" sheet with two paths. Existing-title path copies *references* to that title's contents into a new custom title (original untouched). |
| Add custom zikrs | `custom_zikrs` table = user-authored library (content, source, fadl, default count). |
| Link custom or original zikr to a custom title | `custom_title_items` join table (`kind = custom \| original`, `ref_id`). |
| Edit order and count | `sort_order` + per-item `count` on the join row (count override applies to original zikrs too without changing them). |
| Alarm + route on tap | Own `custom_alarms` table, own notification-id range, new payload format parsed in `onNotificationClick`. |
| Home tab | New entry in `appDashboardTabs`. |
| Backup/restore | Register new DB path in `BackupRestoreRepo`. |
| Localization / stateless widgets / bloc / clean arch | See §6. |

**Confirmed decisions**
1. **Alarms are per title only** (one alarm per custom title; tap opens that title). No per-zikr deep link.
2. **Original zikrs: reference + snapshot fallback.** Each link stores `ref_id` *and* a text snapshot (content/source/fadl/hokm). Live original content wins when it resolves; the snapshot is used if the id is gone or its text changed shape. This is the most robust option and costs a few KB.
3. **Custom titles/zikrs appear in global search and in favourites** (v1). See §6b.
4. **Duplicates allowed**: the same original zikr can be linked more than once in a title (separate item rows).
5. Work happens on branch `feature/custom-azkar-tab` (cut from `main`); the pre-existing `custom_zikr` branch is ignored. One commit per phase.

## 2. Folder structure (`lib/src/features/custom_azkar/`)

```
data/
  datasources/custom_azkar_db_helper.dart     # sqflite, same singleton/getDbPath pattern as TallyDatabaseHelper
  models/                                     # *Model with fromMap/toMap, extend/map to entities
  repositories/custom_azkar_repo_impl.dart
domain/
  entities/   custom_title, custom_zikr, custom_title_item (+ resolved view: ResolvedItem), custom_alarm
  repositories/custom_azkar_repo.dart         # abstract
  usecases/   watch/get titles, create title (blank | from original), update title,
              delete title, add/remove/reorder items, set item count,
              upsert/delete custom zikr, resolve title items, alarm CRUD
presentation/
  bloc/custom_titles/        list tab
  bloc/custom_title_editor/  draft title + items, reorder, count, save
  bloc/custom_zikr_picker/   original-zikr search + custom library selection
  screens/ components/       (stateless widgets only)
```

Domain has no Flutter/sqflite imports. Repo impl depends on `CustomAzkarDBHelper` and `HisnDBHelper` (read-only, to resolve original contents).

## 3. Data layer

`custom_azkar.db` (version 1):

```sql
custom_titles(id PK AUTOINC, name TEXT NOT NULL, description TEXT, source_title_id INTEGER NULL,
              is_favourite INTEGER DEFAULT 0, sort_order INTEGER, created TEXT, updated TEXT)
custom_zikrs(id PK AUTOINC, content TEXT NOT NULL, source TEXT, fadl TEXT,
             default_count INTEGER DEFAULT 1, is_favourite INTEGER DEFAULT 0, created TEXT, updated TEXT)
custom_title_items(id PK AUTOINC, title_id INTEGER NOT NULL REFERENCES custom_titles ON DELETE CASCADE,
                   kind TEXT CHECK(kind IN ('custom','original')), ref_id INTEGER NOT NULL,
                   sort_order INTEGER NOT NULL, count INTEGER NOT NULL,
                   snap_content TEXT, snap_source TEXT, snap_fadl TEXT, snap_hokm TEXT)  -- snapshot only for kind='original'
custom_alarms(id PK AUTOINC, title_id INTEGER NOT NULL UNIQUE REFERENCES custom_titles ON DELETE CASCADE,
              body TEXT, repeat_type TEXT, hour INT, minute INT, is_active INT)
```

- Enable `PRAGMA foreign_keys = ON` in `onConfigure`.
- Deleting a custom zikr that is linked: block with a confirm dialog listing titles using it, then remove the links (or keep an "in use" guard — decide in UX review).
- Reordering: write `sort_order` for the affected rows in one transaction.
- Resolving original items: `HisnDBHelper.getContentsByIds`. Live content is used when the id resolves; otherwise the stored snapshot is shown (marked as "saved copy"). Snapshot is refreshed whenever the item is saved and the original resolves. No "missing" placeholder needed.
- Keep `getDbPath()` identical in shape to `TallyDatabaseHelper` (note: backup's `_getDbPaths` uses an any-desktop check for fake_hadith but tally uses `Platform.isWindows`; call the helper's own `getDbPath()` so both agree).

## 4. Viewer integration (largest risk area)

`ZikrViewerBloc._start` is hard-wired to `HisnDBHelper` and an `int titleIndex`; session restore is keyed by title id; bookmarks/audio/report assume original `DbContent`.

Plan:
1. Add a sealed `ZikrSource` (`OriginalTitle(id)` / `CustomTitle(id)`) in `zikr_viewer/data/models`. `ZikrViewerScreen` takes a source (keep a `ZikrViewerScreen(index:)` factory/constructor for existing call sites).
2. Add a small `ZikrContentsProvider` abstraction in zikr_viewer with two impls: original (current `_start` logic incl. filters) and custom (resolves items → `List<DbContent>` + title name). Bloc picks by source; the rest of the bloc is unchanged.
3. Map custom items into `DbContent` with **negative ids** (`-item.id`) so they never collide with original ids used in bookmarks/sessions/audio; set `titleId` to the custom title id, `count` from the item row, `hasAudio=false`.
4. Session key: `ZikrViewerRepo.sessionKey` gets a `custom_<id>` variant so custom sessions don't overwrite original title N's session. Sessions live in GetStorage → already in backup.
5. Don't apply `AzkarFiltersRepo` to custom items (user chose them explicitly).
6. For custom items: hide report-to-email; title-bookmark and zikr-bookmark buttons toggle the custom favourite flags (§6b); audio stays only for original items that have it.
7. Next/previous-title events: for custom source, disable (or cycle custom titles) — decide in UX.

## 5. Alarms & routing

Existing constraints: `alarms.titleId` is the notification id **and** the payload (`int.tryParse`), `555`/`666` are reserved, `"الكهف"` is a special payload.

- Notification id for custom alarms: `1_000_000 + custom_alarm.id` (documented constant, can't collide with original title ids or reserved ids).
- Payload: `custom:<titleId>` (per title only). Extend `LocalNotificationManager.onNotificationClick` with a `custom:` branch **before** the `int.tryParse` branch → `ZikrViewerScreen(source: CustomTitle(id))`. Cold-start path already goes through `handleLaunchNotification` → same function.
- Scheduling: extend `AlarmManager` (or add `CustomAlarmManager` using the same `LocalNotificationManager.addCustomDailyReminder/WeeklyReminder`) and re-register active custom alarms where `checkAllAlarmsInDb` runs. After restore the app restarts (`RestartWidget`), so alarms get re-scheduled from the restored DB — verify that path covers custom alarms.
- Cancel scheduled notifications when a title/alarm is deleted.
- Reuse existing UI: `AlarmEditor`, `permission_dialog`, `AlarmRepeatType`. If `AlarmEditor` is coupled to `DbAlarm`, extract a tiny shared value type rather than duplicating.
- If the title no longer exists, ignore the tap safely; deleting a title cancels its alarm.

## 6. Presentation / UX

State: `flutter_bloc`, registered in `dependency_injection.dart` (`initSL`). All widgets `StatelessWidget`; no `_buildX()` helper methods (extract widgets instead); `part` screens only if truly needed.

**Home tab** — add to `data_source/app_dashboard_tabs.dart` with `S.of(context).customAzkar`. Before merging, check how `AppComponent`/dashboard tabs are used elsewhere (settings may persist tab order/visibility by index) and make sure inserting a tab doesn't shift saved settings; append it last to be safe.

**Tab screen (`CustomTitlesScreen`)**: list of cards styled like `title_card.dart` (name, zikr count, alarm indicator, overflow menu: edit / duplicate / alarm / delete with undo snackbar). Empty state with illustration + CTA. Extended FAB "New title" → bottom sheet: *Start from scratch* / *Start from existing title* (opens searchable picker of originals).

**Editor (`CustomTitleEditorScreen`)**: name + optional description fields; `ReorderableListView` of items with drag handle, content preview (2 lines), source badge (Original / Custom), count stepper (− n +, long-press to type); swipe to remove; "Add zikr" bottom sheet with 3 tabs: *New custom zikr* (form), *My zikrs* (library), *From Hisn al-Muslim* (search reusing `SearchRepo`/`HisnDBHelper`, multi-select). Unsaved-changes guard on back. Validation: non-empty name, ≥1 item, count 1..9999.

**Theme**: only `Theme.of(context)` colors/text styles and existing shared widgets/fonts (`font_settings`, zikr text styling via `ZikrTextRepo`) so custom zikrs render exactly like built-in ones; verify light/dark/RTL.

**Localization**: add every string to `lib/l10n/en.arb` + `ar.arb` (with placeholders/plurals for counts), run `fvm flutter gen-l10n`; use `S.of(context)` in widgets and `SX.current` only outside the widget tree (alarm notification text). Alarm notification title = custom title name; body default localized.

## 6b. Search & favourites integration

Original favourites live in `data.db` as bare ids that are resolved against the original DB, so custom ids must **not** go there (collision). Custom favourite flags live in `custom_azkar.db` (`is_favourite` columns), so they're backed up with it.

- **Favourites (titles tab)**: below original favourite titles, show favourite custom titles (reuse the custom title card). Empty state only when both are empty.
- **Favourites (zikr tab)**: same pattern — favourite custom zikrs listed after original ones with a dedicated stateless card (original card assumes `state.titles.where(...).first`, which would throw for custom ids).
- **Search**: `SearchCubit` additionally queries `custom_azkar.db` (LIKE on name for titles, on content for zikrs; same `SearchType` semantics as far as practical). Custom matches go on the **first page** ahead of original matches; later pages compute the original offset as `pageKey - customCountOnFirstPage`. Result count = custom + original. Custom results use a `CustomTitleCard` / a custom-zikr search card that opens `ZikrViewerScreen(source: CustomTitle(id))`. Search UI items become a small sealed union (original | custom) rather than `DbTitle`/`DbContent` only.
- Custom zikr that is only in the library (not linked to any title) is still searchable; tapping it opens a single-zikr read dialog/preview.

## 7. Backup & restore

- Add `CustomAzkarDBHelper` to `BackupRestoreRepo` constructor, `_getDbPaths()`, and the "close all connections" block in `importData()`; update the DI registration of `BackupRestoreRepo`.
- Restore matches files by `basename`, so `custom_azkar.db` is picked up automatically once it's in `_getDbPaths()`.
- Old backups without the file restore fine (file simply absent → DB created empty on next open). Verify that a stale open connection isn't reused after restore (the existing flow closes connections then restarts the app).
- Any new GetStorage prefs (none planned) are already exported via `preferences.json`.

## 8. Phases (one commit each, on `feature/custom-azkar-tab`)

0. **Plan**: this document updated (commit).
1. **Data + domain**: DB helper, models, entities, repo interface/impl, use cases, unit tests (sqflite_common_ffi in-memory: CRUD, cascade delete, reorder, snapshot fallback, search, favourites).
2. **Localization + DI + home tab + list screen**: ARB strings, blocs registered, `CustomTitlesScreen`, empty state, create-from-scratch.
3. **Editor + zikr library + create-from-existing**: `ReorderableListView`, count stepper, add-zikr sheet (new / library / from Hisn al-Muslim).
4. **Viewer integration**: `ZikrSource`, provider abstraction, negative ids, session keys. Regression-check original titles.
5. **Alarms & routing**: `custom_alarms`, scheduling, `custom:` payload, cold-start.
6. **Favourites + global search** (§6b).
7. **Backup/restore** wiring.
8. Polish: undo, a11y, RTL/dark, `flutter analyze`, `CHANGELOG.md`.

## 9. Verification checklist

- Original `hisn_elmoslem.db` byte-identical after using the feature (only read paths touch it).
- Original title viewer, sessions, bookmarks, existing alarms behave unchanged.
- Custom notification tap: app foreground, background, and killed → opens correct title/item.
- Backup → restore on a fresh install reproduces titles, items, order, counts, alarms.
- Arabic + English, RTL layout, light/dark, phone and Windows window sizes.
- No test directory exists today; add `test/` for domain/data layers (and `bloc_test` for blocs if added as a dev dependency).

## 10. Open questions

None outstanding — resolved above.

## 11. Implementation notes (as built, branch `feature/custom-azkar-tab`)

Deviations / decisions made while implementing:

- **Viewer ids**: custom titles open with title id `-customTitleId` and every item gets content id `-itemId` (unique per row, so the same original zikr added twice counts independently). `DbContent.customZikrId` marks zikrs the user authored. Helpers live in `zikr_viewer/data/models/custom_title_source.dart`.
- **Not available for original zikrs inside a custom title** (they need the real original id): commentary, report and zikr-favourite buttons are hidden. Custom zikrs can be favourited; custom titles have a title bookmark.
- **Search**: custom matches are prepended to the first page of results (all of them at once); later pages subtract that count from the original-DB offset.
- **Alarms**: one per title, notification id `1_000_000 + titleId`, payload `custom:<titleId>`; rescheduled in `AlarmManager.checkAllAlarmsInDb` and on `CustomTitlesRefreshEvent`; stale custom notifications are cancelled.
- **Dashboard order**: `AppSettingsRepo.getDashboardArrangement(tabsCount)` now normalizes the saved order, otherwise existing users (saved order `0,1,2`) would crash with a 4th tab.
- **Tests**: `test/features/custom_azkar/` — repository (sqflite ffi, in-memory), backup file round trip, alarm payloads, and widget tests for the editor screen.
- **Not verified here**: no manual run on a device/emulator (notification delivery, tap-to-open from a killed app, real backup/restore through the file picker, RTL visual check). Those still need a hands-on pass.

### Voice recordings

- **Where**: the recording belongs to a title *item* (`custom_title_items.audio_file`, db v3), so it works for custom zikrs and as an override for linked original zikrs. Only the file name is stored; files live in `<app documents>/custom_audio/` (`CustomAudioStorage`). Playback order: user recording, else the original's bundled audio.
- **Editor drafts**: saving a title replaces its item rows, so the file name travels on the draft item. Takes made in an open editor are pinned (`CustomAudioStorage.pin`) so cleanup triggered elsewhere (e.g. deleting a library zikr) cannot remove them, and are deleted if the editor is left without saving. Replaced or removed recordings that were already saved stay on disk until the title is saved.
- **Cleanup**: `CustomAzkarRepoImpl` deletes recordings no item references after `updateTitle`, `deleteTitle`, `deleteZikr` and `setItemAudio`.
- **Recording**: `record` package (AAC, mono, 22.05 kHz, 64 kbps), max 3 minutes, stops when the app goes to the background. `ZikrRecorderCubit` + `RecordAudioSheet` (record, listen, use / record again, delete existing, play the original recitation). The sheet cannot be dismissed by swipe so a take is not lost by accident; closing asks first.
- **Entry point**: the "Record my voice" chip on each row of the title editor. There is no recording entry in the viewer yet (item ids change when a title is saved, so recording there would need its own save path).
- **Permissions**: Android `RECORD_AUDIO`, iOS `NSMicrophoneUsageDescription` (English text only in `Info.plist`).
- **Backup**: `CustomAudioBackup` adds the files under `custom_audio/` in the `.hisn` archive; restoring a backup that contains the custom database replaces the device's recordings. A missing file falls back to the original audio.
- **Not verified here**: microphone permission flow, recording and playback on a real device (Android, iOS, Windows), and an interrupted recording (call, background).
