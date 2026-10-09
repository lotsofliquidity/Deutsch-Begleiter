#!/usr/bin/env python3
"""Check that every pattern in the library is reachable from grammatik.md.

`patterns/patterns.md` is the library; `course/grammatik.md` is the one-page rule index
that a learner actually reads. This catches the failure mode where a rule exists only as
a card, or only as debris inside someone else's pattern section, and so never reaches the
index.

Usage:
    python3 course/check_grammatik.py            # report
    python3 course/check_grammatik.py --list     # also list every pattern found linked

Exit 0 = every pattern reachable, 1 = gaps.
"""

import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PATTERNS = os.path.join(ROOT, "patterns", "patterns.md")
GRAMMATIK = os.path.join(HERE, "grammatik.md")

# Section headings in patterns.md that are structure, not patterns.
STRUCTURAL = {
    "Index — A1.1 units 1–10",
    "Later seeds (not yet fully met)",
    "Traps (cross-pattern)",
    "Adding a pattern",
}


def slug(heading: str) -> str:
    """GitHub-ish heading slug, with runs of hyphens collapsed.

    Punctuation runs slug ambiguously (``so wie / -er als`` could be 2 or 3 hyphens), so
    hyphen runs are normalised — this check is about reachability, not URL spelling.
    """
    s = heading.strip().lower().replace("\u2019", "").replace("\u2018", "")
    s = re.sub(r"[^\w\s\-äöüß]", "", s)
    return re.sub(r"-+", "-", re.sub(r"\s", "-", s.strip())).strip("-")


def headings() -> list[str]:
    out = []
    with io.open(PATTERNS, encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("## "):
                name = line[3:].strip()
                if name not in STRUCTURAL:
                    out.append(name)
    return out


def linked() -> set[str]:
    with io.open(GRAMMATIK, encoding="utf-8") as fh:
        text = fh.read()
    anchors = re.findall(r"\]\(\.\./patterns/patterns\.md#([^)]+)\)", text)
    return {re.sub(r"-+", "-", a).strip("-") for a in anchors}


def main() -> int:
    for path in (PATTERNS, GRAMMATIK):
        if not os.path.exists(path):
            print(f"missing {os.path.relpath(path, ROOT)}")
            return 1

    pats = headings()
    have = linked()
    missing = [h for h in pats if slug(h) not in have]

    print(f"patterns in library  : {len(pats)}")
    print(f"anchors in grammatik : {len(have)}")

    if "--list" in sys.argv:
        for h in pats:
            mark = "ok " if slug(h) in have else "MISS"
            print(f"  {mark}  {h}")

    if missing:
        print(f"\nnot reachable from grammatik.md: {len(missing)}")
        for h in missing:
            print(f"  · {h}")
        return 1

    print("OK  every pattern is reachable from grammatik.md")
    return 0


if __name__ == "__main__":
    sys.exit(main())
