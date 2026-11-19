# Crown 1000, the Brood half (crown-1000-brood)

The owner, 2026-11-19 07:26: "The Crown's computer is the weak one... We need a complete job of 1000 crown games, every 10
games changing something to see if crown gets better, currently its bad ai." This job is the Brood half: the Crown computer
(Hard OPTIMAL) against the Brood computer (Hard OPTIMAL), in blocks of 10 games to 20:00, one change of the Crown computer's
play a block, kept only when the block is clearly better than the best so far. The sister job crown-1000-clockwork does the
Clockwork half; every change here runs only against the Brood (scripts/ai_crown_1k_brood.gd, AICrown1kBrood).

## Summary

(written at the end of the job)

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
