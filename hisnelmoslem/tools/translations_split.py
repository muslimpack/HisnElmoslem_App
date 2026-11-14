#!/usr/bin/env python3
"""Split the the source DB English and French blobs into transliteration, meaning and note.

Each the source DB zikr is one blob wrapped in <1>...</1>. The layout differs per language:
  English: line based. Transliteration lines, then the meaning in single quotes, plus narration
           ("The Prophet said: ...") and glossary / "Note:" lines. Some items carry a second
           version for the other time of day ("In the evening:", "...likewise, one says in the morning:").
  French : paragraph based. Meaning first, then a blank line and the transliteration (hard wrapped).
           Instructions are in [brackets].
Output per zikr: translit, meaning, note, optional sections {morning|evening: {translit, meaning}},
and flags for anything uncertain. Transliteration keeps the published style (En "AA", Fr "c" for ayn).

Usage: python -I -X utf8 tools/translations_split.py [--azkar-db PATH] [--out tools/translations_out]
Writes <out>/split.json.
"""
import argparse, difflib, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from translations_match import DEFAULT_AZKAR_DB, ro, ar_clean  # noqa: E402

# the source DB English uses a symbol font (private use area) for the honorifics.
PUA = {0xF072: '(peace be upon him)', 0xF074: '(may Allah be pleased with him)', 0xF075: '(peace be upon him)',
       0xF073: '(may Allah be pleased with her)'}
EN_STOP = set('the and of to is are was were you your he his him who whom which that with for from be by it its this these as at on all '
              'i my me we our us not nor has have had there one when then should will would shall if or so do does what upon unto '
              'into than they their them she her said say says o lord'.split())
FR_STOP = set("le les de des du et à que qui est il elle je tu nous vous ne pas en pour sur dans par ce cette ces son sa ses mon mes "
              "te se un une au aux lui toi moi leur leurs ton ta tes notre nos votre vos été être dit dire ô seigneur contre auprès "
              "comme fois celui ceux toute tout tous".split())
TRANSLIT_HINT = re.compile(r"(aa|ee|oo|[âîû]|^(al|bi|li|wa|fa|ka)-|-(l|al|il|ul|ll)-|-(l|al)\b|^l-|lah\b|lahu|llah|allâh|"
                           r"\b(allahumma|allâhumma|inn[eaî]|ilaha|ilâha|illa|illâ|subhana|subhâna|rabbi|rabbana|rabbanâ|bismi|bismil|"
                           r"astaghfiru|hamd|akbar|calâ|aAAoothu|acûdhu|wa|la|lâ|min|mina|ma|mâ|fee|fî|ya|yâ|anta|laka|bika|lahu)\b)")
INSTR_EN = re.compile(r'^(note\b|recite|it is also from|the following|this supplication|one should|summary|in the evening|for the evening|'
                      r'\.\.\.|…|then\b|\(|\u25a0)', re.I)
RECITE = re.compile(r'\b(recit(e|es|ed|ing)|lire|réciter)\b', re.I)
EVENING_START = re.compile(r'^(in the evening|for the evening, the supplication is read)', re.I)
MORNING_START = re.compile(r'(likewise, one says in the morning)', re.I)
# Arabic honorifics written inside the English text
AR_HONORIFICS = [('تبارك و تعالى', '(the Blessed and Exalted)'), ('تبارك وتعالى', '(the Blessed and Exalted)'),
                 ('رحمه الله', '(may Allah have mercy on him)'), ('رضي الله عنهما', '(may Allah be pleased with them)'), ('رضي الله عنها', '(may Allah be pleased with her)'),
                 ('رضي الله عنه', '(may Allah be pleased with him)'), ('صلى الله عليه وسلم', '(peace be upon him)'),
                 ('عليه السلام', '(peace be upon him)'), ('عز وجل', '(the Mighty and Majestic)'), ('تعالى', '(the Exalted)')]
GLOSS = re.compile(r"^[A-Za-z’'\- ]{2,40}\s?:\s?\S")      # "shaheed: one who ...", "al-waseelah: A station ..."


