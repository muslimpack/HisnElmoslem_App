#!/usr/bin/env python3
"""Match DB contents to binwahaf lessons by text similarity. Writes match.json next to content.json.

Usage: python tools/binwahaf_match.py [--site tools/binwahaf_out/content.json] [--out DIR]
"""
import argparse, difflib, json, re, sqlite3
from pathlib import Path

DIA = re.compile('[\u064b-\u065f\u0670\u06d6-\u06ed\u0640\u200c-\u200f\u202a-\u202f]')

def norm(s: str) -> str:
    s = DIA.sub('', s or '')
    s = s.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ٱ', 'ا')
    s = s.replace('ى', 'ي').replace('ة', 'ه').replace('ؤ', 'و').replace('ئ', 'ي')
    s = re.sub(r'[^\u0621-\u064a ]', ' ', s)
    return re.sub(r'\s+', ' ', s).strip()

def expand_quran_all(text, q):
    def rep(m):
        out = []
        for part in re.findall(r'\(([\d:]+)\)', m.group(0)):
            sura, a, b = (int(x) for x in part.split(':'))
            out += [r[0] for r in q.execute('select text from arabic_text where sura=? and ayah between ? and ? order by ayah', (sura, a, b))]
        return ' '.join(out)
    return re.sub(r'QuranText\[[^\]]*\]', rep, text or '')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--site', default='tools/binwahaf_out/content.json')
    ap.add_argument('--out', default='tools/binwahaf_out')
    a = ap.parse_args()
    site = json.loads(Path(a.site).read_text(encoding='utf-8'))
    c = sqlite3.connect('assets/db/hisn_elmoslem.db'); q = sqlite3.connect('assets/db/quran.ar.uthmani.v2.db')
    stoks = [(l, norm(l.get('text', ''))) for l in site]
    chapters = {}
    for l, st in stoks:
        chapters.setdefault(l['chapter'], []).append((l, st))
    chap_keys = list(chapters)
    chap_norm = {k: norm(re.sub(r'^[\d\s،:\-]+', '', k)) for k in chap_keys}
    # DB title -> site chapter by name (morning and evening share one chapter)
    title_chapter = {}
    for tid, name in c.execute('select id,name from titles'):
        n = norm(name)
        best = max(chap_keys, key=lambda k: difflib.SequenceMatcher(None, n, chap_norm[k]).ratio())
        title_chapter[tid] = (best, round(difflib.SequenceMatcher(None, n, chap_norm[best]).ratio(), 2))
    # Names that do not match by text: the intro, and morning/evening sharing one chapter.
    manual = {1: 'المقدمة', 2: 'المقدمة', 29: '27- أذكار الصباح والمساء', 30: '27- أذكار الصباح والمساء'}
    for tid, key in manual.items():
        if key in chapters:
            title_chapter[tid] = (key, 1.0)
    result = []
    for cid, tid, order, content in c.execute('select id,titleId,"order",content from contents order by id'):
        t = norm(expand_quran_all(content, q))
        dt = set(t.split())
        scored = []
        chap, chap_score = title_chapter[tid]
        for l, st in chapters[chap]:
            ss = set(st.split())
            if not dt or not ss: continue
            cont = len(dt & ss) / len(dt)          # how much of the DB text is in the lesson
            back = len(dt & ss) / len(ss)          # how much of the lesson is in the DB text
            ratio = difflib.SequenceMatcher(None, t, st, autojunk=False).ratio() if cont > .5 else 0
            scored.append((max(ratio, 0), cont, back, l['id']))
        scored.sort(reverse=True)
        top = scored[:3]
        best = top[0] if top else (0, 0, 0, None)
        # How the DB item relates to the best lesson. "part" and "whole" need a real
        # contiguous (diacritic-free) overlap, so short texts cannot match long lessons by chance.
        kind, lessons = 'nomatch', []
        if best[0] >= .98: kind, lessons = 'exact', [best[3]]
        elif best[0] >= .85: kind, lessons = 'near', [best[3]]
        elif t:
            part = [l['id'] for l, st in chapters[chap] if len(t) >= 12 and t in st]
            if part: kind, lessons = 'part', part[:1]           # the DB item is one piece of a lesson
            else:
                whole = [l['id'] for l, st in chapters[chap] if len(st) >= 12 and st in t]
                if whole: kind, lessons = 'whole', whole          # the DB item holds several lessons
                else:
                    glob = [l['id'] for l, st in stoks if len(t) >= 12 and t in st]
                    if glob: kind, lessons = 'part_other_chapter', glob[:1]
        result.append({'contentId': cid, 'titleId': tid, 'order': order, 'chapter': chap, 'chapterScore': chap_score,
                       'kind': kind, 'lessons': lessons, 'norm': t[:80],
                       'best': [{'lesson': x[3], 'ratio': round(x[0], 3), 'contained': round(x[1], 3), 'covers': round(x[2], 3)} for x in top]})
    Path(a.out, 'match.json').write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding='utf-8')
    Path(a.out, 'title_chapter.json').write_text(json.dumps({str(k): v for k, v in title_chapter.items()}, ensure_ascii=False, indent=1), encoding='utf-8')
    import collections
    print(len(result), 'contents;', dict(collections.Counter(r['kind'] for r in result)))

main()
