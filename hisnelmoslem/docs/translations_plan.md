# Zikr translations and transliteration: plan

Status: plan only. Branch `feature/translations`. References: `custom_azkar_plan.md`, `remote_audio_plan.md`, `binwahaf_sync_report.md`, `tools/binwahaf_match.py`.

## 0. Scope update (owner decision)

- **v1 ships English and French only.** Source: a local source database (path passed with `AZKAR_DB`) (tables `HSN_En`, `HSN_Fr`, `HSN_Categories_En/Fr`; `ZekarID` equals the hisnmuslim.com item id, so it matches the app's data through the book's hadith numbers). Its odd design is ignored: each translated zikr is one blob wrapped in `<1>...</1>` mixing transliteration and meaning (English: transliteration first; French: meaning first), so the import splits the blob per language.
- No scraping of other languages, no hisnmuslim JSON needed beyond a cross-check. Other languages are phase 2.
- Defaults chosen: switches on for non-Arabic devices and off for Arabic; partial matches shown with a note; transliteration kept as published; no fadl in v1.
- Arabic UI users can still pick English or French in settings.

## 1. Requirements and decisions

| Requirement | Decision |
|---|---|
| Arabic always shown | Translation blocks are added below the Arabic, never replace it. |
| Meaning and transliteration, each switchable | Settings `translation_show_meaning`, `translation_show_translit`. |
| Fallback user language -> English -> hide | Applied per field. A transliteration that exists only in English is shown with an "EN" badge. |
| Titles, body, ideally fadl | Titles and body in v1. The `fadl` column exists but stays empty (no source data). |
| About 10 popular languages | Ship every language that passes the quality checks (section 7). French and ur/tr/ms/ru come from a second source in phase 2. |
| Do not touch `hisn_elmoslem.db` | New read-only bundled `assets/db/translations.db`, keyed by the app's content and title ids. |
| Offline | Bundled, no download packs (small, see section 4). |

**User language.** The UI is only ar/en, so the translation language has its own setting `translation_lang` = `auto` or a code. `auto` resolves to: device language if available, else the app language if not `ar`, else `en`. Meaning and transliteration default to on when the resolved language is not Arabic (open decision).

## 2. Data source facts (verified)

- hisnmuslim.com JSON exists only for **ar and en** (`api/husn.json`). `api/<lang>/...` is 404 for every other language, including French.
- Fields: `ID`, `ARABIC_TEXT`, `LANGUAGE_ARABIC_TRANSLATED_TEXT`, `TRANSLATED_TEXT`, `REPEAT`, `AUDIO`. The top-level key of a chapter file is the chapter title in that language.
- Files start with a BOM and contain raw control characters: read with `utf-8-sig`, `strict=False`. `en/126.json` is malformed.
- The 13 other languages (bn, bs, es, fa, ha, hi, id, pt, so, sw, th, yo, zh) are HTML pages at `/i/<code>/<n>`: transliteration and translation, no Arabic or repeat count. They must be scraped and aligned to English by (chapter, position). The Indonesian table of contents has 133 entries.
- Site item `ID` = the book's hadith number = the number at the start of each binwahaf lesson title. `tools/binwahaf_out/match.json` already links 330 of 335 zikrs, so it is a second, independent matcher.
- `LANGUAGE_ARABIC_TRANSLATED_TEXT` holds either a transliteration ("Asbahna wa-asbahal-mulku...") or an instruction ("Recite Ayat-Al-Kursiy"). It must be classified.
- No fadl, source or hokm in the data. Index entries 86 and 87 point to the same file.
- English coverage from the download: 264 of 266 items have a translation, about 190 have a transliteration, 36 are instructions.

## 3. Matching strategy (`tools/`)

