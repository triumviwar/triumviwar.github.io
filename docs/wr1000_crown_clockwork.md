# Win rate 1000, Crown v Clockwork (wr1000-crown-clockwork)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in blocks
of 10 games, changing ONE thing in a computer's play each block. This job is the Crown v Clockwork pairing: the Crown
computer (Hard OPTIMAL) against the Clockwork computer (Hard OPTIMAL), to 20:00, on the six parity maps of
ai-opponent-review. No number of the game was changed: only how the computers play, and every change has a switch.

## In short

**The fresh win rate (main 0.38.124, 20 baseline games: blocks 1 and 6, the same 10 games twice)**:

| Crown v Clockwork at 20:00, 20 games | games |
|---|---|
| the Crown won | 2 |
| the Crown led by 10% or more | 11 |
| even (within 10%) | 4 |
| the Clockwork led by 10% or more | 2 |
| the Clockwork won | 1 |
| **the Crown won or led** | **13 of 20 (65%)** |
| **the Clockwork won or led** | **3 of 20 (15%)** |
| decided by 20:00 | 3 of 20 (defeats at 18:08, 18:41 and 19:01) |

| the same 20 games, Crown / Clockwork | 8:00 | 12:00 | 14:00 | 20:00 |
|---|---|---|---|---|
| income earned (median ratio) | 0.95 | 0.97 | | |
| army value (median ratio) | 0.97 | 0.84 | | |
| score, income + 2 x army (mean ratio) | | | x1.00 (even) | x1.38 (the Crown ahead) |
| halls (mean) | 3.0 / 3.0 | 4.8 / 4.0 | 5.3 / 4.8 | 7.0 / 5.2 |
| workers (mean) | 49 / 43 | 80 / 51 | 88 / 50 | 89 / 40 |
| gold banked (median) | 38 / 134 | 50 / 530 | 31 / 502 | 9,977 / 250 |

Read aloud: the two computers are **even until about 14:00**; then the Crown pulls ahead and leads at the bell in two
games of three, but **almost no game ends**: 3 of 20 were decided by 20:00. The Crown reaches its 200 supply at 14:00-16:00
with 80-110 labourers and banks 7,000-21,000 gold it cannot spend; the Clockwork's Winders peak at ~52 at 10:00 and fall
to ~43 as its presses run dry, and its pushes into the Crown's line and guns lose about two for one.

**The blocks**: (filled in below as they finish)

## How it is measured

- **The 10 games**: the six parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), game k
  on map k mod 6, the first four maps twice; the start spots swapped every other game and on a map's second game, so each
  side plays both spots. The seeds are 9400 + 97 k. The same 10 games every block, so blocks compare game by game:
  `python3 tools/study/wr1000_crown_clockwork.py run BLOCK --extra SWITCHES` (two games at a time on the 2-core machine,
  about 40 minutes a block; `tools/study/wr1000_crown_clockwork_queue.sh` runs a queue of blocks, each on a frozen copy of
  the committed code).
- **A game's score** (the Crown's view): g = ln(the Crown's (income earned + 2 x army) / the Clockwork's) at 20:00 or at the
  defeat, the beaten side's score counted a quarter (plan_matrix_report's rule). Positive: the Crown ahead; +0.10 = 10% ahead.
- **Results**: W = the Crown won, w = it led by 10% or more at 20:00, = within 10%, l = the Clockwork led, L = the Clockwork won.
- **g14**: the same score ratio at 14:00, before most of the late swings: a steadier second measure.
- **The noise**: block 6 reran block 1's code: mean g +0.46 against +0.19, g14 +0.05 against -0.06. Two blocks of the same
  code differ by about 0.3 in g and 0.1 in g14 (a match is not deterministic: the same seed plays another game). So every
  block is weighed against the pool of both baseline blocks (each game the mean of its two runs, "b01+b06"), paired game by
  game: d = the mean difference of g (its t), and the games better / worse by more than 0.05. A change would be KEPT only
  with d of 0.35 or more in its side's favour, t of 1.5 or more, and g14 the same way, then confirmed by a second block.
- **Which side a change helps**: a change of the Crown's play is good when g goes UP; a change of the Clockwork's play is
  good when g goes DOWN.
- Data: `docs/wr1000_crown_clockwork/data/<block>/<game>/` (result.json, story.txt, planlog.txt = the Crown's plan lines,
  cwlog.txt = the Clockwork's own log lines; base.txt = the block it was weighed against); `blocks.csv` one row a block.
  Readers: `tools/study/wr1000_cw_pushes.py` (the Clockwork's pushes: lost and killed), `tools/study/wr1000_winders.py`
  (the Winders lost and to what). The whole match logs were kept outside the repo (they are big).
