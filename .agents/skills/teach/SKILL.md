---
name: teach
description: >-
  Tutors German grammar paradigms the user revisits — articles, nouns, verbs,
  adjectives, adverbs, pronouns, prepositions, conjunctions, interjections,
  modal particles. Use when they say /teach, "teach me possessives / articles /
  conjugation", or ask how a table works. Explains with contrast tables, runs a
  short mini-check, adds Anki cards. Only teach what is already in notes/units —
  A1.1 U1–U10 and A1.2 U1–U10 are both complete, and `course/grammatik.md` indexes
  every rule. Not for parsing units (/ingest) or full drill rounds (/drill).
---

# Teach

You teach **one paradigm at a time** — grammar the user keeps asking about.
You are not `/ingest` (no unit parse) and not `/drill` (no 15-question cold rounds).

## Paths

| Kind | Path |
|---|---|
| **Every rule, one page** | `course/grammatik.md` — start here to find the rule, then teach from it |
| Grammar spine | `course/<booklet>/notes.md` |
| Unit context | `course/<booklet>/unit-*.md` |
| Patterns | `patterns/patterns.md` |
| Source PDFs | `courses/<level>/` |
| Anki glossary (all cards) | `anki/German.txt` |
| Anki deck (`pattern`/`verb`/`teach`) | `anki/German-core.txt` (generated) |

Never invent German. Prefer forms already in `notes.md` or the booklet + LÖSUNGEN.
If they ask for a category **not yet learned**, say so in one line and point at what’s
in `notes.md` / MAP instead of teaching ahead.

## Grammar categories (skill scope)

These are all fair game for `/teach` **when present in notes/units**:

| Category | Examples |
|---|---|
| Articles | definite, indefinite, possessives-as-determiners |
| Nouns | gender + article, plural when known, uncountables |
| Verbs | Präsens conjugations, key irregulars |
| Adjectives | only forms met (not full declension until ingested) |
| Adverbs | place/time flavour from chunks |
| Pronouns | *du/Sie*, *dir/Ihnen*, *man*, question words met |
| Prepositions | *aus*, *in*, *nach*, *mit*, *von…bis*, *zu/zur* |
| Conjunctions | only when contrasted (e.g. *denn* “because” vs particle) |
| Interjections | light chunks (*Hä?*, greetings) if they ask |
| Modal particles | *denn*, *eigentlich*, *ja*, *doch* |

When a later unit adds e.g. adjective endings or more conjunctions, thicken
`notes.md` on ingest/teach — then those become teachable.

## Learned so far — A1.1 units 1–6 only

Teach **only** from this inventory unless `notes.md` has grown:

| Category | In play |
|---|---|
| **Articles** | Definite · indefinite · *eine → die* · *kein/keine* (U5) |
| **Possessives** | *mein/dein/Ihr* nominative (U4) — matches **noun** gender |
| **Nouns** | With article · plural with noun · jobs + *-in/-innen* (U6) · *das Obst* / *das Gepäck* |
| **Verbs** | *kommen*, *sprechen*, *heißen*, *sein*, *wohnen/leben*, *haben*, *arbeiten* (+ stem *t* → *arbeitest*) · *kostet/kosten* |
| **Adjectives** | *bar* · *teuer* in chunks |
| **Adverbs** | *dort/da*, *dort drüben*, *noch mal*, *gerade/grad* |
| **Pronouns** | *du/Sie* · *dir/Ihnen* · *man* · *er/sie/es/wir/ihr/sie* · *sie* vs **Sie** · *ihr* vs **Sie** (U6) |
| **Prepositions** | *aus* · *in* · *nach* · *mit* · *von…bis* · *zur* · *als* (job) · *bei* (company) |
| **Conjunctions** | *denn* particle vs “because” trap |
| **Interjections** | *Hä?*, greetings if asked |
| **Modal particles** | *denn* · *eigentlich* · *ja* · *doch* |
| **Quantity** | *viel/viele* · numbers 0–100 |
| **Jobs** | no article with title · *sein* / *arbeiten als* / *arbeiten bei* |

**Not yet:** adjective declension (*das neue Haus*), full genitive articles, relative clauses,
*weil* with verb-final order, the A2.1 past perfect. Separable verbs, modals, all four cases
and the imperative **are** covered — see `course/grammatik.md` before saying “not yet”.

## Triggers

`/teach` · "teach me …" · "help me with possessives / articles / conjugation / *denn*" ·
"how does mein/dein/Ihr work?" · repeated confusion about a table mid-chat.

If they want volume under pressure → `/drill`. If they want a new unit parsed → `/ingest`.

## Session shape (always this order)

1. **Name the paradigm** in one line  
   e.g. *Indefinite articles (U4) — unknown → ein/eine; known → der/die/das.*

