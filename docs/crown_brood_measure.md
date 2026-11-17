# The merged Crown coach v the Brood (crown-brood-measure, 2026-11-17)

A measuring job: no game or AI code changed. It measures 0.38.38 (eaab153a, the Crown coach as merged: v the Brood the
economy rules are off, and FARM FIRST, rule 3 THE HONEST RECKONING, rule 5 THE SCREEN FIRST and rule 6 GUNS FIRST stay on)
against the Brood only, in four arms:

- **M** as is (0.38.38);
- **C** `coach:off` (the Crown before the coach, no farm first);
- **H** `honest:off` (as is, but the old reckoning of the Brood);
- **F** `screenfirst:off gunsfirst:off` (as is, without the two fight rules).

Data: docs/crown_brood_measure/data/{M,C,H,F}/<tag>/ (result.json, story.txt); every table in
docs/crown_brood_measure/tables.md (tools/study/crown_brood_measure_report.py); the film in docs/crown_brood_measure/films/.

## In short

| arm | W-D-L | won or led: Crown / Brood / even | decided (mean length) |
|---|---|---|---|
| M as is | 0-32-6 | 1 / 35 / 2 | 6 (11:02) |
| C coach:off | 0-31-7 | 2 / 33 / 3 | 7 (10:46) |
| H honest:off | 0-33-5 | **5** / 30 / 3 | 5 (11:08) |
| F screen/guns off | 0-31-7 | 1 / 34 / 3 | 7 (10:29) |

1. **M is as good as C against the Brood, and no better.** Paired (same map, seed and sides): outcome M better in 6, C
   better in 7, same in 25 (p 1.0); income at 8:00 16 / 22 (p 0.42), at 12:00 16 / 13 (p 0.71); army at 5:00 15 / 18, at
   8:00 16 / 22, at 12:00 11 / 16 (all p > 0.4). Built halls lost 0.79 a game (C 0.89). The merge did no harm v the Brood:
   the damage of the last measurement (A v C worse 12 v 3) was the economy rules, now off.
2. **Why M and C are so alike: OPTIMAL rushes.** With NO BLIND RUSH off v the Brood, OPTIMAL leans to the Rush at 0:00 in
   37 of 38 games in every arm (one Balanced), as on main before the coach. FARM FIRST does not apply to the Rush plan, so
   the openings of all four arms are the same; the coach acts only after the rush fails (~5:15, the Economy plan takes over).
   Labourers 19.3 at 5:00 in every arm; income at 5:00 1.02-1.04 of the Brood's in every arm.
3. **Rule 3 (the honest reckoning) costs the Crown v the Brood.** H v M: income at 8:00 higher in **26** of 38 (12 lower,
   **p 0.034**), at 12:00 21 / 8 (**p 0.024**); army at 8:00 25 / 13 (p 0.073), at 12:00 18 / 8 (p 0.076); outcome H better
   in 11, M better in 6 (p 0.33); won or led 5 v 1. Pooled: income 0.84 v 0.78 at 8:00, 0.76 v 0.68 at 12:00; army 0.84 v
   0.68 at 8:00, 0.53 v 0.34 at 12:00. The mechanism shows in the story: with the honest reckoning the Crown "holds its wave
   back" 9 times in 7 games (H 27 in 13, C 32 in 18) and its own first attack goes out in 23 games (H 17, C 15): it sends
   waves into a Brood that has grown since it was last seen, loses them, and its economy follows. The old floor (BROOD_TABLE
   whatever was seen) was pessimistic, but against this Brood's 7:00-8:00 Timing it was closer to the truth.
4. **Rules 5 and 6 (screen first, guns first) neither help nor hurt measurably.** M v F: outcome 5 / 5 / 28 (p 1.0), income
   8:00 20 / 18, army 8:00 17 / 21 (p 0.63). They do fire: screen riders trained first in 21 of 38 M games (1.2 a game),
   guns set early in 16 (9.9 a game), lines formed on the march 24 in 16 games (F 20 in 15, C 6 in 5). At the first Brood
   arrival M loses a median 9 units and 1 building in 90 s, F 14 and 3 (C 9 and 1): a hint in their favour, not a result.
5. 152 games, none failed, no script errors.

