# app/ — Deutsch-Begleiter for iOS and macOS

One SwiftUI multiplatform target (iPhone + Mac) plus a local design package. The
markdown in the repo stays the source of truth; this app is a client of it.

## Build and run

```bash
cd app
xcodegen generate                     # regenerate the project after adding files
open DeutschBegleiter.xcodeproj       # then Run (⌘R)
```

Command line, unsigned:

```bash
xcodebuild -project DeutschBegleiter.xcodeproj -scheme DeutschBegleiter \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

`project.yml` is the source of truth for the project; the `.xcodeproj` is generated,
so new Swift files need a `xcodegen generate` before Xcode sees them.

**Quit Xcode before regenerating.** Xcode keeps the project it loaded in memory and
does not reload a `.xcodeproj` rewritten underneath it — it will report missing
products for packages added since it opened, and no amount of cache clearing fixes
that while it is running. Running from
Xcode needs a signing team on the target — the CLI build above bypasses that.

## Run it

Simulator only — no signing, no provisioning profile, no device:

```bash
tools/run_sim.sh                 # builds, boots, installs, launches
tools/run_sim.sh "iPhone 17"     # any installed simulator
```

Or open `DeutschBegleiter.xcodeproj`, pick an iPhone simulator, ⌘R.

A device build needs `DEVELOPMENT_TEAM` in `project.yml`; it is deliberately not
set, so no personal team id sits in a public repo.

### Jump straight to a screen

For screenshots and QA, the app takes launch arguments:

```bash
xcrun simctl launch "iPhone 17 Pro" com.hayden.DeutschBegleiter --tab course --course g1
xcrun simctl launch "iPhone 17 Pro" com.hayden.DeutschBegleiter --tab cards
xcrun simctl io "iPhone 17 Pro" screenshot /tmp/shot.png
```

`--tab` takes `home · speak · course · cards · settings`; `--course` takes a rule
or pattern id.

## Snapshots

The app renders its own screens offscreen — no screen-recording permission needed:

```bash
xcodebuild -project DeutschBegleiter.xcodeproj -scheme DeutschBegleiter \
  -destination 'platform=macOS' -derivedDataPath /tmp/dd CODE_SIGNING_ALLOWED=NO build

/tmp/dd/Build/Products/Debug/DeutschBegleiter.app/Contents/MacOS/DeutschBegleiter \
  --snapshot ./Snapshots
```

Every tab is written at phone (440×900) and desktop (1180×780), plus states a tab
render cannot reach: the empty B1 shelf, a deck detail, the study screen, and German
chrome (`home-de-phone`). Regenerate and eyeball the diff after a design change.

Two things cannot be captured offscreen: `ScrollView` content and AppKit-backed text
fields. `ScreenScroll`, `SecretField` and `PlainField` swap in static equivalents
while `RenderMode.isRendering` is set, so the snapshot still shows the real layout.

## Layout

```
app/
  project.yml                     # xcodegen source of truth
  Packages/DesignKit/             # tokens, scene, mascot, components
  Packages/SRSKit/                # SM-2 scheduler + review replay, with tests
    Tokens/Palette.swift          # sampled hues + the four noun colours
    Tokens/SceneTokens.swift      # day and dusk token sets
    Tokens/Metrics.swift          # type scale, radii, motion curves
    Scene/MeadowScene.swift       # procedural sky, hills, trees, clouds
    Scene/Dackel.swift            # the mascot, drawn in Canvas
    Components/                   # ChunkyButtonStyle, FloatCard, LeafProgress,
                                  # SpeechOrb, SpeechBubble, ScreenScroll
  DeutschBegleiter/
    App/                          # entry point, tab shell, UIText, snapshot harness
    Models/Deck.swift             # Level, DeckOrigin, Deck, DeckStore
    Models/Course.swift           # course pack + block decoding
    Models/BookletIndex.swift     # unit/dialog page ranges from the PDFs
    Models/ReviewStore.swift      # GRDB review log, replay, due queue
    Screens/                      # Home, Speak, Settings
    Screens/Course/               # shelves + block reader (tables, chunks)
    Screens/Cards/                # library, detail, editor, study + routing
  Snapshots/                      # generated phone baselines
