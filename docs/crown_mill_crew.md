# The Mills' full crew (crown-mill-crew)

The owner, 2026-11-20 20:41, after the powder study (docs/crown_powder_study.md): "YES" to coaching the Crown computer to
put a full crew of six labourers on each Powder Mill when its army's powder runs low. No number of the game changed: this
is the computer's play only. The switch is `-- millcrew:off`.

## In short

**Against the Clockwork it helps, and it is on there.** Over 40 games with the rule (two versions, 20 games each) against
the same 20 games without it, the Crown won or led at 20:00 in 34 of 40 (without: 14 of 20) and won outright 13 of 40
(without: 3 of 20). The score moved up in both versions (+0.29 and +0.20; game by game that is still inside the noise,
t 1.4 and 0.8, but it leaned the same way twice). Its musket men stood without powder less often (dry minutes 1.5 a game
down to 0.4 to 0.6), and it ground more of its saltpetre (about 550 to 800 less left in its halls at 16:00).

**Against the Brood it changes nothing**, so it is off there (-0.16 and -0.07, no sign either way). The Crown against the
Brood is short of gold, not powder: its powder bank was healthy without the rule.

**In the mirror it is off too.** With both Crowns playing it, the games ran further apart: the two sides ended one and a
half times apart at 16:00 in 7 and 9 of 20 games, against 4 of 20 without it (a snowball, which the design principles
warn against), and the first version measured clearly worse for the side the queue calls the Crown (-0.73, t -3.3).

`-- millcrew:on` turns it on in every matchup (for more games); `-- millcrew:off` turns it off everywhere.

## Why the computer kept so few hands on its Mills

Two things in the code, both found while reading it:

1. **The Mills' crew followed the powder bank only while a Barracks or Foundry was training** (AICrown._mill_feedback).
   But the army also spends powder when its soldiers refill: a Musketeer with no shots walks to a Mill, Barracks or Town
   Hall and takes ten powder from the bank. Late in the game, at the supply cap, nothing trains, so the rule never asked for
   another hand, however many Musketeers stood with only the bayonet.
2. **The shared mover only ever filled the first Mill** (AI._balance_mill sends farm hands to `mills[0]` and to no other).
   So the second to fifth Mills kept the one or two hands the idle labourers happened to wander to. That is the "6 to 9
   hands on 4 or 5 Mills" the powder study saw.

## What changed (scripts/ai_crown_mill_crew.gd, AICrownMillCrew)

After the opening (from 5:00), every think:

- **When is the powder low?** It counts the powder the army is missing: every firearm's empty shots, at what a shot
  costs (counted up to 120 powder: men far out in the field cannot refill anyway). The army "asks" for powder when that is
  30 powder or more, or two or more musket men have no shot at all, or a Barracks is waiting for powder. The powder is low
  when the army asks and the bank holds less than half of what is needed (the Barracks' and Foundry's usual want plus the
  missing shots).
- **Then** every Mill whose Town Hall still has saltpetre is filled toward a full crew of six, the nearest Mill to each
  labourer first, at most three labourers a think. Idle labourers go first, then labourers from the Farm with the most
  hands. Nobody carrying a harvest is moved, and nobody is sent to a Mill near enemies.
- **The Farms are not starved**: the Mills take at most a third of the labourers (35%), half while six or more musket
  men are dry.
- **Not** during a rush defence (the opening's own rule already keeps the Musketeers' powder first), and not when no Mill
  has saltpetre left.
- **It lets go** when the bank holds what the army needs (after 20 seconds at least), and then the extra hands go back to
  the Farms one every two seconds, so the crew does not swing back and forth.

The Crown's own Mill cap takes the larger of its old number and this rule's (AICrown._mill_cap), and while the rule is on
it moves the hands itself (AICrown._balance_mill), so the second and later Mills get their crews.

## How it was measured

The crown-1000 and powder study's ten games per matchup: five maps (Greenhold, Ashford Crossing, Mirewood, Frostfang,
Cinder Steps), two rounds each with the start spots swapped, their seeds. Crown Hard OPTIMAL against the Brood Hard
OPTIMAL, the Clockwork Hard OPTIMAL and another Crown Hard OPTIMAL (in the mirror both Crowns play the arm), to 20:00, on
0.38.107 (the rule cleanup merged). Each arm played the ten games twice (two blocks), so 20 games a cell, 180 games in all.

