#!/usr/bin/env python3
"""Fill the gaps the source DB leaves: every recited zikr gets a transliteration and a meaning in en and fr.

Classes of app contents (decided here, listed in the report):
  skip         : the book introduction (titles 1 and 2), Quran passages longer than LONG_QURAN_WORDS words
                 (Surat As-Sajda, Al-Mulk, Al Imran 190-200, the first ten verses of Al-Kahf), any text
                 longer than LONG_TEXT_WORDS words. Nothing is required.
  not_recited  : narrations, virtues and instructions that a user reads but does not recite
                 (`not_recited` in tools/translations_filled.json). A meaning or a note is required.
  recited      : everything else, including Ayat al-Kursi, the three Quls and other short verses.
                 A meaning and a complete transliteration are required.

Provenance lives in tools/translations_filled.json, one entry per filled field:
  {content_id, lang, field: meaning|translit, method: source|rule|drafted, text, note, replace?}
  source  : copied from data already available locally (hisnmuslim files, another row of the same Arabic,
            a field the split put in the wrong place)
  rule    : tools/translations_translit.py on the vowelled Arabic of the app (or the `recite` override)
  drafted : written for this app (short, well-known zikrs only); listed for owner review
The build applies the entries; nothing in the database records the method (no schema change).

Usage:
  python -I -X utf8 tools/translations_fill.py            # list the gaps that have no entry yet
  python -I -X utf8 tools/translations_fill.py --generate # add 'source' copies of the same Arabic and 'rule' entries
  python -I -X utf8 tools/translations_fill.py --refresh  # regenerate the text of every 'rule' entry
"""
import argparse, collections, difflib, json, re, sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from hisn_text import norm  # noqa: E402
from translations_translit import transliterate, unvowelled_words, vowel_coverage  # noqa: E402

CONFIG = Path('tools/translations_filled.json')
SKIP_TITLES = {1: 'book introduction', 2: 'book introduction (virtue of remembrance)'}
LONG_QURAN_WORDS = 100
LONG_TEXT_WORDS = 150
MIN_VOWELS = .95
LANGS = ('en', 'fr')
METHODS = ('source', 'rule', 'drafted')


def _ro(path):
    return sqlite3.connect(Path(path).resolve().as_uri() + '?mode=ro', uri=True)


def load_config():
    return json.loads(CONFIG.read_text(encoding='utf-8'))


def save_config(cfg):
    fills = sorted(cfg['fills'], key=lambda f: (f['content_id'], LANGS.index(f['lang']), f['field']))
    lines = ['{']
    for k in ('_doc', 'skip', 'not_recited', 'recite', 'unfillable'):
        lines.append(f' {json.dumps(k)}: ' + json.dumps(cfg.get(k, {}), ensure_ascii=False, indent=2).replace('\n', '\n ') + ',')
    lines.append(' "fills": [')
    lines.append(',\n'.join('  ' + json.dumps(f, ensure_ascii=False) for f in fills))
    lines.append(' ]')
    lines.append('}')
    CONFIG.write_text('\n'.join(lines) + '\n', encoding='utf-8')


_APP = None


def app_contents():
    """{id: (titleId, content)} from hisn_elmoslem.db, and the Quran db."""
    global _APP
    if _APP is None:
        app = _ro('assets/db/hisn_elmoslem.db')
        _APP = ({i: (t, c) for i, t, c in app.execute('select id, titleId, content from contents')}, _ro('assets/db/quran.ar.uthmani.v2.db'))
    return _APP


def quran_verses(placeholder, q):
    out = []
    for part in re.findall(r'\(([\d:]+)\)', placeholder):
        sura, a, b = (int(x) for x in part.split(':'))
        out += [r[0] for r in q.execute('select text from arabic_text where sura=? and ayah between ? and ? order by ayah', (sura, a, b))]
    return out


def recite_parts(cid, cfg=None):
    """The recited Arabic of a content as [(text, quran)]: the `recite` override, else the app text without
    narration outside ((...)), parenthesised remarks and honorific glyphs; Quran placeholders expanded."""
    cfg = cfg or load_config()
    contents, q = app_contents()
    text = cfg['recite'][str(cid)] if str(cid) in cfg.get('recite', {}) else contents[cid][1] or ''
    places = re.findall(r'QuranText\[[^\]]*\]', text)
    text = re.sub(r'QuranText\[[^\]]*\]', '@Q@', text)
    if str(cid) not in cfg.get('recite', {}):
        if '((' in text:
            text = ' ، '.join(re.findall(r'\(\((.*?)\)\)', text, re.S))
        text = re.sub(r'\((?!\()[^()]*\)', ' ', text)
    parts = []
    for k, piece in enumerate(text.split('@Q@')):
        if piece.strip():
            parts.append((piece, False))
        if k < len(places):
            parts.append((' ۝ '.join(quran_verses(places[k], q)), True))
    return [(re.sub(r'^[\s\-–:،]+', '', t), qn) for t, qn in parts if re.search('[ء-ي]', t)]


