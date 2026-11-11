# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Hisn Elmoslem — an Arabic/English Flutter app (Android, iOS, Windows) with the book of Islamic supplications. The Flutter project lives in `hisnelmoslem/` inside the repo root (which also holds `CHANGELOG.md`, `fastlane/`, `distribution/`). Run all commands from `hisnelmoslem/`.

## Commands

Flutter version is pinned via FVM (`.fvmrc`, currently 3.44.8); prefer `fvm flutter ...` / `fvm dart ...`.

- Install deps: `fvm flutter pub get`
- Run: `fvm flutter run --flavor dev` (flavors: `dev`, `prod`; Android flavors are defined in `android/app/build.gradle`). Windows has no flavor.
- Analyze: `fvm flutter analyze` (strict `package:lint/strict.yaml`; excludes `*.g.dart`, `*.freezed.dart`, `lib/generated/**`, `packages/**`)
- Format: `fvm dart format .` (page width 100, trailing commas preserved)
- Release build: `fvm flutter build apk|appbundle --flavor prod`; releases are CI-driven by pushing a `v*.*.*` tag (see `../WORKFLOW_GUIDE.md`).
- Test: `fvm flutter test` (single file: `fvm flutter test test/features/custom_azkar/custom_audio_test.dart`). Tests live in `test/features/<feature>/`. After editing code run `fvm dart fix --apply --code=directives_ordering`, `fvm dart format lib test` and `fvm flutter analyze lib test`; keep analyze clean.

### Testing notes
- sqflite code is tested with `sqflite_common_ffi` and `inMemoryDatabasePath`; widget tests that touch sqflite or files need `tester.runAsync` (real async) and, for multi-step file IO, a `settle` helper that alternates real delays and pumps.
- Platform plugins (audioplayers, record) cannot run in unit tests: put them behind a small interface (see `AudioRecorderService`, `AudioPreviewPlayer`) or inject a fake (`ZikrAudioPlayerCubit(repo, player: fake)`).
- Tests cannot judge sound, vibration or layout. Check those on a device (below).

### Checking on a device
`adb` is installed and the owner's phone is usually connected (wireless, so the same phone can be listed twice: use one serial with `-s`). `fvm flutter devices` / `adb devices` show it. The dev build's package is `com.hassaneltantawy.hisnelmoslem.dev`.
- Install and run: `fvm flutter run --flavor dev -d <serial>` (use the `run` skill, or run in the background and read its output).
- Screenshot to the scratchpad and look at it with the Read tool: `adb -s <serial> exec-out screencap -p > "<scratchpad>/screen.png"`. Do this after a UI change instead of guessing how it looks; the image is 1080x2340 and is shown scaled.
- Logs: `adb -s <serial> logcat -d | grep -i -E "flutter|hisnelmoslem"` (app errors also print via `hisnPrint`).
- Focused screen: `adb -s <serial> shell dumpsys window | grep mCurrentFocus`.
- Taps and text: `adb -s <serial> shell input tap <x> <y>` / `input swipe` / `input text`. Coordinates are in device pixels.
- Never leave test data on the owner's phone beyond what the check needs, and say clearly what could not be checked (audio, vibration, notifications from a killed app).

### Conventions
- Every user-visible string goes through localization: add keys to both `en.arb` and `ar.arb`, then `fvm flutter gen-l10n`.
- Prefer small stateless widget classes over `_buildX` helper methods.
- Dialogs, sheets and pickers expose `static Future<T?> show(BuildContext, ...)` on the widget class (no top-level `showXxx` functions).
- New features: clean architecture, feature-first (`domain/`, `data/`, `presentation/`), `flutter_bloc`, registered in `initSL()`. Match the app theme; support RTL and dark mode.
- Bottom sheets that use `useSafeArea: true` still need a bottom `SafeArea` (it only covers the top).

### Localization
ARB files are `lib/l10n/en.arb` (template) and `ar.arb`. Generated class `S` goes to `lib/generated/lang/` (committed, analyzer-excluded). Regenerate with `fvm flutter gen-l10n` after editing ARBs. Outside widgets, strings are accessed via the `SX` helper (`core/extensions/localization_extesion.dart`), initialised in `loadLocalizations()`.

## Architecture

Feature-first layout under `lib/src/`: `core/` (shared extensions, utils, widgets, constants, DI) and `features/<name>/` (home, zikr_viewer, alarms_manager, tally, bookmark, quran, settings, themes, backup_restore, share_as_image, zikr_audio_player, etc.). Each feature generally splits into `data/` (models, repository, DB helpers) and `presentation/` (controller, screens, components).

- **Startup**: `main.dart` → `initServices()` (`init_services.dart`) → `runApp(RestartWidget(App))`. `initServices` sets up the BLoC observer, the service locator, localization, orientation/system bars, sqflite FFI on desktop/web, `GetStorage`, local notifications, and the desktop window manager. `RestartWidget` allows an in-app restart (used by backup/restore).
- **Dependency injection**: single `get_it` instance `sl` in `core/di/dependency_injection.dart`. All repos, DB helpers, and blocs/cubits are registered there — new features must be registered in `initSL()`. Repos are lazy singletons wrapping `GetStorage` (key `kAppStorageKey`); screens obtain state via `sl<...>()` with `flutter_bloc`.
- **State management**: `flutter_bloc` (Bloc/Cubit) in each feature's `presentation/controller/`.
- **Persistence**: two kinds — `GetStorage` key/value for settings/preferences (via `*Repo` classes), and sqflite databases (`*_database_helper.dart` / `*_db_helper.dart`, bundled DBs under `assets/db`) for azkar content, commentary, alarms, tally, fake hadith. Desktop uses `sqflite_common_ffi`.
- **Custom azkar** (`features/custom_azkar`, plan and as-built notes in `docs/custom_azkar_plan.md`): the user's own titles and zikrs, stored in a separate `custom_azkar.db` (the bundled `hisn_elmoslem.db` is never written). The zikr viewer shows them through the normal `ZikrViewerBloc` with negative ids: viewer title id `-(customId+1)` (`-1` is the fake-hadith screen), content id `-itemId`; helpers in `zikr_viewer/data/models/custom_title_source.dart`. Notification payload `custom:<titleId>`, id `1_000_000 + titleId`. Voice recordings are files in `<documents>/custom_audio/`, referenced by name from `custom_title_items.audio_file`, included in backups, and cleaned up by the repo when no item references them.
- **Sound and vibration**: `EffectsManager` (tap/zikr/title effects) and `ZikrAudioPlayerCubit` (recited audio) are independent and each owns its player; do not make one read the other's state. Do not use `PlayerMode.lowLatency` for effects: on Android `play()` never completes and every later sound times out. One effect plays per tap (`pickEffectTier`).
- **Platform branching**: use `PlatformExtension` (`core/extensions/extension_platform.dart`) (`isDesktop`, `isDesktopOrWeb`, ...) rather than ad-hoc `Platform` checks.
- **Local package**: `packages/capture_widget` (path dependency, used for share-as-image); excluded from analysis.
- `tools/` contains Python helpers for audio files/compression, not part of the build.
