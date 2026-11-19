# Crown 1000, the Clockwork half (crown-1000-clockwork)

The owner, 2026-11-19 07:26: "The Crown's computer is the weak one... We need a complete job of 1000 crown games, every 10
games changing something to see if crown gets better, currently its bad ai." This job is the half against the Clockwork:
blocks of 10 games of the Crown computer (Hard OPTIMAL) against the Clockwork computer (Hard OPTIMAL), to 20:00, a change of
the Crown computer's play between blocks. The sister job crown-1000-brood does the Brood half.

## In short (provisional, updated as the blocks come in)

(Written during the run; the final numbers replace these at the end.)

| | block 0 (0.38.81) | the kept set (block 19) |
|---|---|---|
| survived to 20:00 | 6 of 10 | 9 of 10 |
| won or led at 20:00 | 0 | 6 (3 wins) |
| score, Crown / Clockwork (income + 2 x army; a beaten side x0.25) | x0.19 | x1.07 |
| paired v block 0 | | x5.74 (t 4.2, 10 better / 0 worse) |
| income at 8:00 / 12:00 (of the Clockwork's) | 0.65 / 0.55 | 0.79 / 0.75 |
| army at 8:00 / 12:00 | 0.56 / 0.31 | 0.80 / 0.88 |

The kept changes (all against the Clockwork only, scripts/ai_crown_v_clock.gd): `pick` (OPTIMAL picks Timing or Siege),
`hall2` (the second hall right after the pick), `tech3` (the Church and the Armoury after the third hall), `dry` (with the
powder gone and 400+ gold banked, Field Cannons and bayonet Musketeers).

## How it is measured

- **The 10 games of a block**: five maps (Greenhold, Ashford Crossing, Mirewood, Frostfang, Cinder Steps) x two rounds with
  the start spots swapped; the seeds and sides are the plan-matrix-crown study's OPTIMAL row (tools/study/plan_matrix.py),
  the same in every block. Runner: `tools/study/crown1000.py run BLOCK --extra SWITCHES --root COPY` (two games at a time on
  the 2-core machine, about 55 minutes a block); `tools/study/crown1000_queue.sh` runs a queue of blocks, each on a fresh
  copy of the working tree (`tools/study/crown1000_sync.sh`), so the next change is written while a block runs.
- **Score**: plan_matrix_report's: income earned + 2 x army value, the Crown's over the Clockwork's at the bell (a beaten
  side's score x0.25). "Survived" = not beaten by 20:00. "Won or led" = won, or 10% ahead on the score at 20:00.
- **Paired**: each game against the same game (map, round, seed, sides) of the baseline blocks (the mean of their log
  scores when the baseline was run more than once): x = the geometric mean of the ratio, t = paired t on the logs,
  up/down = games better / worse by more than 5%.
- **Noise**: a match is not deterministic (the same seed plays a different game), so one block is noisy. A change is
  KEPT when its block beats the kept baseline by a clear margin (x >= 1.15 with t >= 1.2, and no fewer games survived); the
  kept set is rerun every 10 blocks to check it was not luck.
- **What changes**: the Crown computer's play only, gated to the Crown v Clockwork matchup (scripts/ai_crown_v_clock.gd,
  AICrownVClock, every change behind its switch `cvc:<name>`); no number of the game.
- Data: `docs/crown_1000_clockwork/data/<block>/` (result.json, story.txt per game, extra.txt = its switches);
  `docs/crown_1000_clockwork/blocks.csv` (one row a block: `python3 tools/study/crown1000.py report --csv ...`).

## Block 0: where the Crown stands (0.38.81, no change)

Survived 6 of 10, won or led 0, score x0.19 of the Clockwork's (a beaten Crown's score counted a quarter); the median
defeat 17:27. OPTIMAL picked Timing 7, Balloon 2, Economy 1 (read NORMAL at ~1:30 in all 10).

| minute | 3:00 | 5:00 | 8:00 | 10:00 | 12:00 | 16:00 |
|---|---|---|---|---|---|---|
| labourers / Winders | 15 / 17 | 21 / 27 | 34 / 44 | 39 / 52 | 36 / 53 | 31 / 52 |
| income earned (Crown / Clockwork) | 1,330 / 1,904 | 2,850 / 4,085 | 6,194 / 9,596 | 8,664 / 14,830 | 11,124 / 20,174 | 14,900 / 29,882 |
| army value | 18 / 14 | 229 / 467 | 1,139 / 2,018 | 1,628 / 2,743 | 1,228 / 3,928 | 740 / 6,998 |
| halls | 1 / 2 | 2 / 2 | 2 / 3 | 2 / 3 | 3 / 4 | 2 / 5 |
| bank | 57 / 143 | 25 / 303 | 41 / 376 | 114 / 688 | 144 / 913 | 1,053 / 2,594 |

