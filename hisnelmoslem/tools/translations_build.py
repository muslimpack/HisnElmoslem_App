#!/usr/bin/env python3
"""Build assets/db/translations.db (English and French) and docs/translations_match_report.md.

Inputs: tools/translations_out/match.json and titles.json (translations_match.py),
        tools/translations_out/split.json (translations_split.py).
Keys are the app's own ids from assets/db/hisn_elmoslem.db (never written).
Hard checks stop the build: every id exists in hisn_elmoslem.db; no leftover tags, entities,
control characters or footnote markers; French has Latin letters; English has no Arabic letters.

Usage: python -I -X utf8 tools/translations_build.py [--out assets/db/translations.db] [--report docs/translations_match_report.md]
Run translations_match.py and translations_split.py first (or pass --all to run them).
"""
import argparse, collections, json, os, re, shutil, sqlite3, subprocess, sys, zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from translations_match import ro, MORNING_TITLE, EVENING_TITLE  # noqa: E402
from translations_split import RECITE  # noqa: E402
import translations_fill as fill  # noqa: E402

WORK = Path('tools/translations_out')
SCHEMA = '''
CREATE TABLE languages(code TEXT PRIMARY KEY, name_native TEXT NOT NULL, name_en TEXT NOT NULL, is_rtl INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL, source TEXT NOT NULL, source_url TEXT, has_meaning INTEGER NOT NULL, has_translit INTEGER NOT NULL);
CREATE TABLE title_translations(title_id INTEGER NOT NULL, lang TEXT NOT NULL, name TEXT NOT NULL, PRIMARY KEY(title_id, lang)) WITHOUT ROWID;
CREATE TABLE content_translations(content_id INTEGER NOT NULL, lang TEXT NOT NULL, meaning TEXT, translit TEXT, note TEXT, fadl TEXT, coverage TEXT NOT NULL DEFAULT 'exact', PRIMARY KEY(content_id, lang)) WITHOUT ROWID;
PRAGMA user_version = 1;
'''
LANGS = [
    # code, native, english, rtl, sort, source, url
    ('en', 'English', 'English', 0, 1, 'hisnmuslim.com', 'https://www.hisnmuslim.com'),
    ('fr', 'Français', 'French', 0, 2, 'hisnmuslim.com', 'https://www.hisnmuslim.com'),
]
COVERAGE = ('exact', 'near', 'combined', 'partial')
EVENING_GENERIC_FR = re.compile(r'ou (au|de ce|le|ce) soir', re.I)
ARABIC = re.compile('[؀-ۿ\u0750-\u077f\ufb50-\ufdff\ufe70-\ufeff]')
LATIN = re.compile('[A-Za-zÀ-ſ]')
BAD = [('tag', re.compile(r'<[^>]*>|[<>]')), ('entity', re.compile(r'&[a-zA-Z]+;|&#\d+;')),
       ('control', re.compile('[\x00-\x09\x0b-\x1f\x7f\u200b-\u200f\u202a-\u202e\ufeff]')),
       ('private use', re.compile('[\ue000-\uf8ff]')), ('footnote marker', re.compile(r'\(\s*\d{1,2}\s*\)\s*[.,]?\s*$|\[\s*\d{1,2}\s*\]', re.M)),
       ('double space', re.compile(r'  |\n\n\n|^\s|\s$'))]


def text_of(lines):
    t = '\n'.join(l.strip() for l in lines if l and l.strip())
    return t or None


def is_quran_only(content):
    """The app zikr is Quran verses with at most a few words around them."""
    rest = re.sub(r'QuranText\[[^\]]*\]|\ufd3f[^\ufd3e]*\ufd3e|\{[^}]*\}', ' ', content or '')
    return rest != (content or '') and len(re.findall(r'[ء-ي]{2,}', rest)) < 5


