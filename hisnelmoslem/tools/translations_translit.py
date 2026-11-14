#!/usr/bin/env python3
"""Rule-based transliteration of fully vowelled Arabic in the two styles of the published rows.

en (hisnmuslim style): 'Allahumma anta rabbee la ilaha illa ant, khalaqtanee wa-ana AAabduk'
    long vowels a / ee / oo, ayn 'AA', hamza '-' before a vowel ("as-aluka", "wa-ana") and "'" before a
    consonant, th for ث ذ ظ, prefixes written together ("walhamdu", "billahi"), and a word whose first
    vowel is elided joined to the previous word ("illal-lahu", "fatiras-samawati", "maAAas-mihi").
    Pause (drop of the final short vowel, -un/-in, ta marbuta -> h) before , ; . : and at the end.
fr (French rows):     'Allâhumma anta rabbî, lâ ilâha illâ anta.'
    long vowels â / î / û, ayn 'c', hamza "'", dh for ذ, z for ظ, consonants sh / j / kh / gh as in the
    published French rows (not ch / dj), article as "l-" / "sh-" after a space ("mina sh-shaytâni
    r-rajîm"), "bi-l-lâhi", "wa-l-ardi", "wa lâ", "fa-ghfir". Pause only before . ; : and at the end.

Input: the app's vowelled text (sukun U+0652), or Uthmani Quran text from quran.ar.uthmani.v2.db with
quran=True (sukun U+06E1; U+0652 and U+06E0 mark a silent letter; alef wasla; small waw / yeh; open
tanwin forms; waqf marks read as a comma).

`vowel_coverage(text)` is the share of consonants that carry a vowel, shadda or sukun; a text below
about 0.95 is not vowelled enough for the rule and needs a vowelled override.

Usage: python -I -X utf8 tools/translations_translit.py en|fr "<arabic>"
"""
import re
import sys

FATHA, DAMMA, KASRA = 'َ', 'ُ', 'ِ'
SHADDA, SUKUN, Q_SUKUN = 'ّ', 'ْ', 'ۡ'
VOWEL = {FATHA: 'a', DAMMA: 'u', KASRA: 'i'}
TANWIN = {'ً': 'an', 'ٗ': 'an', 'ٌ': 'un', 'ٞ': 'un', 'ٍ': 'in', 'ٖ': 'in'}
DAGGER, SMALL_WAW, SMALL_YEH, SMALL_HIGH_YEH = 'ٰ', 'ۥ', 'ۦ', 'ۧ'
IQLAB = ('ۢ', 'ۭ')
SILENT = '۠'
WAQF = 'ۖۗۘۚۛۜ'
AYAH_END = '۝'

CONS = {'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j', 'ح': 'H', 'خ': 'kh', 'د': 'd', 'ذ': 'dh', 'ر': 'r', 'ز': 'z',
        'س': 's', 'ش': 'sh', 'ص': 'S', 'ض': 'D', 'ط': 'T', 'ظ': 'Z', 'ع': 'c', 'غ': 'gh', 'ف': 'f', 'ق': 'q',
        'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n', 'ه': 'h', 'و': 'w', 'ي': 'y', 'ة': 'T_', 'ء': "'", 'أ': "'",
        'إ': "'", 'ؤ': "'", 'ئ': "'", 'آ': "'"}
SUN = set('تثدذرزسشصضطظلن')
LETTERS = set(CONS) | {'ا', 'ٱ', 'ى'}
STYLE = {
    'en': {'th': 'th', 'H': 'h', 'dh': 'th', 'S': 's', 'D': 'd', 'T': 't', 'Z': 'th', 'c': 'AA', 'T_': 't',
           'A': 'a', 'I': 'ee', 'U': 'oo'},
    'fr': {'th': 'th', 'H': 'h', 'dh': 'dh', 'S': 's', 'D': 'd', 'T': 't', 'Z': 'z', 'c': 'c', 'T_': 't',
           'A': 'â', 'I': 'î', 'U': 'û'},
}
PAUSE = {'en': set(',;.:!?]'), 'fr': set(';.:!?]')}
PUNCT = {'،': ',', '؛': ';', '؟': '?'}
SHORT_WORDS = {'لا', 'لم', 'لن', 'من', 'ما', 'في', 'هو', 'هي', 'له', 'لك', 'لي', 'به', 'بك', 'بي', 'هم', 'إن', 'أن', 'عن', 'قد',
               'كل', 'ذا', 'إذ', 'لو', 'يا', 'أو', 'إلى', 'على', 'لنا', 'بنا', 'منك', 'منه'}   # after wa / fa, short words that are not roots