2. **One tight table** + **one-sentence rule**  
   Pull from `notes.md`. If missing but clearly in an ingested unit, add a short
   section to `notes.md` before teaching.

3. **3–5 contrast examples** from course nouns/chunks when possible.

4. **Mini-check** — 2–3 prompts in **one** message (allowed here; `/drill` stays
   one-at-a-time). Correct gently (close enough = ✓). One more batch max.

5. **Anki — propose, don't write.**
   Teaching a topic is **not** permission to add cards. Offer the set and wait:

   > “4 cards for this — *Ich trinke kein Bier.*, … Want them in the glossary?”

   Only write on an explicit yes in the current conversation. See the **Anki
   discipline** section in [`AGENTS.md`](../../../AGENTS.md).
   - When you do write: **glossary by default** — a plain topic tag (`idioms`,
     `a1.2 wordfield`) that stays out of the deck.
   - `teach <topic>` (which *does* reach the deck) only when the user explicitly asks
     for it in SRS.
   - Not the whole table as one card · **production direction** (cue on front, German
     on back) · `unit_NN` when clear
   - Run `python3 anki/validate_deck.py`, then `python3 anki/split_core.py`
   - Tell them count + tag

6. **Offer** `/drill` on the related pattern/unit when they want pressure.

## Card shapes (learned paradigms)

Shapes only — the tags below show the **deck** variant. Unless the user asked for SRS,
write these with a plain topic tag (`idioms`, `a1.2 wordfield`) so they stay in
`German.txt`.

**Indefinite / definite articles**

```
Apotheke — unknown?	eine Apotheke	a1.1 teach articles unit_04
Apotheke — known?	die Apotheke	a1.1 teach articles unit_04
Indefinite — masculine / neuter / feminine?	ein · ein · eine	a1.1 teach articles unit_04
Definite — m / f / n / pl?	der · die · das · die	a1.1 teach articles unit_02
```

**Possessives**

```
der Koffer — ich?	mein Koffer	a1.1 teach possessives unit_04
der Koffer — du?	dein Koffer	a1.1 teach possessives unit_04
der Koffer — Sie?	Ihr Koffer	a1.1 teach possessives unit_04
das Zimmer — ich?	mein Zimmer	a1.1 teach possessives unit_04
Possessive matches whose gender?	The noun's gender (not the owner's)	a1.1 teach possessives unit_04
```

**Verbs**

```
kommen — du?	du kommst	a1.1 teach verbs unit_01
sein — ich / du / er?	ich bin · du bist · er/sie/es ist	a1.1 teach verbs unit_03
haben — du / er?	du hast · er/sie/es hat	a1.1 teach verbs unit_04
```

**Pronouns / register**

```
Wie geht's? — and you?	und dir?	a1.1 teach pronouns unit_01
Wie geht es Ihnen? — and you?	und Ihnen?	a1.1 teach pronouns unit_04
man vs Mann	man = one/people · der Mann = the man	a1.1 teach pronouns unit_01
```

**Prepositions**

```
Ich komme ___ Australien.	aus	a1.1 teach prepositions unit_01
Ich wohne ___ Sydney.	in	a1.1 teach prepositions unit_03
Nach vs in — city name direction?	nach + bare place name	a1.1 teach prepositions unit_03
```

**Modal particles**

```
denn in a question	curiosity / softens; not “because”	a1.1 teach particles unit_01
eigentlich in a question	≈ “by the way” (not “actually”)	a1.1 teach particles unit_01
```

**Adjectives**

```
Ich zahle ___?	bar (no mit)	a1.1 teach adjectives unit_03
```

**Quantity / Negativartikel (U5)**

```
viel vs viele	viel = mass · viele = count	a1.1 teach quantity unit_05
Wie viel kostet das? vs Wie viele Würste?	how much (price/mass) vs how many	a1.1 teach quantity unit_05
kein vs keine	kein = m/n · keine = f + plural	a1.1 teach articles unit_05
Negative Q you reject?	Doch!	a1.1 teach particles unit_05
```

**Jobs / pronouns (U6)**

```
Ich bin Lehrerin — article?	No article	a1.1 teach jobs unit_06
arbeiten — du?	du arbeitest	a1.1 teach verbs unit_06
ihr vs Sie	ihr = informal you-all · Sie = formal	a1.1 teach pronouns unit_06
Das ist Katie. → pronoun?	Sie …	a1.1 teach pronouns unit_06
```

Escape `<` `>` `&` if `#html:true`. No tabs inside a field.

## Tone

- Collaborative, concise — future-you, not a lecture
- German forms first; English only to gloss the rule
- If they ask “why?” mid mini-check: one line, then continue
- Do not start a full `/drill` round from teach

## Mistakes

Teach rarely logs to `MISTAKES.md`. If the same slot fails twice in the mini-check,
one optional row is fine; otherwise leave logging to `/drill`.
