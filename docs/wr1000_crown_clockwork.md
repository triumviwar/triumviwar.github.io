# Win rate 1000, Crown v Clockwork (wr1000-crown-clockwork)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in blocks
of 10 games, changing ONE thing in a computer's play each block. This job is the Crown v Clockwork pairing: Hard OPTIMAL
against Hard OPTIMAL, to 20:00, on the six parity maps of ai-opponent-review.

(Work in progress: this page is rewritten as the blocks come in.)

## How it is measured

- **The 10 games**: the six parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), game k
  on map k mod 6, the first four maps twice; the start spots swapped every other game and on a map's second game, so each
  side plays both spots. The seeds are 9400 + 97 k. The same 10 games every block, so blocks compare game by game:
  `python3 tools/study/wr1000_crown_clockwork.py run BLOCK --extra SWITCHES` (two games at a time; about 40 minutes a block).
- **A game's score** (the Crown's view): g = ln(Crown's (income earned + 2 x army) / the Clockwork's) at 20:00 or at the
  defeat, the beaten side's score counted a quarter (plan_matrix_report's rule). Positive: the Crown ahead.
- **Results**: W = the Crown won, w = it led by 10% or more at 20:00, = within 10%, l = the Clockwork led, L = the Clockwork won.
- **g14**: the same score ratio at 14:00, a steadier second measure.
- Data: `docs/wr1000_crown_clockwork/data/<block>/<game>/` (result.json, story.txt, planlog.txt = the Crown's plan lines,
  cwlog.txt = the Clockwork's own log lines); the whole match logs were kept outside the repo.
