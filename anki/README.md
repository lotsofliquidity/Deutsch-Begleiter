# Anki — German

Two files, two jobs:

| File | In Anki? | What it is |
|---|---|---|
| [`German.txt`](German.txt) | **no** | **Glossary.** Every card from every ingested unit (`chunk` / `noun` / `pattern` / `verb` / `teach`). Reference — search it, don't schedule it. |
| [`German-core.txt`](German-core.txt) | **yes** | **Deck.** Only `pattern` / `verb` / `teach` — the grammar skeleton (~15/unit). This is the one you review. |

`German-core.txt` is **generated** from `German.txt` — never hand-edit it.

```bash
python3 split_core.py     # regenerate German-core.txt from German.txt
```

**Never** import `German.txt` into Anki. At ~80 cards/unit it becomes a backlog that
cannot be cleared (~1.5–2.5 h/day at steady state, against a 25-min slot).

## Import German-core

Anki → **File → Import** → pick `German-core.txt` → Tab separator, fields Front / Back / Tags.
Deck name in Anki: **German-core**. Set **New cards/day = 10** in the deck options.

> Re-importing rebuilds the deck from the file. To keep review history, set the import
> option *Update existing notes when first field matches* = on — a card whose **front**
> is unchanged keeps its scheduling. Renaming a front breaks the match (see below).

Import options that matter:

- **Update existing notes when first field matches** = on
- Match scope: **Note type** (or Note type and deck: **German-core**)

**What keeps scheduling**

| Change | What Anki does | Progress |
|---|---|---|
| Same front, edit back/tags | Updates that note | Kept |
| New line (new front) | New note | New card (fine) |
| **Renamed front** | Treated as **new** note; old note stays | Old progress stays on the *old* front; new front starts at zero |

So: **edit backs freely and re-import.** Renaming a front breaks the match.

Edit cards in **`German.txt`** (the glossary), then regenerate:

```bash
python3 split_core.py     # German.txt  ->  German-core.txt
```

**If you must rename a front**

1. In Anki **Browse**, find the card, edit the Front there (scheduling stays on that note).
2. Mirror the same front text in `German.txt`.
3. Or: re-import the new front, then **suspend/delete** the old orphan — you lose that card’s history.

**Optional (renames-safe later):** export the deck from Anki with **Include unique identifier (GUID)**, keep a GUID column in the text file, and match on GUID when importing. Then you can rename Front and still update in place. Not set up in this repo yet — say if you want that.

**After a big re-import:** Browse → sort by *Created* / search `deck:German-core is:new` and suspend obvious duplicates from renamed fronts.


## Tags

Every card in `German.txt`: `a1.1 unit_NN` plus one of `chunk` / `noun` / `pattern` /
`verb` (or `a1.1 teach <topic> unit_NN`).

**`German-core.txt` carries only `pattern` / `verb` / `teach`.** `chunk` and `noun`
live in the glossary and are never scheduled.

Filter: `tag:unit_01` (both files) · `deck:German-core tag:a1.1` (in Anki).

## After edits

```bash
python3 validate_deck.py   # checks every *.txt deck
python3 split_core.py      # regenerate German-core.txt from German.txt
```

## Atomic cards (hard rules)

**One job per card.** If the back teaches two things, split it.

| Tag | Front | Back |
|---|---|---|
| `chunk` | English / situation cue | German only |
| `pattern` | One grammar question | One short rule |
| `verb` | Lemma — person? | Form(s) only |
| `noun` | English | `article + sg · article + pl` |

- Register / sense cues live on the **front** (*informal* / *formal* / *pointing* / *farther*) — English only, never as a lesson on the back.
- **Never put the German answer on the front.** No `(da drüben)`, `(hätten gern)`, `(Verzeihung)` in parentheses — that turns production into confirmation. Disambiguate with English sense (*curious / softened*, *polite*, *old-fashioned*).
- Never glue particle/grammar asides onto a chunk (`denn again`, `don't drop aus`, `job = no article`).
- Alternatives (`Gern geschehen` vs `Keine Ursache`) = **two cards**, not `A / B` on one back.
- Contrast pairs (`dir` vs `du`, `bar` vs `mit Karte`) = a `pattern` card; each sayable line stays its own `chunk`.
- **Frame, not dialog line.** Back = the reusable chunk (`Steigen Sie ein.`), not the
  full Neue Chunk sentence with comedy/names/glue. Unit `.md` still stores all 10
  lines; Anki does not. Prefer `Ich komme aus X.` over a filled place name when
  the slot is the point. Slot marker is **`X`** — especially when German sits on
  both sides (`Ich steige am X ein.` · `Hier steht X drauf.`).
- No teaching parentheses on chunk backs.

`validate_deck.py` flags chunk fronts whose parentheses leak a word from the back.

## Also

- Card **frames** from Neue Chunks + phrase-box bullets worth saying — not whole
  dialog lines, not drill ladders.
- New cards from `/ingest`, `/teach`, or `/drill` cold queue.
- Teach tags look like `a1.1 teach possessives`.