PRONOUN_TAILS = {'ك', 'ه', 'ي', 'نا', 'كم', 'هم', 'هما', 'كما', 'هن', 'كن'}
VOWEL_CHARS = 'aeiouâîûAEIOU'
H = '[ً-ْ]*'
NB = r'(?<![ء-ي])'
NA = r'(?![ء-ي])'
# long a that ordinary vowelled text leaves unwritten
LEXICON = [
    (re.compile(NB + '([وفب]?' + H + ')(ه' + H + ')(?=ذ' + H + '[اهيى])'), r'\1\2' + DAGGER),          # هذا هذه هذين
    (re.compile(NB + '([وفبك]?' + H + ')(ذ' + H + ')(?=ل' + H + 'ك)'), r'\1\2' + DAGGER),              # ذلك
    (re.compile(NB + '([وف]?' + H + ')(ل' + H + ')(?=ك' + H + 'ن' + H + NA + ')'), r'\1\2' + DAGGER),    # لكن
    (re.compile('(إ' + H + 'ل' + H + ')(?=ه' + H + '(?:' + NA + '|ي|ن|ك))'), r'\1' + DAGGER),          # إله إلهي إلهنا
    (re.compile('(ر' + H + 'ح' + H + 'م' + H + ')(?=ن' + H + NA + ')'), r'\1' + DAGGER),                 # الرحمن
    (re.compile('(س' + H + 'م' + H + ')(?=و' + H + 'ا' + H + 'ت)'), r'\1' + DAGGER),                    # السموات
]


def _prep(text, quran):
    t = re.sub('ـ(' + H + ')ٔ(' + H + ')', 'ء\\1\\2', text)          # hamza on a tatweel: يَـُٔودُهُۥ
    t = t.replace('ـ', '').replace('ﷺ', ' ').replace('۞', ' ')
    t = re.sub('[' + WAQF + ']', ' ، ', t)
    t = t.replace(AYAH_END, ' . ')
    t = re.sub(r'\(\(|\)\)|[«»"“”()﴿﴾*]', ' ', t)
    if not quran:
        for rx, rep in LEXICON:
            t = rx.sub(rep, t)
    return t


def _tokens(text):
    out = []
    for m in re.finditer(r'[ء-يٱ][ً-ٰٟ۠-ۭ]*(?:[ء-يٱ][ً-ٰٟ۠-ۭ]*)*|[،؛؟,.:;!?\[\]]', text):
        s = m.group(0)
        if len(s) == 1 and s in '،؛؟,.:;!?[]':
            out.append(('p', PUNCT.get(s, s)))
            continue
        units = []
        for ch in s:
            if ch in LETTERS:
                units.append([ch, set()])
            elif units:
                units[-1][1].add(ch)
        out.append(('w', units))
    return out


def _vowel_of(marks):
    for k, v in VOWEL.items():
        if k in marks:
            return v + 'n' if any(i in marks for i in IQLAB) else v
    for k, v in TANWIN.items():
        if k in marks:
            return v
    return ''


class Seg:
    __slots__ = ('c', 'v')

    def __init__(self, c, v=''):
        self.c, self.v = c, v

    def __repr__(self):
        return f'{self.c}{self.v}'


class Word:
    __slots__ = ('pre', 'art', 'wasl', 'segs')

    def __init__(self, pre, art, wasl, segs):
        self.pre, self.art, self.wasl, self.segs = pre, art, wasl, segs