def rule_translit(cid, lang, cfg=None):
    return ' '.join(transliterate(t.replace('۝', '.'), lang, quran=qn) for t, qn in recite_parts(cid, cfg))


def rule_vowels(cid, cfg=None):
    parts = [(t, qn) for t, qn in recite_parts(cid, cfg) if not qn]
    return min((vowel_coverage(t) for t, _ in parts), default=1.0)


def rule_unvowelled(cid, cfg=None):
    return [w for t, qn in recite_parts(cid, cfg) if not qn for w in unvowelled_words(t)]


def word_count(cid):
    contents, q = app_contents()
    text = contents[cid][1] or ''
    expanded = re.sub(r'QuranText\[[^\]]*\]', lambda m: ' '.join(quran_verses(m.group(0), q)), text)
    return len(norm(re.sub(r'<[^>]*>', ' ', expanded)).split())


def is_quran_only(content):
    rest = re.sub(r'QuranText\[[^\]]*\]|﴿[^﴾]*﴾|\{[^}]*\}', ' ', content or '')
    return rest != (content or '') and len(re.findall(r'[ء-ي]{2,}', rest)) < 5


def classify(cfg=None):
    cfg = cfg or load_config()
    contents, _ = app_contents()
    out = {}
    for cid, (tid, content) in sorted(contents.items()):
        n = word_count(cid)
        if tid in SKIP_TITLES:
            out[cid] = {'class': 'skip', 'reason': SKIP_TITLES[tid], 'words': n}
        elif str(cid) in cfg.get('skip', {}):
            out[cid] = {'class': 'skip', 'reason': cfg['skip'][str(cid)], 'words': n}
        elif 'QuranText' in (content or '') and is_quran_only(content) and n > LONG_QURAN_WORDS:
            out[cid] = {'class': 'skip', 'reason': f'long Quran passage ({n} words > {LONG_QURAN_WORDS})', 'words': n}
        elif n > LONG_TEXT_WORDS:
            out[cid] = {'class': 'skip', 'reason': f'long text ({n} words > {LONG_TEXT_WORDS})', 'words': n}
        elif str(cid) in cfg.get('not_recited', {}):
            out[cid] = {'class': 'not_recited', 'reason': cfg['not_recited'][str(cid)], 'words': n}
        else:
            out[cid] = {'class': 'recited', 'reason': '', 'words': n}
    return out


def counts(rows, n_contents):
    out = {}
    for lang in LANGS:
        r = [x for x in rows if x['lang'] == lang]
        out[lang] = {'rows': len(r), 'meaning': sum(1 for x in r if x['meaning']), 'translit': sum(1 for x in r if x['translit']),
                     'n': n_contents}
    return out


def truncated(row, cid, cfg=None):
    """A published transliteration cut short with an ellipsis ("Qul huwa Allahu ahad… [Al-Ikhlas]")."""
    t = row.get('translit') or ''
    if not re.search(r'…|\.\.\.', t):
        return False
    full = rule_translit(cid, row['lang'], cfg)
    return len(t) < .6 * len(full)


def gaps(rows, classes, cfg=None):
    """Missing fields per non-skipped content, before fills: [{content_id, lang, field, why}]."""
    by = {(x['content_id'], x['lang']): x for x in rows}
    out = []
    for cid, c in classes.items():
        if c['class'] == 'skip':
            continue
        for lang in LANGS:
            r = by.get((cid, lang))
            if c['class'] == 'not_recited':
                if not r or not (r['meaning'] or r['note']):
                    out.append({'content_id': cid, 'lang': lang, 'field': 'meaning', 'why': 'no row' if not r else 'no meaning or note'})
                continue
            for f in ('meaning', 'translit'):
                if not r or not r[f]:
                    out.append({'content_id': cid, 'lang': lang, 'field': f, 'why': 'no row' if not r else f'no {f}'})
                elif f == 'translit' and truncated(r, cid, cfg):
                    out.append({'content_id': cid, 'lang': lang, 'field': f, 'why': 'translit cut short', 'replace': True})
    return out


