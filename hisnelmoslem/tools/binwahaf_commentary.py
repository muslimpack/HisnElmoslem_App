#!/usr/bin/env python3
"""Turn a binwahaf lesson explanation (html) into the two texts the app stores in commentary.db:
`sharh` (شرح مفردات...) and `benefit` (ما يستفاد من الحديث), in the same layout as the existing rows:

    شرح مفردات الحديث:\r\n1-   قوله: ...: text /55 footnote /55 .

Library module, used by tools/binwahaf_apply.py.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from download_binwahaf import Node, parse_html  # noqa: E402


# The site writes the eulogies with a private-use icon font. Known ones are spelled out,
# the two whose meaning is not certain are dropped.
GLYPHS = {
    '\uf065': 'ﷺ',
    '\uf074': 'رضي الله عنه',
    '\uf079': 'رضي الله عنهم',
    '\uf075': 'رضي الله عنها',
    '\uf055': 'عز وجل',
    '\uf049': '',
    '\uf059': '',
}


def clean(text: str) -> str:
    for k, v in GLYPHS.items():
        text = text.replace(k, v)
    text = re.sub(r'\s*…\s*Continue reading', ' …', text)  # truncated footnote tooltips
    return text


def _inline(n, out):
    if isinstance(n, str):
        out.append(n)
        return
    c = n.classes()
    if 'footnote_referrer' in c:
        tip = n.find(lambda x: 'footnote_tooltip' in x.classes())
        if tip is not None:
            foot = []
            _inline(tip, foot)
            out.append(' /55 ' + re.sub(r'\s+', ' ', ''.join(foot)).strip() + ' /55 ')
        return
    if n.tag == 'br':
        out.append('\r\n')
        return
    if 'toc_container' in n.attrs.get('id', '') or 'footnotes_reference_container' in c:
        return
    for ch in n.children:
        _inline(ch, out)


def _text(n):
    out = []
    _inline(n, out)
    return re.sub(r'[ \t\u00a0\u202f]+', ' ', clean(''.join(out))).strip()


def convert(explanation_html: str) -> dict:
    """Returns {'sharh': str, 'benefit': str} ('' when the section is absent)."""
    root = parse_html(explanation_html)
    box = root.find(lambda n: n.attrs.get('data-sut') == 'content-explanation')
    if box is None:
        return {'sharh': '', 'benefit': ''}
    sections: list[tuple[str, list[str]]] = [('', [])]
    for n in box.children:
        if not isinstance(n, Node):
            continue
        if n.attrs.get('id') == 'toc_container' or 'footnotes_reference_container' in n.classes():
            continue
        if n.tag in ('h2', 'h3'):
            sections.append((_text(n), []))
        elif n.tag in ('ol', 'ul'):
            for i, li in enumerate((c for c in n.children if isinstance(c, Node) and c.tag == 'li'), 1):
                t = _text(li)
                if t:
                    sections[-1][1].append(f'{i}-   {t}' if n.tag == 'ol' else f'-   {t}')
        elif n.tag in ('p', 'div'):
            t = _text(n)
            if t:
                sections[-1][1].append(t)
    sharh, benefit = [], []
    for heading, lines in sections:
        if not lines:
            continue
        block = (heading + '\r\n' if heading else '') + '\r\n'.join(lines)
        (benefit if 'يستفاد' in heading or 'فوائد' in heading else sharh).append(block)
    return {'sharh': '\r\n'.join(sharh).strip(), 'benefit': '\r\n'.join(benefit).strip()}