```

## Language

The chrome is English by default; **Settings → App language** switches it to German.
Only chrome moves — buttons, headings, tab titles. German material stays German in
both modes: card fronts and backs, grammar section names (`Artikel`, `Die vier Fälle`),
scene labels (`Café · Perfekt`), and every pattern string. `UIText` holds the ~60
chrome strings and is injected through the environment.

## Decks

Three levels — A1, A2, B1 — and three origins:

| Origin | Who edits it | In-app actions |
|---|---|---|
| **Built in** | you, in the repo | Study only |
| **Yours** | the user | Study · Edit · Delete |
| **Generated** | the app, from lapses | reserved, not built |

Built-in decks can't be edited in the app on purpose: the next pack update would
overwrite the edit. Curated material changes in the repo, then ships as a new pack.
Custom decks are created in the app — name, level, cards typed in or pasted as TSV
(`front<TAB>back`, the same shape as `anki/German.txt`, so cards move in and out of
Anki without conversion).

### Where the built-in cards come from

`anki/Brainscape-German.txt` — the chunk deck, one cloze card per phrase
(`Hi! __________?(What’s up?)` → `Hi! **Was geht ab**? (ugs.)`). Not the core deck:
the core is the pattern/verb/teach skeleton for Anki, and these cards are the spoken
phrases.

```bash
python3 tools/export_brainscape.py           # rewrite decks.json
python3 tools/export_brainscape.py --check   # fail if the pack is stale
```

The script groups cards by the leading tag (`a1.1`, `a2.1`, …) into one deck per
level, converts Anki HTML into the inline markdown the app renders, and writes
`DeutschBegleiter/Resources/decks.json` (152 KB). The Brainscape file stays the only
source of truth; the JSON is generated and loaded at launch.

| Level | Cards | State |
|---|---|---|
| A1 | 595 | built in (a1.1 297 + a1.2 298) |
| A2 | 594 | built in (a2.1 300 + a2.2 294) |
| B1 | 0 | empty shelf — nothing in the repo produces B1 cards yet |

## Course content

Two views of the same material:

**Booklet** — the actual PDF pages. Each unit opens on its own dialogue, with
chips for *Unit · Dialog 1 · Dialog 2 · Dialog 3*. This is the default because the
booklets are two-column layouts: dialogue script with the English beside it,
footnote boxes on particles, *Neue Chunks* cloze tables, grammar tables and
exercises. Re-typesetting them loses all of that, which is what the first attempt
did.

**Notes** — the markdown in `course/**`, rendered as blocks.

```bash
python3 tools/export_booklet.py           # index the PDFs, stage them for the app
python3 tools/export_booklet.py --check   # fail if the index is stale
```

### How the indexing works

There are no "Dialog 1" headings in the body of a booklet — the titles exist only
on the contents page. So the index is built from two facts:

1. **Printed page numbers** from the contents page give each dialog's start.
2. **Page footers** (a bare number on the last line) give the offset between
   printed pages and PDF pages — 6 for A1.1, 0 for the rest. The median across
   every page is used, so one odd footer cannot shift the whole book.

Two adjustments matter: the page a dialog starts on is usually the **unit divider**
(`Unit 1: … -Im Flugzeug-`), so the index steps past any page beginning with
`Unit N:` to the first real page of text.

Result: 40 units, 119 dialogs across A1.1, A1.2, A2.1 and A2.2.

### Copyright

The booklets are © Anja Winter LTD, all rights reserved. `tools/export_booklet.py`
**copies** the PDFs into `Resources/booklets/` for the app to read, and those copies
are gitignored — the app bundle is a private build, not a redistribution. The
originals in `courses/` are already tracked in this repo; that is a separate
decision from this pipeline.

## Spaced repetition

Anki's classic SM-2, in `Packages/SRSKit` (no UI, no database — just the maths):

```bash
cd app/Packages/SRSKit && swift test      # 11 tests: intervals, ease, lapses, replay
```

| Rating | Quality | Effect |
|---|---|---|
| Again | 2 | repetitions reset, ease −0.32, back in 10 minutes, lapse counted |
| Good | 4 | 1 day → 6 days → previous × ease |
| Easy | 5 | as Good, ease +0.1 |

`scheduler.next(state, rating, at:)` is a pure function behind a `Scheduler`
protocol, so FSRS can replace SM-2 without touching the app. It is **not** FSRS
yet on purpose: FSRS is at v6/v7 with 21–34 parameters, and a from-memory port
would produce plausible-but-wrong intervals that tests written against the same
port could not catch.

### Local database

SQLite via GRDB, one table:

```sql
CREATE TABLE review (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cardID TEXT NOT NULL,      -- stable id from the pack: a1-33ed790359
  deckID TEXT NOT NULL,
  rating INTEGER NOT NULL,   -- 1 again · 2 hard · 3 good · 4 easy
  reviewedAt DATETIME NOT NULL
);
```

Path: `~/Library/Application Support/DeutschBegleiter/reviews.sqlite` (iOS: the
app container's Application Support). Inspect it with `sqlite3` at any time.

The log is the only stored truth — a card's schedule is replayed from its rows at
launch rather than written a second time, so there is no way for a schedule and
its history to disagree. Two consequences worth knowing:

- **Card ids must be stable.** The exporter hashes the front text (`a1-<sha1[:10]>`),
  so a pack refresh preserves history; editing a card's front creates a new card,
  which is the honest outcome rather than a silent state transfer.
- **Timestamps are truncated to milliseconds** before scheduling. SQLite stores
  dates at that resolution, so an untruncated `Date` produced a schedule that
  differed from its own replay. `--selftest` is what caught it.

New cards are capped at 20 per session — without a cap the first launch would open
a 595-card queue.

```bash
/…/DeutschBegleiter.app/Contents/MacOS/DeutschBegleiter --selftest
# good  → interval 1d  ease 2.50
# again → lapses 1  due +10m
# reopened → lapses 1  ease 2.18  reps 0   (state survives a relaunch)
```

## Design rules

| Rule | Why |
|---|---|
| Everything is drawn, nothing is a bitmap | One palette, scales to any screen, re-tints for dusk for free |
| Three elevations only: card, floating, modal | Keeps the scene calm behind the UI |
| Interactive surfaces have a bottom edge they press into | Reads as a toy, not a form |
| `der` red · `die` pink · `das` green · plural purple, everywhere | Gender becomes a mnemonic across tables, cards and corrections |
| Success is teal, never green | Green-on-grass is invisible |
| Error feedback is a row with a ✗, never a pill | `der` red and `die` pink sit close to the error coral, so the shape carries the signal |
| Dark mode is dusk | Same drawing, night tokens |

## Status

Working: course reader over all processed material, deck library over the real
Brainscape chunks, custom decks (in memory only), SM-2 scheduling in a local SQLite
log, due counts on Home, English/German chrome. Verified on the iOS simulator, not
just in the offscreen renderer.

Not yet wired: speech, the DeepSeek tutor, cloud sync, Keychain storage, custom-deck
persistence, and any link between a pattern and the cards that drill it. Tables wider
than a phone screen wrap rather than scroll.

The offscreen snapshot harness cannot see layout that depends on real safe areas —
the tab-bar overlap and the letterboxed window were both only visible in the
simulator.