def apply_fills(rows, classes, cfg=None):
    """Apply tools/translations_filled.json to the rows (in place). Returns (applied entries, errors)."""
    cfg = cfg or load_config()
    by = {(x['content_id'], x['lang']): x for x in rows}
    applied, errors = [], []
    for f in cfg['fills']:
        cid, lang, field = f['content_id'], f['lang'], f['field']
        tag = f"fill {cid} {lang} {field}"
        if f['method'] not in METHODS or field not in ('meaning', 'translit', 'note') or lang not in LANGS:
            errors.append(f'{tag}: bad method/field/lang')
            continue
        if cid not in classes or classes[cid]['class'] == 'skip':
            errors.append(f'{tag}: content is skipped or unknown')
            continue
        r = by.get((cid, lang))
        if r is None:
            r = {'content_id': cid, 'lang': lang, 'meaning': None, 'translit': None, 'note': None, 'coverage': 'exact',
                 'zikrs': [], 'rescued': False, 'filled': True}
            rows.append(r)
            by[(cid, lang)] = r
        if r.get(field) and not f.get('replace'):
            errors.append(f'{tag}: the source now has this field; remove the entry or mark it replace')
            continue
        r[field] = f['text']
        r.setdefault('fills', []).append(f['method'])
        applied.append(f)
    return applied, errors


def completeness(rows, classes, cfg=None):
    cfg = cfg or load_config()
    by = {(x['content_id'], x['lang']): x for x in rows}
    out = []
    for cid, c in classes.items():
        if c['class'] == 'skip':
            continue
        for lang in LANGS:
            r = by.get((cid, lang)) or {}
            need = ['meaning', 'translit'] if c['class'] == 'recited' else ['meaning']
            for f in need:
                ok = r.get(f) or (c['class'] == 'not_recited' and r.get('note'))
                if not ok:
                    key = f'{cid}:{lang}:{f}'
                    out.append({'content_id': cid, 'lang': lang, 'field': f, 'class': c['class'],
                                'unfillable': cfg.get('unfillable', {}).get(key)})
    return out


def _canon(s, lang):
    s = re.sub(r'\([^)]*\)|\[[^\]]*\]', ' ', s or '')
    if lang == 'en':
        s = s.replace('AA', 'c')
    s = s.lower()
    for a, b in (('ee', 'i'), ('oo', 'u'), ('aa', 'a'), ('â', 'a'), ('î', 'i'), ('û', 'u'), ('ou', 'u'), ('é', 'e')):
        s = s.replace(a, b)
    s = re.sub(r"[^a-z]", '', s)
    return re.sub(r'(.)\1+', r'\1', s)


def agreement(rows, cfg=None):
    """Rule transliteration against the published one, on recited contents whose row is an exact match,
    whose Arabic is vowelled and whose published transliteration is not cut short."""
    cfg = cfg or load_config()
    classes = classify(cfg)
    res = {'by_lang': {}, 'rows': []}
    for lang in LANGS:
        scores = []
        for r in rows:
            cid = r['content_id']
            if r['lang'] != lang or not r['translit'] or r['coverage'] != 'exact' or classes.get(cid, {}).get('class') != 'recited':
                continue
            if r.get('fills') or re.search(r'…|\.\.\.', r['translit']) or rule_vowels(cid, cfg) < MIN_VOWELS:
                continue
            ours = rule_translit(cid, lang, cfg)
            a, b = _canon(ours, lang), _canon(r['translit'], lang)
            sc = difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()
            same = bool(a and b) and .75 <= len(a) / len(b) <= 1.33
            scores.append((sc, same))
            res['rows'].append({'content_id': cid, 'lang': lang, 'score': round(sc, 3), 'same': same, 'rule': ours, 'published': r['translit']})
        if scores:
            res['by_lang'][lang] = {}
            for key, sub in (('all', [x for x, _ in scores]), ('same', [x for x, s in scores if s])):
                res['by_lang'][lang][key] = {'n': len(sub), 'mean': round(sum(sub) / len(sub), 3),
                                             'ge90': sum(1 for x in sub if x >= .9), 'ge80': sum(1 for x in sub if x >= .8)}
    res['summary'] = '; '.join(f"{l} mean {v['same']['mean']:.0%} over {v['same']['n']} same-length rows ({v['same']['ge90']} >= 90%), "
                               f"{v['all']['mean']:.0%} over all {v['all']['n']}" for l, v in res['by_lang'].items())
    return res


