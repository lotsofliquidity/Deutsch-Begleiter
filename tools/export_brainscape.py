#!/usr/bin/env python3
"""Export the Brainscape chunk deck into the app's bundled card pack.

    anki/Brainscape-German.txt  ->  app/DeutschBegleiter/Resources/decks.json

The Brainscape file stays the single source of truth; the JSON is generated.
Cards are grouped into one deck per CEFR level (A1 / A2 / B1), because the app's
library is organised by level.

Usage:
    python3 tools/export_brainscape.py            # write decks.json
    python3 tools/export_brainscape.py --check    # report drift, write nothing

Exit 0 = up to date, 1 = drift or problem.
"""

import datetime
import hashlib
import html
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "anki" / "Brainscape-German.txt"
DST = ROOT / "app" / "DeutschBegleiter" / "Resources" / "decks.json"

LEVELS = [
    ("a1", "A1", "Brainscape · A1.1 + A1.2 · Units 1–10"),
    ("a2", "A2", "Brainscape · A2.1 + A2.2 · Units 1–10"),
    ("b1", "B1", "Brainscape · B1"),
]


def clean(text: str) -> str:
    """Anki HTML -> the inline markdown the app renders."""
    text = re.sub(r"<b>", "**", text)
    text = re.sub(r"</b>", "**", text)
    text = re.sub(r"<br\s*/?>", " ", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def cards_by_level() -> dict[str, list[dict]]:
    grouped: dict[str, list[dict]] = {key: [] for key, _, _ in LEVELS}

    for raw in SRC.read_text(encoding="utf-8").splitlines():
        if not raw.strip() or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) < 3:
            continue

        front, back = clean(parts[0]), clean(parts[1])
        if not front or not back:
            continue

        tags = parts[2].split()
        if not tags:
            continue
        level = tags[0].split(".")[0].lower()
        if level not in grouped:
            continue

        grouped[level].append(
            {
                # stable across runs and independent of ordering, so review
                # history survives a pack refresh; editing the front makes a
                # new card, which is the honest outcome
                "id": f"{level}-{hashlib.sha1(front.encode('utf-8')).hexdigest()[:10]}",
                "front": front,
                "back": back,
            }
        )

    return grouped


def build() -> dict:
    grouped = cards_by_level()
    decks = []

    for key, label, subtitle in LEVELS:
        cards = grouped[key]
        if not cards:
            continue
        decks.append(
            {
                "id": f"{key}-chunks",
                "name": f"{label} Chunks",
                "level": label,
                "subtitle": subtitle,
                "origin": "predefined",
                "cards": cards,
            }
        )

    return {
        "source": "anki/Brainscape-German.txt",
        "generated": datetime.date.today().isoformat(),
        "decks": decks,
    }


def summary(payload: dict) -> None:
    print(f"source : {SRC.relative_to(ROOT)}")
    for deck in payload["decks"]:
        print(f"  {deck['level']:>2}  {len(deck['cards']):>4} cards  {deck['subtitle']}")
    total = sum(len(deck["cards"]) for deck in payload["decks"])
    print(f"total  : {total} cards in {len(payload['decks'])} deck(s)")


def main() -> int:
    if not SRC.exists():
        print(f"missing {SRC.relative_to(ROOT)}")
        return 1

    payload = build()
    summary(payload)

    text = json.dumps(payload, ensure_ascii=False, indent=1) + "\n"
    check = "--check" in sys.argv

    if DST.exists():
        current = json.loads(DST.read_text(encoding="utf-8"))
        if current.get("decks") == payload["decks"]:
            print(f"\nup to date: {DST.relative_to(ROOT)}")
            return 0
        if check:
            print(f"\nDRIFT: {DST.relative_to(ROOT)} is stale — rerun without --check")
            return 1

    if check:
        print(f"\nmissing {DST.relative_to(ROOT)}")
        return 1

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text(text, encoding="utf-8")
    print(f"\nwrote {DST.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