What the stories show: the Crown spends every coin (a bank of 25-60 gold to 8:00) and is still behind on every count. Its
second hall comes at ~4:30-5:00 (the Clockwork's at ~2:30), its third at ~11:00 (the Clockwork's ~6:30). In the opening a
hall stood idle with 2+ free Farm posts 5-6 of every 12 looks (every 5 s) at 3:00-5:00, the build order owning the gold.
The Clockwork's first push (8 units) leaves at ~4:45 and the Crown holds at its ramp top with half the army; from 10:00 the
Clockwork's army doubles the Crown's and the halls fall from 11:00-13:00. The Crown's waves are few and late (none in 4
games; 7:34-13:35 in the rest) and the one into the Clockwork's base melts (Cinder Steps r0: 1,610 -> 544 in two minutes).

## The log, block by block

| block | the change (its switch) | survived | won or led | score x | v kept baseline | kept? |
|---|---|---|---|---|---|---|
| 0 | none (0.38.81) | 6 | 0 | 0.19 | - | baseline |
| 1 | OPTIMAL's pick against the Clockwork: Timing or Siege, half and half (was Timing 3 : Economy 1 : Balloon 2) (`pick`) | 7 | 0 | 0.31 | x1.66 (t 1.1, 6 better / 3 worse); at 12:00 x1.14 (t 1.5) | **kept** (with the plan matrix behind it: Siege and Timing were the two best plans of 12 games each) |
| 2 | the army clock's share 0.6 -> 0.4 of a Hard Clockwork's usual army (`share`), run on block 0's code (without `pick`) | 5 | 1 (a win, Cinder Steps r1) | 0.24 | v block 0: x1.27 (t 0.4, 5/4); at 12:00 x1.24 (t 2.5), labourers at 8:00 37.9 (33.5), income 12:00 0.64 (0.55) | not decided: the economy clearly up, survival one game down; run again on the kept set (block 8) |
| 3 | the third hall at 28 labourers (not 40 and an army of 0.7 a labourer) (`hall3`) | 7 | 0 | 0.29 | v block 1: x0.92 (t -0.2, 5/4); at 12:00 x0.97 | not kept: 3.5 halls at 12:00 (3.2), no more income, less army |
| 8 | `share` again, on the kept set (with `pick`) | 7 | 0 | 0.25 | v block 1: x0.80 (t -0.5, 3/7); at 12:00 x0.96; labourers at 8:00 34.0 (34.0) | not kept: block 2's labourers did not come again |
| 9 | a Field Cannon for every 3 Musketeers, the Barracks waiting for its gold (`guns`; the guns killed 10 Clockwork units a gun lost in blocks 1-8) | 4 | 0 | 0.13 | v block 1: x0.43 (t -1.8, 3/7); at 12:00 x0.85 (t -2.6), army at 12:00 0.21 (0.41) | not kept: clearly worse; the Barracks waiting for the guns' gold thinned the line |
| 10 | none: the kept set again (`pick`), the baseline's rerun | 7 | 0 | 0.32 | v block 1: x1.03 (t 0.1); v block 0: x1.71 (t 1.9, 6/1), at 12:00 x1.17 (t 2.2) | the kept baseline from here is blocks 1 and 10 pooled; `pick` confirmed |
| 11 | the Mills keep one hand each once 250 powder is banked, the rest to the free Farm posts (`powder`; read from result.json's "res2", which turned out to be the powder ground so far, not the bank: the premise was wrong) | 7 | 0 | 0.27 | v blocks 1+10: x0.85 (t -0.6, 5/3); at 12:00 x1.02 | not kept: it hardly acted (Mill hands 4.0 at 8:00, 6.9 at 12:00); the bank is rarely that full (see block 18: late, the powder runs OUT) |
| 4 | no wave into a bigger army: a wave waits until it is worth 1.3x the Clockwork army it reckons (the army at the supply cap still goes) (`hold`) | 7 | 0 (2 even) | 0.28 | v blocks 1+10: x0.90 (t -0.3, 5/5); at 12:00 x1.03; labourers at 8:00 37.2 (34.2), income 8:00 0.73 (0.69) | not kept: a little more economy, the same defeats |
| 5 | the second hall next after OPTIMAL's pick, at 11 labourers (`hall2`) | 6 | 1 (led Greenhold r0, x1.47) | 0.27 | v blocks 1+10: x0.85 (t -0.4, 4/5); **at 12:00 x1.19 (t 2.8)**; the second hall at 3:00 in 9 of 10 (was 4:00-6:00), labourers at 8:00 40.6 (34.2), income 8:00 0.82 (0.69), army 8:00 0.82 (0.65) | not decided: the clearest economy gain yet, but the defeats still come at 17:00-19:00 (4 of them); run again (block 14) |
| 13 | stand at the halls: the army goes down to an expansion against a force up to 1/0.9 of itself (was 1/1.3) and musters only under 0.85 of the force (was 1.2) (`stand`) | 4 | 0 | 0.17 | v blocks 1+10: x0.55 (t -1.7, 3/7); at 12:00 x0.98 | not kept: the fights it now takes it loses; the old thresholds were right |
| 14 | `hall2` again | 8 | 0 | 0.42 | v blocks 1+10: x1.33 (t 0.9, 7/3); at 12:00 x1.35 (t 3.0); income 8:00 0.80, army 8:00 0.95, army 12:00 0.67 (0.43) | **kept** (blocks 5 and 14: survived 14 of 20 as the baseline's 14, at 12:00 x1.19 and x1.35, the economy and the army up in both). The baseline from here: blocks 5 and 14 |
| 7 | labourers before the army clock (the coach's LABOURERS FIRST no longer yields to it before 6:00, nor under 30 labourers) (`labs`), on `pick` only | 5 | 2 | 0.20 | v blocks 1+10: x0.64 (t -1.0, 4/6); at 12:00 x0.99; labourers at 8:00 37.8 (34.2) | not kept: more labourers, no more income at 12:00, fewer survived |
| 15 | a big bank late: another Barracks when 500+ gold is banked and every Barracks is busy (from 8:00) (`spend`) | 6 | 3 (2 wins) | 0.51 | v blocks 5+14: x1.52 (t 0.5, 6/4); at 12:00 x0.97 | not kept: a test game with it (Frostfang 9236, traced every 20 s) shows it never acts: the Crown already lays Barracks (9 at 14:00) and they stand idle for want of gold or powder, not buildings; the 3 games won or led are within the noise (t 0.5) |
| 6 | the Church and the Armoury wait for the third hall (`tech3`), on `pick` + `hall2` | 9 | 2 | 0.72 | v blocks 5+14: **x2.15 (t 1.6, 6/3)**; at 12:00 x1.08 (t 0.9); army 12:00 0.60 (0.59) | **kept** (clear margin, 9 survived); to be checked again with the kept set's rerun |
| 18 | no powder and a big bank (400+ gold, the powder under a Musketeer's load): the Foundries cast Field Cannons (gold only, they fire no powder) and the Barracks train Musketeers with the bayonet, who fill up when the powder comes (`dry`), on `pick` + `hall2`. Found by tracing a game: from 9:00 the powder bank sat at 0-30 (the halls' saltpetre runs down) while the gold grew to 9,000 and the Barracks and Foundries stood idle | 9 | **4** | 0.63 | v blocks 5+14: **x1.88 (t 1.6, 8/2)**; at 12:00 x0.95 (it acts later) | **kept**: it acted (hundreds to thousands of times) in 6 games, and 4 of those were led at 20:00 |
| 17 | the wave pulls back once it loses 1.3x what it kills over 30 s (was 2.2) (`trade`), on `pick` + `hall2` + `tech3` | 6 | 1 | 0.27 | v blocks 5+14: x0.82 (t -0.4); v block 6: x0.38 (t -2.0) | not kept: it never acted (0 times: the Crown's waves fall back by the musket line's own rule first). So block 17 is in effect a rerun of block 6's set, and it did far worse than block 6: **block 6 was lucky**; `tech3` stays on for now (blocks 6 and 17 together x1.33 v blocks 5+14, 15 of 20 survived against 14), to be judged on the kept set's reruns |
| 19 | none: the kept set (`pick`, `hall2`, `tech3`, `dry`) | 9 | **6** (3 wins) | **1.07** | v blocks 5+14: x3.20 (t 2.5, 8/2); at 12:00 x1.10 (t 1.4) | the kept set's first rerun |
| 21 | the kept set without `tech3` (`cvctech3:off`): is `tech3` real? | 8 | 6 | 0.77 | v block 19: x0.71 (t -0.5, 4/6); at 12:00 x0.98 | `tech3` stays: across blocks 6, 17 and 21 it leans positive (x1.3-1.4) and never measured as harm; most of the gain is `dry` and `hall2` |
| 23 | `dry` from 200 gold banked (was 400) (`cvcdrybank=200`) | 7 | 6 | 0.68 | v blocks 19+21: x0.75 (t -0.6, 4/6); **at 12:00 x0.85 (t -3.2)** | not kept: bayonet Musketeers bought sooner cost the army at 12:00; 400 stays |
| 16 | `hold` again, on the kept set | 8 | 5 | 0.61 | v blocks 19+21: x0.68 (t -0.7, 4/6); at 12:00 x0.97 | not kept (as in block 4: more economy, no better end) |
| 12 | a second Foundry at 26 labourers and two halls (was 40-44 and three) (`foundry2`), on the kept set | 9 | 4 | 1.09 | v blocks 19+21: x1.21 (t 0.4, 4 better / 6 worse); at 12:00 x0.93 (t -1.0) | not kept: within the noise |
| 20 | with 1,000+ gold banked no labourer past 55, so the supply goes to soldiers (`richlabs`), on the kept set | 9 | 4 | 0.80 | v blocks 19+21: x0.89 (t -0.6, 4/5); at 12:00 x0.98 | not kept: within the noise (`dry` already turns the late bank into soldiers) |
