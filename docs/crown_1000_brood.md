# Crown 1000, the Brood half (crown-1000-brood)

The owner, 2026-11-19 07:26: "The Crown's computer is the weak one... We need a complete job of 1000 crown games, every 10
games changing something to see if crown gets better, currently its bad ai." This job is the Brood half: the Crown computer
(Hard OPTIMAL) against the Brood computer (Hard OPTIMAL), in blocks of 10 games to 20:00, one change of the Crown computer's
play a block, kept only when the block is clearly better than the best so far. The sister job crown-1000-clockwork does the
Clockwork half; every change here runs only against the Brood (scripts/ai_crown_1k_brood.gd, AICrown1kBrood).

## Summary

**140 games against the Brood (14 blocks of 10, to 20:00) fit the run, not 500**: a game took 12-14 minutes of the
machine's time two at a time (the Crown now lasts to 17-20 minutes), so a block of 10 took 60-75 minutes. Two more blocks
checked the kept changes against the Clockwork and in the mirror (below). The job finished cleanly: the kept changes ON
by default, the rest OFF behind their switches, the AI tests run.

**Kept (on by default, against the Brood only)**: `lean` (OPTIMAL plays the Horseman rush's own build from 0:00 in every
game, as the plan matrix found best) and `siege` (when the rush is over it hands over to the Siege push, not the Economy
plan: Field Cannons and Mortars, a push on the Brood's rooted ground weighed against the Brood army it has SEEN, and no
late re-pick back to the Economy race). Not kept: `eco`, `press`, `tech`, `halls`, `farms`, `queen`, `pester`.

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
on the rooted ground before reaching her.

**Claude's choices for the owner**:
1. `lean` makes the Crown's opening against the Brood always the Horseman rush (no more 35/65 dice). A human facing the
   Crown computer will see the same opening every time; the matrix and this job both say it is the best one.
2. `siege` was kept on a pooled measure (+0.26 g at first, +0.45 with its third block), under the doc's own +0.3 bar for
   one block, because its survival (14 of 20, then 20 of 30) and its guns, halls and later defeats were clear.
3. `siege` also stops OPTIMAL's late re-pick to the Economy race on a GREEDY read against the Brood (it threw away the
   push in 3 of 20 games: Ashford r0 block 10 at 11:52); a part of the same change, not measured on its own.
4. Comparisons are against pooled blocks of the kept code (block 5 showed one block of the same code moves g by 0.6).
5. 140 games instead of 500: the machine played 10 games an hour; the run stopped with time left for the check blocks and
   the tests.

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

## The other matchups (the kept code, one block each)

Every change is gated to a Crown computer facing a Brood (AICrown.vb(), AIOptimal's foe), so against the Clockwork and in
the mirror the kept code plays exactly as main; one block each checked it on the same 5 maps x 2 rounds (plan_matrix_crown's
seeds for those matchups) with no script error, and its counters show nothing of this job acted (no lean, no Siege
handover: `c1kb_siege_at` -1 in all 20 games).

| block | matchup | mean g | g14 | survived | won/led | median defeat | income 8:00 / 12:00 | army 8:00 / 12:00 | plan matrix 0.38.59, same seeds: g, g14, survived |
|---|---|---|---|---|---|---|---|---|---|
| cw01 | Crown v Clockwork | -1.82 | -0.92 | 5 | 0 | 16:34 | 0.64 / 0.56 | 0.68 / 0.26 | -1.75, -0.92, 6 |
| cr01 | Crown v Crown (the "subject" is one seat of two identical computers) | +0.43 | +0.09 | 10 | 6 | - | 0.98 / 1.02 | 0.93 / 1.30 | -0.37, -0.10, 9 |
