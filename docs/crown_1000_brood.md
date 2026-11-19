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
- **Keep or not**: a change is kept when its block beats the best so far by a clear margin: the mean g up by 0.3 or more and
  more games better than worse, paired game by game (same map, round, seed) against the kept baseline's block. The match is
  not deterministic (a film of the same seed is another game), so two blocks of the same code differ too: the reruns of the
  baseline (every few blocks) measure that noise.
- **Switches**: every change is `-- c1kb<name>:on`; the kept ones are on by default (AICrown1kBrood.KEPT), `-- c1kb:off`
  plays as before the job.
- Data: `docs/crown_1000_brood/data/<block>/<tag>/` (result.json, story.txt, extra.txt = the block's switches);
  `docs/crown_1000_brood/blocks.csv` one row a block.

## The log

| block | what changed (switches on) | mean g | survived | won/led | median defeat | v best: d (t), better/worse | kept? |
|---|---|---|---|---|---|---|---|
| b01 | the baseline: main 0.38.81, nothing on | -0.90 | 5 | 2 | 17:44 | | the baseline |
| b02 | **lean**: OPTIMAL plays the Rush plan's own build from 0:00 in every game (it leaned to it in 35% before, else the common opening and the Rush on a GREEDY read at ~1:40) | -0.76 | 4 | 3 | 17:41 | +0.15 (t 0.2), 5/4 | no (not clear; but the income at 8:00 1.40 v 1.17 and the army at 8:00 2.43 v 1.71 of the Brood's) |
| b03 | **eco**: the coach's economy rules (LABOURERS FIRST, HALLS ON TIME) from 5:00 against the Brood (they come on after the first push is held or at 9:00 now), the army floor still first | -1.91 | 1 | 1 | 17:28 | -1.00 (t -2.1), 3/6 | no: the army at 12:00 fell to 1.37 of the Brood's (2.99), lost 9 |
| b04 | **press**: from 7:30, with a fresh report, the wave goes when it is 2x the Brood army seen in the last two minutes (never under 0.35 of the clock's reckoning, BROOD_TABLE) | -1.59 | 3 | 1 | 17:37 | -0.69 (t -1.2), 6/4 | no (mixed: 6 games better, but the two wins of block 1 lost) |
