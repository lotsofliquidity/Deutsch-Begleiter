#!/usr/bin/env python3
"""Split German.txt into a curated core deck.

Core = cards tagged `pattern`, `verb`, or `teach` (the grammar skeleton).
Everything else (chunk / noun) stays in German.txt and is not imported as SRS.

Usage:
    python3 split_core.py            # writes German-core.txt
    python3 split_core.py --check    # report only, write nothing

Exit 0 = clean, 1 = problems.
"""

import os
import sys

CORE_TAGS = {"pattern", "verb", "teach"}
HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "German.txt")
DST = os.path.join(HERE, "German-core.txt")
DST_DECK = os.path.splitext(os.path.basename(DST))[0]  # "German-core"


def tags_of(line: str) -> list[str]:
    parts = line.split("\t")
    return parts[2].split() if len(parts) == 3 else []


def is_core(line: str) -> bool:
    return any(t in CORE_TAGS for t in tags_of(line))


def split():
    top: list[str] = []
    blocks: list[dict] = []
    cur = None

    with open(SRC, encoding="utf-8") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            if not line.strip():
                continue
            if line.startswith("# ──"):  # unit section header
                cur = {"header": line, "cards": []}
                blocks.append(cur)
            elif line.startswith("#"):
                top.append(line)
            else:
                if cur is None:
                    cur = {"header": None, "cards": []}
                    blocks.append(cur)
                cur["cards"].append(line)

    # rewrite the deck name so validate_deck.py passes (deck == filename stem)
    out = [f"#deck:{DST_DECK}" if h.startswith("#deck:") else h for h in top]
    out.append("")

    kept = dropped = 0
    for b in blocks:
        core = [c for c in b["cards"] if is_core(c)]
        dropped += len(b["cards"]) - len(core)
        if not core:
            continue
        if b["header"]:
            out.append(b["header"])
        out.extend(core)
        out.append("")
        kept += len(core)

    return out, kept, dropped


def main() -> int:
    check = "--check" in sys.argv
    if not os.path.exists(SRC):
        print(f"missing {SRC}")
        return 1

    out, kept, dropped = split()
    total = kept + dropped

    print(f"source : German.txt      ({total} cards)")
    print(f"core   : {kept} card(s)  tags={sorted(CORE_TAGS)}  -> German-core.txt")
    print(f"glossary: {dropped} card(s) stay in German.txt (not imported)")

    if kept == 0:
        print("nothing to write — no core cards found")
        return 1

    if check:
        print("\n--check: no file written")
        return 0

    with open(DST, "w", encoding="utf-8") as fh:
        fh.write("\n".join(out))
    print(f"\nwrote {os.path.relpath(DST, HERE)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
