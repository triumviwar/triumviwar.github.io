# The Crown's powder, four options measured (crown-powder-study)

The owner, 2026-11-20 01:09, on crown-1000-clockwork's finding that the Crown runs out of powder late while its gold piles
up: "Measure". Four design options were built, each a match switch, all OFF by default, and measured in computer games and
on the scripted economy bench. Nothing a player sees changes unless a switch is given.

## In short

**None of the four options measurably changed how the Crown computer does.** Over 300 games, 360 with the A+C pair (Crown Hard OPTIMAL v the
Brood, v the Clockwork and the Crown mirror, 20 games per option per matchup, to 20:00) every option stayed within the
noise of the baseline (no paired difference reached t 2 in its two pooled blocks). The reason is in the numbers: **the
saltpetre is not what runs out.** At 16:00 the Crown computer's halls still hold 4,300 to 6,600 saltpetre between them
(medians); what is short is the grinding. It keeps 4 or 5 Mills but only 6 to 9 labourers on all of them together (a full
Mill takes 6), so it grinds roughly a Mill and a half's worth of powder for the whole army. More saltpetre (A) and a higher
floor (B) change little because the computer's Mills rarely reach the floor; the Nitre Beds (C) and BUY POWDER (D) do add
powder (about 360 to 560 from the beds, 250 to 530 bought, in a game) but they cost the same gold the army wanted.

**The "dry" minutes are few.** A dry minute here is one with under 10 powder banked and 400 gold or more banked. The
baseline Crown had 1 to 3 of them a game (v the Clockwork the most). The powder bank is near 0 from 12:00 against the
Clockwork in most games, but mostly because the gold is spent too, not because it piles up.

