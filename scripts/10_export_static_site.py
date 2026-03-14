#!/usr/bin/env python3
import argparse
import os
import re
import sys
from collections import deque
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin, urlparse, urldefrag
from urllib.request import Request, urlopen


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag in ("a", "link") and "href" in attrs:
            self.links.append(attrs["href"])
        if tag in ("img", "script", "source", "video", "audio") and "src" in attrs:
            self.links.append(attrs["src"])
        if "srcset" in attrs:
            for part in attrs["srcset"].split(","):
                u = part.strip().split(" ")[0]
                if u:
                    self.links.append(u)


def sanitize_url(url):
    url, _ = urldefrag(url)
    return url


def is_same_site(url, base_netloc):
    p = urlparse(url)
    return p.scheme in ("http", "https") and p.netloc == base_netloc


def path_for_url(url, out_dir):
    p = urlparse(url)
    path = p.path or "/"
    if path.endswith("/"):
        path = path + "index.html"
    if "." not in path.split("/")[-1]:
        path = path + ".html"
    target = Path(out_dir) / path.lstrip("/")
    return target


def fetch(url):
    req = Request(url, headers={"User-Agent": "Mozilla/5.0 (compatible; static-export-bot/1.0)"})
    with urlopen(req, timeout=20) as res:
        content_type = res.headers.get("Content-Type", "")
        data = res.read()
    return data, content_type


def main():
    parser = argparse.ArgumentParser(description="Export a same-domain static snapshot for Vercel")
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--out-dir", default="vercel-static")
    parser.add_argument("--max-pages", type=int, default=300)
    args = parser.parse_args()

    base = sanitize_url(args.base_url.rstrip("/"))
    base_parsed = urlparse(base)
    if base_parsed.scheme not in ("http", "https"):
        print("Base URL must be http/https")
        sys.exit(1)

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    queue = deque([base])
    visited = set()
    downloaded = 0

    while queue and downloaded < args.max_pages:
        url = sanitize_url(queue.popleft())
        if url in visited:
            continue
        visited.add(url)

        if not is_same_site(url, base_parsed.netloc):
            continue

        try:
            data, content_type = fetch(url)
        except Exception as exc:
            print(f"[skip] {url} ({exc})")
            continue

        target = path_for_url(url, out_dir)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        downloaded += 1
        print(f"[saved] {url} -> {target}")

        if "text/html" in content_type or target.suffix in (".html", ""):
            text = data.decode("utf-8", errors="ignore")
            parser = LinkParser()
            parser.feed(text)

            css_urls = re.findall(r"url\(([^)]+)\)", text)
            all_links = parser.links + css_urls

            for raw_link in all_links:
                link = raw_link.strip().strip('"').strip("'")
                if not link or link.startswith("mailto:") or link.startswith("tel:") or link.startswith("data:"):
                    continue
                abs_url = sanitize_url(urljoin(url, link))
                if is_same_site(abs_url, base_parsed.netloc) and abs_url not in visited:
                    queue.append(abs_url)

    print(f"\nDone. Saved {downloaded} files into {out_dir}")


if __name__ == "__main__":
    main()