def clean(t):
    t = re.sub(r'</?\d+>', '', t or '')
    t = ''.join(PUA.get(ord(c), c) for c in t)
    for k, v in AR_HONORIFICS:
        t = t.replace(k, v)
    t = t.replace('\u25a0', '\u2022').replace('\t', ' ').replace('\r\n', '\n').replace('\r', '\n')
    t = re.sub(r'[\x00-\x08\x0b-\x1f\x7f\u200b-\u200f\u202a-\u202e\ufeff]', '', t)
    t = re.sub(r'&[a-z]+;|&#\d+;', ' ', t)
    t = re.sub(r'<<\s*|\s*>>', '', t)                          # En 50 marks a verse with << >>
    lines = [re.sub(r'[ \u00a0]+', ' ', l).strip() for l in t.split('\n')]
    lines = [l for l in lines if not re.fullmatch(r'[\s.)(“”"]*', l)]   # stray ")" "." lines
    lines = [re.sub(r'\s+[“"]$', '', re.sub(r'(?<=\s)>|>(?=[A-Za-z])', '', l)) for l in lines]   # stray '>' and dangling quote
    return lines


def words(line):
    return re.findall(r"[^\W\d_]+(?:[-'’][^\W\d_]+)*", line.lower())


def translit_score(line, stop):
    w = words(line)
    if not w:
        return 0, 0
    n = len(w)
    s = sum(1 for x in w if x in stop)
    h = sum(1 for x in w if TRANSLIT_HINT.search(x))
    return h / n, s / n


def is_translit(line, lang):
    hint, stop = translit_score(re.sub(r'\([^)]*\)|\[[^\]]*\]', ' ', line), EN_STOP if lang == 'en' else FR_STOP)
    if not words(line):
        return False
    if lang == 'en' and stop == 0 and not line.startswith(('‘', '’', '“', '"')):
        return True       # English meaning lines are quoted; an unquoted line without any English word is transliteration
    return stop <= .12 and hint >= .25


def join_wrapped(lines):
    """French blobs are hard wrapped: join lines unless the previous one ends a sentence."""
    out = []
    for l in lines:
        if out and not re.search(r'[.!?:;)\]»”’]$', out[-1]):
            out[-1] = out[-1] + ('' if out[-1].endswith('-') else ' ') + l
        else:
            out.append(l)
    return out


def unquote(line):
    m = re.fullmatch(r'[‘’](.*)’(\s*\([^)]*\))?\.?', line)
    if m and '‘' not in m.group(1):
        return (m.group(1) + (m.group(2) or '')).strip()
    return line


def split_en(blob):
    lines = clean(blob)
    flags = []
    section = None
    parts = {None: {'translit': [], 'meaning': [], 'narr': []}}
    note = []
    for l in lines:
        if EVENING_START.match(l):
            section = 'evening'
            parts.setdefault(section, {'translit': [], 'meaning': [], 'narr': []})
            if not parts[None]['translit'] and not parts[None]['meaning']:
                flags.append('evening marker before any text')
            continue
        if MORNING_START.search(l):
            section = 'morning'
            parts.setdefault(section, {'translit': [], 'meaning': [], 'narr': []})
            continue
        p = parts[section]
        bare = re.sub(r'^[{(]|[})]$', '', l)
        if is_translit(l, 'en'):
            # Quran verses come as {first words…} [Sura]; keep the reference with the line
            p['translit'].append(re.sub(' {2,}', ' ', re.sub(r'^\{(.*?)\}', r'\1', l).replace('{', '').replace('}', '')).strip())
        elif re.match(r'^note\s*:', l, re.I) or (GLOSS.match(l) and not re.match(r"^(the|he|she|ibn|abu|aboo|jabir|sa’d|o )", l, re.I)
                                                 and len(l.split(':')[0].split()) <= 4):
            note.append(l)
        elif re.fullmatch(r'\((?:[^()]|\([^)]*\))*\)\.?', l) and not is_translit(bare, 'en'):
            note.append(l)                                  # "(one hundred times every day)", "(From Verse 3:190 ...)"
        else:
            # meaning, narration and instructions stay together in the published order
            p['meaning'].append(unquote(l) if p['translit'] else l)
    main = parts.pop(None)
    res = {'translit': main['translit'], 'meaning': main['meaning'], 'note': note, 'flags': flags}
    # The first section (before a marker) belongs to the other time of day
    if parts:
        other = {'evening': 'morning', 'morning': 'evening'}[next(iter(parts))]
        res['sections'] = {other: {'translit': main['translit'], 'meaning': main['meaning']}}
        for k, v in parts.items():
            res['sections'][k] = {'translit': v['translit'], 'meaning': v['meaning']}
    return res