**Recommendation (Claude's, nothing applied):**

- **Keep M's merge** (it is at least as good as C v the Brood, as it should be), but
- **turn rule 3 (the honest reckoning) off v the Brood** (keep it v the Clockwork, where it was measured with the rest of
  the coach): it is the only rule this measurement can see, and it hurts (income p 0.02-0.03, army p 0.07). Gate
  `honest_on()` by the matchup like the economy rules (a switch `broodhonest:on` to bring it back), and measure H's
  version against M once more if wanted (76 games, ~4 h on one core).
- **Keep rules 5 and 6 v the Brood**: no measurable cost, they fire in about half the games, and the first-arrival losses
  lean their way; their effect is small because the Crown rarely marches out formed against the Brood.
- The bigger lever is not in this coach: v the Brood the Crown's plan is the Horseman rush in 37 of 38 games, it fails
  (the Brood sees the Horse Breeder at ~1:30 and makes Raptors), and the Economy plan that follows is too thin for the
  Brood's Timing push at 7:00-8:30 (film below). The last measurement's rule 4 (no blind rush) was worse only together
  with the economy rules; a measure of `norush` alone v the Brood (no blind rush, no labourers first, no halls on time)
  is the natural next arm.

## How it was measured

- **The win-rate design** (docs/winrate_2026_11_15.md, as docs/crown_coach_measure_2.md): tools/qa_match.gd, Hard OPTIMAL
  Crown v Hard OPTIMAL Brood, the 19 two-player maps x round 0 and round 1 (`qa_matches.base()`: the same tags, seeds and
  side swaps), **to 12:00** (`end 720`).
- **Each game in every arm**, the arms next to each other in the queue (tools/study/crown_brood_measure.py; 152 games; one
  at a time on a 2-core machine (jobs = cores - 1), Godot 4.7.1 headless, every game under `timeout 2400`, about 3.3 minutes
  a game, ~8.5 hours). The machine restarted once mid-run (after about 62 games); the queue resumed from the saved results, no game
  was lost or run twice. The match is not deterministic, so a pair shares map, seed and sides, not the game.
- **Won or led**: won, or led a draw by 10% on income earned + 2 x army value. **Ratios**: the Crown's over the Brood's,
  pooled (sum over sum); tables.md also has per-game means (H's army at 12:00 per-game mean, 1.74, is lifted by a few
  games where the Brood's army was tiny: read the pooled one). **Sign test**: two-sided exact, ties dropped.

## Economy and army (Crown / Brood, pooled)

| arm | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| M as is | 1.02 | 0.78 | 0.70 | 0.68 | 0.72 | 0.68 | 0.57 | 0.34 |
| C coach:off | 1.04 | 0.81 | 0.76 | 0.70 | 0.74 | 0.73 | 0.59 | 0.33 |
| H honest:off | 1.03 | **0.84** | **0.80** | **0.76** | 0.70 | **0.84** | **0.69** | **0.53** |
| F screen/guns off | 1.03 | 0.78 | 0.74 | 0.70 | 0.73 | 0.65 | 0.55 | 0.26 |

| arm | Crown halls 8:00 | 12:00 | Brood halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Brood workers 5:00 | 8:00 | built Crown halls lost a game |
|---|---|---|---|---|---|---|---|---|---|
| M as is | 2.1 | 1.5 | 3.8 | 3.9 | 19.3 | 26.9 | 23.4 | 47.2 | 0.79 |
| C coach:off | 2.0 | 1.6 | 3.7 | 4.0 | 19.3 | 28.1 | 22.8 | 46.2 | 0.89 |
| H honest:off | 2.0 | 1.6 | 3.6 | 3.8 | 19.6 | 30.4 | 22.8 | 46.5 | 0.82 |
| F screen/guns off | 2.0 | 1.4 | 3.6 | 3.9 | 19.5 | 26.7 | 23.3 | 46.4 | 0.92 |

## Paired

| X v Y | outcome X better / Y better / same (p) | income 8:00 X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|
| M v C | 6 / 7 / 25 (1.0) | 16 / 22 (0.42) | 16 / 13 (0.71) | 15 / 18 (0.73) | 16 / 22 (0.42) | 11 / 16 (0.44) |
| M v H | 6 / 11 / 21 (0.33) | 12 / 26 (**0.034**) | 8 / 21 (**0.024**) | 16 / 16 (1.0) | 13 / 25 (0.073) | 8 / 18 (0.076) |
| M v F | 5 / 5 / 28 (1.0) | 20 / 18 (0.87) | 11 / 18 (0.27) | 15 / 16 (1.0) | 17 / 21 (0.63) | 15 / 12 (0.70) |

## The Brood's first arrival in the Crown's base (medians; 300+ army value within 500 px)

| arm | games | when | Brood army | Crown army there | Crown units lost in 90 s | Brood units lost | Crown buildings lost | Crown army 5:00 | 8:00 | the Crown's own first attack (games, when) | games with a built hall lost (first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| M | 30 | 7:55 | 550 | 710 | 9 | 33 | 1 | 360 | 770 | 23, 9:00 | 20, 10:37 |
| C | 32 | 8:05 | 587 | 800 | 9 | 27 | 1 | 360 | 835 | 15, 5:35 | 21, 10:30 |
| H | 29 | 8:00 | 600 | 830 | 11 | 32 | 1 | 360 | 940 | 17, 6:45 | 19, 10:55 |
| F | 30 | 8:00 | 515 | 855 | 14 | 31 | 3 | 360 | 820 | 22, 8:07 | 23, 10:00 |

## OPTIMAL's picks and which rules fired

OPTIMAL: the Rush 37 of 38 in every arm (Balanced 1; C also one switch to Economy). The story mentions the Horseman rush in
37 games of every arm.

| arm | screen riders trained first (games) | guns set early (games) | lines formed on the march | screen sightings | screen riders sent / lost | "forms its musket line" | "holds its wave back" |
|---|---|---|---|---|---|---|---|
| M | 1.2 (21) | 9.9 (16) | 0.6 | 0.4 | 2.3 / 0.3 | 24 in 16 | 9 in 7 |
| C | 0 | 0 | 0.2 | 0.1 | 0.4 / 0.1 | 6 in 5 | 32 in 18 |
| H | 1.3 (24) | 4.3 (10) | 0.4 | 0.2 | 1.6 / 0.3 | 17 in 10 | 27 in 13 |
| F | 0 | 0 | 0.5 | 0.4 | 1.8 / 0.3 | 20 in 15 | 15 in 12 |

The economy rules (labourers first, halls on time) fired in no game of any arm, as intended in 0.38.38.

## Film (arm M, tools/film_coach.gd shots:1 under xvfb-run, 12:00)

docs/crown_brood_measure/films/crbr_border_march_1121/: coach.txt (both sides every 15 s), story.txt, log.txt,
result_short.json (with the coach counters), map_0600/0900/1145, both armies every 30 s from 6:00 and the fights (jpg, 60%).
The same map, seed and sides as the last measurement's film (Border March, the Crown P2), so the two can be set side by
side. A film is a new game, not a replay of the study's (in the study M trailed here; C trailed, H led).

- **crbr_border_march_1121**: a draw on the clock, but the Crown is wiped out (0 halls, 0 labourers from 10:45). The Crown
  leans to the Rush at 0:00; the Brood sees its Horse Breeder at 1:32 and goes Timing with Raptors kept by its grubs. Three
  Cuirassiers ride out at 3:44 into 8 Raptors, the rush "fails (no headway in 90 s)" at 5:14 and hands over to the Economy
  plan: a walled natural, 2 halls, 22-25 labourers. The musket line rule speaks every minute and is never met (180 of 702
  wanted at 6:00, 410 of 1,035 at 8:00). None of the coach's counters fired (no screen riders, no guns set early: the
  Crown never marched). At 8:15 the Brood comes with 1,665 (22 Spitters, 19 Raptors, a Tyrant Challenger) against 650; the
  Crown holds the natural's gate and shifts a line of 3-6 Musketeers along the palisade for 30 s (fight_0826: Raptors
  pouring round the end of the wall, the Farms still full), then the line is gone; the natural's hall falls at 9:50, the
  main's at 10:40.

### What the Crown still does wrong v the Brood (coach's notes)

1. **The blind Horseman rush is back as the whole opening.** It rides out at ~3:45 with 3 riders into a Brood that saw it
   coming two minutes earlier; 37 of 38 games start this way in every arm, so nothing the coach does before 5:00 matters.
2. **After the rush the Economy plan is too thin for the Timing push.** 360 of army at 5:00, 700-800 at 8:00, against
   1,500+ at 8:15 in the film; the musket line rule names the gap every minute and cannot close it.
3. **The honest reckoning sends waves out it cannot afford** (finding 3); against the Brood it should keep the pessimistic
   floor.
4. **The palisade defence is a thin line running along the wall** (film): the Brood comes round the end of a wall the
   Crown's army chases along, instead of the army holding a short front behind it.
