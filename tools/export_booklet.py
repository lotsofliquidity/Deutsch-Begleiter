#!/usr/bin/env python3
"""Index the course booklets and stage them for the app.

Reads each booklet's table of contents, works out the offset between its printed
page numbers and the PDF's own page indices, then writes:

    app/DeutschBegleiter/Resources/booklets/index.json   (committed)
    app/DeutschBegleiter/Resources/booklets/*.pdf        (generated, gitignored)

The PDFs are copied rather than re-typeset: they are two-column layouts with
dialogue script, footnote boxes, cloze exercises and grammar tables, and any
reflow loses that. The app renders the real pages with PDFKit.

Usage:
    python3 tools/export_booklet.py [--check]
"""

from __future__ import annotations

import json
import pathlib
import re
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "app" / "DeutschBegleiter" / "Resources" / "booklets"

BOOKLETS = [
    ("a1.1", "A1.1", ROOT / "courses/a1.1/A1-1-KOMPLETT.pdf"),
    ("a1.2", "A1.2", ROOT / "courses/a1.2/A1-2-KOMPLETT.pdf"),
    ("a2.1", "A2.1", ROOT / "courses/a2.1/A2-1-KOMPLETT.pdf"),
    ("a2.2", "A2.2", ROOT / "courses/a2.2/A2-2-KOMPLETT.pdf"),
]

INVISIBLE = dict.fromkeys(map(ord, "\u202a\u202b\u202c\u202d\u202e\u200e\u200f\ufeff"), None)

UNIT = re.compile(r"Unit (\d+):\s*(.+?)$")
SETTING = re.compile(r"^-{1,2}\s*(.+?)\s*-{1,2}(?:\s+\d+)?$")
DIALOG = re.compile(r"Dialog (\d+):\s*(.+?)\s+(\d+)\s*$")


def flat(text: str) -> str:
    return re.sub(r"\s+", " ", text.translate(INVISIBLE)).strip()