def _parse(units, quran):
    u = [[c, set(m)] for c, m in units]
    if quran:
        u = [x for x in u if not (SUKUN in x[1] and x[0] in 'اوىي') and SILENT not in x[1]]
        for x in u:
            if Q_SUKUN in x[1]:
                x[1].add(SUKUN)
    else:
        u = [x for x in u if SILENT not in x[1]]
    if u and SHADDA in u[0][1]:
        u[0][1].discard(SHADDA)               # assimilated tanwin / nun of the previous word: نَوۡمٞ لَّهُۥ, مِّنۡ

    def vowel(k):
        if not 0 <= k < len(u):
            return ''
        v = _vowel_of(u[k][1])
        if not v and k + 1 < len(u) and u[k + 1][0] == 'ا' and u[k][0] not in 'اٱ':
            v = _vowel_of(u[k + 1][1]) or ('a' if SHADDA in u[k + 1][1] else '')   # marks typed on the alif: لاَ
        return v

    def is_article(k):
        if k + 2 >= len(u) or u[k][0] not in 'اٱ' or u[k + 1][0] != 'ل':
            return False
        if u[k][0] == 'ا' and vowel(k) and k == 0:
            return False
        return SUKUN in u[k + 1][1] or not vowel(k + 1) or SHADDA in u[k + 2][1] or SHADDA in u[k + 1][1]

    pre, i = [], 0
    while i < len(u) - 2 and len(pre) < 2:
        c, m = u[i]
        nxt = u[i + 1]
        rest = ''.join(x[0] for x in u[i + 1:])
        if c == 'ل' and vowel(i) in ('i', '') and SHADDA not in m and nxt[0] == 'ل' and (SUKUN in nxt[1] or SHADDA in nxt[1] or SHADDA in u[i + 2][1]):
            pre.append(Seg('l', 'i'))            # li + article without its alif: لِلْمَوْتِ, لِلَّهِ, للَّهِ
            u.insert(i + 1, ['ا', set()])
            if SHADDA in nxt[1]:
                u.insert(i + 2, ['ل', set()])     # the article lam is assimilated into the written one
            i += 1
            continue
        if c not in 'وفبلك' or vowel(i) not in ('a', 'i') or SHADDA in m:
            break
        if is_article(i + 1) or (nxt[0] in 'أإآ' and len(rest) >= 2) or (nxt[0] in 'اٱ' and c in 'وف' and not _vowel_of(nxt[1])):
            pre.append(Seg(CONS[c], vowel(i)))
            i += 1
            continue
        if c in 'وف' and vowel(i + 1) and not pre and (rest in SHORT_WORDS or len(rest) + sum(SHADDA in x[1] for x in u[i + 1:]) >= 3):
            pre.append(Seg(CONS[c], vowel(i)))
            i += 1
            continue
        break
    stem = u[i:]
    art, wasl = None, False
    if is_article(i) and SHADDA in stem[1][1]:
        art = 'l'                                # الَّذِي, الَّتِي: the article lam is not written twice
        stem[1][1].discard(SHADDA)
        stem = stem[1:]
    elif is_article(i):
        lam_next = stem[2]
        if SHADDA in lam_next[1] and lam_next[0] in SUN:
            art = CONS[lam_next[0]]
            lam_next[1].discard(SHADDA)
        else:
            art = 'l'
        stem = stem[2:]
        if art == 'l' and len(stem) >= 2 and stem[0][0] == 'ل' and stem[1][0] == 'ه' and vowel(i + 2) in ('a', ''):
            stem[0][1].add(DAGGER)               # the name Allah: long a on its lam
    elif stem and stem[0][0] == 'ٱ' or (stem and stem[0][0] == 'ا' and len(stem) > 1 and not _vowel_of(stem[0][1])):
        wasl = True
        stem = stem[1:]
    return Word(pre, art, wasl, _segs(stem))


def _segs(units):
    segs = []
    n = len(units)
    for k, (ch, m) in enumerate(units):
        v = _vowel_of(m)
        last = segs[-1] if segs else None
        if ch in 'اٱ':
            if last is None:
                segs.append(Seg("'", v or 'a'))
                continue
            if last.v == '' and (v or SHADDA in m):
                if SHADDA in m:                   # lam-alif ligature typed with the marks on the alif: إِلاَّ
                    segs.insert(len(segs) - 1, Seg(last.c, ''))
                last.v = 'A' if v in ('a', '') else v
            elif last.v == 'a' or last.v == '':
                last.v = 'A'
            if v == 'an':
                last.v = 'an'                     # رَبَّاً
            continue                              # otherwise silent: tanwin seat, plural waw alif, مِائَة
        if ch == 'ى':
            if last is not None:
                if last.v == 'i':
                    last.v = 'I'
                elif last.v in ('a', 'A', '') or DAGGER in m:
                    last.v = 'an' if v == 'an' else 'A'
            continue
        if (ch in 'وي' and last is not None and v == ('u' if ch == 'و' else 'i') and last.v == v and SHADDA not in m
                and k + 1 < n and units[k + 1][0] not in 'اىوي'):
            v = ''                                # long vowel letter typed with the same short vowel: سُبُّوُحٌ
        if ch in 'وي' and last is not None and not v and SHADDA not in m:
            short = 'u' if ch == 'و' else 'i'
            if DAGGER in m:
                last.v = 'A'                      # Uthmani seat: ٱلصَّلَوٰةَ, عَلَىٰ
                continue
            if last.v == short:
                last.v = short.upper()
                continue
            if last.v in ('a', 'A'):
                segs.append(Seg(CONS[ch], ''))   # diphthong aw / ay
                continue
            if last.v == '' and SUKUN not in m and k == n - 1 and ch == 'و':
                continue                          # silent final waw: عَمْرٍو
            if last.v == '' and SUKUN not in m:
                last.v = short.upper()
                continue
        c = CONS[ch]
        if ch == 'آ':
            segs.append(Seg("'", 'A'))
            continue
        if not v and last is None and ch in 'وف' and n > 2 and SUKUN not in m:
            v = 'a'                               # unvowelled conjunction: ويقف
        if not v:
            if ch == 'إ':
                v = 'i'
            elif ch == 'أ' and last is None:
                v = 'a'
        if DAGGER in m:
            v = 'A'
        if SHADDA in m:
            segs.append(Seg(c, ''))
        segs.append(Seg(c, v))
        if SMALL_WAW in m and v == 'u':
            segs[-1].v = 'U'
        if (SMALL_YEH in m or SMALL_HIGH_YEH in m) and v == 'i':
            segs[-1].v = 'I'
    return segs


