# WR1000, the Brood mirror (wr1000-brood-mirror)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games over six parallel jobs, in
blocks of 10 games, ONE change in the computer's play a block. This job is the Brood against the Brood (the mirror):
Hard OPTIMAL against Hard OPTIMAL, games to 20:00 on the six parity maps of ai-opponent-review. In a mirror "better"
does not mean one side winning: it means games that END by play (the side ahead closes it out, the side behind fights
back sensibly), not games that see-saw to the bell. No unit, price or income number was changed.

## Summary

__SUMMARY__

## The fresh baseline (main 0.38.124, nothing changed)

__BASELINE__

## Every block

__BLOCKS__

## What the games showed

__SHOWED__

## The start-spot edge

__SPOT__

## Claude's choices for the owner

__CHOICES__

## Proposals (not built: numbers or bigger changes for the owner)

__PROPOSALS__

## What is still wrong

__WRONG__

## How it is measured

- **The 10 games**: the six parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), then
  the first four again with other seeds: tags `wbm_<map>_r0/r1`, seed 12100 + 97 r + 11 x the map's place. The same 10 every
  block: `python3 tools/study/wr1000_brood_mirror.py run <block> --extra <switches>`. Two games at a time on the 2-core
  machine: a block of 10 took 30-45 minutes.
- **P1** is player 1 of the match setup, who stands on spot A (the map's first start) unless `spotswap` is on (block 12).
- **A game's score**: g = ln((income earned + 2 x army value) of P1 / of P2) at 20:00 or at the defeat, the beaten side's
  score counted a quarter (the crown-1000 and plan-matrix rule). In the mirror the sign only says which seat did better;
  the block's measures are about how decisive the games are:
  - **decided**: a side beaten (its Mother killed or nothing left) by 20:00;
  - **mean |g|**: how far apart the two sides ended (a beaten side gives about 1.6-2.0, an even 20:00 draw 0.0-0.3);
  - **|g14|**: the same at 14:00 (the last minute of a side beaten sooner), steadier;
  - **led at 12:00 / closed / comeback**: games where one side was 10% ahead at 12:00, how many that side then won or led
    at the end, and how many the other side turned round;
  - P1's record (won or 10% ahead at 20:00 / even / lost or behind) and mean g, for the spot edge.
- **The noise**: the match is not deterministic (the same seed plays another game: the same as crown-1000 found). Block 5
  and block 15 reran block 1's code. Blocks of the same code differ by 1-2 decided games and about 0.15 in mean |g|, so a
  change is weighed against the POOLED baseline blocks game by game (`b01+b05+b15`: each game's numbers the mean of its
  runs) and kept only when clearly better than that (and not worse to watch).
- **Switches**: every change is `-- wbm<name>:on`, in scripts/ai_wr1000_brood_mirror.gd (AIWr1000BroodMirror) with five
  small hooks in scripts/ai_brood_new.gd (the wave rules, the wave's goal, the wave's steering, MATURE, the grubs wanted)
  and one in its observe step; every change runs only when a Brood computer faces another Brood (AIBroodNew._foe_is("brood")).
  `-- wbm:off` turns the whole job off. The kept ones would be listed in AIWr1000BroodMirror.KEPT.
- Data: `docs/wr1000_brood_mirror/data/<block>/<tag>/` (result.json, story.txt, planlog.txt = the Brood computers' own lines
  of the match log), `extra.txt` the block's switches; `docs/wr1000_brood_mirror/blocks.md` one row a block
  (`python3 tools/study/wr1000_brood_mirror.py csv`).

## The tests

__TESTS__
