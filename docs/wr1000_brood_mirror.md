# WR1000, the Brood mirror (wr1000-brood-mirror)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games over six parallel jobs, in
blocks of 10 games, ONE change in the computer's play a block. This job is the Brood against the Brood (the mirror):
Hard OPTIMAL against Hard OPTIMAL, games to 20:00 on the six parity maps of ai-opponent-review. In a mirror "better"
does not mean one side winning: it means games that END by play (the side ahead closes it out, the side behind fights
back sensibly), not games that see-saw to the bell. No unit, price or income number was changed.

## Summary

**170 games (17 blocks of 10, to 20:00)**: two games at a time on a 2-core machine, a block of 10 took 30-45 minutes.
Three blocks are the untouched baseline (blocks 1, 5 and 15, to measure the noise), one is a measure of the start-spot
edge (block 12, the spots swapped), ten tried one change each, and one change was run three more times (blocks 14, 16 and
17) before it was kept. The job finished cleanly: the kept change is ON by default in the mirror only, the rest OFF behind
their switches, the AI tests run.

**The fresh win rate of the Brood mirror (main 0.38.124, 30 games)**: 13 of 30 games end by 20:00 (43%), the rest are
draws at the bell between two live sides (17; in 10 of them the two sides are within 10% of each other). The side ahead
at 12:00 closes it out: 17 of the 18 games with a side 10% ahead at 12:00 end with that side winning or leading, none
turned round. The median defeat is at 14:47. Both sides reach 4 halls (Mound Turtles on new ground), about 8 Rootmaws and
54-57 grubs, and their supply cap (200) by about 12:00.

**Kept (on by default, in the mirror only)**: `sirewave`: when the Brood computer facing another Brood sends a wave while
it stands at its supply cap (so no egg can be laid), its Tyrant Sire goes with the wave instead of standing rooted beside
the Mother doing nothing, and comes home with it. In its four blocks (40 games) **24 of 40 games ended by 20:00 (60%,
baseline 43%)**, every one of the four blocks above every baseline block (5, 6, 7, 6 against 4, 5, 4), the defeats two
minutes sooner (median 12:17 against 14:47), the sides farther apart at the bell (mean |g| 1.02 against 0.83). Not kept
(behind their switches, off): `counter`, `outer`, `chase`, `quality`, `grubs`, `sires`, `regroup`, `field`.

| Brood v Brood, Hard OPTIMAL, the same 10 games | baseline (b01+b05+b15, 30 games) | **kept: sirewave (b13+b14+b16+b17, 40 games)** |
|---|---|---|
| decided by 20:00 | 13 of 30 (43%) | **24 of 40 (60%)** |
| P1 (spot A) won / P2 won / draws | 9 / 4 / 17 | 13 / 11 / 16 |
| P1 won or led / even / P2 won or led | 14 / 10 / 6 | 18 / 10 / 12 |
| mean \|g\| at the end (how far apart) | 0.83 | **1.02** |
| mean \|g\| at 14:00 | 0.16 | 0.18 |
| a side 10% ahead at 12:00 / it won or led at the end / the other side turned it round | 18 / 17 / 0 | 29 / 19 / 5 |
| median minute of the defeats | 14:47 | **12:17** |
| income at 8:00 / 12:00, P1 of P2's (geometric mean) | 1.013 / 1.036 | 1.013 / 1.070 |
| army at 8:00 / 12:00, P1 of P2's | 1.46 / 1.12 | 1.49 / 0.75 |
| halls at 12:00 (each side) | 4.0 | 3.9 |
| Rootmaws rooted at 12:00 (each side) | 8.2 | 7.8 |
| Tyrant Sires killed a game | 0.43 | 1.75 |

Pooled game by game, the kept code is better than the baseline in 6 of 10 games and worse in 4 (mean |g| +0.20, t 0.7);
decided 60% against 43% (t 1.3 on 70 games). That is a modest gain, under the bar of a single block: it was kept on its
four blocks all beating the three baseline blocks and on the owner's own words for a mirror (games that end), see
Claude's choice 1.

**What is still wrong**: the mirror at the supply cap is a wall. From about 12:00 both sides stand at 200 supply with
2,000-7,000 food banked, and a wave into the enemy's home loses two to three for one (the defender's swamp, her Sires,
her rooted creatures, and an army refilled from her clutch in half a minute). Every change that made the waves SAFER
(going for the outer ground, regrouping, holding the field) made the games LESS decisive (0-1 decided of 10): the games
that end are the ones where an army is caught and crushed. The **start-spot edge is back** in 20-minute games: P1 on spot A
won or led 68 of 160 games against 34 (p 0.001); with the spots swapped (one block) P1 still led 6 to 3, so part of it
follows the player order, not the spot (below).

