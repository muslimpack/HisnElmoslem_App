#!/usr/bin/env python3
"""Download the whole "Hisn al-Muslim" book (text, explanation and every reader's audio)
from binwahaf.com, the source of truth for the azkar.

Standard library only. Usage (from `hisnelmoslem/`):

    python tools/download_binwahaf.py                       # everything
    python tools/download_binwahaf.py --no-audio            # text only
    python tools/download_binwahaf.py --limit 5             # first 5 lessons (smoke test)
    python tools/download_binwahaf.py --readers hamad       # only readers whose name matches
    python tools/download_binwahaf.py --out tools/binwahaf_out --delay 0.5

Output (default `tools/binwahaf_out/`, ignored by git):
    index.json            chapters and lessons found in the sidebar
    content.json          one record per lesson: title, zikr text, footnotes (takhrij),
                          explanation (html + text), readers and their local audio files
    html/<id>.html        raw page, so parsing can be redone without hitting the site
    audio/<reader>/NNN-<id>.<ext>

Re-running is safe: cached pages and finished audio files are skipped, audio is written to
a .part file first and renamed when complete.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from html.parser import HTMLParser
from pathlib import Path

START_URL = "https://binwahaf.com/ar/audio-book-lesson/1567/"
USER_AGENT = "Mozilla/5.0 (compatible; HisnElmoslemContentCheck/1.0)"
VOID = {"br", "img", "hr", "input", "meta", "link", "source", "area", "base", "col", "wbr"}

# Known readers -> ascii folder names. Unknown readers get a hash based name.
READER_SLUGS = {
    "حمد الدريهم": "hamad_alduraihem",
    "سليمان الشويهي": "sulaiman_alshuwaihi",
    "راشد الحليبة": "rashid_alhulaibah",
}


# --------------------------------------------------------------------------- HTML tree


class Node:
    __slots__ = ("tag", "attrs", "children", "parent")

    def __init__(self, tag: str, attrs: dict[str, str], parent: "Node | None" = None):
        self.tag = tag
        self.attrs = attrs
        self.children: list[Node | str] = []
        self.parent = parent

    def classes(self) -> set[str]:
        return set(self.attrs.get("class", "").split())

    def walk(self):
        yield self
        for child in self.children:
            if isinstance(child, Node):
                yield from child.walk()

    def find_all(self, pred):
        return [n for n in self.walk() if pred(n)]

    def find(self, pred):
        for n in self.walk():
            if pred(n):
                return n
        return None


class TreeBuilder(HTMLParser):
    """Tiny tolerant DOM builder, enough for this site."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = Node("root", {})
        self.cur = self.root

    def handle_starttag(self, tag, attrs):
        node = Node(tag, {k: (v or "") for k, v in attrs}, self.cur)
        self.cur.children.append(node)
        if tag not in VOID:
            self.cur = node

    def handle_startendtag(self, tag, attrs):
        self.cur.children.append(Node(tag, {k: (v or "") for k, v in attrs}, self.cur))

    def handle_endtag(self, tag):
        n = self.cur
        while n is not self.root and n.tag != tag:
            n = n.parent
        if n is not self.root:
            self.cur = n.parent

    def handle_data(self, data):
        self.cur.children.append(data)


def parse_html(html: str) -> Node:
    builder = TreeBuilder()
    builder.feed(html)
    return builder.root


def by_sut(root: Node, value: str):
    return root.find_all(lambda n: n.attrs.get("data-sut") == value)


def to_html(node: Node | str) -> str:
    if isinstance(node, str):
        return node.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    attrs = "".join(f' {k}="{v}"' for k, v in node.attrs.items())
    if node.tag in VOID:
        return f"<{node.tag}{attrs}>"
    inner = "".join(to_html(c) for c in node.children)
    return f"<{node.tag}{attrs}>{inner}</{node.tag}>"


