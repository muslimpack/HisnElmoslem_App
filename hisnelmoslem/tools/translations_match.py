#!/usr/bin/env python3
"""Map the app's titles and contents (assets/db/hisn_elmoslem.db) to the source DB categories and zikrs.

Two independent signals per zikr:
  text   : normalised Arabic of the app zikr vs HSN_Ar (ZekarText and OrgZekarText).
  number : app zikr -> binwahaf lesson (tools/binwahaf_out) -> book hadith number N
           -> hisnmuslim.com item N (tools/translations_raw) -> the source DB zikr. The last hop compares
           the source DB with the hisnmuslim files only (Arabic and English), never with the app text.
High confidence = both signals land on the same the source DB zikr. Manual decisions live in
tools/translations_overrides.json and win over both signals.

the source DB facts the script relies on (checked): ZekarID is the hisnmuslim id up to ~115 and drifts
after that, so it is never used as a hadith number. Category 135 holds evening copies (Arabic only);
the translated text is on the morning/evening item in category 27. Ids above 275 are Arabic-only
splits of a translated item.

Usage: python -I -X utf8 tools/translations_match.py [--azkar-db PATH] [--out tools/translations_out]
Writes <out>/match.json (contents), <out>/titles.json.
"""
import argparse, collections, difflib, glob, json, os, re, sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from hisn_text import norm, expand_quran_all  # noqa: E402

LANGS = ('En', 'Fr')
DEFAULT_AZKAR_DB = os.environ.get('AZKAR_DB', '')
MORNING_CAT, EVENING_CAT = 27, 135
MORNING_TITLE, EVENING_TITLE = 29, 30
PART_RELATIONS = {'part', 'part_other_chapter', 'part_of_lesson', 'different_wording'}
NO_SOURCE_TITLES = {1, 2}  # book introduction and the virtue of dhikr: not in the source DB


def ro(path):
    return sqlite3.connect(Path(path).resolve().as_uri() + '?mode=ro', uri=True)


HONORIFICS = re.compile(r'\b(صلي الله عليه وسلم|رضي الله عنهما|رضي الله عنها|رضي الله عنه|عليه السلام)\b')


def anorm(t):
    """norm() without the honorifics that one side writes out and the other drops or puts in a glyph."""
    return re.sub(r'\s+', ' ', HONORIFICS.sub(' ', norm(t))).strip()


def ar_clean(t):
    t = re.sub(r'<FN>.*?</FN>', ' ', t or '', flags=re.S)
    return anorm(re.sub(r'<[^>]*>', ' ', t))


def ratio(a, b):
    return difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()


def tok_scores(t, s):
    a, b = set(t.split()), set(s.split())
    if not a or not b:
        return 0, 0
    i = len(a & b)
    return i / len(a), i / len(b)


def load_site(root):
    """hisnmuslim files: {id: {'chapter': n, 'ar': norm, 'en': words}}."""
    site = {}
    for lang in ('ar', 'en'):
        for f in glob.glob(str(Path(root, lang, '*.json'))):
            if not Path(f).stem.isdigit():
                continue
            raw = Path(f).read_text(encoding='utf-8-sig')
            try:
                d = json.loads(raw, strict=False)
            except json.JSONDecodeError:
                # en/126.json is malformed: pick the items out with a regex.
                d = {'?': [{'ID': int(m.group(1)), 'TRANSLATED_TEXT': m.group(2)}
                           for m in re.finditer(r'"ID"\s*:\s*(\d+).*?"TRANSLATED_TEXT"\s*:\s*"(.*?)"', raw, re.S)]}
            for items in d.values():
                for it in items:
                    e = site.setdefault(it['ID'], {'chapter': int(Path(f).stem), 'ar': '', 'en': set()})
                    if lang == 'ar':
                        e['ar'] = anorm(it.get('ARABIC_TEXT', ''))
                        e['chapter'] = int(Path(f).stem)
                    else:
                        txt = ' '.join(str(it.get(k) or '') for k in ('LANGUAGE_ARABIC_TRANSLATED_TEXT', 'TRANSLATED_TEXT', 'Text'))
                        e['en'] = en_words(txt)
    return site


def index_items(root, lang):
    d = json.loads(Path(root, lang, f'husn_{lang}.json').read_text(encoding='utf-8-sig'), strict=False)
    return [it for items in d.values() for it in items]


