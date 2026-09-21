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
- **Production direction:** English / situation cue on the **front**, German on the **back** (survival chunks, nouns, sayable frames). Mark *informal* / *formal* on the front when both exist.
- Card **every Neue Chunk** (all ~10 per dialog from LÖSUNGEN), plus **frames** / particles — not whole drill ladders.
- **Nouns:** one card each — front English/lemma, back `article + singular · article + plural`.
- New cards come from `/ingest` (unit parse), `/teach` (paradigms), or `/drill` cold queue.
- Teach tags look like `a1.1 teach possessives`.

**Re-import note:** Anki matches on the **front**. Flipping direction creates new cards — delete or suspend the old German-front versions after import.