def to_text(node: Node | str, skip=lambda n: False) -> str:
    """Plain text; <p>/<li>/<br>/headings become line breaks."""
    out: list[str] = []

    def rec(n):
        if isinstance(n, str):
            out.append(n)
            return
        if skip(n):
            return
        block = n.tag in {"p", "li", "div", "h1", "h2", "h3", "h4", "tr", "ol", "ul"}
        if block:
            out.append("\n")
        if n.tag == "br":
            out.append("\n")
        for c in n.children:
            rec(c)
        if block:
            out.append("\n")

    rec(node)
    text = "".join(out).replace(" ", " ").replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r" ?\n ?", "\n", text)
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def is_footnote_part(n: Node) -> bool:
    c = n.classes()
    return bool(c & {"footnote_referrer", "footnotes_reference_container", "footnote_container_prepare"})


# --------------------------------------------------------------------------- fetching


def fetch(url: str, retries: int = 4, timeout: int = 60) -> bytes:
    # Percent-encode non-ascii paths (the audio file names are Arabic).
    parts = urllib.parse.urlsplit(url)
    url = urllib.parse.urlunsplit(
        (parts.scheme, parts.netloc, urllib.parse.quote(parts.path, safe="/%"), parts.query, "")
    )
    last: Exception | None = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return resp.read()
        except Exception as e:  # noqa: BLE001 - retry on anything network related
            last = e
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(f"failed to fetch {url}: {last}")


def fetch_page(url: str, cache: Path, delay: float) -> str:
    lesson_id = url.rstrip("/").split("/")[-1]
    path = cache / f"{lesson_id}.html"
    if path.exists() and path.stat().st_size > 0:
        return path.read_text(encoding="utf-8")
    html = fetch(url).decode("utf-8", errors="replace")
    path.write_text(html, encoding="utf-8")
    time.sleep(delay)
    return html


# --------------------------------------------------------------------------- parsing


def parse_index(root: Node) -> list[dict]:
    """Chapters (<details><summary>) with their lesson links, in site order."""
    lst = by_sut(root, "index-list")
    if not lst:
        raise RuntimeError("index list not found: the site layout changed")
    lessons: list[dict] = []
    for li in lst[0].children:
        if not isinstance(li, Node):
            continue
        details = li.find(lambda n: n.tag == "details")
        if details is None:
            continue
        summary = details.find(lambda n: n.tag == "summary")
        chapter = to_text(summary) if summary else ""
        for a in details.find_all(lambda n: n.attrs.get("data-sut") == "index-item-link"):
            href = a.attrs.get("href", "")
            m = re.search(r"/audio-book-lesson/(\d+)/?", href)
            if m:
                lessons.append(
                    {"id": int(m.group(1)), "url": href, "title": to_text(a), "chapter": chapter}
                )
    # Lessons may also sit directly under the list without a chapter.
    seen = {x["id"] for x in lessons}
    for a in lst[0].find_all(lambda n: n.attrs.get("data-sut") == "index-item-link"):
        m = re.search(r"/audio-book-lesson/(\d+)/?", a.attrs.get("href", ""))
        if m and int(m.group(1)) not in seen:
            lessons.append(
                {"id": int(m.group(1)), "url": a.attrs["href"], "title": to_text(a), "chapter": ""}
            )
    return lessons


def parse_lesson(html: str) -> dict:
    root = parse_html(html)
    title = by_sut(root, "title")
    content = by_sut(root, "content")
    explanation = by_sut(root, "content-explanation")
    date = by_sut(root, "publication-date")

    footnotes: list[str] = []
    text = ""
    if content:
        text = to_text(content[0], skip=is_footnote_part)
        for td in content[0].find_all(lambda n: "footnote_plugin_text" in n.classes()):
            footnotes.append(to_text(td))

    expl_html = expl_text = ""
    if explanation:
        # Drop the table of contents box and the footnote tables from the text version.
        def skip(n: Node) -> bool:
            return n.attrs.get("id") == "toc_container" or (
                "footnotes_reference_container" in n.classes()
            )

        expl_html = to_html(explanation[0])
        expl_text = to_text(explanation[0], skip=skip)

    readers = []
    for btn in by_sut(root, "reader-option"):
        url = btn.attrs.get("data-audio-url", "")
        if url:
            readers.append({"name": btn.attrs.get("data-reader-name", "").strip(), "url": url})
    if not readers:  # a lesson with a single, unnamed reader
        src = root.find(lambda n: n.tag == "source" and n.attrs.get("id") == "audio-source")
        if src and src.attrs.get("src"):
            readers.append({"name": "default", "url": src.attrs["src"]})

    return {
        "title": to_text(title[0]) if title else "",
        "date": (date[0].attrs.get("datetime", "") if date else ""),
        "text": text,
        "footnotes": footnotes,
        "explanation_text": expl_text,
        "explanation_html": expl_html,
        "readers": readers,
    }