def pick_lang(rows, lang, split, tid, coverage, evening_rescue=False, quran_only=False):
    """Compose meaning/translit/note for one content from its the source DB zikrs. Returns (row, why) or (None, why).
    An item that only says to recite verses becomes a note when the app zikr is the verses themselves."""
    want = 'morning' if tid == MORNING_TITLE else 'evening' if tid == EVENING_TITLE else None
    meaning, translit, note, cov = [], [], [], coverage
    for z in rows:
        r = split.get(str(z))
        if r is None:
            return None, f'no {lang} item for the source DB {z}'
        tl, mn = r['translit'], r['meaning']
        if r.get('sections') and want:
            sec = r['sections'].get(want)
            if not sec:
                return None, f'{lang} {z} has no {want} version'
            tl, mn = sec['translit'], sec['meaning']
            if any(x.rstrip().endswith(('…', '….', '...')) for x in tl + mn):
                cov = 'partial'       # the second version is abbreviated in the source
        elif evening_rescue:
            if lang == 'fr' and any(EVENING_GENERIC_FR.search(x) for x in mn):
                tl = []               # the French meaning covers both times ("[ou au soir]"); its transliteration is the morning one
            else:
                return None, f'{lang} {z}: morning wording only'
        if quran_only and (r.get('instructionOnly') or (lang == 'en' and RECITE.search(' '.join(mn)))):
            note += mn        # "The Prophet said: recite ..." is not the meaning of the verses the app shows
            mn = []
        if any(re.search(r'(…|\.\.\.)[.)\]]*\s*(\[[^\]]*\])?$', x) for x in tl):
            cov = 'partial'   # transliteration of the verses is cut short in the source ("Qul huwa Allahu ahad…")
        if len(rows) > 1 and meaning and mn:
            meaning.append('')
        meaning += mn
        translit += tl
        note += r['note']
    m, t, n = text_of(meaning), text_of(translit), text_of(note)
    if m:
        m = re.sub(r'\n{2,}', '\n\n', '\n'.join(meaning).strip())
    if not (m or t or n):
        return None, f'{lang}: empty after split'
    if not m and not t:
        cov = 'partial' if cov in ('exact', 'near') else cov
    return {'meaning': m, 'translit': t, 'note': n, 'coverage': cov}, ''