def generate(refresh=False):
    import translations_build as build
    cfg = load_config()
    d = build.compute_rows()
    rows = d['content_rows']
    classes = classify(cfg)
    have = {(f['content_id'], f['lang'], f['field']) for f in cfg['fills']}
    if refresh:
        for f in cfg['fills']:
            if f['method'] == 'rule':
                f['text'] = rule_translit(f['content_id'], f['lang'], cfg)
    g = gaps(rows, classes, cfg)
    by = {(x['content_id'], x['lang']): x for x in rows}
    contents, _ = app_contents()
    recited_text = {cid: norm(' '.join(t for t, _ in recite_parts(cid, cfg))) for cid, c in classes.items() if c['class'] != 'skip'}
    todo = []
    for x in g:
        key = (x['content_id'], x['lang'], x['field'])
        if key in have:
            continue
        cid, lang, field = key
        # (a) another row of the same Arabic
        twin = next((o for o, t in recited_text.items() if o != cid and t == recited_text[cid]
                     and by.get((o, lang), {}).get(field) and by[(o, lang)]['coverage'] == 'exact'
                     and not (field == 'translit' and truncated(by[(o, lang)], o, cfg))), None)
        if twin is not None and classes[cid]['class'] == classes[twin]['class']:
            cfg['fills'].append({'content_id': cid, 'lang': lang, 'field': field, 'method': 'source',
                                 'text': by[(twin, lang)][field], 'note': f'same Arabic as content {twin}',
                                 **({'replace': True} if x.get('replace') else {})})
            continue
        # (b) rule transliteration
        if field == 'translit' and classes[cid]['class'] == 'recited':
            v, bad = rule_vowels(cid, cfg), rule_unvowelled(cid, cfg)
            if v < MIN_VOWELS or bad:
                todo.append({**x, 'why': x['why'] + f'; Arabic vowelled {v:.0%}, unvowelled {bad}: add a vowelled `recite` override'})
                continue
            cfg['fills'].append({'content_id': cid, 'lang': lang, 'field': field, 'method': 'rule',
                                 'text': rule_translit(cid, lang, cfg), 'note': x['why'],
                                 **({'replace': True} if x.get('replace') else {})})
            continue
        todo.append(x)
    save_config(cfg)
    for x in todo:
        print(f"TODO {x['content_id']} {x['lang']} {x['field']}: {x['why']} | {contents[x['content_id']][1][:90]!r}")
    print(len(todo), 'gaps need a source or drafted entry')


