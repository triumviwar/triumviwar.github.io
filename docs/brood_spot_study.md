# Brood spot study (job brood-spot-study, 2026-11-15/16)

The owner (2026-11-15 22:20) on the win-rate study's finding S1 (docs/winrate_2026_11_15.md: in the Brood mirror P1, who
always stood on spot A, won or led 26 of 38 to P2's 9, p 0.006, and out-earned P2 by about 8% from the second minute):
"this shouldn't be happening, spots should be equal." This job found where the edge comes from, fixed what is a rule of
the game or the computer measuring the two starts differently (behind switches), and measured again.

Words: **spot A** = the map's first start (top / top-left), **spot B** its mirror. **P1** = the first player of the
match setup (team 0, the first computer to think each tick, the first in every list). **Won or led** = won, or led the
12:00 draw by 10% on income + 2 x army value (the win-rate studies' rule). Games are the 38 Brood mirrors of the win-rate
studies (qa_matches.base(): 19 maps x rounds 0 and 1, the same seeds), OPTIMAL v OPTIMAL, Hard, to **12:00** (not 15:00:
time), each played twice: as before (P1 on spot A) and with the new measuring switch `spotswap` (P1 on spot B, P2 on spot
A; the same map and seed).

## The answer in short

1. **The maps are fair**: every cell of all 19 two-player maps is the exact mirror of its twin (section 2).
2. **It is the spot, not the player order**: with P1 moved to spot B (`spotswap`) spot A kept its income lead (5:00:
   1.044 with P1 on A, 1.052 with P1 on B) and P1 v P2 was 31-28 (section 1).
3. **The cause is the game measuring the two starts differently.** The Brood's rooted creatures' feet hang below their
   footprints on screen, toward the map's middle on spot A and toward its back on spot B; several Brood rules and the
   Brood computer's spot choices measured from those feet (section 3). The biggest one is a rule: a far Rootmaw drinks
   its ground faster by its distance from the Mother, and spot B's Rootmaws (below their Mother on the turned map) read
   nearer and drank slower. Second, **every game on a map replayed the same opening** (both computers started thinking
   at 0:00 whatever the seed; the nine classic maps even share one opening), so the small differences a mirror can't
   avoid fell the same way game after game.
4. **Fixed, behind switches** (both on): `fairspot` measures the Brood's sums from the point the first start would
   (BroodRoot.anchor / sym_feet / BroodNew.fdist): spot A plays exactly as before, spot B now its mirror. `thinkphase`
   starts every computer of a match thinking at a moment drawn from the match seed (the same for all of them), so each
   seed plays its own opening.
5. **Measured again** (76 games, plain and swapped, the final fix):

   | | before (0.38.30) | after |
   |---|---|---|
   | spot A won or led / spot B / even | 34 / 25 / 17 (p 0.30) | **28 / 25 / 23 (p 0.78)** |
   | spot A's income over B's at 2:00 / 3:00 | 1.023 / 1.032 (p < 0.0001 both) | **1.002 / 1.005 (p 0.30 / 0.42)** |
   | at 5:00 / 8:00 / 10:00 | 1.048 / 1.047 / 1.057 (all p < 0.001) | 1.028 / 1.012 / 1.024 (p 0.008 / 0.002 / 0.03) |
   | at 12:00 | 1.061 | 1.016 (p 0.90) |
   | P1 won or led / P2 | 31 / 28 | 34 / 19 (p 0.053) |

   No spot edge is left in the results, and the opening is even. **A small mid-game lean remains** (spot A ahead in 2 of
   3 games at 5:00-8:00 by 1-3%); it shows only when the two Broods play each other, not alone (section 4), so it lies in
   what they see of and do to each other: candidates and a next step in the proposals. The P1 34-19 is not significant
   (and was 31-28 before); watch it in the next study (proposal P2).

## 1. Spot or player order? (the swap test, 0.38.30 as it was)

76 games (38 plain, 38 swapped), `docs/brood_spot_study/data`:

| run | games | spot A won or led / B / even | p | P1 won or led / P2 | decided | income A/B 2:00 | 3:00 | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| plain (P1 at A) | 38 | 18 / 12 / 8 | 0.362 | 18 / 12 | 2 | 1.023 | 1.034 | 1.044 | 1.047 | 1.065 | 1.075 |
| spotswap (P1 at B) | 38 | 16 / 13 / 9 | 0.711 | 13 / 16 | 3 | 1.022 | 1.030 | 1.052 | 1.048 | 1.050 | 1.046 |
| both | 76 | 34 / 25 / 17 | 0.298 | 31 / 28 | 5 | 1.023 | 1.032 | 1.048 | 1.047 | 1.057 | 1.061 |

(9 of these games were first killed by the machine running out of memory and played again; the "income" columns are
means of each game's spot A over spot B.)

- **It is the spot, not the player order.** Spot A's income lead is the same whether P1 or P2 stands on it (5:00: 1.044
  plain, 1.052 swapped); P1 v P2 is 31-28. The swapped games are not exact mirrors of the plain ones (the first differing
  minute is 1 to 5): who is processed first does change the game a little (section 5), but not toward one side.
- On 0.38.30 at 12:00 the record itself leans less than the win-rate study's 26-9 (0.38.14 at 15:00): spot A won or led
  34, spot B 25, even 17 (p 0.30). **The economy leans clearly**: spot A out-earned spot B at 2:00 in 57 games of 76, at
  5:00 in 61, at 8:00 in 58 (sign test p < 0.0001 at each; mean A/B 1.023, 1.048, 1.047).

| minute | games | A/B mean | sd | t | A ahead / B ahead | sign test p |
|---|---|---|---|---|---|---|
| 2:00 | 76 | 1.023 | 0.030 | 6.7 | 57 / 18 | < 0.0001 |
| 3:00 | 76 | 1.032 | 0.039 | 7.3 | 60 / 16 | < 0.0001 |
| 5:00 | 76 | 1.048 | 0.074 | 5.7 | 61 / 15 | < 0.0001 |
| 8:00 | 76 | 1.047 | 0.057 | 7.2 | 58 / 18 | < 0.0001 |
| 10:00 | 76 | 1.057 | 0.099 | 5.1 | 53 / 23 | 0.0008 |
| 12:00 | 71 | 1.061 | 0.154 | 3.3 | 42 / 29 | 0.15 |

The Rootmaws and turtles (the new "root" events, both runs together): spot B rooted its third Rootmaw first in 49 games
(spot A in 9; mean 116 s against 121 s) and its second to sixth Mound Turtles later (A first 39-51 times, B 11-21).

## 2. The maps are exact mirrors

`tools/study/map_mirror_check.gd` compared every cell of each of the 19 two-player maps with its mirror twin (walkable or
not, height, ramp, water, cliff, a tree, rock or decoration): **no cell differs on any map**, round the starts or on the
whole map. Nothing to fix in the maps.

## 3. Why spot A: what the game and the computer measured differently

**The Brood's rooted creatures stand on a footprint, and their feet (Unit.position, where the picture hangs from) are below
the footprint's middle on screen**: the Mother's 40 px, a Rootmaw's or a Mound Turtle's 24, a Sire's 16 to 33. On spot A
the feet hang toward the map's middle; on spot B (the map turned round) they hang toward its back edge. start-spots-fix
(0.33.23) carried the start itself and the Brood computer's spot finders through the mirror (Game.sym_*, BroodRoot.anchor),
but several sums still measured from the plain feet, and the newer code (the Rootmaw count and marked spots of 0.38.14)
added more. Every sum between two points that hang by different amounts comes out a little different on the two starts:

| where | what it decided | what spot B got |
|---|---|---|
| BroodNew rooted Rootmaw (brood_new.gd, the drinking) | how fast a Rootmaw draws its ground: faster the farther it is from the Mother (Game.food_mult), Mother's feet to Rootmaw's feet | its Rootmaws behind the Mother read up to ~0.5 tile nearer than their twins: drank a few % slower (the grubs wait at a Rootmaw that is drinking) |
| BroodNew.father_near, fathers(), father_tick, BroodRoot.place_problem (a Sire's reach) | a Sire close enough to fertilise her eggs; where he may nest | a different reach |
| BroodNew.expansions | a turtle far enough from her to be new ground | a different count |
| BroodNew.free_source | which Rootmaw a grub without one goes to | a different Rootmaw on a near tie |
| Unit (swamp mending) | a rooted creature on its swamp mends 2 hp/s | its cocoons and turtles at the swamp's edge mended differently (a cocoon grew 2 hp/s slower in the probe) |
| the Brood computer: _nb_morphs_go | which grub goes to turn into a Rootmaw / turtle (the nearest to the spot's feet) | another grub (the first difference of the mirrored game, 2.7 s in) |
| _nb_far_spots, _nb_eco_sites, ExpansionSpots.nb_pick | which turtle spots count as new ground, near enough to guard | "22 tiles out" on A was "20 tiles out" on B |
| _nb_spot_for, _nb_marked_spot (0.38.14) | the score of each Rootmaw spot ("the FAR edge", away from the enemy) | the far-edge sum a tile and a half off: spot B rooted its third Rootmaw first in 49 of 76 games (A first 9), its Mound Turtles later |

Each is small; together, in the same direction game after game, they gave spot A its few %. On top of that **the early
game of a map did not depend on the seed** (start-spots-fix found this too): both computers start thinking on the same
tick, so every round of a map replays the same first minutes, and the nine classic maps share one opening (Greenhold,
Dune Sea, Mirewood, Red Coast and Twin Fords gave the same incomes to the coin for minutes, alone and in the mirror, with
any seed). The few differences a mirror cannot avoid (positions are 32-bit floats: x and its mirror W - x round
differently; who is processed first) then fall the same way in every game on a map, so a map's whole record leans one way.

**Alone** (tools/econ_ai_alone_brood.gd: one Brood computer, the other side an idle dummy; the same side, at spot A and
with `spotswap` at spot B, so nothing but the spot changes), spot A over spot B, cumulative food at 1:00 ... 6:00:

| map, seed | 0.38.30, the same computer at A (team 0) and at B (team 1) | the final fix, team 0 at A and at B | the final fix with `fairspot:off` |
|---|---|---|---|
| Greenhold (= Dune Sea, Mirewood, Red Coast, Twin Fords) | 1.000 1.033 1.045 1.050 1.037 0.995 (any seed) | seed 1104: 0.982 0.986 0.983 0.973 0.962 0.922; seed 3/7: 1.019 1.019 1.018 1.005 1.005 1.004 | 0.982 0.986 0.983 0.964 0.961 0.926; 1.019 1.019 1.019 1.026 1.030 **1.066** |
| Frostfang (= Highmoor) | 1.000 1.033 1.045 1.056 1.050 1.046 | | |
| Kestrel Rise | 1.000 at every minute | 0.943 0.964 0.980 0.962 0.981 0.946; 1.019 1.019 1.013 1.025 1.022 0.989 | 0.943 0.964 0.980 0.962 0.987 0.991; 1.019 1.019 1.013 1.025 1.030 1.003 |
| Hollowfen | 1.000 at every minute | 1.000 1.031 1.010 1.006 1.029 1.029; 0.982 0.980 0.996 1.003 0.980 0.973 | 1.019 1.038 1.014 1.006 1.003 1.009; 1.000 1.014 1.040 **1.088 1.069 1.073** |
| Ashford Crossing, Cinder Steps | 1.000 at every minute | | |

- Before: the classic maps (one opening for all of them) gave spot A 3-5% from 2:00 alone; the named maps were exact to
  the coin for six minutes (their opening happened not to tip).
- With the final fix the seeds give different openings (seeds 3 and 7 land on the same think tick), the ratios scatter
  round 1 (6:00: 0.92 to 1.03, mean 0.98), and **switching `fairspot` off brings spot A's lead back** where the opening
  allows (Greenhold seed 3/7 1.004 -> 1.066, Hollowfen 0.973 -> 1.073 at 6:00): spot A's side earns exactly what it did
  (the fix only moves spot B's measurements), spot B earns 4-10% more with it.
- The data: docs/brood_spot_study/alone/ (before_0.38.30: the old side 0 / side 1 runs; fix and fix_fairspot_off: team 0
  at spot A, `_0`, and with spotswap at spot B, `_1`).

## 4. The fix and the measurement

**What changed** (all behind `fairspot`, BroodRoot.fair_spot; with it on, spot A measures exactly as before and spot B
measures from the mirror of spot A's points):

- BroodRoot.sym_feet(g, t, k, p): the point a `k` rooted at p stands for in the first start's frame, carried back.
  BroodNew.fdist(g, a, b): two of a side's creatures' distance from their anchors (BroodRoot.anchor).
- The rules (the game, any player): a rooted Rootmaw's drinking (Game.food_mult by fdist), BroodNew.father_near, the
  fathers round her, father_tick, BroodNew.expansions, BroodNew.free_source (anchor), BroodRoot.place_problem and the ROOT
  ghost's IN RANGE for a Sire (BroodRoot.father_d), a rooted creature's swamp mending (Unit, at its anchor).
- The Brood computer: the grub it sends to turn into something (_nb_morphs_go, nearest to sym_feet), the far turtle
  spots (_nb_far_spots, _nb_eco_sites, ExpansionSpots.nb_pick), the Rootmaw spot scores (_nb_spot_for, _nb_marked_spot:
  the spot's feet in the first start's frame, the turtle on new ground from its anchor, the enemy's distance), and after
  the merge with brood-rootmaw-coach its new checks (_toward_foe, the supply turtle sent to new ground).

**And** `thinkphase` (AI.first_phase): the first think waits a share of the think period drawn from the match seed, the
same share for every computer of the match. A first try gave each side its own share (data_fix_v1): that hands one side a
random head start of up to 0.4 s; with one share for all, nobody waits longer.

**The measurement.** Three runs of the 76 games: data_fix_v1 (first fixes, a phase per side: 24 games), data_fix_v2 (the
rules fixed too: 22 games), data_fix (the final fix, all 76; run on the branch before the merge with main, 0.38.30 plus the
fix):

| run | games | spot A won or led / B / even | p | P1 / P2 | decided | income A/B 2:00 | 3:00 | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0.38.30 | 76 | 34 / 25 / 17 | 0.30 | 31 / 28 | 5 | 1.023 | 1.032 | 1.048 | 1.047 | 1.057 | 1.061 |
| final, plain (P1 at A) | 38 | 17 / 8 / 13 | 0.11 | 17 / 8 | 8 | 1.002 | 1.006 | 1.017 | 1.006 | 1.033 | 1.035 |
| final, spotswap (P1 at B) | 38 | 11 / 17 / 10 | 0.35 | 17 / 11 | 4 | 1.001 | 1.004 | 1.040 | 1.019 | 1.015 | 1.000 |
| **final, both** | 76 | **28 / 25 / 23** | **0.78** | 34 / 19 | 12 | **1.002** | **1.005** | 1.028 | 1.012 | 1.024 | 1.016 |

| minute (final) | A/B mean | sd | t | A ahead / B ahead | sign test p |
|---|---|---|---|---|---|
| 2:00 | 1.002 | 0.023 | 0.6 | 42 / 32 | 0.30 |
| 3:00 | 1.005 | 0.035 | 1.3 | 41 / 33 | 0.42 |
| 5:00 | 1.028 | 0.082 | 3.0 | 50 / 26 | 0.008 |
| 8:00 | 1.012 | 0.064 | 1.7 | 52 / 24 | 0.002 |
| 10:00 | 1.024 | 0.101 | 2.1 | 48 / 28 | 0.03 |
| 12:00 | 1.016 | 0.156 | 0.8 | 33 / 31 | 0.90 |

- The opening is even now (2:00 and 3:00), the Rootmaws and turtles root at the same times (third Rootmaw: A first 19, B
  first 16, same 41; was 9 / 49 / 18), and the result has no spot edge (28-25).
- **What is left**: spot A is still a little ahead from 4:00-5:00 in two games of three (1-3% on average), only when the
  two Broods play each other: alone (above) the fixed sides are even. In a traced game (Twin Fords seed 1116) the gap
  opens at 3:04 when spot B hatches its first two Raptors while spot A's eggs are still grubs, and B stays two grubs short from then on; the
  scouting reads come at the same time on average (B 1.8 s after A). Something B sees of A (or A of B) differs: proposal
  P1.
- The two partial runs on the way: data_fix_v1 (24 games) 11 / 8 / 5, P1 15 / 4 (the per-side phase), income 1.007 /
  1.009 at 2:00 / 3:00 and 1.051 at 5:00; data_fix_v2 (22 games) 8 / 6 / 8, P1 9 / 5, 1.007 / 1.003 and 1.052. The last
  fix (the Rootmaw spot scores) took the 5:00 lean from about 5% to 3%.

**What this costs or changes for players**: nothing on spot A; on spot B a Brood player's far Rootmaws drink as fast as
their twins on spot A would, Sires reach as far, and rooted creatures mend on the same swamp edge. The think phase moves
a computer's first decision by up to one think (0.4 s on Hard, 2.2 s on Easy).

## 5. Player order in the code

What is done in team order, checked for this study (the swap test above says none of it favours one side in the Brood
mirror):

- **The computers think on the same ticks** (Hard: every 0.4 s from 0:00 for both; AI._tick_ai, AIBroodNew._tick_ai),
  team 0's node first in the tick. Now with a phase from the match seed, the same for every computer (`thinkphase:off`).
- **Units act in the order they were made** (Game.units, the scene tree): the starting units of team 0 come first; later
  ones interleave. Who strikes first in a tick, the shove between units (summed in that order, as floats) and
  find_target's ties (the first found) follow it. The swapped games differ from the plain ones from minute 1 to 5 because
  of this, but P1 v P2 was 31-28.
- **The global random numbers** (randf(), seeded by the match seed) are drawn in unit order (a musket's spare cooldown, a
  fog miss): a different draw for each side, not a better one. Game.rng is not drawn by the Brood's or the AI's rules.
- **Claims**: no Mound Turtle site or Rootmaw spot was contested in the 76 games (the two sides' turtles never rooted
  within 10 tiles of each other), so Game.ai_keep / site_keepout and first-come reservations play no part here.
- The two computers' random numbers and timers are the same per side; no team-index offsets exist.

## 6. The other pairings (existing data)

The same "spot A won or led / spot B / even" and spot A's income over spot B's (meaningful only in the mirrors), from
docs/winrate_2026_11_15 (0.38.14, 15:00) and docs/winrate_2026_11_12 (0.33.x):

| pairing | study | games | spot A / B / even | p | income A/B 5:00 (sd) | 8:00 |
|---|---|---|---|---|---|---|
| Brood mirror | 11-15 | 38 | 26 / 9 / 3 | 0.006 | 1.077 (0.082) | 1.082 |
| Brood mirror | 11-12 | 38 | 23 / 9 / 6 | 0.020 | 1.047 (0.074) | 1.062 |
| Clockwork mirror | 11-12 | 38 | 19 / 13 / 6 | 0.377 | 1.042 (0.065) | 1.041 |
| Crown mirror | 11-12 | 38 | 16 / 18 / 4 | 0.864 | 0.994 (0.109) | 0.971 |
| Brood v Clockwork | 11-15 | 38 | 20 / 18 / 0 | 0.871 | | |
| Brood v Clockwork | 11-12 | 38 | 25 / 12 / 1 | **0.047** | | |
| Crown v Brood | 11-15 | 38 | 19 / 18 / 1 | 1.000 | | |
| Crown v Brood | 11-12 | 38 | 19 / 17 / 2 | 0.868 | | |
| Crown v Clockwork | 11-15 | 38 | 19 / 19 / 0 | 1.000 | | |
| Crown v Clockwork | 11-12 | 38 | 19 / 17 / 2 | 0.868 | | |

Each faction's own income at 5:00 at spot A and at spot B in the cross pairings (each faction stands on each spot 19
times a study): **the Brood earned 2-5% more on spot A** in all three samples (11-15: 2,694 v 2,558; 11-12 winrate-a: 2,815
v 2,752; winrate-b: 2,238 v 2,151), the Clockwork 0-4% more (3,885 v 3,779; 3,979 v 3,836; 3,525 v 3,536), the Crown the
same (2,750 v 2,730; 2,670 v 2,690). So the win-rate study's "a Brood at spot A in the cross pairings earns no more per
grub" holds per grub, not in total: the Brood's spot edge shows in every pairing, the Clockwork's a little (its mirror
1.04 at 5:00), the Crown's not at all. The Clockwork is not looked into here (proposal P3).

## Claude's choices (for the owner)

1. **The fix is on by default**, gated by measuring switches (`fairspot:off`, `thinkphase:off`) that bring back the old
   behaviour. It changes no number: only where spot B measures from.
2. **The rules were fixed too, not only the computer** (a far Rootmaw's drinking, a Sire's reach, new ground, a grub's
   Rootmaw, swamp mending): they hit a human Brood player on the lower start just the same. Spot A is untouched; spot B
   gets its mirror. The ROOT ghost's IN RANGE for a Sire follows the rule.
3. **One think phase for every computer of a match**, drawn from the seed (a phase per side gives one side a random head
   start; data_fix_v1).
4. **12:00, not 15:00**, to fit three runs of 76 games in the job's time; "won or led" at 12:00 by the studies' 10% rule.
5. **No map edits**: none was needed (every map an exact mirror).
6. **Not changed**: what a rooted creature sees, how far it reaches when it fights, and where the enemy sees it are still
   measured from its feet (the fog's stamp at the feet's cell, Game.find_target, Game.is_visible_to(team, u.position)),
   and the Brood computer's threat sums round the Mother's feet (units_near(q.position), 13 places). These touch the fog
   and combat code of every faction; left for the owner (P1).
7. **The Clockwork's smaller spot edge** (its mirror 1.04 at 5:00 in 11-12, 0-4% at spot A in the cross pairings) was not
   looked into.
8. **The other jobs' code**: the merge with brood-rootmaw-coach (0.38.35) brought new Brood computer checks that measure
   from turtle feet; the two that decide where a turtle goes (_toward_foe and the layout-refused supply turtle's check) are
   made mirror-fair too. The measured runs are on the code before that merge (0.38.30 plus this fix); the merged build was
   only run through tools/test_brood_mirror.gd and tools/test_start_layout.gd.

## Proposals

- **P1. The rest of the mid-game lean (1-3% from 4:00).** A follow-up with tools/study/spot_trace.gd (`inc kinds` from
  3:00) on a few games where spot B fell behind, and one experiment at a time behind `fairspot`: a rooted creature's
  sight and attack reach from its anchor (Game fog stamping, find_target), being seen at its anchor
  (is_visible_to for rooted Brood creatures), and the Brood computer's threat sums from the Mother's anchor (_qp). Then
  the 76 games again (about 3 hours on two cores).
- **P2. Player order.** P1 won or led 34 to 19 in the final run (p 0.053), 31 to 28 before: not significant, but the
  final run decided more games (12 to 5). If the next study shows it again, alternate which computer thinks first each
  think (a switch), the order kind of fix.
- **P3. The Clockwork mirror** with the same tool: `python3 tools/study/brood_spot_study.py run OUT --pair cwcw`.
- **P4. A guard**: a test that a Brood alone earns the same at both starts (team 0 with and without `spotswap`, three
  seeds, within 3% at 6:00), so new Brood code that measures from feet is caught.

## Tools and switches

- `spotswap` (measuring switch, scripts/game.gd `_generate_map`): with two players, player 1 takes spot B, player 2 spot A.
- `fairspot:off` (BroodRoot.fair_spot): the Brood's sums from the plain feet again, as before this job.
- `thinkphase:off` (AI.think_phase_on): every computer thinks first at 0:00 again.
- tools/study/brood_spot_study.py (the 38 Brood mirrors plain and swapped; `--root` another checkout, `--pair` another
  pairing), tools/study/brood_spot_report.py (`study`: spot v order, the mirror check, per game, root times; `spots`: any
  win-rate study's spot balance by pairing and faction), tools/study/brood_spot_income.py (spot A's income share per
  minute with its t and sign test), tools/study/spot_trace.gd (two mirrored sides compared unit by unit every tick, `inc`
  for a per-second income line), tools/study/map_mirror_check.gd (the maps' cells against their mirror).
- tools/qa_match.gd now logs each Rootmaw's and Mound Turtle's first rooting (event "root": cell, the cell carried to
  spot A's side, time) and each player's start cell and mirror flip in result.json.
- Data: docs/brood_spot_study/data (0.38.30, 76 games), data_fix_v1 / data_fix_v2 (two partial runs of earlier versions
  of the fix, 24 and 22 games), data_fix (the final fix, 76 games).