def _pause(segs):
    if not segs:
        return segs
    segs = [Seg(s.c, s.v) for s in segs]
    last = segs[-1]
    if last.c == 'T_':
        last.c, last.v = 'h', ''
        if len(segs) >= 2 and segs[-2].v == '':
            segs[-2].v = 'a'
    elif last.v in ('a', 'i', 'u', 'un', 'in'):
        if last.c in ('w', 'y') and last.v in ('a', 'i', 'u'):
            return segs                           # huwa, hiya: no pausal "huw"
        if last.c == 'h' and len(segs) >= 2 and segs[-2].v == '' and segs[-2].c != 'h':
            return segs                           # thabbit-hu, not thabbit-h
        last.v = ''
        if len(segs) >= 2 and segs[-2].c == last.c and segs[-2].v == '':
            segs.pop()
    return segs


def _render(segs, style, initial=True):
    """Syllables to text; a hamza at the start of the rendered piece is not written."""
    st = STYLE[style]
    out = ''
    for k, s in enumerate(segs):
        c = s.c
        if c == "'":
            if k == 0 and initial:
                c = ''
            elif style == 'en':
                c = '-' if s.v else "'"
        else:
            c = st.get(c, c)
        if c == 'h' and out[-1:] in ('t', 's', 'k', 'd', 'g', 'c') and k > 0 and segs[k - 1].v == '':
            c = '-h'                              # thabbit-hu, not a th digraph
        v = st.get(s.v, s.v) if s.v in ('A', 'I', 'U') else s.v
        out += c + v
    return out


def _helping(prev):
    """A word ending in a consonant before an elided alif takes a helping vowel."""
    if not prev or prev[-1] in VOWEL_CHARS or not prev[-1].isalpha():
        return prev
    if re.search(r'(^|[\s\-])min$', prev):
        return prev + 'a'                         # min -> mina before the article
    return prev + ('u' if re.search(r'(hum|kum|tum)$', prev) else 'i')


def _shorten(prev):
    for a, b in (('ee', 'i'), ('oo', 'u')):
        if prev.endswith(a):
            return prev[:-2] + b
    return prev


def _fr_prefix(pre, before_article):
    out = ''
    for k, s in enumerate(pre):
        p = s.c + s.v
        last = k == len(pre) - 1
        out += p + ('-' if p != 'wa' or (last and before_article) else ' ')
    return out


