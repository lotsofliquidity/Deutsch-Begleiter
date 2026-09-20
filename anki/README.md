# Anki — German

Deck file: [`German.txt`](German.txt) · deck name in Anki: **German**

## Import

Anki → **File → Import** → pick `German.txt` → confirm Tab separator, fields Front / Back / Tags.

Re-importing updates cards that share the same front.

## Tags

Every card: `a1.1 unit_NN` plus optional `chunk` / `verb` / `pattern`.

Filter in Anki: `tag:unit_01` or `deck:German tag:a1.1`.

## After edits

```bash
python3 validate_deck.py
```

## Rules of thumb

- One fact per card.
- Card **chunks** and **frames**, not whole drill ladders.
- New cards come from `/ingest` (unit parse), `/teach` (paradigms), or `/drill` cold queue.
- Teach tags look like `a1.1 teach possessives`.