**Claude's recommendation**: change no number yet. The lever this study points at is the computer's own play: crew the
Mills it already has (6 hands a Mill once the army's powder runs low), which is coaching, not design, and belongs with
crown-rule-cleanup or a job after it. If the owner wants a design change for human players anyway (a human crews his Mills
and does reach the floor late), **B, the 35% floor**, is the smallest and quietest: on the bench it gives a perfect Crown
+11% powder over 20 minutes, mostly after 12:00, it never pays more than a fresh Mill, it needs no new button or building,
it measured the best against the Brood (+0.30 in g, t 1.5) and neutral elsewhere, and it did not make the mirror snowball
(the two Crowns ended 1.5 times apart at 16:00 in 3 of 20 games, the baseline in 6). Of the others, D (BUY POWDER) was the
best against the Clockwork (+0.40, t 0.9) but is a gold-to-powder exchange with no exposure (no building to raid) and leaned to a snowball in the mirror (1.5 times apart at 16:00 in 10 of 20, the baseline 6), C (the
Nitre Beds) leaned worse against the Brood and the Clockwork and made the mirror end sooner and more often (11 of 20
decided, baseline 7), and A changes nothing for the computer before 16:00 (its halls are not spent).

**A and C together** (`salt2500+nitre`, 60 more games): also within the noise against the Brood (-0.02) and the Clockwork
(+0.21, t 0.9); in the mirror the games ended decided more often (12 of 20, the baseline 7), as with C alone. Over 360 games
in all, no option nor the pair is a clear gain, and the beds (with or without A) are the ones that make the mirror end.

## The options (all OFF; `-- powder:<option>`, several with `+`: `powder:salt2500+nitre`)

| option | switch | what it does | where |
|---|---|---|---|
| A | `salt2500` | a Town Hall holds 2,500 saltpetre (was 1,320) | CrownPowder.lode_full (Building.lode_full, Game.lode_at_spot) |
| B | `floor35` | a Mill on spent saltpetre grinds at 35% (was 15%) | CrownPowder.powder_floor (Game.draw_lode, lode_pay, the cards) |
| C | `nitre` | NITRE BEDS: a small Crown building (3 x 2, 125 gold, 25 s, 450 hp) on the build list after the Powder Mill; by itself it turns gold into powder, 3 gold a powder, one every 1.5 s (40 a minute, 120 gold a minute); it must stand by a Farm or a Horse Breeder (8 tiles, centre to centre) near a Town Hall, one per Town Hall; it rests while 400 powder are banked and goes hungry if its Farm or Horse Breeder is gone | CrownPowder.place_problem, beds_tick; Defs.BUILDINGS "nitre_beds"; art tools/draw_nitre_beds.py |
| D | `buy` | BUY POWDER on the Town Hall's card: 50 powder for 150 gold at once, then 30 s before the side may buy again (one wait for the side, not per hall) | CrownPowder.buy, card; Game.buy_powder (forwarded online, NetCommands) |

**The computer** (CrownPowder.ai_tick, think stage 1 of AICrown): from 6:00, with under 60 powder banked, it BUYS
POWDER when it holds 400 gold or more (D) and lays Nitre Beds at the hall with the least saltpetre left that has none,
one site at a time and one a minute at most, whenever it can pay 175 (C).

## How it was measured

- **The games**: the crown-1000 jobs' 10 games per matchup (5 maps: Greenhold, Ashford Crossing, Mirewood, Frostfang,
  Cinder Steps; 2 rounds with the start spots swapped; their seeds), Crown Hard OPTIMAL v Brood / Clockwork / Crown Hard
  OPTIMAL, to 20:00, on 0.38.86 (both crown-1000 jobs' kept changes on). Two blocks of the same 10 per option per matchup,
  pooled: 20 games a cell, 300 in all, and 60 more for the A+C pair. In the mirror BOTH Crowns play the option.
  `tools/study/crown_powder_study.py run <opt> <opp> <block>`, the queue `tools/study/crown_powder_queue.sh`, the tables
  `python3 tools/study/crown_powder_study.py report`.
- **The score** (crown_1000_brood's): g = ln of (income + 2 x army) Crown over the enemy's at 20:00 or the defeat, a
  beaten side's counted a quarter; g14 the same at 14:00. "v base" is the paired difference game by game against the
  baseline pool, with its t and the games better / worse. Two blocks of the same code differ by about 0.6 in g: nothing
  under about +-0.5 with t under 2 is a finding.
- **The powder measures** (new in tools/qa_match.gd, result.json minutes, "crown"): the powder bank, the saltpetre left in
  all the side's halls, the musket men (Musketeers, Guardsmen, Dragoons) with shots and with none (bayonet only), what the
  options made (CrownPowder.made_of: powder from beds and bought, the gold paid).
- **The bench** (tools/econ_bench.gd, the scripted perfect Crown alone on Greenhold to 20:00, no army; the powder is drained
  every second so the beds never rest; with `nitre` a bed at every hall after its Mill, with `buy` a buy whenever the
  merchant comes): docs/crown_powder_study/bench/<option>.json.

## The scripted bench: a perfect Crown's powder (Greenhold, 20:00, 3 halls)

| option | powder a minute at 8:00 / 12:00 / 16:00 / 20:00 | powder in 20 minutes | gold paid for it | saltpetre left at 20:00 |
|---|---|---|---|---|
| base | 156 / 261 / 192 / 141 | 2,879 | 0 | 1,080 |
| A salt2500 | 171 / 300 / 255 / 217 | 3,547 (+23%) | 0 | 3,952 |
| B floor35 | 163 / 279 / 221 / 175 | 3,186 (+11%) | 0 | 772 |
| C nitre | 238 / 342 / 233 / 142 | 3,785 (+31%) | 2,748 | 1,089 |
| D buy | 263 / 367 / 297 / 245 | 4,634 (+61%) | 5,400 | 1,124 |

Even the perfect Crown, its Mills fully crewed, has not spent its halls by 20:00 (1,080 left in three halls); it is past
its best (141 a minute at 20:00 against 261 at 12:00). C's beds stop paying late on the bench because the bench pulls its
spent Farms down and a bed with no Farm near goes hungry (a Horse Breeder would keep it fed). D is the most powder and the
most gold; on the bench the gold is free (it builds no army), in a game it is not.

## The games

How to read the mirror: both Crowns play the option, so "survived" and "won or led" are for the side the queue calls the
Crown (its seeds and spots), and the mean g leans to that side (+0.45 in the baseline: the spots, not the option). What tells
in the mirror is the last table: how often the two ended far apart (a snowball) and how often the game was decided.

(The tables below are `python3 tools/study/crown_powder_study.py report`.)

<!-- REPORT -->
### Crown v the Brood

| option | games | survived | won or led (won) | mean g | g 14:00 | v base: d g (t) b/w | v base: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/bayonet 12 | armed/bayonet 16 | made: nitre / bought |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| base | 20 | 14 | 5 (1) | -0.54 | 0.12 |  |  | 18:13 | 1.43 / 1.20 / 1.00 | 2.17 / 1.70 / 0.97 | 1.1 | 68 / 155 / 46 | 220 / 128 / 90 | 14 / 0 | 13 / 0 | 0 / 0 |
| salt2500 | 20 | 14 | 6 (0) | -0.66 | 0.06 | -0.12 (-0.3) 4/6 | -0.07 (-0.5) | 16:54 | 1.38 / 1.10 / 0.97 | 2.11 / 1.75 / 0.95 | 0.1 | 100 / 140 / 196 | 105 / 142 / 130 | 21 / 0 | 18 / 0 | 0 / 0 |
| floor35 | 20 | 16 | 7 (2) | -0.24 | 0.09 | +0.30 (1.5) 6/2 | -0.03 (-0.4) | 16:50 | 1.44 / 1.09 / 1.12 | 2.26 / 1.52 / 0.74 | 1.2 | 97 / 177 / 46 | 288 / 82 / 223 | 16 / 0 | 18 / 0 | 0 / 0 |
| nitre | 20 | 10 | 8 (0) | -0.95 | 0.02 | -0.41 (-1.1) 5/5 | -0.10 (-0.8) | 18:30 | 1.44 / 1.16 / 1.02 | 2.72 / 1.79 / 1.10 | 0.6 | 92 / 202 / 42 | 100 / 132 / 40 | 17 / 0 | 17 / 1 | 356 / 0 |
| buy | 20 | 15 | 5 (0) | -0.67 | 0.08 | -0.13 (-0.4) 5/5 | -0.04 (-0.3) | 17:34 | 1.40 / 1.10 / 0.93 | 2.23 / 1.48 / 0.81 | 0.5 | 91 / 134 / 113 | 182 / 148 / 96 | 15 / 0 | 14 / 0 | 0 / 248 |
| salt2500+nitre | 20 | 15 | 3 (1) | -0.56 | 0.06 | -0.02 (-0.0) 4/5 | -0.07 (-0.4) | 16:41 | 1.40 / 1.11 / 0.98 | 2.29 / 1.60 / 1.01 | 0.2 | 104 / 180 / 222 | 138 / 86 / 85 | 17 / 0 | 13 / 0 | 226 / 0 |

### Crown v the Clockwork

| option | games | survived | won or led (won) | mean g | g 14:00 | v base: d g (t) b/w | v base: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/bayonet 12 | armed/bayonet 16 | made: nitre / bought |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| base | 20 | 14 | 9 (1) | -0.66 | -0.46 |  |  | 16:05 | 0.76 / 0.67 / 0.77 | 0.91 / 0.42 / 1.47 | 2.9 | 95 / 4 / 0 | 31 / 157 / 851 | 8 / 0 | 21 / 11 | 0 / 0 |
| salt2500 | 20 | 17 | 8 (0) | -0.52 | -0.42 | +0.14 (0.5) 5/5 | +0.04 (0.4) | 13:20 | 0.77 / 0.66 / 0.78 | 0.85 / 0.68 / 0.90 | 2.2 | 112 / 8 / 0 | 32 / 288 / 335 | 16 / 0 | 21 / 10 | 0 / 0 |
| floor35 | 20 | 16 | 6 (2) | -0.56 | -0.42 | +0.10 (0.3) 7/3 | +0.04 (0.4) | 16:20 | 0.79 / 0.72 / 0.74 | 0.95 / 0.48 / 0.66 | 1.6 | 74 / 3 / 0 | 47 / 235 / 293 | 14 / 0 | 23 / 0 | 0 / 0 |
| nitre | 20 | 16 | 3 (1) | -0.76 | -0.51 | -0.10 (-0.3) 7/3 | -0.05 (-0.5) | 15:58 | 0.77 / 0.69 / 0.73 | 0.87 / 0.42 / 0.29 | 0.5 | 96 / 32 / 22 | 14 / 31 / 50 | 13 / 0 | 21 / 0 | 558 / 0 |
| buy | 20 | 17 | 8 (2) | -0.26 | -0.28 | +0.40 (0.9) 7/3 | +0.18 (1.3) | 19:14 | 0.81 / 0.75 / 0.88 | 0.99 / 0.80 / 0.86 | 1.4 | 100 / 26 / 1 | 84 / 18 / 178 | 16 / 0 | 21 / 1 | 0 / 532 |
| salt2500+nitre | 20 | 16 | 7 (2) | -0.45 | -0.38 | +0.21 (0.9) 7/3 | +0.08 (0.7) | 16:14 | 0.78 / 0.72 / 0.76 | 0.99 / 0.73 / 0.89 | 0.7 | 101 / 16 / 27 | 31 / 54 / 110 | 17 / 0 | 15 / 0 | 519 / 0 |

### Crown v the Crown (mirror)

| option | games | survived | won or led (won) | mean g | g 14:00 | v base: d g (t) b/w | v base: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/bayonet 12 | armed/bayonet 16 | made: nitre / bought |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| base | 20 | 18 | 12 (5) | +0.45 | 0.14 |  |  | 18:06 | 1.00 / 1.00 / 1.01 | 1.20 / 1.31 / 1.27 | 2.2 | 54 / 0 / 39 | 20 / 24 / 67 | 16 / 1 | 9 / 3 | 0 / 0 |
| salt2500 | 20 | 16 | 9 (4) | -0.01 | 0.03 | -0.47 (-1.3) 4/6 | -0.11 (-1.9) | 18:33 | 0.98 / 0.99 / 0.92 | 1.08 / 1.21 / 0.71 | 2.1 | 58 / 1 / 0 | 25 / 148 / 47 | 15 / 0 | 10 / 2 | 0 / 0 |
| floor35 | 20 | 18 | 11 (5) | +0.51 | 0.27 | +0.05 (0.1) 4/6 | +0.13 (1.4) | 19:43 | 0.99 / 1.08 / 1.05 | 1.31 / 1.96 / 1.26 | 1.5 | 49 / 8 / 198 | 28 / 93 / 80 | 18 / 0 | 17 / 2 | 0 / 0 |
| nitre | 20 | 17 | 15 (8) | +0.73 | 0.15 | +0.28 (0.7) 6/4 | +0.01 (0.1) | 15:54 | 0.96 / 1.04 / 1.25 | 1.04 / 1.24 / 2.06 | 0.7 | 62 / 18 / 134 | 16 / 16 / 12 | 14 / 1 | 16 / 0 | 541 / 0 |
| buy | 20 | 18 | 14 (7) | +0.75 | 0.26 | +0.29 (0.7) 8/2 | +0.12 (1.3) | 18:59 | 0.99 / 1.07 / 1.20 | 0.98 / 1.36 / 1.70 | 0.9 | 59 / 15 / 60 | 26 / 45 / 30 | 16 / 2 | 18 / 2 | 0 / 382 |
| salt2500+nitre | 20 | 18 | 16 (10) | +1.08 | 0.28 | +0.62 (1.8) 7/3 | +0.13 (1.4) | 17:55 | 0.99 / 1.15 / 1.22 | 1.07 / 1.44 / 1.81 | 0.5 | 60 / 40 / 168 | 20 / 30 / 7 | 17 / 0 | 30 / 1 | 473 / 0 |

### The Mills (medians, the Crown side): Mills built / hands on them / saltpetre left in all its halls / halls, at 8:00, 12:00, 16:00

| matchup | option | 8:00 | 12:00 | 16:00 |
|---|---|---|---|---|
| brood | base | 1 / 6 / 2362 / 2 | 4 / 8 / 4520 / 4 | 5 / 8 / 5424 / 5 |
| brood | salt2500 | 2 / 6 / 4700 / 2 | 4 / 6 / 9272 / 4 | 4 / 9 / 8987 / 4 |
| brood | floor35 | 1 / 6 / 2350 / 2 | 3 / 7 / 4546 / 4 | 5 / 6 / 6324 / 6 |
| brood | nitre | 2 / 6 / 2357 / 2 | 4 / 6 / 4548 / 4 | 4 / 4 / 6622 / 6 |
| brood | buy | 1 / 6 / 2358 / 2 | 4 / 8 / 4582 / 4 | 4 / 6 / 5424 / 5 |
| brood | salt2500+nitre | 1 / 6 / 4704 / 2 | 4 / 6 / 9272 / 4 | 5 / 7 / 11038 / 5 |
| clockwork | base | 2 / 6 / 3590 / 3 | 4 / 6 / 4507 / 4 | 5 / 8 / 6617 / 6 |
| clockwork | salt2500 | 2 / 6 / 4674 / 2 | 4 / 6 / 9029 / 4 | 5 / 8 / 11197 / 5 |
| clockwork | floor35 | 2 / 6 / 2342 / 2 | 3 / 6 / 4320 / 4 | 4 / 9 / 4271 / 4 |
| clockwork | nitre | 2 / 6 / 2332 / 2 | 4 / 6 / 4430 / 4 | 4 / 8 / 5286 / 5 |
| clockwork | buy | 2 / 6 / 2344 / 2 | 4 / 7 / 4534 / 4 | 5 / 7 / 5716 / 5 |
| clockwork | salt2500+nitre | 2 / 6 / 4705 / 2 | 4 / 6 / 9120 / 4 | 4 / 6 / 11112 / 5 |
| crown | base | 2 / 7 / 3012 / 2 | 3 / 10 / 4141 / 4 | 4 / 11 / 4450 / 5 |
| crown | salt2500 | 2 / 4 / 7127 / 3 | 4 / 6 / 7922 / 4 | 4 / 6 / 8582 / 4 |
| crown | floor35 | 2 / 6 / 3607 / 3 | 4 / 10 / 4435 / 4 | 4 / 12 / 4312 / 4 |
| crown | nitre | 2 / 5 / 3582 / 3 | 4 / 8 / 4548 / 4 | 5 / 10 / 6201 / 6 |
| crown | buy | 2 / 5 / 3605 / 3 | 4 / 7 / 4536 / 4 | 4 / 7 / 3998 / 4 |
| crown | salt2500+nitre | 2 / 6 / 5962 / 2 | 4 / 7 / 9272 / 4 | 5 / 10 / 10926 / 5 |

### The mirror: how far apart the two Crowns end (both play the option)

| option | games | decided by 20:00 | mean abs(g) | 1.5x apart at 16:00 (score) | median minute decided |
|---|---|---|---|---|---|
| base | 20 | 7 | 1.20 | 6 | 16:40 |
| salt2500 | 20 | 8 | 1.20 | 6 | 18:33 |
| floor35 | 20 | 7 | 1.17 | 3 | 15:35 |
| nitre | 20 | 11 | 1.50 | 7 | 17:05 |
| buy | 20 | 9 | 1.33 | 10 | 18:02 |
| salt2500+nitre | 20 | 12 | 1.60 | 6 | 16:41 |
<!-- /REPORT -->

## Claude's choices (for the owner to confirm or change)

1. **The prices.** Beds and buying both at 3 gold a powder (a Musketeer's 10 shots = 30 gold, half his own price): dear
   enough that a fresh Mill (about 119 a minute for 6 labourers and 100 gold once) is always better, cheap enough to matter
   once the Mills are spent. The beds 40 a minute, the merchant 50 every 30 s (at most 100 a minute for the side): neither
   beats a fresh Mill.
2. **The beds need a Farm or a Horse Breeder near** (the dung: the fiction of real nitre beds) and are one per Town Hall,
   so they are exposed income at a hall, as design_principles 2 asks, not a safe global bonus. They rest at 400 banked so
   they do not eat the gold of a side that has powder enough.
3. **BUY POWDER has one wait for the whole side**, not one per Town Hall, so more halls do not buy more. It has nothing to
   raid: a safe exchange, the one option against "no permanent safe global bonuses" (design_principles 2).
4. **The computer's trigger is the dry bank after 6:00, not "a hall whose saltpetre is low".** Traced first (Mirewood 9269 v
   the Clockwork with `nitre`): the bank was dry from about 10:00 while every hall still held over a third of its saltpetre,
   so a "low saltpetre" trigger laid no beds at all. The beds go by the hall with the least saltpetre first.
5. **The computer buys only with 400 gold banked** (the same bar as crown-1000-clockwork's `dry`), but lays beds whenever it
   can pay 175: a building is a lasting choice and the bank sat at 200 to 370 for minutes in the trace.
6. **Stand-in art** for the beds and the buy button is drawn in code (tools/draw_nitre_beds.py), listed in
   docs/art_style_inconsistency.md for a redraw only if the owner keeps C.
7. **The switches are match switches from the command line** (like `cvc...`), so the study and tools can set them; there is
   no lobby or Settings toggle, no translation of the new texts and they are not kept in saves or replays. If the owner
   keeps an option it becomes a plain rule (or a lobby option) and those are done then.

## Open questions for the owner

1. The premise "each hall's saltpetre is spent in ~11 minutes" holds for a fully crewed Mill (the bench's main hall); the
   computer crews its Mills at 1 to 2 labourers each, so its saltpetre lasts. Shall a coaching job crew the computer's Mills
   (6 a Mill once the bank runs low) before any number changes? (Claude's recommendation: yes, after crown-rule-cleanup.)
2. For human players, does the owner want more late powder at all? A human who crews his Mills does reach the floor, around
   15:00 to 20:00 at the main. If yes: B (the 35% floor) is the quietest; A delays the problem by about 8 minutes a hall; C
   and D turn gold into powder (C exposed at a hall, D safe).
3. If C is kept: keep the dung rule (Farm or Horse Breeder near), or let it stand anywhere near a hall?
4. If D is kept: is a 30-second merchant right, or should it be a Town Hall queue item (it would then compete with the
   Labourers, a real opportunity cost)?

## The tests (options off; run on 0.38.86, the new test and test_exhaust again after merging main 0.38.87)

`tools/test_crown_powder.gd` (new): every option on and off: PASS. The AI and Crown tests (tools/test_ai_*.gd,
tools/test_crown_*.gd, tools/test_exhaust.gd, 46 scripts) with the options off: all pass but test_ai_rush_followup (Crown v
Brood, listed as stale before), test_ai_wall_vs_rush ("Barracks and Powder Mill laid by 75 s": listed as failing before) and
test_crown_dragoon_raid's [plan] check (listed as failing before). The godot process aborts at exit after every test and
game (exit 134 after the result is written), as it does on main.