def write_report_sections(path, before, after, classes, filled, missing, agree, app_ar):
    contents, _ = app_contents()

    def ar(cid):
        return re.sub(r'\s+', ' ', re.sub(r'QuranText\[[^\]]*\]', ' [Quran] ', app_ar.get(cid) or '')).strip()

    def md(s):
        return (s or '').replace('|', '/').replace('\n', ' / ')

    L = ['', '## Completeness (every recited zikr in en and fr)', '']
    L.append(f'Rows from the source DB, then the fills of `tools/translations_filled.json`. A recited zikr needs a meaning and a complete '
             f'transliteration; a narration or instruction (not recited) needs a meaning or a note; skipped contents need nothing.')
    L.append('')
    L.append('| lang | rows | meaning | transliteration |')
    L.append('|---|---|---|---|')
    for lang in LANGS:
        b, a = before[lang], after[lang]
        L.append(f"| {lang} | {b['rows']} -> {a['rows']} | {b['meaning']} -> {a['meaning']} | {b['translit']} -> {a['translit']} |")
    L.append('')
    cc = collections.Counter(c['class'] for c in classes.values())
    L.append(f"Classes: recited {cc['recited']}, not recited {cc['not_recited']}, skipped {cc['skip']}. "
             f"Filled fields: {dict(collections.Counter((f['method']) for f in filled))} "
             f"({dict(collections.Counter((f['lang'], f['field'], f['method']) for f in filled).most_common())}).")
    L.append('')
    rem = [m for m in missing]
    L.append(f'Remaining gaps: {len(rem)}.' + ('' if rem else ' None.'))
    for m in rem:
        L.append(f"- {m['content_id']} {m['lang']} {m['field']}: {m['unfillable'] or 'not filled'}")
    L.append('')
    L.append('### Skipped')
    L.append('')
    L.append(f'Book introduction (titles 1 and 2), Quran passages over {LONG_QURAN_WORDS} words, any text over {LONG_TEXT_WORDS} words.')
    L.append('')
    L.append('| app id | words | reason | app Arabic |')
    L.append('|---|---|---|---|')
    for cid, c in classes.items():
        if c['class'] == 'skip':
            L.append(f"| {cid} | {c['words']} | {c['reason']} | {md(ar(cid)[:70])} |")
    L.append('')
    L.append('### Not recited (meaning or note only)')
    L.append('')
    L.append('| app id | reason | app Arabic |')
    L.append('|---|---|---|')
    for cid, c in classes.items():
        if c['class'] == 'not_recited':
            L.append(f"| {cid} | {md(c['reason'])} | {md(ar(cid)[:70])} |")
    L.append('')
    L.append('### Rule-based transliteration: agreement with the published rows')
    L.append('')
    L.append('`tools/translations_translit.py` run on the recited contents that already have a published transliteration '
             '(exact match, vowelled Arabic, not cut short), compared after folding spelling variants (ee/î -> i, AA/c -> ayn, '
             'doubled letters, punctuation and hyphens ignored). Character similarity:')
    L.append('')
    L.append('| lang | rows | mean | rows >= 90% | rows >= 80% |')
    L.append('|---|---|---|---|---|')
    for lang, v in agree['by_lang'].items():
        for key, label in (('same', 'same unit (length within 0.75-1.33)'), ('all', 'all compared rows')):
            x = v[key]
            L.append(f"| {lang}, {label} | {x['n']} | {x['mean']:.1%} | {x['ge90']} | {x['ge80']} |")
    L.append('')
    L.append('"Same unit" leaves out rows where the published transliteration covers a different span than the app zikr (only the formula '
             'inside a narration, an added count, or the next zikr appended); those are differences of span, not of spelling. '
             'Lowest ten per language among the same-unit rows:')
    L.append('')
    L.append('| app id | lang | score | rule | published |')
    L.append('|---|---|---|---|---|')
    for lang in LANGS:
        for r in sorted((r for r in agree['rows'] if r['lang'] == lang and r['same']), key=lambda r: r['score'])[:10]:
            L.append(f"| {r['content_id']} | {lang} | {r['score']} | {md(r['rule'][:110])} | {md(r['published'][:110])} |")
    L.append('')
    L.append('## Needs owner review')
    L.append('')
    L.append('Every field filled by rule (`rule`, generated transliteration) or written for this app (`drafted`). '
             'Fields copied from data already available (`source`) are listed after them. Edit the text in '
             '`tools/translations_filled.json` and rebuild.')
    for method, title in (('drafted', 'Drafted (written for this app)'), ('rule', 'Rule-based transliteration'), ('source', 'Copied from local data (for reference)')):
        items = [f for f in filled if f['method'] == method]
        L.append('')
        L.append(f'### {title}: {len(items)}')
        L.append('')
        L.append('| app id | lang | field | app Arabic | filled text | note |')
        L.append('|---|---|---|---|---|---|')
        for f in sorted(items, key=lambda f: (f['content_id'], f['lang'], f['field'])):
            L.append(f"| {f['content_id']} | {f['lang']} | {f['field']} | {md(ar(f['content_id'])[:90])} | {md(f['text'])} | {md(f.get('note'))} |")
    with open(path, 'a', encoding='utf-8') as fh:
        fh.write('\n'.join(L) + '\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--generate', action='store_true')
    ap.add_argument('--refresh', action='store_true')
    ap.add_argument('--agreement', action='store_true', help='print every compared row')
    a = ap.parse_args()
    if a.generate or a.refresh:
        generate(refresh=a.refresh)
        return
    import translations_build as build
    d = build.compute_rows()
    cfg = load_config()
    classes = classify(cfg)
    if a.agreement:
        ag = agreement(d['content_rows'], cfg)
        for r in sorted(ag['rows'], key=lambda r: r['score']):
            print(f"{r['content_id']} {r['lang']} {r['score']}\n  R: {r['rule']}\n  P: {r['published']}")
        print(ag['summary'])
        return
    have = {(f['content_id'], f['lang'], f['field']) for f in cfg['fills']}
    for x in gaps(d['content_rows'], classes, cfg):
        mark = 'filled' if (x['content_id'], x['lang'], x['field']) in have else 'OPEN'
        print(mark, x)


if __name__ == '__main__':
    main()