def compute_rows():
    """Rows built from the source DB only (before tools/translations_filled.json is applied)."""
    match = json.loads((WORK / 'match.json').read_text(encoding='utf-8'))
    titles = json.loads((WORK / 'titles.json').read_text(encoding='utf-8'))
    split = json.loads((WORK / 'split.json').read_text(encoding='utf-8'))
    app = ro('assets/db/hisn_elmoslem.db')
    content_ids = {i for (i,) in app.execute('select id from contents')}
    title_ids = {i for (i,) in app.execute('select id from titles')}
    app_ar = {i: c for i, c in app.execute('select id, content from contents')}
    title_ar = {i: n for i, n in app.execute('select id, name from titles')}

    # ---- rows
    content_rows, skipped = [], []
    for r in match:
        evening_rescue = r['confidence'] == 'evening_excluded'
        zikrs = r['zikrs'] or (r['morningEvening']['carrier'] if evening_rescue else [])
        if not zikrs:
            continue
        cov = r['coverage'] or 'near'
        for lang, _, _, _, _, _, _ in LANGS:
            row, why = pick_lang(zikrs, lang, split[lang], r['titleId'], cov, evening_rescue, is_quran_only(app_ar.get(r['contentId'])))
            if row:
                content_rows.append({'content_id': r['contentId'], 'lang': lang, **row, 'zikrs': zikrs,
                                     'rescued': evening_rescue})
            else:
                skipped.append({'contentId': r['contentId'], 'lang': lang, 'why': why})
    title_rows = []
    for t in titles:
        for lang, names in t.get('names', {}).items():
            name = re.sub(r'\s+', ' ', ''.join({0xF072: '(peace be upon him)'}.get(ord(c), c) for c in names['name'])).strip()
            name = re.sub(r'\s+\)', ')', name)
            title_rows.append({'title_id': t['titleId'], 'lang': lang, 'name': name, 'from': names['from']})
    return {'match': match, 'titles': titles, 'split': split, 'content_rows': content_rows, 'skipped': skipped,
            'title_rows': title_rows, 'content_ids': content_ids, 'title_ids': title_ids, 'app_ar': app_ar, 'title_ar': title_ar}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default='assets/db/translations.db')
    ap.add_argument('--report', default='docs/translations_match_report.md')
    ap.add_argument('--all', action='store_true', help='run translations_match.py and translations_split.py first')
    a = ap.parse_args()
    if a.all:
        for s in ('translations_match.py', 'translations_split.py'):
            subprocess.run([sys.executable, '-I', '-X', 'utf8', str(Path('tools', s))], check=True)
    d = compute_rows()
    match, titles, split, content_rows, skipped = d['match'], d['titles'], d['split'], d['content_rows'], d['skipped']
    title_rows, content_ids, title_ids, app_ar, title_ar = d['title_rows'], d['content_ids'], d['title_ids'], d['app_ar'], d['title_ar']

    # ---- gap filling (tools/translations_filled.json): source / rule / drafted, recorded per field
    before = fill.counts(content_rows, len(content_ids))
    agreement = fill.agreement(content_rows)
    classes = fill.classify()
    filled, fill_errors = fill.apply_fills(content_rows, classes)
    missing = fill.completeness(content_rows, classes)

    # ---- hard checks
    errors = list(fill_errors)
    for g in missing:
        if not g.get('unfillable'):
            errors.append(f"content {g['content_id']} {g['lang']}: no {g['field']} ({g['class']}); fill it in tools/translations_filled.json "
                          f"or list it under 'unfillable' with a reason")
    for x in content_rows:
        if x['content_id'] not in content_ids:
            errors.append(f"content {x['content_id']} not in hisn_elmoslem.db")
        if x['coverage'] not in COVERAGE:
            errors.append(f"content {x['content_id']} {x['lang']}: bad coverage {x['coverage']}")
        for f in ('meaning', 'translit', 'note'):
            v = x[f]
            if v is None:
                continue
            for name, rx in BAD:
                if rx.search(v):
                    errors.append(f"content {x['content_id']} {x['lang']} {f}: {name}: {rx.search(v).group(0)!r}")
            if x['lang'] == 'fr' and not LATIN.search(v):
                errors.append(f"content {x['content_id']} fr {f}: no Latin letters")
            if x['lang'] == 'en' and ARABIC.search(v):
                errors.append(f"content {x['content_id']} en {f}: Arabic letters {ARABIC.search(v).group(0)!r}")
    for x in title_rows:
        if x['title_id'] not in title_ids:
            errors.append(f"title {x['title_id']} not in hisn_elmoslem.db")
        for name, rx in BAD:
            if rx.search(x['name']):
                errors.append(f"title {x['title_id']} {x['lang']}: {name}")
        if not LATIN.search(x['name']) or ARABIC.search(x['name']):
            errors.append(f"title {x['title_id']} {x['lang']}: script")
    if errors:
        print('BUILD FAILED')
        print('\n'.join(errors[:80]))
        sys.exit(1)

    # ---- database
    out = Path(a.out)
    tmp = out.with_suffix('.tmp')
    if tmp.exists():
        tmp.unlink()
    db = sqlite3.connect(tmp)
    db.executescript(SCHEMA)
    for code, native, en, rtl, sort, source, url in LANGS:
        has_m = any(x['meaning'] for x in content_rows if x['lang'] == code)
        has_t = any(x['translit'] for x in content_rows if x['lang'] == code)
        db.execute('insert into languages values (?,?,?,?,?,?,?,?,?)', (code, native, en, rtl, sort, source, url, int(has_m), int(has_t)))
    db.executemany('insert into title_translations values (?,?,?)', [(x['title_id'], x['lang'], x['name']) for x in title_rows])
    db.executemany('insert into content_translations values (?,?,?,?,?,?,?)',
                   [(x['content_id'], x['lang'], x['meaning'], x['translit'], x['note'], None, x['coverage']) for x in content_rows])
    db.commit()
    db.execute('vacuum')
    db.close()
    try:
        os.replace(tmp, out)
    except PermissionError:
        # the target is held open (an IDE or the app): overwrite its content instead of replacing the file
        shutil.copyfile(tmp, out)
        tmp.unlink()
    size = out.stat().st_size
    packed = len(zlib.compress(out.read_bytes(), 9))
    print(f'{out}: {size / 1024:.0f} KB ({packed / 1024:.0f} KB deflated); {len(content_rows)} content rows, {len(title_rows)} title rows')

    after = fill.counts(content_rows, len(content_ids))
    write_report(a.report, match, titles, split, content_rows, title_rows, skipped, app_ar, title_ar, size, packed,
                 len(content_ids), len(title_ids))
    fill.write_report_sections(a.report, before, after, classes, filled, missing, agreement, app_ar)
    for lang in ('en', 'fr'):
        print(f"{lang}: meaning {before[lang]['meaning']} -> {after[lang]['meaning']}, translit {before[lang]['translit']} -> {after[lang]['translit']}")
    print(f"filled fields: {dict(collections.Counter(f['method'] for f in filled))}; remaining gaps: {len(missing)}; "
          f"rule agreement: {agreement['summary']}")


