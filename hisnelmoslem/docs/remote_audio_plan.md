# Implementation Plan: Remote azkar audio (reciters, streaming, downloads)

Status: plan only, nothing of the app code is written yet. Data is already in the bundled DB
(`contents.audio_urls`, commit 75813ec5). Source of the audio: binwahaf.com (see
`docs/binwahaf_sync_report.md`).

## 1. Requirements → decisions

| Requirement | Decision |
|---|---|
| Play a zikr from the internet when it has no bundled file | Stream from `audio_urls[reciter]` |
| Choose the reciter | New setting `audioReciter` (default `hamad_alduraihem`, the reciter of the bundled files) |
| **Download a whole reciter** | Download manager, one job per reciter, resumable, cancellable |
| **Download a whole title** (e.g. morning azkar) | Same manager, job scope = one title for the selected reciter |
| Work offline after a download | Playback order below, files stored in the app documents folder |
| Keep the owner's trimmed bundled audio | Bundled file always wins over anything remote |
| Do not break custom azkar recordings | User recording stays first in the order |

### Source priority when a zikr is played
1. user recording (`userAudioPath`, custom azkar)
2. bundled asset `assets/sounds/azkar/<audio>` (owner's trimmed files, reciter 1 only)
3. downloaded file for the selected reciter
4. stream `audio_urls[reciter]` (only when online and the zikr is not excluded, see 2)
5. no audio: narration ends cleanly as today (existing behaviour)

When the selected reciter is not the bundled one, step 2 is skipped for the zikrs that have a remote
file, so the whole session uses one voice.

## 2. Zikrs that must not stream or download (data caveats)

- **Evening zikrs whose recording says the morning wording**: 119, 122, 123, 131 (the site has one
  recording for morning and evening). Only 132 and 120 have correct local `_m` files. Until they are
  re-recorded, evening playback of these uses the bundled file only, and no remote file is offered.
  Keep this list as data (`audio_blocklist` in the DB or a const), not scattered in code.
- **Split zikrs**: the site has one lesson, the app has two zikrs. Both URLs point at the full
  lesson recording, so streaming would play the other half too. Mark them (`audio_urls` value stays,
  add `audio_exact = 0`) and skip them in remote playback and in downloads. The 13 "فضل الذكر"
  items share one long recording: treat as one entry, not 13.
- Remote files are not trimmed (leading silence, longer pauses). The existing delay between azkar
  setting already covers most of it; an optional "skip silence" is out of scope.

## 3. Data layer

DB (`hisn_elmoslem.db`, already shipped):
- `contents.audio_urls` TEXT JSON `{reciterSlug: url | [url,...]}`. A list means one zikr spans several
  lessons: play them in order.
- New in the next DB version: `audio_exact INTEGER DEFAULT 1` (0 = split or shared lesson) and the
  blocklist above.
- Reciters are a const list in code (`hamad_alduraihem`, `sulaiman_alshuwaihi`, `rashid_alhulaibah`
  with Arabic and English names). The intro lesson only has the last two.

Files:
- Folder `<documents>/reciter_audio/<reciterSlug>/<lessonId>.mp3`. The key is the lesson id taken
  from the URL file name, so zikrs that share a lesson share the file (about 262 files per reciter,
  not 335).
- Download to `<name>.part`, rename when complete; resume with HTTP `Range` (the CDN answers
  `Accept-Ranges: bytes`).
- Size: files are about 100-450 KB each, so roughly 60-100 MB per reciter. Read `Content-Length`
  with HEAD before starting and show the real total in the confirm dialog.
- The downloaded folder is **not** part of backup/restore (re-downloadable), unlike custom
  recordings. Restore must not delete it.

## 4. Feature layout (`lib/src/features/reciter_audio/`)

```
domain/    reciter.dart, audio_source_resolver.dart (the priority list), download_scope.dart
data/      reciter_audio_repo.dart (settings via GetStorage), audio_file_store.dart (paths, sizes, delete),
           audio_downloader.dart (interface) + http_audio_downloader.dart (Range, retry, progress)
presentation/
  controller/ reciter_downloads_cubit.dart   (jobs: queued, running, paused, failed, done; progress)
  components/ reciter_picker_sheet.dart, download_reciter_tile.dart, download_title_button.dart
```

- Register everything in `initSL()`; the cubit is a lazy singleton so a download keeps running while
  the user leaves the screen.
- Dependencies: `http` only (added; it was already a transitive dependency; `dio` adds nothing this
  needs). **No `connectivity_plus`**: it is unreliable on VPN and Windows, so the app does not try to
  tell Wi-Fi from mobile data. "Offline" is detected from real request failures instead.
  `path_provider` is already there.
- `ZikrAudioPlayerCubit` gets an injected `AudioSourceResolver` and asks it for the `Source`
  (`DeviceFileSource`, `AssetSource` or `UrlSource`). It does not learn about downloads or the
  network itself. Sound effects (`EffectsManager`) stay independent as today.
- A background service or progress notification is **out of scope for v1**:
  v1 runs while the app is open and resumes on the next open.

## 5. UX

- **Audio settings sheet** (existing `zikr_audio_settings_dialog.dart`): a "Reciter" row opening the
  picker. Each reciter row shows: name, downloaded status (none / partial n% / complete), size, and a
  download or delete action.
- **Download a whole reciter**: confirm dialog that shows the total size and
  warns it may use mobile data (no network-type detection, see section 4), then a progress row with pause and cancel. Finishing shows a snackbar. Failed files
  are retried 3 times, then listed ("12 files failed, retry").
- **Download a whole title**: button in the zikr actions sheet and in the title card menu
  ("Download audio for this title"), for the selected reciter. Shows `n/total` and is greyed out when
  every file of the title is already local.
- A small cloud/offline icon on the audio dock when the current zikr is streaming; if offline and not
  downloaded, show "audio not available offline" once, then continue silently to the next zikr (same
  as a zikr without audio).
- Strings in `en.arb` and `ar.arb`, static `show` methods on sheets and dialogs, RTL and dark mode
  checked, bottom `SafeArea` on sheets (project conventions).
- Deleting a reciter's files asks for confirmation and frees the space immediately.

## 6. Phases (one commit each)

1. Domain + data: reciters, resolver, file store, repo and settings, unit tests (resolver priority,
   blocklist, split zikrs, lesson-id keys).
2. HTTP downloader with Range resume, retry, `.part` handling; tests with `MockClient`. **Done.**
3. `ZikrAudioPlayerCubit` uses the resolver (stream + downloaded files), test with the existing fake
   player, check `hasPlayableAudio` and the tally voice session still work.
4. `ReciterDownloadsCubit` (scopes: reciter, title), queue, progress, cancel, persistence across
   app restarts (resume list in `GetStorage`).
5. UI: picker, download tiles, title button, offline hints, l10n.
6. DB version bump (`audio_exact`, blocklist), changelog, whats-new text, device check (airplane mode,
   kill during a download).

## 7. Verification checklist

- [ ] Bundled file still wins for reciter 1; a user recording still wins over everything.
- [ ] Streaming works for a zikr without a bundled file; the blocked and split zikrs never stream.
- [ ] Killing the app during a download and reopening resumes from the `.part` size.
- [ ] Airplane mode: downloaded zikrs play, others are skipped without stalling the session.
- [ ] The confirm dialog shows the real size and nothing downloads before the user accepts.
- [ ] Download whole title: only that title's files, shared lessons are not downloaded twice.
- [ ] Delete reciter frees the folder; backup/restore leaves downloads alone.
- [ ] Low storage: the download stops with a clear message, nothing half-written is left as `.mp3`.
- [ ] `fvm flutter analyze lib test` clean, tests pass; layout and RTL checked on the phone.

## 8. Open questions

- **Permission and attribution**: the audio belongs to binwahaf.com. Ask the site owner for
  permission to stream and to let users download it, agree on credit text in the app, and decide
  whether to hotlink their CDN or mirror the files.
- Default reciter for new installs (bundled one, so nothing changes for existing users)?
- Re-record the evening zikrs (119, 122, 123, 131) with the bundled reciter, or accept the blocklist?
- Allow mixing: bundled voice where available and another reciter elsewhere? (plan says no)
- Cap on parallel downloads (suggested 3) and whether to continue in the background in a later version.

## 9. As built: download center (phase 5 revised)

- **Settings > Download center** (`DownloadCenterScreen`): the three reciters with what is on the
  phone, the current reciter marked, and the "play online" switch. Also opened from the audio
  settings sheet and from the pill below.
- **Reciter screen** (`ReciterTitlesScreen`): header with "use this reciter", download all and delete
  all; below it every title that has recordings, each with a download button (not yet complete) and a
  delete button (anything on the phone). A running title shows a progress ring that pauses.
  Titles that share a lesson (morning and evening azkar) share its files, so deleting one affects
  the other.
- **Download pill** (`DownloadActivityPill`, in `MaterialApp.builder`): floats above every screen
  while a download runs or is paused, shows files done of total with pause or resume, opens the
  center when tapped, reports the end and stays when files failed (retry).
- **Streaming**: the dock shows a progress bar and a spinner on the play button while a recording
  from the internet loads (`ZikrAudioPlayerState.isLoadingAudio`).
- **About** has a card saying the reciters and recordings come from binwahaf.com.