- **Shared module** `tools/hisn_text.py`: move `norm()` and `expand_quran_all()` out of `binwahaf_match.py` (it runs `main()` on import). The old script imports the module.
- **Stage A, site master list:** join ar and en by `ID`; other languages attach by (chapter, position); a chapter with a different item count is flagged and skipped for that language.
- **Stage B, chapter to title:** normalised Arabic title similarity with forward-only order; manual cases: app titles 1 and 2 have no site chapter, site chapter 27 maps to titles 29 and 30, chapters 86/87 share a file. Cross-check with `binwahaf_out/title_chapter.json`.
- **Stage C, item to content, two signals:** (1) text matcher with the same ratio, containment and kinds as `binwahaf_match.py`; (2) number matcher via binwahaf lesson number. High confidence = both agree. Others go to a review list. Manual decisions live in the committed `tools/translations_overrides.json`.
- **Coverage kinds:** `exact`, `near`, `combined` (app zikr spans several site items), `partial` (app zikr is a piece of a site item).
- **Morning/evening:** evening zikrs (title 30) matched to a morning text are listed, not auto-accepted.
- **Classifier** for `LANGUAGE_ARABIC_TRANSLATED_TEXT`: instruction (starts with Recite/Then/Say..., high stopword ratio) vs transliteration (romanisation markers, token count near the Arabic word count). Uncertain items go to the report. Instructions are stored as `note`, transliterations as `translit`.
- **Validation** in `docs/translations_match_report.md`: counts by kind and confidence, the full review list, per-language coverage. Hard checks that stop the build: ids exist in `hisn_elmoslem.db`; each language has at least 90% of English coverage or is dropped; script check per language; no HTML entities, control characters or leftover `( n )` markers. Soft check: `REPEAT` vs `contents.count`. Human check: 30 random English pairs by the owner, 10 per language by a reader of it.

### Gap filling (after the match)

Goal: every recited zikr has a meaning and a complete transliteration in en and fr. `tools/translations_fill.py` classifies contents (skip: titles 1-2, Quran passages over 100 words, texts over 150 words; not recited: narrations and instructions, which need a meaning or note only; recited: the rest, Ayat al-Kursi and the Quls included) and lists the gaps. Fills live in `tools/translations_filled.json`, one entry per field with `method` = `source` (local data: hisnmuslim files, another row of the same Arabic, a mis-split field), `rule` (`tools/translations_translit.py` on the vowelled Arabic, with vowelled `recite` overrides where the app text lacks vowels) or `drafted` (short well-known zikrs). The build applies them, fails on any remaining gap, and lists rule and drafted fields under "Needs owner review" in the report. No schema change.

## 4. Schema and size: `assets/db/translations.db`

```sql
CREATE TABLE languages(code TEXT PRIMARY KEY, name_native TEXT NOT NULL, name_en TEXT NOT NULL,
  is_rtl INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL, source TEXT NOT NULL,
  source_url TEXT, has_meaning INTEGER NOT NULL, has_translit INTEGER NOT NULL);
CREATE TABLE title_translations(title_id INTEGER NOT NULL, lang TEXT NOT NULL, name TEXT NOT NULL,
  PRIMARY KEY(title_id, lang)) WITHOUT ROWID;
CREATE TABLE content_translations(content_id INTEGER NOT NULL, lang TEXT NOT NULL,
  meaning TEXT, translit TEXT, note TEXT, fadl TEXT,
  coverage TEXT NOT NULL DEFAULT 'exact',  -- exact|near|combined|partial
  PRIMARY KEY(content_id, lang)) WITHOUT ROWID;
PRAGMA user_version = 1;  -- must equal TranslationsDBHelper.dbVersion
```

- Estimated size: English about 110 KB; all 15 languages about 2.5 to 3.5 MB raw, about 1 MB in the APK (`commentary.db` is 5.6 MB). The build script prints the real size.
- Fallback: if compressed size grows by more than 3 MB, switch to bundled English plus downloadable packs reusing the reciter_audio downloader.
- Uses the existing `DBHelper` pattern (copy from assets, recopy when `user_version` is lower).
- `tools/translations_raw/` is gitignored. Committed: scripts, overrides, the database, the report.

## 5. App layers: `lib/src/features/translations/`

```
domain/  translation_language.dart, zikr_translation.dart, translation_resolver.dart (pure)
data/    translations_db_helper.dart, translations_repo.dart, translation_settings_repo.dart (GetStorage)
presentation/
  controller/translations_cubit.dart   lazy singleton; loads chosen language + en into maps
  components/zikr_translation_block.dart, title_translation_text.dart, translation_language_sheet.dart
```

- Widgets read the in-memory maps synchronously. The cubit is separate from `SettingsCubit`. Register everything in `initSL()`.
- **Custom azkar:** original zikrs inside a custom title have id `-itemId`. Add `int? originalContentId` to `DbContent` (from `refId` for `kind=original`) and a getter `translationKey`. The user's own zikrs have no translation.

## 6. UI

