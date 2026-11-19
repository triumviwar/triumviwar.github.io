# Crown 1000, the Brood half (crown-1000-brood)

The owner, 2026-11-19 07:26: "The Crown's computer is the weak one... We need a complete job of 1000 crown games, every 10
games changing something to see if crown gets better, currently its bad ai." This job is the Brood half: the Crown computer
(Hard OPTIMAL) against the Brood computer (Hard OPTIMAL), in blocks of 10 games to 20:00, one change of the Crown computer's
play a block, kept only when the block is clearly better than the best so far. The sister job crown-1000-clockwork does the
Clockwork half; every change here runs only against the Brood (scripts/ai_crown_1k_brood.gd, AICrown1kBrood).

## Summary

**210 games against the Brood (21 blocks of 10, to 20:00) fit the run, not 500**: two games at a time on the 2-core
machine, a block of 10 took 26-35 minutes (the Crown now lasts to 17-20 minutes), about 12 hours of games with the
reading and coding between. Two more blocks checked the kept changes against the Clockwork and in the mirror (below), 230
games in all. The job finished cleanly: the kept changes ON
by default, the rest OFF behind their switches, the AI tests run.

**Kept (on by default, against the Brood only)**: `lean` (OPTIMAL plays the Horseman rush's own build from 0:00 in every
game, as the plan matrix found best) and `siege` (when the rush is over it hands over to the Siege push, not the Economy
plan: Field Cannons and Mortars, a push on the Brood's rooted ground weighed against the Brood army it has SEEN, and no
late re-pick back to the Economy race). Not kept (behind their switches, off): `eco`, `press`, `tech`, `halls`, `farms`, `queen`, `pester`, `edge`, `guns`,
`maws`, `mortars`, `guard`, `spare`.

| Crown OPTIMAL v Brood OPTIMAL, the same 10 games | before (main 0.38.81, b01+b05, 20 games) | lean (b02+b07, 20) | **kept: lean + siege (b09+b10+b14, 30)** | plan matrix 0.38.59, the same seeds (10) |
|---|---|---|---|---|
| mean g (ln score ratio, beaten counted a quarter) | -1.19 | -0.98 | **-0.73** | -2.41 |
| g14 (the ratio at 14:00) | -0.25 | -0.02 | **+0.10** | -0.78 |
| survived to 20:00 | 9 of 20 (45%) | 8 of 20 (40%) | **20 of 30 (67%)** | 0 of 10 |
| won or led at 20:00 | 3 of 20 (2 won) | 4 of 20 (3 won) | **10 of 30 (0 won, 10 led)** | 0 |
| median minute of the defeats | 16:55 | 17:59 | **18:52** | 15:39 |
| income at 8:00 / 12:00, of the Brood's | 1.18 / 0.95 | 1.35 / 1.13 | **1.47 / 1.16** | 0.85 / 0.70 |
| army at 8:00 / 12:00, of the Brood's | 1.86 / 2.20 | 2.14 / 2.20 | **2.65 / 2.98** | 1.34 / 0.64 |
| Crown halls at 12:00 | 3.0 | 3.0 | **3.8** | 2.3 |
| Field Cannons at once (most) | 1-3 | 2.3 | **5.7-6.4** | |

Paired game by game against the baseline pool, the kept code is better in 7 of 10 games, mean g +0.45 (t 1.7), g14 +0.35
(t 3.7). The noise between two blocks of the same code is about 0.6 in g and 0.2 in g14 (block 5 reran block 1): the kept
code's three blocks scored -1.18, -0.25 and -0.77.

