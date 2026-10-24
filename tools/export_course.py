#!/usr/bin/env python3
"""Export the processed course markdown into the app's bundled content pack.

    course/a{1,2}.{1,2}/*.md + course/grammatik.md + patterns/patterns.md
        ->  app/DeutschBegleiter/Resources/course.json

Markdown is parsed into typed blocks (heading / paragraph / list / table /
callout) rather than shipped as markdown, because SwiftUI text cannot lay out
tables and the course is 2,900 table rows deep.

Usage:
    python3 tools/export_course.py            # write course.json
    python3 tools/export_course.py --check    # report drift, write nothing
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DST = ROOT / "app" / "DeutschBegleiter" / "Resources" / "course.json"

LEVELS = [("a1.1", "A1.1"), ("a1.2", "A1.2"), ("a2.1", "A2.1")]
GRAMMAR = ROOT / "course" / "grammatik.md"
PATTERNS = ROOT / "patterns" / "patterns.md"


def slug(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return text.strip("-")[:60]


def split_table_row(line: str) -> list[str]:
    cells = line.strip().strip("|").split("|")
    return [cell.strip() for cell in cells]


def is_separator(cells: list[str]) -> bool:
    return all(re.fullmatch(r":?-{2,}:?", cell) for cell in cells if cell)


def parse_blocks(lines: list[str]) -> list[dict]:
    blocks: list[dict] = []
    paragraph: list[str] = []
    items: list[dict] = []
    fence: list[str] | None = None

    def flush_paragraph() -> None:
        if paragraph:
            text = " ".join(part.strip() for part in paragraph).strip()
            if text:
                blocks.append({"type": "paragraph", "text": text})
            paragraph.clear()

    def flush_items() -> None:
        if items:
            blocks.append({"type": "list", "items": list(items)})
            items.clear()

    def flush() -> None:
        flush_paragraph()
        flush_items()

    index = 0
    while index < len(lines):
        raw = lines[index]
        line = raw.rstrip()
        stripped = line.strip()

        if fence is not None:
            if stripped.startswith("```"):
                blocks.append({"type": "code", "text": "\n".join(fence).strip("\n")})
                fence = None
            else:
                fence.append(raw)
            index += 1
            continue

        if stripped.startswith("```"):
            flush()
            fence = []
            index += 1
            continue

        if not stripped:
            flush()
            index += 1
            continue

        if stripped in ("---", "***", "___"):
            flush()
            index += 1
            continue

        heading = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if heading:
            flush()
            blocks.append(
                {
                    "type": "heading",
                    "level": len(heading.group(1)),
                    "text": heading.group(2).strip(),
                }
            )
            index += 1
            continue

        if stripped.startswith("|"):
            flush()
            header = split_table_row(stripped)
            rows: list[list[str]] = []
            index += 1
            while index < len(lines) and lines[index].strip().startswith("|"):
                cells = split_table_row(lines[index])
                if not is_separator(cells):
                    rows.append(cells)
                index += 1
            blocks.append({"type": "table", "header": header, "rows": rows})
            continue

        bullet = re.match(r"^(\s*)[-*+]\s+(.*)$", line)
        if bullet:
            flush_paragraph()
            depth = len(bullet.group(1)) // 2
            items.append({"text": bullet.group(2).strip(), "depth": depth})
            index += 1
            continue

        numbered = re.match(r"^(\s*)(\d+)[.)]\s+(.*)$", line)
        if numbered:
            flush_paragraph()
            depth = len(numbered.group(1)) // 2
            items.append({"text": numbered.group(3).strip(), "depth": depth})
            index += 1
            continue

        if stripped.startswith(">"):
            flush()
            quote = [stripped.lstrip(">").strip()]
            index += 1
            while index < len(lines) and lines[index].strip().startswith(">"):
                quote.append(lines[index].strip().lstrip(">").strip())
                index += 1
            blocks.append({"type": "callout", "text": " ".join(quote).strip()})
            continue

        flush_items()
        paragraph.append(line)
        index += 1

    flush()
    if fence:
        blocks.append({"type": "code", "text": "\n".join(fence).strip("\n")})
    return blocks


def read(path: pathlib.Path) -> list[str]:
    return path.read_text(encoding="utf-8").splitlines()


def split_sections(lines: list[str], level: int) -> list[tuple[str, list[str]]]:
    """Split on `level`-deep headings, returning (heading text, body lines)."""
    pattern = re.compile(r"^" + "#" * level + r"\s+(.*)$")
    sections: list[tuple[str, list[str]]] = []
    current: tuple[str, list[str]] | None = None
    preamble: list[str] = []

    for line in lines:
        match = pattern.match(line)
        if match:
            if current:
                sections.append((current[0], current[1]))
            current = (match.group(1).strip(), [])
        elif current:
            current[1].append(line)
        else:
            preamble.append(line)

    if current:
        sections.append((current[0], current[1]))
    return sections


def unit_number(name: str) -> int:
    match = re.search(r"unit-(\d+)", name)
    return int(match.group(1)) if match else 0


def build_units() -> list[dict]:
    levels = []
    for folder, label in LEVELS:
        directory = ROOT / "course" / folder
        if not directory.exists():
            continue

        units = []
        for path in sorted(directory.glob("unit-*.md")):
            lines = read(path)
            title = next(
                (line.lstrip("# ").strip() for line in lines if line.startswith("# ")),
                path.stem,
            )
            # "A1.1 Unit 3 — Wie bitte?" -> "Wie bitte?"; the level and unit
            # number are rendered by the app, not repeated in the title
            title = re.sub(r"^A\d\.\d Unit \d+\s*[—–-]\s*", "", title)
            blocks = parse_blocks(lines)
            # drop the H1 — the reader renders the title itself
            if blocks and blocks[0]["type"] == "heading" and blocks[0]["level"] == 1:
                blocks.pop(0)
            units.append(
                {
                    "id": f"{folder}-u{unit_number(path.name):02d}",
                    "number": unit_number(path.name),
                    "title": title,
                    "blocks": blocks,
                }
            )

        if units:
            levels.append({"id": folder, "name": label, "units": units})
    return levels


def build_grammar() -> list[dict]:
    sections = split_sections(read(GRAMMAR), 2)
    rules = []
    for heading, body in sections:
        match = re.match(r"^(\d+)\.\s+(.*)$", heading)
        if not match:
            continue  # the "what this page does not cover" tail
        rules.append(
            {
                "id": f"g{match.group(1)}",
                "number": int(match.group(1)),
                "title": match.group(2).strip(),
                "blocks": parse_blocks(body),
            }
        )
    return rules


def build_patterns() -> list[dict]:
    sections = split_sections(read(PATTERNS), 2)
    patterns = []
    for heading, body in sections:
        joined = "\n".join(body)
        if "**Frame:**" not in joined:
            continue  # the index tables at the top
        patterns.append(
            {
                "id": "p-" + slug(heading),
                "title": heading,
                "blocks": parse_blocks(body),
            }
        )
    return patterns


def build() -> dict:
    return {
        "generated": __import__("datetime").date.today().isoformat(),
        "levels": build_units(),
        "grammar": build_grammar(),
        "patterns": build_patterns(),
    }


def main() -> int:
    payload = build()
    text = json.dumps(payload, ensure_ascii=False, indent=0) + "\n"
    check = "--check" in sys.argv

    units = sum(len(level["units"]) for level in payload["levels"])
    print(f"levels   : {len(payload['levels'])}  units: {units}")
    print(f"grammar  : {len(payload['grammar'])} rules")
    print(f"patterns : {len(payload['patterns'])}")

    if DST.exists():
        current = json.loads(DST.read_text(encoding="utf-8"))
        same = all(
            current.get(key) == payload[key] for key in ("levels", "grammar", "patterns")
        )
        if same:
            print(f"\nup to date: {DST.relative_to(ROOT)}")
            return 0
        if check:
            print(f"\nDRIFT: {DST.relative_to(ROOT)} is stale")
            return 1
    elif check:
        print(f"\nmissing {DST.relative_to(ROOT)}")
        return 1

    DST.parent.mkdir(parents=True, exist_ok=True)
    DST.write_text(text, encoding="utf-8")
    print(f"\nwrote {DST.relative_to(ROOT)} ({DST.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