def ar_title(t):
    return norm((t or '').replace('ﷺ', ' صلى الله عليه وسلم '))


def en_words(t):
    t = re.sub(r'<[^>]*>', ' ', (t or '').lower())
    return set(w for w in re.sub(r'[^a-z]+', ' ', t).split() if len(w) > 2)


def jacc(a, b):
    return len(a & b) / len(a | b) if a and b else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--azkar-db', default=DEFAULT_AZKAR_DB)
    ap.add_argument('--out', default='tools/translations_out')
    ap.add_argument('--raw', default='tools/translations_raw')
    a = ap.parse_args()
    Path(a.out).mkdir(parents=True, exist_ok=True)
    overrides = json.loads(Path('tools/translations_overrides.json').read_text(encoding='utf-8'))

    src = ro(a.azkar_db)
    app = ro('assets/db/hisn_elmoslem.db')
    quran = ro('assets/db/quran.ar.uthmani.v2.db')

    # ---- the source DB side
    zar, zorg, zcat, zsort = {}, {}, {}, {}
    for z, t, org in src.execute('select ZekarID, ZekarText, OrgZekarText from HSN_Ar'):
        zar[z] = ar_clean(t)
        zorg[z] = ar_clean(org) if org and org.strip() else zar[z]
    for c, z, so in src.execute('select CategoryID, ZekarID, sort from HSN_CategoriesHSN_Ar'):
        zcat[z], zsort[z] = c, so
    has = {L: {z for (z,) in src.execute(f'select ZekarID from HSN_{L}')} for L in LANGS}
    translated = has['En'] | has['Fr']
    zen = {z: en_words(t) for z, t in src.execute('select ZekarID, ZekarText from HSN_En')}
    cat_ar = {c: n for c, n in src.execute('select CategoryID, Category from HSN_Categories_Ar')}
    cat_has = {L: {c for (c,) in src.execute(f'select CategoryID from HSN_Categories_{L} where Category is not null and trim(Category) != ""')} for L in LANGS}

    def zscore(t, z):
        return max(ratio(t, zar[z]), ratio(t, zorg[z]) if zorg[z] != zar[z] else 0)

    # canonical(z): the translated the source DB zikr that carries z's translation.
    canon, canon_why = {}, {}
    for z in zar:
        if z in translated:
            canon[z], canon_why[z] = z, 'self'
        elif zcat[z] == EVENING_CAT:
            twins = [m for m in zar if zcat[m] == MORNING_CAT and m in translated]
            best = max(twins, key=lambda m: zscore(zorg[z], m))
            sc = zscore(zorg[z], best)
            canon[z], canon_why[z] = (best, f'evening_twin:{sc:.2f}') if sc >= .8 else (None, 'evening_only')
        else:
            same = [m for m in translated if zcat[m] == zcat[z]]
            cont = [m for m in same if len(zar[z]) >= 8 and (zar[z] in zorg[m] or zar[z] in zar[m])]
            canon[z], canon_why[z] = (cont[0], 'piece_of') if cont else (None, 'untranslated')

    # ---- hisnmuslim side: site id N -> the source DB zikr, by Arabic (site ar vs HSN_Ar) and English (site en vs HSN_En).
    site = load_site(a.raw)
    def site_best(n):
        s = site[n]
        sc = []
        for z in translated:
            r_ar = max(ratio(s['ar'], zar[z]), ratio(s['ar'], zorg[z])) if s['ar'] else 0
            r_en = jacc(s['en'], zen.get(z, set()))
            if s['ar']:
                c1, c2 = tok_scores(s['ar'], zorg[z])
                r_ar = max(r_ar, .9 * min(c1, c2) if min(c1, c2) >= .5 else 0, .8 * c2 if len(zorg[z].split()) >= 3 else 0)
            sc.append((max(r_ar, r_en), r_ar, r_en, z))
        sc.sort(reverse=True)
        return sc
    site_scores = {n: site_best(n) for n in site}
    # site chapter -> the source DB category by the Arabic chapter title (hisnmuslim index vs HSN_Categories_Ar)
    chap_title = {it['ID']: it['TITLE'] for it in index_items(a.raw, 'ar')}
    chap_title_en = {it['ID']: it['TITLE'].strip() for it in index_items(a.raw, 'en')}
    chap_cat = {}
    for ch, name in chap_title.items():
        n = ar_title(name)
        best = max((c for c in cat_ar if c != EVENING_CAT), key=lambda c: ratio(n, ar_title(cat_ar[c])))
        chap_cat[ch] = best
    cat_chap = {c: ch for ch, c in chap_cat.items()}
    site_z = {}
    for n, sc in site_scores.items():
        cat = chap_cat.get(site[n]['chapter'])
        inside = [x for x in sc if zcat[x[3]] == cat or (cat == MORNING_CAT and zcat[x[3]] == EVENING_CAT)]
        # inside the chapter's own category a weaker score is enough; elsewhere it must be strong
        pick = inside[0] if inside and inside[0][0] >= .45 else (sc[0] if sc and sc[0][0] >= .8 else None)
        if pick:
            site_z[n] = {'z': pick[3], 'score': round(pick[0], 3), 'ar': round(pick[1], 3), 'en': round(pick[2], 3),
                         'via': 'ar' if pick[1] >= pick[2] else 'en', 'inChapter': pick in inside}

    # ---- binwahaf side: lesson id -> hadith number; app content -> lessons
    lessons = json.loads(Path('tools/binwahaf_out/content.json').read_text(encoding='utf-8'))
    lesson_num = {}
    for l in lessons:
        m = re.match(r'\s*(\d+)\s*-', l['title'])
        if m:
            lesson_num[int(l['id'])] = int(m.group(1))
    bw = {r['contentId']: [int(x) for x in r['lessons']] for r in json.loads(Path('tools/binwahaf_out/match.json').read_text(encoding='utf-8'))}
    bw_rel = {r['contentId']: r['kind'] for r in json.loads(Path('tools/binwahaf_out/match.json').read_text(encoding='utf-8'))}
    for r in json.loads(Path('tools/binwahaf_out/nomatch_resolved.json').read_text(encoding='utf-8')):
        bw[r['contentId']] = [int(x) for x in r['lessons']]
        bw_rel[r['contentId']] = r['relation']

    # ---- titles
    cat_name = {L: {c: n.strip() for c, n in src.execute(f'select CategoryID, Category from HSN_Categories_{L}') if n and n.strip()} for L in LANGS}

    def title_names(cat, o):
        names = {}
        for L in LANGS:
            l = L.lower()
            if o and o.get('names', {}).get(l):
                names[l] = {'name': o['names'][l], 'from': 'override'}
            elif cat in cat_name[L]:
                names[l] = {'name': cat_name[L][cat], 'from': f'HSN_Categories_{L}'}
            elif L == 'En' and cat in cat_chap and chap_title_en.get(cat_chap[cat]):
                names[l] = {'name': chap_title_en[cat_chap[cat]], 'from': 'hisnmuslim en index'}
        return names

    title_rows = list(app.execute('select id, name from titles order by "order"'))
    title_chapter = json.loads(Path('tools/binwahaf_out/title_chapter.json').read_text(encoding='utf-8'))
    titles = []
    for tid, name in title_rows:
        n = ar_title(name)
        sc = sorted(((ratio(n, ar_title(cn)), c) for c, cn in cat_ar.items()), reverse=True)
        t_cat, t_score = sc[0][1], round(sc[0][0], 3)
        chap = title_chapter[str(tid)][0]
        m = re.match(r'\s*(\d+)', chap)
        n_cat = chap_cat.get(int(m.group(1))) if m else None
        if tid == EVENING_TITLE and n_cat == MORNING_CAT:
            n_cat = EVENING_CAT        # the book has one chapter; the source DB has a separate evening category
        o = overrides['titles'].get(str(tid))
        if o is not None:
            cat, conf, how = o.get('category'), 'manual', o.get('note', '')
        elif tid in NO_SOURCE_TITLES:
            cat, conf, how = None, 'none', 'no chapter in the source DB (book introduction)'
        elif t_score >= .8 and t_cat == n_cat:
            cat, conf, how = t_cat, 'high', 'text+number'
        elif t_score >= .9:
            cat, conf, how = t_cat, 'medium', 'text only'
        else:
            cat, conf, how = None, 'review', ''
        titles.append({'titleId': tid, 'name': name, 'category': cat, 'confidence': conf, 'how': how,
                       'text': {'category': t_cat, 'score': t_score, 'name': cat_ar[t_cat]},
                       'number': {'chapter': chap, 'category': n_cat},
                       'names': title_names(cat, o),
                       'langs': [L.lower() for L in LANGS if cat in cat_has[L]] if cat else []})

    # ---- contents
    rows = list(app.execute('select id, titleId, "order", content from contents order by titleId, "order"'))
    title_cat = {t['titleId']: t['category'] for t in titles}
    out = []
    for cid, tid, order, content in rows:
        t = anorm(expand_quran_all(content, quran))
        cat = title_cat.get(tid)
        cats = {cat} | ({EVENING_CAT, MORNING_CAT} if tid == EVENING_TITLE else set())
        # ---- text signal: every the source DB zikr (ZekarText and OrgZekarText), the title's category first
        scored = []
        for z in zar:
            for zt in {zar[z], zorg[z]}:
                cont, back = tok_scores(t, zt)
                r = ratio(t, zt) if max(cont, back) > .5 else 0
                scored.append({'r': r, 'cont': cont, 'back': back, 'z': z, 'zt': zt, 'in': zcat[z] in cats})
        scored.sort(key=lambda x: (x['r'], x['in'], x['z'] in translated), reverse=True)
        in_cat = [x for x in scored if x['in']]

        def same_text(pool, floor):
            top = pool[0]['r'] if pool else 0
            if top >= floor:
                ties = [x for x in pool if x['r'] >= top - .005]
                if any(canon[x['z']] is not None for x in ties):
                    return ('exact' if top >= .98 else 'near'), ties
            return None, []

        def contained(pool):
            # the app zikr is a piece of one the source DB zikr
            part = [x for x in pool if len(t) >= 6 and t in x['zt'] and canon[x['z']] is not None]
            part.sort(key=lambda x: -len(x['zt']))
            return ('partial', part[:1]) if part else (None, [])

        def pieces_of(pool):
            # one or more the source DB zikrs inside the app zikr, without overlaps
            spans, picked = [], []
            for x in sorted((x for x in pool if len(x['zt']) >= 6 and x['zt'] in t and canon[x['z']] is not None), key=lambda x: -len(x['zt'])):
                i = t.index(x['zt'])
                if any(i < e and i + len(x['zt']) > b for b, e in spans) or canon[x['z']] in [canon[p['z']] for p in picked]:
                    continue
                spans.append((i, i + len(x['zt'])))
                picked.append(x)
            covered = sum(e - b for b, e in spans)
            if len(picked) >= 2 and covered >= .6 * len(t):
                return 'combined', sorted(picked, key=lambda x: t.index(x['zt']))
            if picked:
                return ('superset' if covered >= .5 * len(t) else 'superset_small'), picked[:1]
            return None, []

        text_kind, ties = 'nomatch', []
        for step in (lambda: same_text(in_cat, .85), lambda: contained(in_cat), lambda: pieces_of(in_cat),
                     lambda: same_text(scored, .9), lambda: contained(scored) if len(t) >= 12 else (None, [])):
            k, ties = step()
            if k:
                text_kind = k
                break
        text_z = [x['z'] for x in ties]
        tie_canon = []
        for z in text_z:
            if canon[z] is not None and canon[z] not in tie_canon:
                tie_canon.append(canon[z])
        # ---- number signal
        nums = [lesson_num[l] for l in bw.get(cid, []) if l in lesson_num]
        num_z, num_links = [], []
        for n in nums:
            if n in site_z and canon[site_z[n]['z']] is not None and canon[site_z[n]['z']] not in num_z:
                num_z.append(canon[site_z[n]['z']])
                num_links.append(site_z[n])
        # text candidates with the same text: the number signal picks among them
        if text_kind == 'combined':
            text_canon = tie_canon
        elif len(tie_canon) > 1 and set(num_z) & set(tie_canon):
            text_canon = [z for z in tie_canon if z in num_z][:1]
        else:
            text_canon = tie_canon[:1]
        # ---- decision
        o = overrides['contents'].get(str(cid))
        note, why = None, ''
        if o is not None:
            final, kind, conf, note, why = o.get('zikrs', []), o.get('coverage'), 'manual', o.get('note'), 'override'
        elif text_canon and num_z and set(text_canon) == set(num_z):
            final, kind, conf, why = text_canon, text_kind, 'high', 'text and number agree'
        elif text_canon and not nums and text_kind in ('exact', 'near', 'partial', 'combined', 'superset'):
            final, kind, conf, why = text_canon, text_kind, 'medium', 'text only (no binwahaf lesson)'
        elif len(num_z) == 1 and text_kind not in ('exact', 'near') and num_links[0]['score'] >= .8:
            # number route, the text signal found nothing better: the the source DB item is the hisnmuslim
            # item of the same hadith number
            # (coverage from binwahaf's own relation between the app zikr and the lesson)
            z = num_z[0]
            r = zscore(t, z)
            cont, back = tok_scores(t, zorg[z])
            rel = bw_rel.get(cid)
            kind = 'partial' if rel in PART_RELATIONS else 'near'
            final, conf = num_z, 'medium'
            why = f'number route (binwahaf {rel}); Arabic ratio {r:.2f}, contained {cont:.2f}, covers {back:.2f}'
            if num_links[0]['via'] == 'en':
                why += '; the source DB English equals the hisnmuslim item'
            elif max(cont, back) < .5 and r < .5:
                final, conf, why = [], 'review', 'number route only, no text support'
        elif not text_canon and not num_z and tid in NO_SOURCE_TITLES:
            final, kind, conf, why = [], None, 'none', 'no counterpart in the source DB'
        else:
            final, kind, conf, why = [], text_kind, 'review', 'signals disagree or are missing'
        if kind == 'superset':
            kind = 'near'
        elif kind == 'superset_small':
            # the the source DB Arabic is only the formula, but when its English is the hisnmuslim item of the same
            # hadith the translation covers the whole app text (narration included)
            kind = 'near' if conf == 'high' and num_links and num_links[0]['en'] >= .9 else 'partial'
        # an Arabic-only piece carried by a longer translated item is partial
        if final and conf != 'manual' and kind in ('exact', 'near') and any(canon_why[z] == 'piece_of' for z in text_z if canon[z] in final):
            kind = 'partial'
        # morning/evening: an evening zikr carried by a morning item is accepted only when the source DB's
        # evening copy has the same Arabic as the morning item (otherwise the meaning says "morning")
        me = None
        if tid == EVENING_TITLE and (final or conf == 'review'):
            ev = [z for z in text_z if zcat[z] == EVENING_CAT]
            if ev and (final or num_z):
                carrier = final or num_z
                sc = max(ratio(zorg[ev[0]], zorg[z]) for z in carrier)
                me = {'eveningZikr': ev[0], 'carrier': carrier, 'arabicRatio': round(sc, 3)}
                if conf == 'manual':
                    me['decision'] = 'override'
                elif sc < .995:
                    me['decision'] = 'excluded: evening wording differs from the morning text that the translation renders'
                    final, conf = [], 'evening_excluded'
                else:
                    me['decision'] = 'accepted: same Arabic as the morning item'
        out.append({'contentId': cid, 'titleId': tid, 'order': order, 'zikrs': final, 'coverage': kind if final else None,
                    'confidence': conf, 'why': why, 'note': note,
                    'text': {'kind': text_kind, 'zikrs': text_z, 'canonical': text_canon,
                             'ratio': round(ties[0]['r'] if ties else scored[0]['r'], 3), 'best': (ties or scored)[0]['z']},
                    'number': {'hadith': nums, 'zikrs': num_z, 'links': num_links},
                    'morningEvening': me,
                    'langs': [L.lower() for L in LANGS if final and all(z in has[L] for z in final)],
                    'arabic': t[:200]})

    Path(a.out, 'match.json').write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding='utf-8')
    Path(a.out, 'titles.json').write_text(json.dumps(titles, ensure_ascii=False, indent=1), encoding='utf-8')
    Path(a.out, 'azkar_ar.json').write_text(json.dumps({z: {'cat': zcat[z], 'ar': zorg[z][:300], 'canon': canon[z], 'why': canon_why[z]} for z in sorted(zar)}, ensure_ascii=False, indent=1), encoding='utf-8')
    Path(a.out, 'site_link.json').write_text(json.dumps({'chapter_category': chap_cat, 'site_zikr': site_z}, ensure_ascii=False, indent=1), encoding='utf-8')
    print(len(out), 'contents', dict(collections.Counter((r['confidence'], r['coverage']) for r in out)))
    print(len(titles), 'titles', dict(collections.Counter(t['confidence'] for t in titles)))


if __name__ == '__main__':
    main()
