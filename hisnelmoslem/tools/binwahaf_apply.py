#!/usr/bin/env python3
"""Apply the binwahaf data to the bundled databases and write a before/after report.

Needs, in tools/binwahaf_out/ (see download_binwahaf.py and binwahaf_match.py):
    content.json, match.json, optional nomatch_resolved.json (manual/assisted matches)

What it changes (nothing else is touched):
  1. commentary.db   fills sharh (and benefit) of zikrs that have none, from the lesson explanation.
                     Existing sharh/benefit are never overwritten.
  2. hisn_elmoslem.db  adds the column contents.audio_urls (JSON, reciter -> url, or a list of urls
                     when one zikr spans several lessons). The old audio / audio_url columns and the
                     bundled trimmed audio files are not changed.

Usage (from hisnelmoslem/):
    python tools/binwahaf_apply.py --dry-run     # report only
    python tools/binwahaf_apply.py               # write the databases and the report
"""
import argparse
import difflib
import json
import re
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from binwahaf_commentary import convert  # noqa: E402
from download_binwahaf import reader_slug  # noqa: E402

OUT = Path('tools/binwahaf_out')
HISN = Path('assets/db/hisn_elmoslem.db')
COMM = Path('assets/db/commentary.db')
USABLE = {'exact', 'near', 'part', 'part_other_chapter', 'whole'}


def cell(s: str, n: int = 60) -> str:
    s = ' '.join((s or '').split())
    return (s[:n] + '…') if len(s) > n else (s or '—')


_DIA = re.compile('[ً-ٰٟۖ-ۭـ]')


def _word(w: str) -> str:
    w = _DIA.sub('', w)
    for a, b in (('أ', 'ا'), ('إ', 'ا'), ('آ', 'ا'), ('ى', 'ي'), ('ة', 'ه')):
        w = w.replace(a, b)
    return re.sub(r'[^ء-ي]', '', w)


