# Anki — German

Deck file: [`German.txt`](German.txt) · deck name in Anki: **German**

## Import

Anki → **File → Import** → pick `German.txt` → confirm Tab separator, fields Front / Back / Tags.

Re-importing updates cards that share the same front.

## Tags

Every card: `a1.1 unit_NN` plus optional `chunk` / `verb` / `pattern` / `noun`.

Filter in Anki: `tag:unit_01` or `deck:German tag:a1.1`.

## After edits

```bash
python3 validate_deck.py
```

## Atomic cards (hard rules)

**One job per card.** If the back teaches two things, split it.

| Tag | Front | Back |
|---|---|---|
| `chunk` | English / situation cue | German only |
| `pattern` | One grammar question | One short rule |
| `verb` | Lemma — person? | Form(s) only |
| `noun` | English | `article + sg · article + pl` |

- Register lives on the **front** (*informal* / *formal* / *with denn*) — never as a lesson on the back.
- Never glue particle/grammar asides onto a chunk (`denn again`, `don't drop aus`, `job = no article`).
- Alternatives (`Gern geschehen` vs `Keine Ursache`) = **two cards**, not `A / B` on one back.
- Contrast pairs (`dir` vs `du`, `bar` vs `mit Karte`) = a `pattern` card; each sayable line stays its own `chunk`.
- Neue Chunk dialog lines stay one English → one German. No teaching parentheses.

## Also

- Card **every Neue Chunk** and phrase-box bullet worth saying, plus frames / particles — not whole drill ladders.
- New cards from `/ingest`, `/teach`, or `/drill` cold queue.
- Teach tags look like `a1.1 teach possessives`.

**Re-import note:** Anki matches on the **front**. Changed fronts create new cards — suspend/delete the old ones after import.