def pages_of(pdf: pathlib.Path) -> list[str]:
    text = subprocess.run(
        ["pdftotext", "-layout", str(pdf), "-"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    return text.split("\f")


def read_toc(pages: list[str]) -> tuple[list[dict], int]:
    """Units and dialogs with their printed page numbers, plus the TOC's last page."""
    units: list[dict] = []
    last_toc_page = 0

    for index, page in enumerate(pages[:12]):
        # keep the column spacing: the printed page number sits far right
        lines = [line.translate(INVISIBLE).rstrip() for line in page.splitlines()]
        lines = [line for line in lines if line.strip()]

        for position, raw_line in enumerate(lines):
            line = flat(raw_line)
            dialog = DIALOG.search(raw_line)
            if dialog and units:
                units[-1]["dialogs"].append(
                    {
                        "number": int(dialog.group(1)),
                        "title": dialog.group(2).strip(),
                        "page": int(dialog.group(3)),
                    }
                )
                last_toc_page = index
                continue

            unit = UNIT.search(line)
            if not unit or "Dialog" in line or "Unit" not in line:
                continue

            title = re.sub(r"\s+\d+\s*$", "", unit.group(2).strip())
            setting = ""
            # some booklets put "-Im Flugzeug-" on the following line
            if position + 1 < len(lines):
                candidate = SETTING.match(flat(lines[position + 1]))
                if candidate:
                    setting = candidate.group(1)
            trailing = re.search(r"-{1,2}\s*(.+?)\s*-{1,2}$", title)
            if trailing:
                setting = trailing.group(1)
                title = title[: trailing.start()].strip()

            units.append(
                {
                    "number": int(unit.group(1)),
                    "title": title,
                    "setting": setting,
                    "dialogs": [],
                }
            )
            last_toc_page = index

    seen: set[int] = set()
    unique = []
    for unit in units:
        if unit["number"] in seen or not unit["dialogs"]:
            continue
        seen.add(unit["number"])
        unique.append(unit)
    return unique, last_toc_page


def median(values: list[int]) -> int:
    ordered = sorted(values)
    return ordered[len(ordered) // 2]


def footer_offset(pages: list[str]) -> int | None:
    """Printed page numbers sit alone on the last line of each page.

    The dialog titles appear only in the contents, never as body headings, so
    the page footers are the reliable way to align printed pages to PDF pages.
    """
    offsets = []
    for index, page in enumerate(pages):
        lines = [line.translate(INVISIBLE).strip() for line in page.splitlines()]
        lines = [line for line in lines if line]
        if not lines:
            continue
        footer = lines[-1]
        if footer.isdigit() and len(footer) <= 3:
            printed = int(footer)
            if printed > 0:
                offsets.append((index + 1) - printed)
    return median(offsets) if offsets else None


def build_booklet(level_id: str, name: str, pdf: pathlib.Path) -> dict | None:
    pages = pages_of(pdf)
    units, toc_end = read_toc(pages)
    if not units:
        print(f"  ! no table of contents in {pdf.name}")
        return None

    offset = footer_offset(pages)
    if offset is None:
        print("  ! could not align printed pages with PDF pages")
        return None

    built = []
    for unit in units:
        unit_number = unit["number"]
        dialogs = []
        for dialog in unit["dialogs"]:
            start = dialog["page"] - 1 + offset
            if not 0 <= start < len(pages):
                continue

            # the printed page a dialog starts on is often the unit divider
            # ("Unit 1: … -Im Flugzeug-"); step past it to the dialogue itself
            for advance in range(3):
                candidate = start + advance
                if candidate >= len(pages):
                    break
                text = flat(pages[candidate])
                divider = re.match(
                    rf"Unit\s+{unit_number}\s*:", text, re.IGNORECASE
                ) is not None
                if not divider and len(text) > 240:
                    start = candidate
                    break
            dialogs.append({"number": dialog["number"], "title": dialog["title"], "start": start})

        if not dialogs:
            continue
        dialogs.sort(key=lambda item: item["start"])
        built.append(
            {
                "number": unit["number"],
                "title": unit["title"],
                "setting": unit["setting"],
                "dialogs": dialogs,
            }
        )

    if not built:
        return None

    # end pages: each dialog runs to the next dialog, each unit to the next unit
    flat_dialogs = [(unit, dialog) for unit in built for dialog in unit["dialogs"]]
    for position, (unit, dialog) in enumerate(flat_dialogs):
        if position + 1 < len(flat_dialogs):
            dialog["end"] = flat_dialogs[position + 1][1]["start"] - 1
        else:
            dialog["end"] = len(pages) - 1

    for unit in built:
        unit["start"] = unit["dialogs"][0]["start"]
    for position, unit in enumerate(built):
        if position + 1 < len(built):
            unit["end"] = built[position + 1]["start"] - 1
        else:
            unit["end"] = len(pages) - 1

    # to 1-based, which is what PDFKit wants, and drop the helper field
    for unit in built:
        unit["start"] += 1
        unit["end"] += 1
        for dialog in unit["dialogs"]:
            dialog["start"] += 1
            dialog["end"] += 1

    return {
        "id": level_id,
        "name": name,
        "file": f"{level_id}.pdf",
        "pages": len(pages),
        "offset": offset,
        "units": built,
    }


def main() -> int:
    check = "--check" in sys.argv
    booklets = []

    for level_id, name, pdf in BOOKLETS:
        if not pdf.exists():
            print(f"missing {pdf.relative_to(ROOT)}")
            continue
        print(f"▸ {name}  {pdf.name}")
        booklet = build_booklet(level_id, name, pdf)
        if not booklet:
            continue
        booklets.append(booklet)
        dialogs = sum(len(unit["dialogs"]) for unit in booklet["units"])
        print(f"  {len(booklet['units'])} units, {dialogs} dialogs, {booklet['pages']} pages")

    payload = {"booklets": booklets}
    index = OUT / "index.json"
    text = json.dumps(payload, ensure_ascii=False, indent=1) + "\n"

    if index.exists() and json.loads(index.read_text(encoding="utf-8")) == payload:
        print(f"up to date: {index.relative_to(ROOT)}")
        return 0
    if check:
        print("DRIFT: index.json is stale")
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    index.write_text(text, encoding="utf-8")
    for level_id, _, pdf in BOOKLETS:
        if pdf.exists():
            shutil.copyfile(pdf, OUT / f"{level_id}.pdf")

    size = sum(f.stat().st_size for f in OUT.glob("*.pdf")) // (1024 * 1024)
    print(f"\nwrote {index.relative_to(ROOT)} + {len(booklets)} pdf(s), {size} MB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