- **Viewer** (`zikr_viewer_zikr_body.dart`, covers card, page and bookmark modes): below the Arabic, above the fadl: optional `note` caption, transliteration (always LTR, italic, secondary colour), meaning (direction from `is_rtl`), a language badge on fallback, a hint for `partial`.
- Do not inherit the Arabic font for Latin text. Check Bengali, Hindi, Thai and Chinese fall back to system fonts on Android and Windows. Colours from the theme only; check light and dark.
- **Titles:** subtitle in `title_card.dart` (when `translation_show_titles`), second line in the viewer app bar.
- **Settings:** a "Translation" section after font settings: language sheet (`TranslationLanguageSheet.show`, with bottom `SafeArea`), switches for meaning, transliteration, titles.
- **Share as text:** checkboxes include meaning / transliteration. **Share as image:** `showMeaning`, `showTranslit` (default off), LTR block, only on the last image when split. Riskiest UI change, so last in the branch.
- No change to notifications. No search in translations in v1.

## 7. Language selection

Ship a language when: (a) meaning for at least 90% of English-covered items and matching passes; (b) its script renders without a bundled font; (c) the source is allowed or credited. Order by Muslim speakers and the app's Play Console countries.

- From hisnmuslim: en, id, bn, fa, hi, es, pt, zh, sw, ha, so, bs, th, yo.
- Phase 2, other source: fr (owner request), ur, tr, ms, ru. fa and ur are RTL.

## 8. Backup, credits, changelog

- `translations.db` is bundled and read-only, so not in the backup. New GetStorage keys are already exported; an unknown restored language falls back through the resolver (test it).
- About screen credit card "Translations: hisnmuslim.com", language sheet shows the source, Arabic entry in `../CHANGELOG.md`, a line in what's new if released with custom azkar.
- Every string in `en.arb` and `ar.arb`, then `fvm flutter gen-l10n`. Language names come from the `languages` table.

## 9. Tasks and models

| # | Task | Depends on | Model |
|---|---|---|---|
| T1 | Finish raw data: repair en/126, scraper for the 13 HTML languages, coverage report (ar/en done) | none | sonnet (scraper), haiku (re-runs) |
| T2 | `hisn_text.py` refactor and `translations_match.py` (stages A to C, overrides) | T1 ar/en | opus |
| T3 | `translations_clean.py`: classifier, noise cleaning, script checks | T1 | sonnet, opus reviews uncertain list |
| T4 | `translations_build.py`: database, report, hard checks, size printout | T2, T3 | sonnet |
| T5 | Manual review (morning/evening, partial, review lists) into overrides | T4 | opus with the owner |
| T6 | Domain and data layer, resolver, DB helper, repos, fixture-DB tests | contract only | sonnet |
| T7 | DI, cubit, settings section, language sheet, l10n | T6 | sonnet |
| T8 | Viewer block, title subtitles, `originalContentId`, RTL and dark mode | T6 | sonnet |
| T9 | Share as text and as image | T7 | sonnet |
| T10 | Credits card, changelog, what's new, gitignore | T4 | haiku |
| T11 | Integrity test on the real db, fallback/restore/RTL widget tests | T4, T8 | sonnet |
| T12 | Device check (languages, fa RTL, Thai/Hindi glyphs, dark mode, share image, Windows) | all | sonnet |
| T13 | Phase 2 spike: French (IslamHouse), ur, tr, ms, ru: licence, format, adapter | none | opus (research), sonnet (adapter) |

One commit per task. After each Dart task: `dart fix --apply --code=directives_ordering`, `dart format lib test`, `flutter analyze lib test`.

## 10. Verification checklist

- [ ] `hisn_elmoslem.db` byte-identical; an Arabic device with default settings looks unchanged.
- [ ] English and Indonesian devices show their meaning and transliteration; EN badge only when a field is missing.
- [ ] Persian meaning RTL, transliteration LTR.
- [ ] Evening zikrs never show a "morning" meaning.
- [ ] Original zikrs in a custom title show a translation; custom zikrs show none.
- [ ] Backup/restore keeps settings; an unknown language falls back.
- [ ] APK size difference noted in the PR.

## 11. Open decisions

1. Permission and credit from hisnmuslim.com (owner says it is free for everyone); credit translators if listed.
2. Default switches: on for non-Arabic devices and off for Arabic, or always off until enabled?
3. Fadl translation: skip in v1, or find a source (IslamHouse PDFs need manual extraction)? No machine translation of religious text without a reviewer.
4. Partial matches: show the full translation with a note, or hide?
5. Evening zikrs with only the morning wording: hand-edit English and hide others, or hide everywhere?
6. Transliteration style: keep the published "AA" style or normalise?
7. Phase 2 languages and source; is French required for v1?
8. Bundle everything (about 1 MB) or download packs.
9. Search in translations and translated alarm text: later?