**What is still wrong**: the Crown now lasts and leads more often, but it **won no game outright** with the kept code (the
baseline won 2 of 20, by crushing the Brood's army mid-game and pressing). The Brood still reaches 4 grounds, 60 grubs and
its supply cap by 13:00-14:00 and keeps 6-8 Rootmaws to the end: the Siege pushes (1-2 a game, from ~9:30) break a
Rootmaw or a few Mound Turtles each and come back when the Brood's army arrives (9 Rootmaws in 13 pushes of block 14).
The Crown holds at home with guns now, and the games that are lost are lost late (18:00-19:40) to the Brood's capped
waves with Battering Horns breaking an outlying hall's palisade. Every economy change tried (labourers first, halls on
time, every hall's second Farm) cost army and did not pay; a quicker strike at the Brood Mother (`queen`) lost its army
on the rooted ground before reaching her. Tuning the Siege push itself (a bigger edge before it goes, more cannons, more
mortars, the far Rootmaws as its goal, a home guard left behind, coming home sooner) gave nothing clear in 8 blocks:
`maws` (+0.16, 7/3) and `guard` (+0.21, then -0.34) were the nearest, within the noise.

**Claude's choices for the owner**:
1. `lean` makes the Crown's opening against the Brood always the Horseman rush (no more 35/65 dice). A human facing the
   Crown computer will see the same opening every time; the matrix and this job both say it is the best one.
2. `siege` was kept on a pooled measure (+0.26 g at first, +0.45 with its third block), under the doc's own +0.3 bar for
   one block, because its survival (14 of 20, then 20 of 30) and its guns, halls and later defeats were clear.
3. `siege` also stops OPTIMAL's late re-pick to the Economy race on a GREEDY read against the Brood (it threw away the
   push in 3 of 20 games: Ashford r0 block 10 at 11:52); a part of the same change, not measured on its own.
4. Comparisons are against pooled blocks of the kept code (block 5 showed one block of the same code moves g by 0.6).
5. 230 games instead of 500 (210 against the Brood): the machine played ~18 games an hour two at a time, and every block
   also needed its reading and its change written.

## How it is measured

- **The 10 games**: 5 maps (Greenhold, Ashford Crossing, Mirewood, Frostfang, Cinder Steps) x 2 rounds with the start spots
  swapped, the same seeds as plan_matrix_crown's OPTIMAL v Brood row (9100 + 97 r + 11 map + 3), Hard OPTIMAL v Hard OPTIMAL,
  to 20:00. The same 10 every block: `python3 tools/study/crown_1000_brood.py run <block> --extra <switches>`.
- **A game's score**: g = ln((income earned + 2 x army) of the Crown / of the Brood) at 20:00 or at the defeat, the beaten
  side's score counted a quarter (plan_matrix_report's rule). A block's score is the mean g of its 10 games; with it the
  games survived (not beaten by 20:00), won or led (won, or 10% ahead at 20:00), the median minute of the defeats.
- **A steadier second measure**: g14 = the same score ratio at 14:00 (the last minute of a side beaten sooner), before
  most defeats; it does not swing by +-2.3 with a won or lost game.
- **The noise**: block 5 reran block 1's code (nothing changed): mean g -1.47 against -0.90, g14 -0.35 against -0.15. Two
  blocks of the same code differ by about 0.6 in g and 0.2 in g14 (the match is not deterministic: the same seed is another
  game). So from block 5 on a change is weighed against the POOLED blocks of the kept code (each game's numbers the mean of
  its runs: base "b01+b05"), and kept when the mean g is up by 0.3 or more AND g14 is up clearly (t 1.5 or more) or more
  games are better than worse. A kept change's later blocks join the pool.
- **Switches**: every change is `-- c1kb<name>:on`; the kept ones are on by default (AICrown1kBrood.KEPT), `-- c1kb:off`
  plays as before the job.
