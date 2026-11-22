# WR1000, the Crown mirror (wr1000-crown-mirror)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in
blocks of 10 games, changing ONE thing in the computer's play each block. This job's pairing is **the Crown against the
Crown** (Hard OPTIMAL v Hard OPTIMAL, to 20:00, on the 6 parity maps of ai-opponent-review). In a mirror "better" means
games that end decisively by skill (the side ahead closes it out, the side behind fights back sensibly), not one spot
winning. Rules followed: docs/design_principles.md 1 (a mirror is decided by play) and 2 (a lead must be closable, and a
lead must not be a win button). **No unit, price or income number was changed.**

## Summary

**170 games (17 blocks of 10) ran, on 0.38.124.** A block took about 30 minutes, two games at a time on the 2-core machine.
The job finished cleanly: the AI tests were run on main and on the branch (below).

**The fresh win rate of the Crown mirror** (blocks b01, b02 and b09: the same code, main 0.38.124, 30 games; "spot A" is
the first seat, the start spot at the top of the map's start list):

| Crown OPTIMAL v Crown OPTIMAL, Hard, to 20:00, 30 games | |
|---|---|
| spot A won / led / even / behind / lost (spot B won) | **3 / 7 / 4 / 10 / 6** |
| decided by 20:00 (a side beaten) | **9 of 30 (30%)**, at 14:33-19:19, median 18:05 |
| decided or 1.5 times apart at 20:00 | 17 of 30 |
| mean g (ln score ratio A/B at the end, a beaten side's score a quarter) | -0.22 (mean of abs g 0.92) |
| g at 14:00 | 0.00 (mean of abs g14 0.24: the sides are within ~25% at 14:00) |
| income at 8:00 / 12:00, A of B (geometric mean) | 1.00 / 1.02 |
| army at 8:00 / 12:00, A of B | 1.01 / 1.09 (1,732 against 1,657 at 12:00) |
| halls at 12:00 | 3.4 each |
| a side 10% ahead at 12:00 | 18 games; it won or led at 20:00 in 14, the other side in 1 |
| the start spot | spot A won or led 10, spot B 16 (sign test p 0.33); over all 170 games 69 against 83 (p 0.29): **no spot edge to act on**, a lean to spot B to watch |

**Nothing was kept** (AIWr1000CrownMirror.KEPT is empty; the computer plays the mirror exactly as main 0.38.124). Every
change is behind its study switch `-- wcm<name>:on`. The reason is the noise: three blocks of the same code decided 1, 4
and 4 games, and two blocks where the change almost never acted (maxed, b12 and b13) decided 4 and 0. **A block of ten
mirror games moves by about 3 decided games and 0.6 in mean abs g by chance alone**; no change came near a clear gain:

| arm (all its blocks) | games | decided | 1.5x apart | mean abs g | abs g14 | median defeat | paired v the baseline pool: d abs g (t) |
|---|---|---|---|---|---|---|---|
| the baseline (b01, b02, b09) | 30 | 9 (30%) | 17 | 0.92 | 0.24 | 18:05 | |
| cut (b03, b05) | 20 | 8 (40%) | 13 | 1.13 | 0.21 | 18:23 | +0.20 (0.6) |
| finish (b04, b07) | 20 | 8 (40%) | 14 | 1.18 | 0.21 | 17:59 | +0.25 (0.8) |
| press2 + finish (b11, b16) | 20 | 4 (20%) | 12 | 0.83 | 0.17 | 18:12 | -0.09 (-0.5) |
| labcap2 (b14, b15) | 20 | 7 (35%) | 15 | 1.12 | 0.25 | 17:34 | +0.20 (0.8) |
| maxed, hardly acting (b12, b13) | 20 | 4 (20%) | 14 | 0.94 | 0.22 | 18:54 | +0.01 (0.1) |

The single blocks (press2 b06, labcap b08, behind b10, all three together b17) are in the log below. Three arms (cut,
finish, labcap2) lean the right way (+0.20-0.25 in abs g, 35-40% decided against 30%), each well inside the noise: to tell
a +0.2 from nothing a mirror needs about 60 games an arm, not 20.

**What is still wrong** (the games, below): a mirror at 20:00 is mostly a coin flip until 15:00-18:00; the leads at 12:00
and 14:00 are small (within 25%), and when a game ends it ends late by a collapse (a lost field fight, then the labourers).
The side ahead keeps its lead (14 of 18), so leads are not thrown away, but they grow slowly. Late in long games a side can
sit at its 200 supply cap with 95-104 labourers, 13 Barracks and 10,000-17,000 gold banked while its army stays the size of
a 12:00 army (Ashford r0 b13, Greenhold r1 b10). These are proposals below, not changes made.

## How it is measured

- **The 10 games**: the 6 parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps), round 0,
  and the first four again with another seed (round 1); seed 12300 + 97 r + 11 map; Hard OPTIMAL v Hard OPTIMAL to 20:00;
  seat 1 always on the map's first start spot (spot A). The same 10 every block:
  `python3 tools/study/wr1000_crown_mirror.py run <block> --extra <switches>`, each block from a frozen copy of the branch
  (tools/study/freeze_copy.sh) so the edits made while it ran never reached its games.
- **A game's numbers**: g = ln((income earned + 2 x army) of spot A / of spot B) at 20:00 or at the defeat, the beaten side's
  score counted a quarter (plan_matrix_report's rule). In a mirror the sign of g is only the spot; **abs g** (how far apart
  the game ended), **decided** (a side beaten by 20:00) and **1.5x apart** (decided, or 1.5 times apart at 20:00) measure
  how decisive it was; abs g14 is the same at 14:00 (steadier); "lead at 12 kept" counts the games where the side 10% ahead
  at 12:00 won or led at 20:00 (and "turned" the other way).
- **The noise**: b02 and b09 reran b01's code (nothing changed): decided 1, 4, 4; mean abs g 0.52, 1.08, 1.17. b12 and b13
  ran a change that acted in 1 game of 20: decided 4 and 0, abs g 1.21 and 0.67. So a change was weighed against the pooled
  baseline b01+b02+b09 (each game the mean of its three runs), paired game by game, and would have been kept with a pooled
  gain clearly past that spread (abs g up 0.5 or more with t 2 or more over two blocks, and more games decided) and no
  game made worse to watch (no turtling, no suicide waves). None got there.
- **Switches**: every change is `-- wcm<name>:on`; `-- wcm:off` turns the whole job off. The code is
  scripts/ai_wr1000_crown_mirror.gd (AIWr1000CrownMirror); each change acts only when a Crown computer faces a Crown
  (AICrown.mirror()), so the sister jobs (the other five pairings) are untouched.
- Data: `docs/wr1000_crown_mirror/data/<block>/<game>/` (result.json, story.txt, planlog.txt; extra.txt = the block's
  switches, base.txt its base); `docs/wr1000_crown_mirror/blocks.csv` one row a block
  (`python3 tools/study/wr1000_crown_mirror.py csv`); `report --base b01+b02+b09 <blocks> --games` prints the tables.

## The log

Every block against the baseline pool b01+b02+b09 (d = the paired mean difference of abs g with its t; better/worse = games
whose abs g moved by more than 0.05).

LOGTABLE

## The changes (all in scripts/ai_wr1000_crown_mirror.gd, each a switch, all off)

1. **cut** (`wcmcut:on`): crown-rule-cleanup cut nine coaching rules against the Clockwork (the army clock and floor, the
   fight group: the guns' coaching, guns first, the line, the screen, the cavalry micro, the defence; and the hold) and left
   the mirror with the full stack: "whether cutting them pays in the mirror cannot be measured by switching both sides". It
   can, on decisiveness: the same cut in the mirror. 8 of 20 decided (30% before), the army at 12:00 smaller (1,151 against
   1,695), income the same (15,223 against 15,079 earned by 12:00). Within the noise. Hook: one line in AICrownRules.cut.
2. **finish** (`wcmfinish:on`): b01 Greenhold r0: P2 had 4,170-6,320 of army against P1's 350-830 from 15:00 (P1 had lost
   72 buildings) and the game was not over at 20:00; the mirror coach's hunt over a token army wants the enemy army under
   450 whatever ours is, and P2's Siege push set up its guns against every Palisade, Gate and Barracks in turn. Now the hunt
   also starts when our fighters are worth 1,500+ and the enemy's under a quarter of them, and a Siege push out ends and joins
   it. It acted (11-12 hunts a block against 4-15 in the baseline blocks); 8 of 20 decided, defeats a little earlier
   (median 17:59 against 18:05). Within the noise. Hooks: AICrown._hunt_anyway, AICrownSiege.tick.
3. **press2** (`wcmpress2:on`): the mirror coach's press (the side ahead lowers its wave's bar) sent 0-3 waves a side a game;
   Frostfang r1 had P1 with 1,635 of army against 370-385 at 12:00 in both b01 and b02 and its first attack at 10:46/11:57.
   Its numbers made easier: from 7:00, 1.15 times, 700 of army, 20 s after the last wave, the reckoning's floor 0.5/0.6
   (8:00, 1.3, 900, 25 s, 0.7/0.8). The presses went from 17-24 a block to 36-48, and Frostfang r1 ended with P1 winning in
   b06 (and with finish in b04); the blocks did not get more decisive (with finish: 4 of 20). The numbers live in
   AICrownMirror (vars read from AIWr1000CrownMirror.press_k; today's values when off).
4. **labcap** (`wcmlabcap:on`): the Crown computer's labourers' top (AICrown.owner_lab_cap: 48 on two halls, 14 more a hall
   after) down to 40 and 8. It hardly bound: the Farms' and Mills' posts cap the labourers first (47 at 12:00, 50 before).
5. **behind** (`wcmbehind:on`): b03 Dune Sea r0: P1, behind after a lost field fight at 8:49 (1,410 killed for 2,410), went
   on sending its army out in small groups ("killed 0, lost 625" at 11:44) and was beaten at 14:52 with its labourers down
   from 50 to 6. Now a side whose fighters are under 0.6 of the enemy army seen in the last 90 s (600+ of it) sends no new
   wave until it is not behind. It acted about once a game (13 times in 10 games); 3 decided, defeats later (19:12).
6. **maxed** (`wcmmaxed:on`): 52 of the first 200 sides reached their 200 supply cap, 42 of them with 1,000+ gold. At the cap
   with 600+ gold the ready army goes at once (the bar comes down to 85% of it, as the press does), no new balloon party
   forms, and (second version, b13) the men at home join a wave already out. It acted once in 20 games: at the cap the
   waves were already out and the home army under 12 supply; the cap is reached with ~100 labourers (point 7).
7. **labcap2** (`wcmlabcap2:on`): no more than 64 labourers however many halls (7-8 halls allow 118-132 today). It binds
   only in the long games with many halls (b14: 42 labourers at 16:00; over b14+b15 48, as the baseline's 48); the army at
   16:00 2,280 (1,939). b14 was one of the best blocks of the job (5 decided, 9 of 10 apart, abs g +0.50, t 1.5) and b15
   the same code one of the worst (2 decided, -0.10): together +0.20.

## What the games showed

1. **A mirror is decided late, and by little.** The leads at 12:00 and 14:00 are within 10-25% in most games (abs g14
   0.24). The side ahead at 12:00 keeps its lead (14 of 18), but a game ends only when one field fight goes badly and the
   loser's labourers follow (Frostfang r0 b02: 13 buildings lost by 12:00, beaten at 18:05). The same game, run again, is
   decided in one block and even in the next: of the 10 games every one was decided in some blocks and not in others.
2. **Both sides sit behind palisades.** Waves of 20-40 supply (a third to a half of the army) go at the walled natural and
   "pull back from the enemy's palisade: the fire there is too strong" 1-5 times a side a game; each pull-back raises the
   next wave's bar by 40%. The hold posts each army at its own natural's gate. Cutting the hold with the rest (cut) made the
   armies smaller, not the games shorter.
3. **The side ahead does push, now.** The mirror coach's press fires 1-3 times a side a game and the hunt over a token army
   starts in most decided games; press2 and finish doubled those, without more decided games.
4. **Late games swell the economy, not the army.** At the cap a side had up to 95-104 labourers, 13 Barracks and a 10,000-
   17,000 bank (Ashford r0 b13 P2: 2,400-2,900 of army from 14:00 to 20:00 with 17,165 gold at 20:00); its waves were out,
   so the cap rule (maxed) had nothing at home to send. labcap2 moved some supply to the army (2,280 against 1,939 at 16:00)
   and its first block was among the best of the job, its second about the baseline.
5. **The Balloon harass in the mirror** (picked on an UNKNOWN read in about a third of the sides, by the owner's weights
   balanced 3 / balloon 2) takes four Musketeers a party, up to five parties at once (Greenhold r1 b10, 14:00-17:00): its
   waves go with 10-23 supply while the army is 2,500-3,000. Its sides did no worse on the score than Balanced (-0.09 against
   +0.13 in b01-b02, within the noise).

## Claude's choices (for the owner)

1. **The measure of "better" in a mirror**: abs g, decided, 1.5x apart (the mean g is zero by design, its sign the spot).
   The 20:00 score with the quarter rule makes abs g jump by ~2 with a decided game, so it is noisy; abs g14 is steadier but
   moved with no change.
2. **No seat swap**: both seats are the same code, so seat 1 is always spot A; the spot edge is read from it (none clear).
3. **Nothing kept.** cut, finish and labcap2 lean the right way, each inside the noise; keeping one on a +0.2 that two
   baseline blocks also show by chance would be keeping noise. All stay behind their switches for a bigger measure.
4. **b12 and b13 counted as changes, not baselines**, though maxed acted in only 1 game of 20: they are the clearest proof
   of the noise (4 and 0 decided with the code almost as main).
5. **b17 ran the three leaning changes together** (cut + finish + labcap2) instead of a third block of one of them: if their
   gains added up the block would show it. One block cannot show less than that.
6. **press2 changed AICrownMirror's constants into vars** read through AIWr1000CrownMirror.press_k (today's values unless
   the switch is on); ai_crown_mirror.gd is used only by this pairing.
7. **170 games, not more**: about 30 minutes a block on two cores and the reading between; the tests at the end.

## Proposals (not done: the owner's call)

1. **Measure decisiveness with bigger arms.** 60 games an arm (6 blocks) for cut, finish and labcap2 against 60 baseline
   games: the +0.2 they show would then be past the noise or gone. The tool is ready (`run <block> --extra ...`).
2. **A labourer cap by supply for the Crown computer in every matchup** (labcap2's 64, or 40% of the supply cap): in long
   games against the Brood and the Clockwork too the Crown reaches 200 supply with ~100 labourers and a bank it cannot use
   (crown_1000_brood's "1-2k unspent gold at the supply cap"). Measured here only in the mirror.
3. **Waves that wait for guns, not for supply, after a pull-back from a palisade** (today x1.4 supply): the mirror's walls
   turn waves back 1-5 times a side a game. Not built.
4. **The spot B lean** (83 against 69 won or led over 170 games, p 0.29): rerun the start-spot study on the six parity maps if
   it grows.

## The tests

TESTS