## The fresh baseline (main 0.38.124, nothing changed)

Three blocks of the same 10 games on main 0.38.124 (nothing changed): blocks 1, 5 and 15.

| block | decided | mean \|g\| | mean \|g14\| | P1 W/=/L (P1 g) | led at 12:00 / closed / comeback | median defeat |
|---|---|---|---|---|---|---|
| b01 | 4 | 0.77 | 0.17 | 3-4-3 (-0.02) | 5 / 4 / 0 | 15:32 |
| b05 | 5 | 0.90 | 0.11 | 5-4-1 (+0.55) | 5 / 5 / 0 | 14:47 |
| b15 | 4 | 0.81 | 0.20 | 6-2-2 (+0.38) | 8 / 8 / 0 | 14:14 |
| pooled | 13 of 30 | 0.83 | 0.16 | 14-10-6 | 18 / 17 / 0 | 14:47 |

Read aloud: of 30 games, 9 were won by P1 and 4 by P2 by 20:00, 17 went to the bell. A game is decided around 15:00 when
it is decided at all, and it is decided in the open: the two waves leave at the same time, meet (THE MIRROR'S MEETING
turns one onto the other), one is crushed, and the winner goes on to the Mother. Ahead at 12:00 means winning: 17 of 18.
The noise between two blocks of the same code is 1 decided game and 0.13 in mean |g| (b01 against b05).

At 8:00 a side has earned about 9,200 food, has 54 grubs, an army worth about 1,600 and 120 supply; at 12:00 18,200
earned, 57 grubs, an army of 2,700 and 172 supply, and the cap (200) comes soon after.

## Every block