- Data: `docs/crown_1000_brood/data/<block>/<tag>/` (result.json, story.txt, extra.txt = the block's switches);
  `docs/crown_1000_brood/blocks.csv` one row a block.

## The log

Every block against the pooled blocks of the code kept at the time (base); d = the paired mean difference (t), better/worse
= games whose g moved by more than 0.05.

| block | what changed (switches on) | mean g | g14 | survived | won/led | median defeat | v base: d g (t) · d g14 (t) · better/worse | kept? |
|---|---|---|---|---|---|---|---|---|
| b01 | the baseline: main 0.38.81, nothing on | -0.90 | -0.15 | 5 | 2 | 17:44 | | the baseline |
| b02 | **lean**: OPTIMAL plays the Rush plan's own build from 0:00 in every game (it leaned to it in 35% before, else the common opening and the Rush on a GREEDY read at ~1:40) | -0.76 | +0.12 | 4 | 3 | 17:41 | +0.43 (0.8) · +0.37 (1.8) · 5/5 (v b01+b05) | **yes** (decided after block 5: the income at 8:00 1.40 v 1.18, the army at 8:00 2.43 v 1.86 and at 12:00 2.99 v 2.20 of the Brood's) |
| b03 | **eco**: the coach's economy rules (LABOURERS FIRST, HALLS ON TIME) from 5:00 against the Brood (they come on after the first push is held or at 9:00 now), the army floor still first | -1.91 | -0.35 | 1 | 1 | 17:28 | -0.72 (-2.7) · -0.10 (-0.8) · 1/7 (v b01+b05) | no: the army at 12:00 fell to 1.37 of the Brood's |
| b04 | **press**: from 7:30, with a fresh report, the wave goes when it is 2x the Brood army seen in the last two minutes (never under 0.35 of the clock's reckoning, BROOD_TABLE) | -1.59 | -0.25 | 3 | 1 | 17:37 | -0.41 (-1.0) · 0.00 (0.0) · 4/6 (v b01+b05) | no |
| b05 | the baseline again (block 1's code): the noise | -1.47 | -0.35 | 4 | 1 | 16:46 | -0.57 (-0.7) · -0.20 v b01 · 3/6 | the pool b01+b05 |
| b06 | **tech** (without lean): the milestones (Armoury, Church, a second Foundry) and the Armoury's research weigh the Brood army seen in the last two minutes (never under 0.4 of the clock's table) instead of the clock's reckoning (3,800 at 10:00) | -1.91 | -0.51 | 2 | 0 | 16:45 | -0.73 (-2.1) · -0.26 (-2.0) · 3/7 (v b01+b05) | no: the buildings came, not the research (Matchlock in 2 of 10), and the army at 12:00 fell to 0.87 of the Brood's |
| b07 | **lean** again (the kept code: block 2's change, now on by default) | -1.20 | -0.17 | 4 | 1 | 17:11 | -0.02 (0.0) · +0.08 (0.5) · 4/5 (v b01+b05) | the pool b02+b07: +0.21 (0.6) · +0.23 (1.5) · 8/2 v b01+b05: a small gain, kept |
| b08 | **halls** (lean on): HALLS ON TIME (2 by 3:30, 3 by 7:30, 4 by 11:30) from the start against the Brood, LABOURERS FIRST still waiting for the first held push | -1.57 | -0.19 | 2 | 2 | 17:08 | -0.59 (-0.9) · -0.16 (-0.6) · 2/7 (v b02+b07) | no: no more halls at 12:00 (2.4 against 3.0) |
| b09 | **siege** (lean on): the rush hands over to the Siege push instead of the Economy plan (its guns, its push on the rooted ground weighed against the Brood army seen) | -1.18 | +0.02 | 5 | 2 | 18:42 | -0.20 (-0.6) · +0.04 (0.4) · 3/7 (v b02+b07) | run again (b10): guns at once 5-12 (were 1-3), 4 halls at 12:00 (3.0), the defeats 1:30 later (18:42) |
| b10 | **siege** again | -0.25 | +0.13 | 9 | 5 | 17:19 | +0.73 (1.5) · +0.15 (0.8) · 5/4 (v b02+b07) | **yes**: the pool b09+b10 +0.26 (0.7) · +0.10 (0.7) · 6/4, survived 14 of 20 (lean 8 of 20), won or led 7 of 20 (4), 3.8 halls at 12:00 (3.0) |
| b11 | **farms** (lean, siege on): every built hall on paying land gets its second Farm at once once the Farms standing are nearly manned (6 free posts at most) | -0.74 | +0.04 | 7 | 2 | 17:43 | -0.03 (-0.1) · -0.04 (-0.4) · 5/4 (v b09+b10) | no: 1-6 Farms laid a game, 5.8 Farms at 12:00 (4.9), the income at 12:00 no higher |
| b12 | **queen** (lean, siege on): a siege push 2.5x the Brood army seen lately (from 8:00) marches on the Brood Mother herself, setting up only against what stands in its way | -0.80 | +0.07 | 6 | 3 | 17:32 | -0.08 (-0.2) · -0.01 (-0.1) · 6/4 (v b09+b10) | no: 1-2 such pushes a game, each broke 1-2 Rootmaws and 1-5 turtles but none reached her, and lost 1,300-10,300 of army doing it |
| b13 | **pester** (lean, siege on): after the rush the riders raid the grubs again 60 s after each party comes home (a successful rush blocked the raids for 10 minutes), and the Siege push leaves the riders to it | -0.65 | +0.06 | 7 | 2 | 18:39 | +0.07 (0.2) · -0.01 (-0.1) · 7/3 (v b09+b10) | no (not clear: 0-5 parties a game) |
| b14 | **the kept code** again (lean + siege, nothing else): the rerun of the best | -0.77 | +0.16 | 6 | 3 | 18:56 | v the baseline b01+b05: +0.42 (1.3) · +0.40 (4.7) · 7/3 | the pool b09+b10+b14 v b01+b05: +0.45 (1.7) · +0.35 (3.7) · 7/3 |
| b15 | **edge** (kept code +): the Siege push against the Brood waits for 2.5x the Brood army seen lately (1.5) | -0.90 | -0.00 | 7 | 1 | 19:06 | -0.17 (-0.5) · -0.10 (-1.2) · 4/5 (v b09+b10+b14) | no |
| b16 | **guns** (kept code +): the push's Field Cannons one for 3 Musketeers, up to 8 (one for 5, up to 4) | -1.00 | -0.02 | 6 | 1 | 17:52 | -0.27 (-0.6) · -0.13 (-0.9) · 4/6 (v b09+b10+b14) | no: 4-9 cannons at once (5.7-6.4), the line thinner |
| b17 | **maws** (kept code +): the Siege push marches on the nearest Rootmaw seen rooted away from the Mother (the enemy's base, before) | -0.57 | +0.03 | 8 | 2 | 17:50 | +0.16 (0.6) · -0.07 (-0.8) · 7/3 (v b09+b10+b14) | no (not clear: 8 Rootmaws broken in 17 pushes, as many as before) |
| b18 | **mortars** (kept code +): the push's Mortars one for 4 Musketeers, up to 6 (one for 7, up to 3) | -0.84 | +0.07 | 6 | 3 | 18:25 | -0.11 (-0.3) · -0.04 (-0.3) · 4/4 (v b09+b10+b14) | no |
| b19 | **guard** (kept code +): while the Siege push is out against the Brood, 30% of the Musketeers (the nearest home) and one gun of four stay home and do not join it | -0.52 | +0.25 | 7 | 5 | 18:17 | +0.21 (0.5) · +0.15 (1.4) · 6/3 (v b09+b10+b14) | not yet (under the bar, the army at 12:00 5.0 of the Brood's): run again (b21) |
| b20 | **spare** (kept code +): the Siege push comes home under 0.7 of what went out (0.45) | -1.47 | -0.16 | 4 | 1 | 17:38 | -0.73 (-2.3) · -0.27 (-2.9) · 1/8 (v b09+b10+b14) | no: clearly worse (the pushes came home before they broke anything) |
| b21 | **guard** again | -1.08 | +0.00 | 6 | 1 | 19:23 | -0.34 (-1.0) · -0.10 (-0.9) · 3/7 (v b09+b10+b14) | no: the pool b19+b21 -0.07 (-0.2) · +0.03 (0.3) · 5/5 |

## What the games showed (the stories, the plan lines, the counters)

1. **The clock's reckoning of the Brood holds the Crown back while it is far ahead.** AICrown.foe_estimate weighs the Brood
   by BROOD_TABLE (3,800 at 10:00, 5,000 at 12:00) whatever was seen: "holds its wave back: the enemy army it knows is
   bigger" with 2,210 of army against 720 there (Ashford r0, block 1, 10:00), "milestone Foundry waits: the army is far
   behind the enemy's (2410 against the 0 it reckons)" (block 5). Loosening it for the waves (`press`) or the tech
   (`tech`) did not help: the waves traded evenly, and the earlier buildings took the soldiers' gold.
2. **Under the Economy handover the Crown had 1-3 Field Cannons**: its Foundries stood idle 500-980 s a game, almost all of
   it without a gun's gold (the Barracks spend first); its musket lines fought "with 0 gun(s) behind them". The Siege push
   handover keeps a gun's gold first (AICrownSiege.gun_due): 5-9 cannons and mortars at once.
3. **The Crown's economy is its Farms**: ~4 Farms (32 posts, ~21 labourers on them) for 2.8 halls at 10:00, the income
   ~1,500 a minute against the Brood's ~2,400 from 11:00. Every change that put labourers, halls or Farms before the army
   (`eco`, `halls`, `farms`) cost army and did not pay within 20 minutes.
4. **The Siege pushes trade about evenly** (killed 575-8,250, lost 1,620-5,290 a push in block 14; 1-2 pushes a game from
   ~9:30), break a Rootmaw or a few Mound Turtles each, and come back when the Brood's army arrives; the Brood rebuilds
   to its cap in two minutes. Changes to the push (`edge`, `guns`, `mortars`, `maws`, `queen`, `guard`, `spare`) did not clearly beat it.
5. **The Brood's late waves (13:00-19:00, 100-200 supply, Battering Horns) still decide the lost games**: they break an
   outlying hall's palisade while the army stands at another, or meet the army at home after a push; the MUSTER rule
   gathers the army out of reach when the force at the buildings is 1.2x its own.

## The other matchups (the kept code, one block each)

Every change is gated to a Crown computer facing a Brood (AICrown.vb(), AIOptimal's foe), so against the Clockwork and in
the mirror the kept code plays exactly as main; one block each checked it on the same 5 maps x 2 rounds (plan_matrix_crown's
seeds for those matchups) with no script error, and its counters show nothing of this job acted (no lean, no Siege
handover: `c1kb_siege_at` -1 in all 20 games).

| block | matchup | mean g | g14 | survived | won/led | median defeat | income 8:00 / 12:00 | army 8:00 / 12:00 | plan matrix 0.38.59, same seeds: g, g14, survived |
|---|---|---|---|---|---|---|---|---|---|
| cw01 | Crown v Clockwork | -1.82 | -0.92 | 5 | 0 | 16:34 | 0.64 / 0.56 | 0.68 / 0.26 | -1.75, -0.92, 6 |
| cr01 | Crown v Crown (the "subject" is one seat of two identical computers) | +0.43 | +0.09 | 10 | 6 | - | 0.98 / 1.02 | 0.93 / 1.30 | -0.37, -0.10, 9 |

## The tests (0.38.82, the kept code on)

All 42 of `tools/test_ai_*.gd` and `tools/test_crown_*.gd` were run. **35 pass.** Two failed once and passed on the
rerun with the kept code on (flaky as CLAUDE.md says): `test_ai_harass` ([raid]), `test_ai_rush` (the rush killed grubs,
workers before the Mother). Five fail the same way with the whole job switched off (`-- c1kb:off`), so not from this job:
`test_ai_rush_followup` (14-15 checks), `test_ai_wall_vs_rush` (Barracks and Mill by 75 s: 58 / 100 s),
`test_crown_rider_screen` (a rider in front of the muskets), `test_crown_stall` ([foundry] by 330 s: 334-349),
`test_crown_dragoon_raid` ([plan], failing on main before, CLAUDE.md). Several tests end with "Aborted" (exit 134) after
"ALL PASS": Godot's exit, not a check.

## Files

- `scripts/ai_crown_1k_brood.gd` (AICrown1kBrood: the switches, KEPT = lean, siege), the changes in `scripts/ai_optimal.gd`
  (lean, siege's keep), `scripts/ai_crown.gd` (siege's handover, press, tech, farms, pester, the counters),
  `scripts/ai_crown_siege.gd` (queen, edge, guns, mortars, maws, guard, spare), `scripts/ai_crown_v_brood.gd` (eco),
  `scripts/ai_crown_coach.gd` (halls); the AI STORY line for the handover (`scripts/ai_story_lines.gd`,
  `tools/i18n/49_spectator.txt`).
- `tools/study/crown_1000_brood.py` (run / report / csv; `--opp` for the check blocks; pooled bases "b09+b10+b14"),
  `tools/qa_match.gd` (result.json: the c1kb counters and every siege push), `tools/study/qa_matches.py` (KEEP_GREP: the
  Crown's plan lines kept as planlog.txt).
- Data: `docs/crown_1000_brood/data/<block>/` (230 games), `docs/crown_1000_brood/blocks.csv`. No film was made: a film
  takes about 3 hours of this machine (tools/film_coach.gd renders every frame), the blocks took the time; the stories,
  plan lines and counters stand in for them.