- **off**: the computer as on main (`millcrew:off`).
- **v1**: the first version: the missing shots counted whole, on for 30 seconds at least, a hand back every six seconds
  (`millcrew:v1`). It kept the Mills full too long: 150 to 430 powder lay banked at 12:00 and 16:00.
- **on**: the second version, the default code (missing shots counted up to 120 powder, 20 seconds, a hand every two
  seconds). Less powder lay idle (124 to 264 against the Clockwork), the results were alike.

The score, as in the crown-1000 jobs: g is the natural log of (income plus twice the army) of the Crown over the enemy's,
at 20:00 or at the defeat. "v off" is the difference game by game against the same game without the rule, with its t and
how many games were better and worse. Two blocks of the same code differ by about half a point of g, so anything under
about half a point with t under two is not a finding on its own.

## The numbers

(`python3 tools/study/crown_mill_crew.py report`; the Crown's side; in the mirror the side the queue calls the Crown.)

#### Crown v the Brood

| arm | games | survived | won or led (won) | mean g | g 14:00 | v off: d g (t) better/worse | v off: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/no shot 12 | armed/no shot 16 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 20 | 14 | 7 (1) | -0.57 | 0.10 |  |  | 17:29 | 1.44 / 1.07 / 0.99 | 2.25 / 2.33 / 0.92 | 1.6 | 78 / 72 / 4 | 130 / 170 / 112 | 19 / 0 | 12 / 0 |
| v1 | 20 | 13 | 5 (0) | -0.73 | 0.04 | -0.16 (-0.6) 4/6 | -0.06 (-0.7) | 18:55 | 1.35 / 1.08 / 0.91 | 2.16 / 1.96 / 0.75 | 0.1 | 88 / 173 / 211 | 110 / 188 / 44 | 15 / 0 | 12 / 0 |
| on | 20 | 14 | 6 (0) | -0.63 | 0.02 | -0.07 (-0.2) 5/5 | -0.08 (-0.9) | 17:23 | 1.40 / 1.09 / 0.97 | 2.21 / 1.39 / 1.17 | 0.3 | 84 / 155 / 62 | 185 / 118 / 124 | 16 / 0 | 16 / 0 |

#### Crown v the Clockwork

| arm | games | survived | won or led (won) | mean g | g 14:00 | v off: d g (t) better/worse | v off: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/no shot 12 | armed/no shot 16 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 20 | 19 | 14 (3) | +0.69 | 0.16 |  |  | 15:18 | 0.93 / 1.01 / 1.34 | 1.18 / 1.29 / 2.44 | 1.5 | 58 / 10 / 84 | 51 / 68 / 3910 | 18 / 0 | 26 / 4 |
| v1 | 20 | 19 | 17 (7) | +0.98 | 0.26 | +0.29 (1.4) 5/4 | +0.11 (1.6) | 19:39 | 0.94 / 1.04 / 1.33 | 1.23 / 1.60 / 1.17 | 0.4 | 70 / 152 / 434 | 38 / 52 / 4490 | 21 / 1 | 23 / 8 |
| on | 20 | 20 | 17 (6) | +0.89 | 0.12 | +0.20 (0.8) 6/4 | -0.04 (-0.3) | - | 0.95 / 0.98 / 1.16 | 1.15 / 0.99 / 1.33 | 0.6 | 64 / 124 / 264 | 30 / 28 / 2108 | 19 / 0 | 29 / 2 |

#### Crown v the Crown (mirror)

| arm | games | survived | won or led (won) | mean g | g 14:00 | v off: d g (t) better/worse | v off: d g14 (t) | median defeat | income 8/12/16 (x enemy) | army 8/12/16 (x enemy) | dry minutes | powder bank 8/12/16 | gold bank 8/12/16 | musket men armed/no shot 12 | armed/no shot 16 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| off | 20 | 19 | 12 (8) | +0.79 | 0.14 |  |  | 13:50 | 0.99 / 1.00 / 1.02 | 1.08 / 1.47 / 1.58 | 1.8 | 35 / 6 / 6 | 30 / 77 / 249 | 17 / 2 | 10 / 1 |
| v1 | 20 | 15 | 11 (4) | +0.06 | 0.09 | -0.73 (-3.3) 2/7 | -0.05 (-0.6) | 18:21 | 0.97 / 1.05 / 1.00 | 0.95 / 1.07 / 1.23 | 0.1 | 52 / 146 / 213 | 25 / 10 / 30 | 16 / 0 | 17 / 2 |
| on | 20 | 18 | 10 (9) | +0.67 | 0.15 | -0.12 (-0.3) 5/5 | +0.01 (0.1) | 17:03 | 0.95 / 1.03 / 1.06 | 1.07 / 1.55 / 2.81 | 0.1 | 46 / 152 / 206 | 22 / 18 / 34 | 20 / 0 | 22 / 1 |

#### The Mills (medians, the Crown side): Mills built / hands on them / saltpetre left in all its halls / halls, at 8:00, 12:00, 16:00; the rule: minutes on, hands it sent (means)

| matchup | arm | 8:00 | 12:00 | 16:00 | rule on (min) | hands sent |
|---|---|---|---|---|---|---|
| brood | off | 1 / 6 / 2350 / 2 | 4 / 6 / 4489 / 4 | 4 / 10 / 5020 / 5 | 0.0 | 0 |
| brood | v1 | 1 / 6 / 2344 / 2 | 3 / 10 / 4528 / 4 | 4 / 8 / 4409 / 4 | 2.8 | 31 |
| brood | on | 1 / 6 / 2345 / 2 | 4 / 9 / 4526 / 4 | 4 / 6 / 4612 / 4 | 3.4 | 42 |
| clockwork | off | 2 / 8 / 3610 / 3 | 4 / 20 / 5496 / 5 | 7 / 23 / 6694 / 7 | 0.0 | 0 |
| clockwork | v1 | 2 / 8 / 3595 / 3 | 4 / 22 / 4138 / 4 | 6 / 30 / 6227 / 7 | 4.6 | 33 |
| clockwork | on | 2 / 9 / 3589 / 3 | 4 / 23 / 4290 / 4 | 7 / 32 / 6108 / 7 | 4.6 | 33 |
| crown | off | 2 / 6 / 2400 / 2 | 3 / 8 / 3852 / 4 | 4 / 9 / 4752 / 4 | 0.0 | 0 |
| crown | v1 | 2 / 6 / 2970 / 2 | 3 / 15 / 4008 / 4 | 3 / 13 / 3476 / 4 | 4.4 | 38 |
| crown | on | 2 / 6 / 2392 / 2 | 4 / 16 / 4096 / 4 | 4 / 15 / 4198 / 5 | 4.8 | 36 |

#### Paired, on minus off, game by game (mean difference (t) better/worse of n)

| matchup | g | g 14:00 | income at 12:00 | income at 16:00 | army at 12:00 | army at 16:00 | powder bank 12 | hands on Mills 12 | hands on Mills 16 | saltpetre left 16 | musket men with no shot 12 | no shot 16 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| brood v1 | -0.16 (-0.6) 4/6 of 10 | -0.06 (-0.7) 5/5 of 10 | -181 (-0.9) 5/5 of 10 | -1268 (-1.6) 2/7 of 10 | -124 (-0.5) 4/6 of 10 | -136 (-0.3) 5/5 of 10 | +69 (3.7) 9/1 of 10 | +4 (4.2) 9/0 of 10 | +3 (1.0) 6/4 of 10 | -730 (-1.4) 3/7 of 10 | -1 (-0.9) 2/6 of 10 | +0 (0.9) 3/2 of 10 |
| brood on | -0.07 (-0.2) 5/5 of 10 | -0.08 (-0.9) 4/6 of 10 | +292 (1.0) 5/4 of 10 | +62 (0.1) 3/7 of 10 | +105 (0.6) 6/4 of 10 | -59 (-0.1) 5/5 of 10 | +84 (4.1) 9/1 of 10 | +3 (2.6) 7/3 of 10 | -1 (-0.6) 5/4 of 10 | -434 (-0.6) 4/6 of 10 | -0 (-0.7) 1/5 of 10 | +1 (1.4) 5/2 of 10 |
| clockwork v1 | +0.29 (1.4) 5/5 of 10 | +0.11 (1.6) 7/3 of 10 | -28 (-0.1) 6/4 of 10 | -520 (-0.7) 7/3 of 10 | +90 (0.5) 6/4 of 10 | +26 (0.2) 6/4 of 10 | +112 (3.8) 8/2 of 10 | +2 (1.0) 5/5 of 10 | +4 (1.9) 6/3 of 10 | -541 (-2.6) 2/8 of 10 | -0 (-0.3) 4/4 of 10 | +6 (2.5) 8/1 of 10 |
| clockwork on | +0.20 (0.8) 6/4 of 10 | -0.04 (-0.3) 4/6 of 10 | -307 (-1.2) 3/7 of 10 | -1590 (-2.2) 2/7 of 9 | -62 (-0.3) 5/5 of 10 | +47 (0.1) 4/5 of 9 | +84 (9.1) 10/0 of 10 | +2 (1.1) 7/3 of 10 | +3 (0.9) 5/4 of 9 | -793 (-2.4) 1/8 of 9 | -2 (-2.1) 1/8 of 10 | +3 (1.3) 5/3 of 9 |
| crown v1 | -0.73 (-3.3) 3/7 of 10 | -0.05 (-0.6) 3/7 of 10 | -26 (-0.1) 7/2 of 10 | +87 (0.1) 5/4 of 9 | -307 (-2.1) 3/7 of 10 | -13 (-0.1) 5/4 of 9 | +161 (5.6) 10/0 of 10 | +6 (4.0) 8/2 of 10 | +3 (1.7) 6/2 of 9 | -1141 (-2.1) 2/7 of 9 | -1 (-1.8) 2/6 of 10 | +2 (0.9) 4/4 of 9 |
| crown on | -0.12 (-0.3) 5/5 of 10 | +0.01 (0.1) 5/5 of 10 | +25 (0.1) 6/4 of 10 | +261 (0.2) 4/5 of 9 | -17 (-0.1) 5/5 of 10 | +68 (0.2) 4/5 of 9 | +134 (6.4) 10/0 of 10 | +6 (3.2) 7/2 of 10 | +5 (1.6) 5/3 of 9 | -689 (-0.9) 4/5 of 9 | -1 (-1.3) 3/6 of 10 | +0 (0.2) 3/6 of 9 |

#### The mirror: how far apart the two Crowns end (both play the arm)

| arm | games | decided by 20:00 | mean abs(g) | 1.5x apart at 16:00 | median minute decided |
|---|---|---|---|---|---|
| off | 20 | 9 | 1.28 | 4 | 15:23 |
| v1 | 20 | 9 | 1.42 | 7 | 18:09 |
| on | 20 | 11 | 1.49 | 9 | 17:08 |

## Claude's choices for the owner

1. **On against the Clockwork only.** Both versions leaned the same way there (34 of 40 won or led, against 14 of 20),
   neither is proven alone (t 1.4 and 0.8). Against the Brood and in the mirror it is off because it did not help. Say if
   you would rather have it everywhere (the owner's words were "when the army's powder runs low", in any matchup).
2. **"Low" is my definition**: the army missing 30 powder of shots, or two musket men dry, or a Barracks waiting, and the
   bank under half of what is needed. The Mills are filled to six, but never past a third of the labourers (half while six
   or more Musketeers are dry), so gold keeps coming.
3. **The missing shots count only up to 120 powder** (a dozen Musketeers' refills): men out in the field cannot refill,
   and counting all of them kept the Mills full while powder piled up (the first version).
4. **The second version is the default** even though the first scored a little higher against the Clockwork (+0.29 v
   +0.20, well inside the noise of each other): the second leaves less powder lying unused and was not worse in the mirror.
   `millcrew:v1` brings the first back.
5. **The shared mover's "first Mill only" was left alone** for the other cases (the opening, the Clockwork's Winders do not
   use it); only while this rule is on does the Crown move its hands to every Mill. Fixing the shared mover for everyone
   would change the opening, which was not asked.
6. **Not during a rush defence**, as the job asked: the opening's own rule already gives the Mill its three hands then.
7. **What is still open**: the Crown against the Brood runs out of gold, not powder; and the musket men with no shot at
   16:00 against the Clockwork are mostly men out in the field, away from any Mill, Barracks or Town Hall (the powder is in
   the bank; a Powder Wagon with the army, or sending dry men home, would be the next coaching).

## The tests

<!-- TESTS -->

## Files

- `scripts/ai_crown_mill_crew.gd` (AICrownMillCrew: when, how many, who moves, the report), hooked in
  `scripts/ai_crown.gd` (`mill_crew()`, `_mill_cap`, `_balance_mill`, the think's stage 0).
- `tools/test_crown_mill_crew.gd` (the rule's checks: the gate, the opening, calm, low, filling the nearest Mill then the
  next, the Farms' hands, the carrier, the release).
- `tools/qa_match.gd` (result.json crown_ai "millcrew": seconds on, hands sent, times on).
- `tools/study/crown_mill_crew.py` (run and report), `tools/study/crown_mill_crew_queue.sh` (the queue); data in
  `docs/crown_mill_crew/data/<off|v1|on>/<matchup>_b<block>/`.
