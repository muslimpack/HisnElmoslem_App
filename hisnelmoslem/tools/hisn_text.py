"""Shared Arabic text helpers for the matching tools (binwahaf_match.py, translations_match.py).

Importing this module has no side effects.
"""
import re

DIA = re.compile('[\u064b-\u065f\u0670\u06d6-\u06ed\u0640\u200c-\u200f\u202a-\u202f]')


def norm(s: str) -> str:
    """Arabic text without diacritics, with unified alef/yaa/taa marbuta and only letters and spaces."""
    s = DIA.sub('', s or '')
    s = s.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ٱ', 'ا')
    s = s.replace('ى', 'ي').replace('ة', 'ه').replace('ؤ', 'و').replace('ئ', 'ي')
    s = re.sub(r'[^\u0621-\u064a ]', ' ', s)
    return re.sub(r'\s+', ' ', s).strip()


def expand_quran_all(text, q):
    """Replace every `QuranText[...]` placeholder with the verses it names, read from the Quran db `q`."""
    def rep(m):
        out = []
        for part in re.findall(r'\(([\d:]+)\)', m.group(0)):
            sura, a, b = (int(x) for x in part.split(':'))
            out += [r[0] for r in q.execute('select text from arabic_text where sura=? and ayah between ? and ? order by ayah', (sura, a, b))]
        return ' '.join(out)
    return re.sub(r'QuranText\[[^\]]*\]', rep, text or '')