def transliterate(text, style='en', quran=False):
    toks = _tokens(_prep(text, quran))
    words = []
    for k, (kind, val) in enumerate(toks):
        if kind == 'p':
            words.append(val)
            continue
        w = _parse(val, quran)
        nxt = toks[k + 1] if k + 1 < len(toks) else None
        if nxt is None or (nxt[0] == 'p' and nxt[1] in PAUSE[style]):
            w.segs = _pause(w.segs)
        words.append(w)
    st = STYLE[style]
    res = ''
    state = 'start'          # start (of a sentence) | pause (after other punctuation) | word (connected speech)
    for w in words:
        if isinstance(w, str):
            if w == '[':
                res += ' ['
            elif w == ']':
                res = res.rstrip() + ']'
            else:
                res = res.rstrip() + w
            state = 'start' if w in '.!?' else 'pause'
            continue
        sep = ' ' if res and not res.endswith('[') else ''
        if w.art or w.wasl:
            if w.art:
                lead, body_segs = st.get(w.art, w.art), w.segs
            else:
                first = w.segs[0] if w.segs else None
                lead = st.get(first.c, first.c) if first is not None and first.v == '' else ''
                body_segs = w.segs[1:] if lead else w.segs
            body = _render(body_segs, style, initial=True)
            hy = '-' if body_segs and body_segs[0].c == "'" else ''
            if w.pre:
                if style == 'en':
                    res += sep + _render(w.pre, style, False) + lead + hy + body
                else:
                    res += sep + _fr_prefix(w.pre, bool(w.art)) + (lead + '-' + body if w.art else lead + body)
            elif state != 'word':
                if w.art and lead == 'l':
                    piece = 'al' + body if body.startswith('l') or (style == 'en' and not hy) else 'al-' + body
                elif w.art:
                    piece = 'a' + lead + '-' + body
                else:
                    piece = ('u' if body_segs and body_segs[0].v == 'u' else 'i') + lead + body
                res += sep + piece
            elif style == 'en':
                res = _shorten(_helping(res)) + lead + '-' + body
            else:
                res = _helping(res) + ' ' + (lead + '-' + body if w.art else lead + body)
        else:
            body = _render(w.segs, style, initial=True)
            if w.pre and style == 'en':
                body = _render(w.pre, style, False) + ('-' if w.segs and w.segs[0].c == "'" else '') + body
            elif w.pre:
                body = _fr_prefix(w.pre, False) + body
            res += sep + body
        state = 'word'
    return _cosmetics(res, style)


def _cosmetics(s, style):
    s = re.sub(r'\s+([,.;:!?\]])', r'\1', s)
    s = re.sub(r'([,;:])(?=[^\s\]])', r'\1 ', s)
    s = re.sub(r'\[\s+', '[', s)
    s = re.sub(r'(?<![a-zâîû])muhammad', 'Muhammad', s)
    s = re.sub(r'(?<![A-Za-zâîû-])all(ah|âh)', lambda m: 'All' + m.group(1), s)
    s = re.sub(r'\b(ibr[aâ]h(ee|î)m)', lambda m: 'I' + m.group(1)[1:], s)
    s = re.sub(r'\s{2,}', ' ', s).strip()
    s = re.sub(r'(^|[.!?]\s+)([a-zâîû])', lambda m: m.group(1) + m.group(2).upper() if not s[m.end():].startswith('AA') else m.group(0), s)
    if s and s[-1] not in '.!?]':
        s += '.'
    return s


def vowel_coverage(text, quran=False):
    """Share of consonants (not word-final, not a long-vowel letter, not the article lam) with a vowel or sukun."""
    need, have, _ = _vowel_scan(text, quran)
    return have / need if need else 1.0


def unvowelled_words(text, quran=False):
    """Words with a consonant that carries no vowel, shadda or sukun (word-final letters excepted)."""
    return _vowel_scan(text, quran)[2]


def _vowel_scan(text, quran):
    need = have = 0
    bad = []
    for kind, units in _tokens(_prep(text, quran)):
        if kind != 'w':
            continue
        for k, (ch, m) in enumerate(units[:-1]):
            marked = bool(_vowel_of(m) or SUKUN in m or Q_SUKUN in m or DAGGER in m)
            if ch in 'اٱىآ' or (ch == 'ل' and k > 0 and units[k - 1][0] in 'اٱ'):
                continue
            if ch in 'وي' and k > 0 and not marked and SHADDA not in m:
                continue
            if k + 1 < len(units) and units[k + 1][0] == 'ا' and (_vowel_of(units[k + 1][1]) or SHADDA in units[k + 1][1]):
                marked = True                 # marks typed on the alif of a lam-alif
            if k == 0 and ch in 'وفبلك' and not marked and len(units) > 2:
                continue                      # an unvowelled conjunction or preposition is read with its usual vowel
            need += 1
            have += marked
            if not marked:
                bad.append(''.join(c + ''.join(sorted(mm)) for c, mm in units))
    return need, have, bad


if __name__ == '__main__':
    print(transliterate(sys.argv[-1], sys.argv[1] if len(sys.argv) > 2 else 'en'))
