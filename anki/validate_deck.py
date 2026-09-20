#!/usr/bin/env python3
"""Validate anki/German.txt (and any other .txt decks in this folder).

Usage:
    python3 validate_deck.py

Exit 0 = clean, 1 = problems.
"""

import glob
import os
import re
import sys
from collections import Counter

REQUIRED_HEADERS = ("#separator:tab", "#html:true", "#notetype:Basic")


def normalise(front: str) -> str:
    s = front.lower()
    s = re.sub(r"&(?:lt|gt|amp|quot|nbsp|#\d+);", " ", s)
    s = re.sub(r"[^a-z0-9 ]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def validate(path: str) -> list[str]:
    problems: list[str] = []
    headers: set[str] = set()
    cards: list[tuple[int, str, str, str]] = []
    expected_deck = os.path.splitext(os.path.basename(path))[0]

    with open(path, encoding="utf-8") as fh:
        for line_no, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if not line.strip():
                continue
            if line.startswith("#"):
                headers.add(line.strip())
                continue
            parts = line.split("\t")
            if len(parts) != 3:
                problems.append(
                    f"line {line_no}: {len(parts)} fields, expected 3 -> {line[:70]!r}"
                )
                continue
            front, back, tags = (p.strip() for p in parts)
            if not front or not back:
                problems.append(f"line {line_no}: empty front or back")
            if not tags:
                problems.append(f"line {line_no}: empty tags")
            cards.append((line_no, front, back, tags))

    for required in REQUIRED_HEADERS:
        if not any(h.startswith(required) for h in headers):
            problems.append(f"missing header {required}")

    declared = [h for h in headers if h.startswith("#deck:")]
    if not declared:
        problems.append("missing header #deck:")
    else:
        name = declared[0].split(":", 1)[1].strip()
        if name != expected_deck:
            problems.append(f"#deck:{name!r} != filename stem {expected_deck!r}")

    if not any(h.startswith("#tags column:3") for h in headers):
        problems.append("missing header #tags column:3")

    fronts = Counter(normalise(f) for _, f, _, _ in cards)
    for key, n in fronts.items():
        if n > 1 and key:
            problems.append(f"duplicate front (~{n}×): {key!r}")

    return problems


def main() -> int:
    root = os.path.dirname(os.path.abspath(__file__))
    decks = sorted(glob.glob(os.path.join(root, "*.txt")))
    if not decks:
        print("No .txt decks found.")
        return 1
    failed = 0
    for path in decks:
        probs = validate(path)
        label = os.path.basename(path)
        if probs:
            failed = 1
            print(f"FAIL {label}")
            for p in probs:
                print(f"  · {p}")
        else:
            # count non-comment card lines
            with open(path, encoding="utf-8") as fh:
                n = sum(
                    1
                    for line in fh
                    if line.strip() and not line.startswith("#") and "\t" in line
                )
            print(f"OK   {label} ({n} cards)")
    return failed


if __name__ == "__main__":
    sys.exit(main())