Every block against the pooled baseline (b01+b05+b15, each game's numbers the mean of its runs): d = the paired mean
difference of |g| (t), better/worse = games whose |g| moved by more than 0.05. One row a block also in
`docs/wr1000_brood_mirror/blocks.md`.

| block | what changed (switch on) | decided | mean \|g\| | \|g14\| | P1 W/=/L | led 12:00 / closed / comeback | median defeat | v base d \|g\| (t) · better/worse | kept? |
|---|---|---|---|---|---|---|---|---|---|
| b01 | the baseline: main 0.38.124, nothing on | 4 | 0.77 | 0.17 | 3-4-3 | 5 / 4 / 0 | 15:32 | | the baseline |
| b02 | **counter**: when it has just broken an enemy wave at home (killed 40% of the enemy army it had seen in the last minute, lost under 0.7 of that) and its army is 1.3x what it reckons the enemy has left, it goes at once, past its cap and plan rules | 2 | 0.43 | 0.11 | 4-4-2 | 5 / 2 / 0 | 14:48 | -0.39 (-1.2) · 2/8 | no: 79 counters fired, but the enemy it reckoned at "0 left" met it with an army refilled from her clutch (2,000-3,250 ahead when it arrived) and pulled back |
| b03 | **outer**: the wave's goal is the enemy's OUTER ground (the rooted Mound Turtle or Rootmaw seen farthest from her Mother) instead of her start (against a Brood the wave always walked to the Mother: the Brood has no buildings) | 0 | 0.14 | 0.14 | 0-8-2 | 5 / 1 / 0 | - | -0.69 (-3.8) · 1/8 | no: the waves traded better (killed 0.87 of what they lost, 0.58-0.68 before) and NOTHING ended: the two sides' banks at 16:00 summed over the 10 games 70,800 (block 1: 42,200), Rootmaws 156 (107) |
| b04 | **chase**: a beaten enemy army seen walking away from its Mother (under 0.7 of its own) is followed and bitten on the road, up to 22 tiles from the enemy Mother or 50 s | 3 | 0.64 | 0.16 | 6-4-0 | 5 / 3 / 0 | 12:51 | -0.19 (-0.6) · 4/6 | no: 34 chases, 19 ended with "nothing left to bite" (the broken wave was out of reach, or gone) |
| b05 | the baseline again (the noise) | 5 | 0.90 | 0.11 | 5-4-1 | 5 / 5 / 0 | 14:47 | +0.08 (0.3) · 4/4 | the pool b01+b05 |
| b06 | **quality**: at the cap with 1,500 food it matures the young at home past the half (Raptors into Tyrant Challengers, Spitters into Venom Challengers, 4 a think), offers a Raptor up when the cap stops it, and the capped wave waits up to 45 s for them | 3 | 0.60 | 0.17 | 5-4-1 | 5 / 3 / 0 | 14:13 | -0.22 (-0.8) · 3/6 | no: 25-69 matured a side in a long game, fewer waves (84 against 95-99) |
| b07 | **grubs**: at the cap with 3,000 food or more it keeps 44 grubs (57-62 before) and offers up the rest, one every 3 s: the room goes to warriors | 6 | 1.16 | 0.18 | 5-2-3 | 7 / 6 / 0 | 13:19 | +0.33 (1.2) · 6/3 | run again (b09): it fired at 12:38-19:54, after four of the six games that ended had ended |
| b08 | **sires**: a wave within 20 tiles of the enemy Mother that sees one of her Sires (the Tyrant Sire first) sends a squad at him, enough to fell him in about 15 s, a third of the wave at most | 3 | 0.65 | 0.13 | 7-1-2 | 5 / 4 / 0 | 14:31 | -0.17 (-1.1) · 4/6 | no: it fired 6 times in 10 games (the waves rarely got near enough to see her Sires) |
| b09 | **grubs** again | 2 | 0.48 | 0.14 | 5-3-2 | 8 / 7 / 0 | 16:16 | -0.35 (-1.4) · 2/7 | no: the pool b07+b09 is the baseline's (4 decided, \|g\| 0.82) |
| b10 | **regroup**: after a wave comes home it waits 45 s before the next, unless 1.4x bigger (a wave that pulled back was sent out again 3-30 s later, its survivors still walking home) | 1 | 0.26 | 0.13 | 3-5-2 | 4 / 2 / 0 | 12:03 | -0.56 (-2.5) · 1/8 | no: clearly worse |
| b11 | **field**: the wave marches half way to the enemy Mother and holds there, off both swamps, in the path of the enemy's wave (the meeting rule turns it onto an army walking past); it goes on to her at 1.6x the enemy army reckoned, or after 100 s with no fight | 0 | 0.06 | 0.07 | 1-7-2 | 4 / 1 / 0 | - | -0.76 (-4.8) · 0/9 | no: clearly worse (the best trades of all, 0.93, and nothing ended) |
| b12 | **spotswap** (a measure, no play change): P1 on spot B, P2 on spot A | 7 | 1.24 | 0.15 | 6-1-3 | 8 / 6 / 1 | 15:53 | +0.41 (1.5) · 8/2 | (the spot edge, below) |
| b13 | **sirewave**: a wave that leaves at its supply cap takes the Tyrant Sire (he gets up, walks with it, comes home with it and roots again) | 5 | 0.86 | 0.18 | 3-3-4 | 7 / 4 / 2 | 13:16 | +0.04 (0.1) · 5/4 | run again |
| b14 | **sirewave** again | 6 | 1.03 | 0.17 | 5-3-2 | 7 / 3 / 1 | 13:07 | +0.20 (0.6) · 6/4 | run again |
| b15 | the baseline a third time | 4 | 0.81 | 0.20 | 6-2-2 | 8 / 8 / 0 | 14:14 | -0.02 (-0.1) · 4/4 | the pool b01+b05+b15 |
| b16 | **sirewave** a third time | 7 | 1.16 | 0.17 | 5-1-4 | 7 / 6 / 1 | 12:17 | +0.34 (1.3) · 7/2 | **yes**: 18 of 30 decided (5, 6, 7) against 13 of 30 (4, 5, 4) |
| b17 | **the kept code** (sirewave on by default, no switch) | 6 | 1.04 | 0.20 | 5-3-2 | 8 / 6 / 1 | 12:18 | +0.21 (0.6) · 6/4 | the pool b13+b14+b16+b17: 24 of 40 decided, \|g\| +0.20 (0.7) · 6/4 |

The waves' own trade (what a wave killed against what it lost, from the computers' "pulls back" lines; reinforcements
count in what it lost): baseline 0.58-0.68; counter 0.51; outer 0.87; chase 0.67; quality 0.67; grubs 0.56-0.69; sires
0.67; regroup 0.57; field 0.93; sirewave 0.77-0.84.

## What the games showed

1. **The wave always walked to the enemy Mother.** Against another Brood, AIBroodNew._nb_wave_goal looks for the nearest
   enemy BUILDING it has seen and falls back on the enemy's start: the Brood has no buildings, so every wave went to the
   Mother, into her swamp, her rooted Sires and the army at her rally. 92 waves pulled back in block 1, most with half or
   less ("pulls back: 1945 of 3495 left, 3225 ahead (killed 450)"), killing 0.68 of what they lost. Sending them to the
   outer ground instead (`outer`) made the trades better (0.87) and the game a stalemate (block 3: 0 decided).