def write_report(path, match, titles, split, content_rows, title_rows, skipped, app_ar, title_ar, size, packed, n_contents, n_titles):
    from translations_match import DEFAULT_AZKAR_DB, ar_clean
    src = ro(DEFAULT_AZKAR_DB)
    zar = {z: ar_clean(org if org and org.strip() and len(org) > len(t or '') else t)
           for z, t, org in src.execute('select ZekarID, ZekarText, OrgZekarText from HSN_Ar')}
    by = collections.defaultdict(dict)
    for x in content_rows:
        by[x['content_id']][x['lang']] = x
    L = []
    w = L.append
    w('# Translations: match and build report')
    w('')
    w('Generated by `tools/translations_build.py` from `tools/translations_match.py` and `tools/translations_split.py`. '
      'Source: the source DB (`HSN_En`, `HSN_Fr`, categories), which follows hisnmuslim.com, plus the gap fills of '
      '`tools/translations_filled.json` (`tools/translations_fill.py`). Do not edit by hand.')
    w('')
    w('## Summary')
    w('')
    w(f'- App: {n_contents} contents, {n_titles} titles. Database `assets/db/translations.db`: **{size / 1024:.0f} KB** '
      f'({packed / 1024:.0f} KB deflated, roughly the APK cost).')
    for lang in ('en', 'fr'):
        rows = [x for x in content_rows if x['lang'] == lang]
        m = sum(1 for x in rows if x['meaning'])
        t = sum(1 for x in rows if x['translit'])
        n = sum(1 for x in rows if x['note'])
        tt = sum(1 for x in title_rows if x['lang'] == lang)
        w(f'- **{lang}**: {len(rows)} contents with a row ({len(rows) / n_contents:.0%}); meaning {m} ({m / n_contents:.0%}), '
          f'transliteration {t} ({t / n_contents:.0%}), note {n}; titles {tt}/{n_titles} ({tt / n_titles:.0%}). '
          f'Coverage: {dict(collections.Counter(x["coverage"] for x in rows))}.')
    w('')
    w('Percentages are of all app contents/titles. Contents of the book introduction (titles 1 and 2, 14 contents) have no counterpart in the source DB.')
    w('')
    w('## How matching works')
    w('')
    w('- **Text signal**: normalised Arabic of the app zikr (Quran placeholders expanded, diacritics and honorifics removed) against `HSN_Ar` '
      '(ZekarText and OrgZekarText), the title\'s own the source DB category first: same text (exact >= 0.98, near >= 0.85), the app zikr inside one item (partial), '
      'several items inside the app zikr (combined), one item inside a longer app zikr with narration (near).')
    w('- **Number signal**: app zikr -> binwahaf lesson (`tools/binwahaf_out`) -> book hadith number N -> hisnmuslim item N (`tools/translations_raw`) '
      '-> the source DB zikr. The last hop compares the source DB with the hisnmuslim files (Arabic and English) only, never with the app text.')
    w('- **ZekarID is not the hadith number**: it equals the hisnmuslim id up to about 113, then drifts (+5 and more). the source DB also holds Arabic-only '
      'items: the evening copies (category 135) and pieces of translated items (ids above 275). Each is mapped to the translated item that carries it.')
    w('- **Confidence**: high = both signals land on the same the source DB zikr; medium = only one signal exists (no binwahaf lesson) or the number signal '
      'is supported by word overlap; manual = `tools/translations_overrides.json`.')
    w('')
    w('## Counts')
    w('')
    c = collections.Counter((r['confidence'], r['coverage'] or '-') for r in match)
    w('| confidence | coverage | contents |')
    w('|---|---|---|')
    for (conf, cov), n in sorted(c.items()):
        w(f'| {conf} | {cov} | {n} |')
    tc = collections.Counter(t['confidence'] for t in titles)
    w('')
    w(f'Titles: {dict(tc)}.')
    w('')

    def ar_of(cid):
        return re.sub(r'\s+', ' ', re.sub(r'<[^>]*>|QuranText\[[^\]]*\]', ' [Quran] ', app_ar.get(cid) or '')).strip()

    def short(s, n=160):
        s = s or ''
        return (s[:n] + '…') if len(s) > n else s

    def md(s):
        return (s or '').replace('|', '/').replace('\n', ' / ')

    w('## Review items for the owner')
    w('')
    w('Everything the scripts could not settle is decided in `tools/translations_overrides.json`; these are the decisions to confirm, '
      'plus the items where the published translation itself looks off.')
    w('')
    w('### Manual decisions (overrides)')
    w('')
    w('| app id | app Arabic | the source DB | decision |')
    w('|---|---|---|---|')
    for t in titles:
        if t['confidence'] == 'manual':
            names = ', '.join(f"{k}: {v['name']}" for k, v in t['names'].items())
            w(f"| title {t['titleId']} | {title_ar[t['titleId']]} | category {t['category']} | {names}. {md(t['how'])} |")
    for r in match:
        if r['confidence'] == 'manual':
            z = r['zikrs'] or [r['text']['best']]
            w(f"| {r['contentId']} | {md(short(ar_of(r['contentId'])))} | {', '.join(f'{x}: {short(zar.get(x), 90)}' for x in z)} | "
              f"{'use ' + str(r['zikrs']) + ' (' + str(r['coverage']) + ')' if r['zikrs'] else 'no translation'}. {md(r['note'])} |")
    w('')
    w('### Morning and evening')
    w('')
    w('the source DB translates the morning/evening zikrs once (category 27, mostly morning wording); its evening copies (category 135) are Arabic only. '
      'An evening zikr takes the morning item\'s translation only when the source DB\'s evening Arabic equals the morning Arabic. Otherwise: English uses '
      'the evening version when the item has one ("In the evening: ..."), French uses its meaning when it says "[ou au soir]" (without the morning '
      'transliteration), else no translation. A morning zikr whose English item leads with the evening text uses the morning version.')
    w('')
    w('| app id | title | app Arabic | the source DB | en | fr |')
    w('|---|---|---|---|---|---|')
    for r in match:
        me = r['morningEvening']
        sec = any(split[l].get(str(z), {}).get('sections') for z in r['zikrs'] or [] for l in ('en', 'fr'))
        if me or (r['titleId'] in (MORNING_TITLE, EVENING_TITLE) and sec):
            cid = r['contentId']
            ln = {l: (f"{by[cid][l]['coverage']}" + (' (meaning only)' if not by[cid][l]['translit'] else '') if l in by[cid] else 'none') for l in ('en', 'fr')}
            zz = (me or {}).get('carrier') or r['zikrs']
            w(f"| {cid} | {r['titleId']} | {md(short(ar_of(cid), 90))} | {zz} {md((me or {}).get('decision', 'morning version'))} | {ln['en']} | {ln['fr']} |")
    w('')
    w('### Transliteration that differs from the Arabic')
    w('')
    w('Consonant skeleton of the transliteration against the the source DB Arabic of the same item; low values are usually a narration or an added '
      'formula, sometimes a real mismatch. Only items used by the app are listed.')
    w('')
    used = collections.defaultdict(list)
    for x in content_rows:
        for z in x['zikrs']:
            used[(x['lang'], z)].append(x['content_id'])
    w('| lang | the source DB | used by | skeleton | transliteration | the source DB Arabic |')
    w('|---|---|---|---|---|---|')
    for lang in ('en', 'fr'):
        for z, r in sorted(split[lang].items(), key=lambda kv: int(kv[0])):
            if (lang, int(z)) in used and r.get('translitVsArabic') is not None and r['translitVsArabic'] < .6:
                w(f"| {lang} | {z} | {sorted(set(used[(lang, int(z))]))} | {r['translitVsArabic']} | {md(short(' '.join(r['translit']), 90))} | {md(short(zar.get(int(z)), 90))} |")
    w('')
    w('## Partial and combined')
    w('')
    w('Partial: the translation and the app zikr are not the same unit (the app zikr is a piece of a longer item, or only part of it is translated). '
      'Combined: the app zikr spans several the source DB items, joined with a blank line.')
    w('')
    w('| app id | coverage | app Arabic | the source DB | the source DB Arabic |')
    w('|---|---|---|---|---|')
    seen = set()
    for x in sorted(content_rows, key=lambda x: x['content_id']):
        if x['coverage'] in ('partial', 'combined') and x['content_id'] not in seen:
            seen.add(x['content_id'])
            covs = '/'.join(sorted({y['coverage'] for y in by[x['content_id']].values()}))
            w(f"| {x['content_id']} | {covs} | {md(short(ar_of(x['content_id']), 110))} | {x['zikrs']} | {md(short(' + '.join(zar.get(z, '') for z in x['zikrs']), 110))} |")
    w('')
    w('## Medium confidence')
    w('')
    w('| app id | coverage | why | app Arabic | the source DB Arabic |')
    w('|---|---|---|---|---|')
    for r in match:
        if r['confidence'] == 'medium':
            w(f"| {r['contentId']} | {r['coverage']} | {md(r['why'])} | {md(short(ar_of(r['contentId']), 90))} | {r['zikrs']}: {md(short(' + '.join(zar.get(z, '') for z in r['zikrs']), 90))} |")
    w('')
    w('## Contents without a translation')
    w('')
    miss = collections.defaultdict(list)
    for r in match:
        for lang in ('en', 'fr'):
            if lang not in by[r['contentId']]:
                why = next((s['why'] for s in skipped if s['contentId'] == r['contentId'] and s['lang'] == lang), None)
                miss[(r['contentId'])].append(f"{lang}: {why or r['confidence'] + (' - ' + r['note'] if r.get('note') else '')}")
    w('| app id | title | app Arabic | reason |')
    w('|---|---|---|---|')
    tid = {r['contentId']: r['titleId'] for r in match}
    for cid, reasons in sorted(miss.items()):
        w(f"| {cid} | {tid[cid]} | {md(short(ar_of(cid), 80))} | {md('; '.join(reasons))} |")
    w('')
    w('## Titles')
    w('')
    nt = [t for t in titles if not t['names']]
    w(f"Titles without a name: {', '.join(str(t['titleId']) for t in nt) or 'none'}. Names come from `HSN_Categories_En/Fr`; English names missing there "
      f"come from the hisnmuslim English index: {', '.join(str(x['title_id']) for x in title_rows if x['from'] == 'hisnmuslim en index') or 'none'}.")
    w('')
    Path(path).write_text('\n'.join(L) + '\n', encoding='utf-8')
    print('report:', path)


if __name__ == '__main__':
    main()