def split_fr(blob):
    t = '\n'.join(clean(blob)) if blob else ''
    raw = re.sub(r'</?\d+>', '', blob or '').replace('\r\n', '\n').replace('\r', '\n')
    paras = [p for p in re.split(r'\n[ \t\u00a0]*\n', raw)]
    flags, note, translit, meaning = [], [], [], []
    for p in paras:
        lines = clean(p)
        if not lines:
            continue
        lines = join_wrapped(lines)
        tl = [l for l in lines if is_translit(l, 'fr')]
        if len(''.join(tl)) >= .6 * len(''.join(lines)):
            translit += lines
            continue
        for l in lines:
            m = re.match(r'^\[([^\]]*:)\s*\]\s*(.*)$', l) or re.match(r'^\[([^\]]*)\]\s*$', l)
            if m:
                note.append('[' + m.group(1).strip() + ']')
                rest = m.group(2).strip() if m.lastindex and m.lastindex >= 2 else ''
                if rest:
                    meaning.append(rest)
            elif re.match(r'^-\s*voir\b', l, re.I):
                note.append(l)
            elif tl and l in tl and meaning:
                translit.append(l)       # a transliteration line inside a French paragraph (after the meaning)
            else:
                meaning.append(l)
    if not t:
        flags.append('empty')
    return {'translit': translit, 'meaning': meaning, 'note': note, 'flags': flags}


# ---- transliteration vs Arabic: compare consonant skeletons
AR_SK = {'ب': 'b', 'ت': 't', 'ث': 't', 'ج': 'j', 'ح': 'h', 'خ': 'k', 'د': 'd', 'ذ': 'd', 'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 's',
         'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': 'c', 'غ': 'g', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
         'ه': 'h', 'و': 'w', 'ي': 'y'}


def ar_skeleton(ar):
    sk = ''.join(AR_SK.get(c, '') for c in ar.replace('ال', 'ل'))
    return re.sub(r'(.)\1+', r'\1', sk)


def lat_skeleton(s, lang):
    s = s.lower()
    s = re.sub(r'\([^)]*\)|\[[^\]]*\]', ' ', s)
    if lang == 'en':
        s = s.replace('aa', 'c')
    s = s.replace('sh', 's').replace('th', 't').replace('dh', 'd').replace('kh', 'k').replace('gh', 'g')
    s = s.replace('ee', 'y').replace('oo', 'w')
    s = re.sub(r'[aeiouâîûáíúàèéêôy\W\d_]', '', s) if False else re.sub(r'[^bcdfghjklmnpqrstvwxz]', '', s)
    s = s.replace('x', 'ks').replace('p', 'b').replace('v', 'f')
    return re.sub(r'(.)\1+', r'\1', s)


def skeleton_ratio(translit, ar, lang):
    a, b = ar_skeleton(ar).replace('w', '').replace('y', ''), lat_skeleton(translit, lang).replace('w', '').replace('y', '')
    if not a or not b:
        return None
    sm = difflib.SequenceMatcher(None, b, a, autojunk=False)
    # share of the transliteration found in the Arabic (the Arabic may be longer: narration, verses)
    return round(sum(m.size for m in sm.get_matching_blocks()) / len(b), 3)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--azkar-db', default=DEFAULT_AZKAR_DB)
    ap.add_argument('--out', default='tools/translations_out')
    a = ap.parse_args()
    src = ro(a.azkar_db)
    ar = {}
    for z, t, org in src.execute('select ZekarID, ZekarText, OrgZekarText from HSN_Ar'):
        ar[z] = ar_clean(org if org and org.strip() and len(org) > len(t or '') else t)
    out = {}
    for lang, fn in (('en', split_en), ('fr', split_fr)):
        out[lang] = {}
        for z, blob in src.execute(f'select ZekarID, ZekarText from HSN_{lang.capitalize()} order by ZekarID'):
            r = fn(blob)
            if r['translit'] and z in ar:
                r['translitVsArabic'] = skeleton_ratio(' '.join(r['translit']), ar[z], lang)
                if r['translitVsArabic'] is not None and r['translitVsArabic'] < .6:
                    r['flags'].append(f"transliteration differs from the Arabic (skeleton {r['translitVsArabic']})")
            if not r['translit'] and not r['meaning']:
                r['flags'].append('no translit and no meaning (instruction only)')
            # text without transliteration that only tells to recite something is an instruction, not a meaning
            r['instructionOnly'] = bool(not r['translit'] and r['meaning'] and RECITE.search(' '.join(r['meaning'])))
            if r['instructionOnly']:
                r['flags'].append('instruction to recite (stored as note)')
            out[lang][z] = r
    Path(a.out).mkdir(parents=True, exist_ok=True)
    Path(a.out, 'split.json').write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding='utf-8')
    for lang, d in out.items():
        print(lang, len(d), 'items;', sum(1 for r in d.values() if r['translit']), 'with translit;',
              sum(1 for r in d.values() if r['meaning']), 'with meaning;',
              sum(1 for r in d.values() if r['flags']), 'flagged')


if __name__ == '__main__':
    main()