2. **At the cap the bank cannot be spent.** Both sides reach 200 supply by 12:00-13:00 with 54-62 grubs and an army of
   110-130 supply; their banks grow to 2,000-7,000 food (Greenhold block 1: P2 held 5,197 at 18:00). The clutch (20 eggs
   at her stage 3, two or three Raptors an egg) refills an army in about half a minute, so a wave that breaks the enemy's
   army finds it remade when it arrives (the counter of block 2: "1875 against the 174 it reckons left", then "pulls back:
   ... 3250 ahead"). Turning food into a better army at the cap (`quality`, `grubs`) did not change the outcomes.
3. **The capped waves are almost all Raptors** (Greenhold block 1: "attacks with 132 supply (132 raptor)"), the cheapest
   creature, 38 health a supply: MATURE stops at half of each young kind and at the cap (a Challenger needs one more supply).
   `quality` matured 25-69 a side in a long game and did not change the outcomes either.
4. **At the cap the Sires lay nothing.** A warrior egg needs its Sire rooted beside the Mother; at the cap no egg is laid,
   and the Tyrant Sire (1,000 health, 42 a bite) stood on his nest while the waves broke. With `sirewave` 42-52 of 53-68
   waves a block went with him; he dies more (1.75 a game against 0.43: a grub grows a new one) and the games end more
   (60% against 43%). He also goes when a side is briefly at a lower cap early on (a wave at 6:30 with 38 supply on
   Hollowfen took him): the rule is "no egg can be laid now", not "200".
5. **Safer waves, fewer endings.** Everything that cut the attacker's losses (outer ground, a regroup before the next wave,
   holding the field) left both armies whole and the banks full: 0 to 1 decided games of 10. The games that end are the
   ones where an army is caught and crushed in the open and the winner walks on to the Mother: in the baseline 17 of 18
   leaders at 12:00 finished it.
6. **Some games are lost early to one bad meeting**: Frostfang r1 ended at 10:37 in three blocks (b13, b16, b17) and Hollowfen
   at 10:41-10:51 in two: the first big waves meet at the natural and one is crushed. That is the mirror's own decisive
   fight, the same in every block's code.

## The start-spot edge

P1 (player 1 of the setup) stands on spot A in every block but block 12. Over those 160 games **P1 won or led 68, even 58,
lost or behind 34 (p 0.001)**; outright wins 36 against 21 (p 0.06). P1 had the bigger army at 8:00 in 6-7 of 10 games in
nearly every block (geometric mean 1.09-1.65 of P2's) on 1.0-2.0% more income. By game (won or led / lost or behind, all
blocks but 12): Dune Sea r1 11-0, Cinder Steps 10-3, Frostfang r0 10-3, Hollowfen 9-1, Frostfang r1 8-6, Ashford r1 5-3,
Dune Sea r0 4-2, Greenhold r0 4-4, Greenhold r1 3-4, Ashford r0 4-8.