def reader_slug(name: str, url: str) -> str:
    if name in READER_SLUGS:
        return READER_SLUGS[name]
    ascii_name = re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")
    return ascii_name or f"reader_{abs(hash(name)) % 10000}"


# --------------------------------------------------------------------------- audio


def download_audio(url: str, dest: Path, delay: float) -> str:
    if dest.exists() and dest.stat().st_size > 0:
        return "skipped"
    dest.parent.mkdir(parents=True, exist_ok=True)
    data = fetch(url, timeout=180)
    part = dest.with_suffix(dest.suffix + ".part")
    part.write_bytes(data)
    part.replace(dest)
    time.sleep(delay)
    return "downloaded"


# --------------------------------------------------------------------------- main


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("--url", default=START_URL, help="any lesson url of the book")
    ap.add_argument("--out", default="tools/binwahaf_out", help="output folder")
    ap.add_argument("--no-audio", action="store_true", help="skip the audio files")
    ap.add_argument("--readers", default="", help="only readers whose name contains this text")
    ap.add_argument("--limit", type=int, default=0, help="only the first N lessons")
    ap.add_argument("--delay", type=float, default=0.3, help="seconds to wait after each request")
    ap.add_argument("--jobs", type=int, default=3, help="parallel audio downloads")
    args = ap.parse_args()

    out = Path(args.out)
    cache = out / "html"
    cache.mkdir(parents=True, exist_ok=True)

    print("reading the index ...")
    lessons = parse_index(parse_html(fetch_page(args.url, cache, args.delay)))
    if args.limit:
        lessons = lessons[: args.limit]
    print(f"{len(lessons)} lessons in {len({x['chapter'] for x in lessons})} chapters")
    (out / "index.json").write_text(
        json.dumps(lessons, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    records: list[dict] = []
    for i, lesson in enumerate(lessons):
        try:
            data = parse_lesson(fetch_page(lesson["url"], cache, args.delay))
        except Exception as e:  # noqa: BLE001
            print(f"[{i + 1}/{len(lessons)}] {lesson['id']} FAILED: {e}", file=sys.stderr)
            records.append({**lesson, "index": i + 1, "error": str(e)})
            continue
        records.append({**lesson, "index": i + 1, **data, "title": data["title"] or lesson["title"]})
        print(f"[{i + 1}/{len(lessons)}] {lesson['id']} {lesson['title']}")

    if not args.no_audio:
        jobs = []
        for rec in records:
            for rd in rec.get("readers", []):
                if args.readers and args.readers not in rd["name"]:
                    continue
                slug = reader_slug(rd["name"], rd["url"])
                ext = Path(urllib.parse.urlsplit(rd["url"]).path).suffix or ".mp3"
                rel = Path("audio") / slug / f"{rec['index']:03d}-{rec['id']}{ext}"
                rd["file"] = rel.as_posix()
                jobs.append((rd, out / rel))
        print(f"downloading {len(jobs)} audio files with {args.jobs} workers ...")
        done = failed = 0
        with ThreadPoolExecutor(max_workers=args.jobs) as pool:
            futures = {pool.submit(download_audio, rd["url"], dest, args.delay): rd for rd, dest in jobs}
            for fut in as_completed(futures):
                rd = futures[fut]
                try:
                    fut.result()
                    done += 1
                except Exception as e:  # noqa: BLE001
                    failed += 1
                    rd["error"] = str(e)
                    rd.pop("file", None)
                    print(f"audio FAILED {rd['url']}: {e}", file=sys.stderr)
                if (done + failed) % 25 == 0:
                    print(f"  {done + failed}/{len(jobs)}")
        print(f"audio: {done} ok, {failed} failed")

    (out / "content.json").write_text(
        json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    errors = [r for r in records if "error" in r]
    print(f"done: {len(records)} lessons, {len(errors)} with errors -> {out / 'content.json'}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