def wording_diffs(db_text: str, web_text: str) -> list[tuple[str, str]]:
    """Word-level differences ignoring tashkeel and punctuation. Not applied, only reported."""
    a, b = db_text.split(), web_text.split()
    sm = difflib.SequenceMatcher(None, [_word(x) for x in a], [_word(x) for x in b], autojunk=False)
    out = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag != 'equal' and (any(_word(x) for x in a[i1:i2]) or any(_word(x) for x in b[j1:j2])):
            out.append((' '.join(a[i1:i2]), ' '.join(b[j1:j2])))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--report', default='docs/binwahaf_sync_report.md')
    args = ap.parse_args()

    site = {l['id']: l for l in json.loads((OUT / 'content.json').read_text(encoding='utf-8'))}
    match = {r['contentId']: r for r in json.loads((OUT / 'match.json').read_text(encoding='utf-8'))}
    resolved_path = OUT / 'nomatch_resolved.json'
    resolved = {}
    if resolved_path.exists():
        for r in json.loads(resolved_path.read_text(encoding='utf-8')):
            if r.get('lessons') and r.get('confidence') in ('high', 'medium'):
                resolved[r['contentId']] = r

    # contentId -> (lesson ids, how it was matched)
    lessons_of: dict[int, tuple[list[int], str]] = {}
    for cid, r in match.items():
        if r['kind'] in USABLE and r['lessons']:
            lessons_of[cid] = (r['lessons'], r['kind'])
        elif cid in resolved:
            lessons_of[cid] = (resolved[cid]['lessons'], 'assisted:' + resolved[cid]['relation'])

    hisn = sqlite3.connect(HISN)
    comm = sqlite3.connect(COMM)
    title_of = {r[0]: r[1] for r in hisn.execute('select id,name from titles')}
    content_title = {r[0]: r[1] for r in hisn.execute('select id,titleId from contents')}

    # ---- 1. missing sharh
    rows = {r[0]: r[1:] for r in comm.execute('select contentId,sharh,hadith,benefit from commentary')}
    filled, unfilled = [], []
    for cid in sorted(match):
        sharh, _hadith, benefit = rows.get(cid, ('', '', ''))
        if (sharh or '').strip():
            continue
        lessons, how = lessons_of.get(cid, ([], ''))
        conv = convert(site[lessons[0]]['explanation_html']) if lessons else {'sharh': '', 'benefit': ''}
        if conv['sharh']:
            new_benefit = benefit if (benefit or '').strip() else conv['benefit']
            filled.append((cid, lessons[0], how, sharh, conv['sharh'], benefit, new_benefit,
                           cid in rows))
        else:
            unfilled.append((cid, lessons[0] if lessons else None, how))

    # ---- 2. audio urls
    audio: dict[int, dict] = {}
    reciters: dict[str, str] = {}
    for cid, (lessons, _how) in lessons_of.items():
        per: dict[str, list[str]] = {}
        for lid in lessons:
            for rd in site[lid].get('readers', []):
                slug = reader_slug(rd['name'], rd['url'])
                reciters[slug] = rd['name']
                per.setdefault(slug, []).append(rd['url'])
        if per:
            audio[cid] = {k: (v[0] if len(v) == 1 else v) for k, v in per.items()}

    # ---- report
    lines = ['# binwahaf sync report', '',
             f'- contents in the app: {len(match)}; matched to a lesson: {len(lessons_of)}; '
             f'without a lesson: {len(match) - len(lessons_of)}',
             f'- sharh filled: {len(filled)}; still without sharh: {len(unfilled)}',
             f'- audio urls added to {len(audio)} contents, reciters: ' +
             ', '.join(f'{k} ({v})' for k, v in sorted(reciters.items())), '',
             '## Sharh filled (before → after)', '',
             '| zikr | title | lesson | match | before | after (sharh) | after (benefit) |',
             '|---|---|---|---|---|---|---|']
    for cid, lid, how, old, new, ob, nb, _had in filled:
        lines.append(f'| {cid} | {cell(title_of.get(content_title[cid], ""), 28)} | {lid} | {how} | '
                     f'{"no row" if not _had else "empty"} | {cell(new, 70)} ({len(new)} chars) | '
                     f'{"kept" if (ob or "").strip() else cell(nb, 40) + f" ({len(nb)} chars)"} |')
    lines += ['', '## Still without sharh (the site has none or no lesson was matched)', '',
              '| zikr | title | lesson | match |', '|---|---|---|---|']
    for cid, lid, how in unfilled:
        lines.append(f'| {cid} | {cell(title_of.get(content_title[cid], ""), 40)} | {lid or "—"} | {how or "no lesson"} |')
    lines += ['', '## Contents without any matching lesson', '',
              '| zikr | title |', '|---|---|']
    for cid in sorted(match):
        if cid not in lessons_of:
            lines.append(f'| {cid} | {cell(title_of.get(content_title[cid], ""), 50)} |')
    covered = {l for ls, _ in lessons_of.values() for l in ls}
    lines += ['', '## Lessons on the site that no zikr in the app uses', '',
              '| lesson | title |', '|---|---|']
    for lid, l in site.items():
        if lid not in covered:
            lines.append(f'| {lid} | {cell(l["title"], 60)} |')
    report = '\n'.join(lines) + '\n'

    print(f'sharh to fill: {len(filled)}, no sharh available: {len(unfilled)}, audio rows: {len(audio)}')
    if args.dry_run:
        print(report[:2500])
        return 0

    # ---- write
    for cid, _lid, _how, _old, new, _ob, nb, had in filled:
        if had:
            comm.execute('update commentary set sharh=?, benefit=? where contentId=?', (new, nb or '', cid))
        else:
            comm.execute('insert into commentary(contentId,sharh,hadith,benefit) values(?,?,?,?)',
                         (cid, new, '', nb or ''))
    comm.commit()
    comm.execute('vacuum')
    cols = [r[1] for r in hisn.execute('pragma table_info(contents)')]
    if 'audio_urls' not in cols:
        hisn.execute('alter table contents add column audio_urls TEXT')
    for cid, urls in audio.items():
        hisn.execute('update contents set audio_urls=? where id=?', (json.dumps(urls, ensure_ascii=False), cid))
    hisn.commit()
    hisn.execute('vacuum')
    Path(args.report).write_text(report, encoding='utf-8')
    print('written:', args.report)
    return 0


if __name__ == '__main__':
    sys.exit(main())