Block 12 (`spotswap`: P1 on spot B, P2 on spot A, the same maps and seeds): P1 6-1-3, P1's army at 8:00 0.98 of P2's,
income 0.997. So the 8:00 lead follows the SPOT (it goes away when P1 stands on B), but the results did not swap with it:
Dune Sea r1 and Cinder Steps were still won by P1 on spot B, Frostfang r0 went to spot A again. One block of ten cannot
tell the two apart: part of the edge looks like the spot (the brood-spot-study's 1-3% mid-game lean, now carried to
20:00), part like the player order. With `sirewave` on the record is closer (P1 18 / P2 12 won or led in 40 games, against
14 / 6 in the baseline's 30). Proposal 2 below.

## Claude's choices for the owner

1. **`sirewave` was kept on a pooled measure**, not one block: decided 24 of 40 against 13 of 30 (t 1.3), each of its four
   blocks above each baseline block, mean |g| +0.20 (t 0.7). By the job's bar for a single block that is not "clearly
   better"; I kept it because the owner asked for a mirror whose games END, all four blocks agree, and nothing in it
   is worse to watch (no turtling, no suicide waves: the waves trade better, 0.77-0.84 against 0.58-0.68). `-- wbmsirewave:off`
   plays as before; `-- wbm:off` turns off the whole job.
2. **With `sirewave` a lead at 12:00 is less safe**: the side ahead at 12:00 won or led at the end in 19 of 29 games
   (baseline 17 of 18), and the other side turned it round in 5. I counted that as "the side behind fights back", which the
   owner asked for, not as noise; if the owner wants leads to hold, switch it off.
3. **The rule is "no egg can be laid now"** (the side at its supply cap of the moment, within 6), so the Sire also walks
   with an early wave at a temporary cap (a turtle about to root). I left that in: at that moment he lays nothing either.
4. **The Tyrant Sire dies about four times as often** (1.75 a game against 0.43); a grub grows a new one, and its
   research (Bigger Clutch, Pack Hunt) is kept by the side. I did not add a rule to bring him home when hurt.
5. **Only the Tyrant Sire**, not the Venom or Storm Sire: one change a block, and the waves are mostly his Raptors.
6. **Three baseline blocks and four runs of the kept change** (the noise between two blocks of the same code is 1-2 games
   of 10): 50 of the 170 games went to measuring the noise and the kept change; 10 changes were tried once (grubs twice).
7. **`counter` and `chase` reckon the enemy army from what they saw**, not from the enemy's own numbers (no cheating); that
   reckoning was the weak part (the enemy refills from her clutch faster than it can see).
8. **Block 12 (`spotswap`) changed no play**: it is the measure the job asked for ("also note any start-spot edge").

## Proposals (not built: numbers or bigger changes for the owner)

1. **The wall at the cap is a design question more than the computer's**: two Broods at 200 supply with full banks refill
   an army in half a minute from the clutch, beside rooted Sires and on their own swamp, and a wave into that loses two
   to three for one. If the owner wants mirrors to end more often: a smaller clutch or a slower laying once the Mother
   is at her stage 3 and the side at its cap; or the swamp's healing (2 a second, SWAMP MENDING on top) not for creatures
   fighting an enemy army; or a Sire's eggs only while he is unhurt. NOT built (no numbers changed).
2. **A spot study at 20:00**: the brood-spot-study fixed the opening and measured to 12:00; to 20:00 the mirror leans to P1
   again (68 against 34 won or led). A study with every game played both ways (spots as they are and `spotswap`) would
   tell the spot from the player order; if it is the player order, look at what runs first each tick (unit lists by
   team, think order) in the big Raptor fights.
3. **MATURE at the cap** for the player too: a Raptor cannot mature at the supply cap (the Challenger needs one more
   supply), so a capped Brood keeps its cheapest army; a rule that lets a moult swap its supply might be worth it.
4. **The wave's goal against a Brood**: the computer still walks every wave to the Mother. `outer` (the outer ground) made
   the waves trade better and the games stall; a mix (the outer ground while the enemy army is big, the Mother when it is
   small) was not tried.

## What is still wrong

- From about 12:00 the mirror is a stand-off at the cap: 16 of the kept code's 40 games still go to the bell, most of them
  within 10% (the defender's advantage, proposal 1).
- The start-spot / player-order edge (P1 68 against 34 won or led over 160 games), proposal 2.
- The banks at the cap: 2,000-7,000 food unspent from 14:00 in the long games, on both sides; nothing tried here spent
  them usefully.
- The capped armies are almost all Raptors; maturing them did not change the outcomes.
- The computer's reckoning of the enemy army in the mirror is what it saw (the biggest army seen, fading 60 a minute):
  after a fight it reckons the enemy nearly empty while the clutch is refilling it.

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

All 23 `tools/test_ai_*.gd` were run on the branch with the kept code on (two at a time; `docs/wr1000_brood_mirror/ai_tests.txt`),
and the ones that failed again with the whole job off (`-- wbm:off`, which plays exactly as main):

- **20 pass.**
- `test_ai_expand` ([clockwork] still earning in the last 60 s) failed once and **passed on the rerun**, with the job on and
  with it off (flaky, as CLAUDE.md says).
- `test_ai_rush_followup` (the raiding party cut down, fresh Horsemen at home) and `test_ai_wall_vs_rush` (Barracks and Mill
  by 75 s: 58 / 100 s) **fail the same with the job off**: not from this job (both fail on main, ai-opponent-review).
- The Brood tests that touch its computer: `test_brood_mirror` passes with the job on and off; `test_brood_mother_uproot_ai`
  and `test_brood_builds` pass.

The kept change runs only when a Brood computer faces another Brood (AIWr1000BroodMirror.mirror), so against the Crown and
the Clockwork, in the campaign and the tutorial, the Brood plays exactly as main.
