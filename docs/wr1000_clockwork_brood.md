# WR1000, the Clockwork v the Brood (wr1000-clockwork-brood)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games over six parallel jobs, in blocks
of 10 games, one change to the computer's play each block. This job is the Clockwork against the Brood: Hard OPTIMAL
against Hard OPTIMAL, to 20:00, on the 6 parity maps of ai-opponent-review, the same 10 map, seed and side games every
block. No unit, price or income number was changed: only how the computers play.

## Summary

**170 games (17 blocks of 10) on 0.38.124.** Two blocks of the game as it is (the fresh baseline, and its noise), then
one change a block. One change is KEPT, on by default against the Brood: **`owls`** (the Clockwork lays a Mainspring at
every Clocktower for the Tension, and against the Brood's Spitters it lays its Clock Aviary at once and turns Swifts into
Ticking Owls, which Spitters cannot spit at). Everything else is OFF behind its switch.

### The fresh baseline (main, 0.38.124: blocks 1 and 2, 20 games)

From the Clockwork's side; "the Brood won" = the Clockwork lost.

| Clockwork v Brood, Hard OPTIMAL both, to 20:00 | 20 games (b01 + b02) |
|---|---|
| Clockwork won (the Brood beaten) | **7** (35%), at 13:03-18:48 |
| Clockwork led at 20:00 (10%+ ahead) | 3 |
| even at 20:00 | 1 |
| Brood led at 20:00 | 3 |
| Brood won (the Clockwork beaten) | **6** (30%), at 14:05-19:54 |
| won or led: Clockwork / Brood | **10 / 9** |
| mean g (ln of the score ratio, the Clockwork's view) | +0.18 (block 1 +0.23, block 2 +0.13) |
| g at 14:00 | +0.14 |
| income at 8:00 / 12:00, the Clockwork's of the Brood's (median) | 1.26 / 1.18 |
| army at 8:00 / 12:00, the Clockwork's of the Brood's (median) | 1.62 / 1.06 |
| halls at 12:00: Clocktowers / the Brood's grounds (mean) | 3.8 / 3.9 |

The matchup is **even**: 7 wins to 6, 10 won or led to 9. The Clockwork earns about a quarter more and has 1.6 times the
army at 8:00, then the armies are even by 12:00 and the game is decided in one or two big fights between 10:00 and 14:00.
When the Clockwork loses, it loses its whole army in a minute to the Brood's **Spitters** (they made 75-85% of its losses
in those fights): its army was ~90 Clock Soldiers with 3-9 Pendulums and 1-3 Springers, because it ran its 4 Clocktowers on
**2 Mainsprings** all game and had no Tension for anything else. When the Brood loses, it fed 100-300 Raptors to the
Pendulums.

### Every block

The score is the Clockwork's (a Brood change is better when it goes DOWN). "v pool" is paired game by game against the
pooled blocks of the code the change was added to: the baseline (b01+b02) for blocks 3-10, the kept `owls` code
(b04+b10+b15) for blocks 11-17.

| block | change (switch) | side | mean g | CW won / led / lost | v pool: d (t), better/worse | g 14:00 | kept? |
|---|---|---|---|---|---|---|---|
| b01 | none: the baseline | | +0.23 | 3 / 3 / 3 | | 0.29 | |
| b02 | none: the baseline again (the noise) | | +0.13 | 4 / 0 / 3 | -0.10 (-0.1) v b01, 4/5 | -0.01 | |
| b03 | `springs`: a Mainspring at every Clocktower | CW | +0.17 | 4 / 1 / 3 | -0.01 (0.0), 5/4 | -0.05 | no |
| b04 | `owls`: springs + the Aviary and Owls against Spitters | CW | +0.57 | 6 / 0 / 4 | +0.39 (0.5), 6/3 | 0.18 | (run again) |
| b05 | `sire`: the Brood's Sire with no nest gets one | Brood | -0.20 | 2 / 3 / 4 | -0.38 (-0.6), 4/5 | 0.11 | (run again) |
| b06 | `table`: the Brood's army reckoned as these games had it | CW | +0.21 | 4 / 1 / 3 | +0.03 (0.1), 7/3 | 0.19 | no |
| b07 | `sire` again | Brood | +0.47 | 4 / 3 / 3 | b05+b07: -0.04 (-0.1), 4/6 | 0.19 | no |
| b08 | `brace`: from 8:00 to 16:00 push only as a counter | CW | +0.19 | 2 / 6 / 2 | +0.01 (0.0), 5/3 | 0.15 | no |
| b09 | `stuck`: a stuck written build hands over after 20 s | CW | +0.06 | 3 / 3 / 4 | -0.12 (-0.2), 6/4 | 0.21 | no |
| b10 | `owls` again | CW | +0.87 | 5 / 2 / 1 | b04+b10: +0.54 (1.1), 5/4 | 0.20 | **KEPT** |
| b11 | `pends`: a Pendulum for every 3 others, up to 12 | CW | +0.76 | 6 / 1 / 3 | +0.04 (0.1), 5/4 | 0.20 | no |
| b12 | `works`: the 2nd and 3rd Light Works by 4:00 / 6:30 | CW | -0.02 | 2 / 4 / 3 | -0.74 (-1.6), 4/6 | 0.01 | no |
| b13 | `owlsmore`: Owls sooner and more of them | CW | +0.17 | 4 / 2 / 4 | -0.55 (-1.0), 5/5 | 0.13 | no |
| b14 | `brace` on top of the owls | CW | +1.09 | 5 / 3 / 1 | +0.37 (0.6), 4/6 | 0.36 | (run again) |
| b15 | none: the kept `owls` alone, a third time | | +0.73 | 5 / 1 / 1 | v baseline: +0.55 (0.9), 6/4 | 0.14 | (the kept code) |
| b16 | `sire` on top of the owls | Brood | +0.54 | 4 / 2 / 2 | -0.18 (-0.2), 4/6 | 0.21 | no |
| b17 | `brace` on top of the owls, again | CW | +0.82 | 5 / 3 / 2 | b14+b17: +0.24 (0.6), 4/6 | 0.37 | no (just under) |

**The kept code against the baseline** (the same 10 games):

| | baseline (b01+b02, 20 games) | **kept: `owls` (b04+b10+b15, 30 games)** |
|---|---|---|
| Clockwork won / led / even / behind / lost | 7 / 3 / 1 / 3 / 6 (of 20) | **16 / 3 / 0 / 5 / 6 (of 30)** |
| Clockwork won, share | 35% | **53%** |
| Clockwork lost, share | 30% | **20%** |
| mean g | +0.18 | **+0.72** (+0.57, +0.87, +0.73 a block) |
| paired, game by game | | +0.54 (t 1.1), 5 better / 4 worse |
| g at 14:00 | +0.14 | +0.18 |
| income at 8:00 / 12:00 of the Brood's (median) | 1.26 / 1.18 | 1.31 / 1.25 |
| army at 8:00 / 12:00 of the Brood's (median) | 1.62 / 1.06 | 1.84 / 1.24 |
| Mainsprings a game | 2-3 | 4-6 (1-2 where it lost early) |
| most Springers at once (a game) | 1-12 | 3-26 (median 15) |
| Ticking Owls | only in the Owl raids build (2 games of 10) | in 6-7 games of 10, 2-10 at once |

Every block of the kept code (+0.57, +0.87, +0.73) scored above both baseline blocks (+0.23, +0.13). At 14:00 the two
codes are level (+0.18 against +0.14): the gain comes in the late fights. With the Tension the Clockwork's army is no
longer all Clock Soldiers (Springers out-range the Spitters by 5 px, the Owls are out of their reach), its army holds at
12:00 (1.24 of the Brood's against 1.06) and it beats the Brood more often from 14:00 on (16 of its 30 games, 12:27-19:35).
The Brood still wins 1 game in 5 (6 of 30, at 10:21-18:17; the two before 11:30 where the Clockwork's opening went wrong).

**What this means for the owner**: on 0.38.124 the Clockwork v Brood is even between the computers (7-6). With `owls` on
the Clockwork computer wins it about half the time and loses one in five. The Brood computer did not get better in this
job: its only change (`sire`, a real bug fix) measured within the noise (below).

## Claude's choices for the owner

1. **"Better" for a pairing between two computers**: each change is measured from the side it coaches (a Clockwork change
   is better when the Clockwork's score goes up, a Brood change when it goes down), against the pool of the code it was
   added to. A kept Clockwork change makes the matchup lean to the Clockwork; that is the point of coaching a computer, but
   it is not "balance".
2. **The bar**: a block of 10 moves the mean g by about 0.6 on its own (block 2 reran block 1: 4 games changed result). A
   change was kept only when it was up by 0.4+ and stayed there in a second block. `owls` passed in blocks 4 and 10 and a
   third block (15) agreed. `brace` on top of the owls had the best block of the job (b14, +1.09) but its second block (b17, +0.82) brought the pool
   to +0.24 over the owls with 4 games better and 6 worse: under the bar, so it is OFF (proposal 4).
3. **`owls` brings `springs`**: the kept switch also lays the Mainsprings (`springs`). Springs alone was tried once
   (block 3: +0.17, no gain), so the two cannot be cleanly separated; most of the effect may be the Springers the Tension
   pays for, with the Owls in about 6 games of 10. `wkbowls:off` turns both off; `wkbsprings:on` alone is the Mainsprings
   without the Owls.
4. **`sire` is left OFF though it fixes a real bug** (the Brood's Venom Sire standing unrooted beside the Mother all game,
   no Spitters at all, 1,000-2,700 food banked): in three blocks (b05, b07, b16) it moved nothing beyond the noise. It
   should be ON for every matchup (it is not about the Clockwork): proposal 1.
5. **The changes act only in this pairing**, in their own file (scripts/ai_wr1000_clockwork_brood.gd), with one- or two-line
   hooks in the shared AI files (ai.gd +5 lines, ai_clockwork.gd +11, ai_cw_army.gd +4, ai_cw_brood.gd +3, ai_brood_new.gd +3),
   so the sister jobs merge beside it.
6. **170 games (17 blocks), as planned**: two games at a time on the 2-core machine, a block took 27-40 minutes.
7. **Block 11 was restarted** (I froze the next block's copy over it by mistake while it ran; its two games in play were
   thrown away and the block run whole again) and block 12's first two games were run again for the same reason. No
   block mixes two codes.

## The changes, one by one

What was seen, what changed, what it did. All gated to the Clockwork computer facing the Brood unless said.

- **`springs` (b03, not kept alone; part of the kept `owls`)**: the baseline ran 4 Clocktowers on 2 Mainsprings (a new one
  came only once the old ones were fatigued, AI._fresh_spring), so Tension sat near 0 and the army was ~90 Clock Soldiers
  and 1-3 Springers at 12:00. From 5:00, every built Clocktower with fresh spring life and no Mainspring drawing on it gets
  one (one laid at a time). Springers at 12:00 went from 1-7 to 8-16; the block scored as the baseline.
- **`owls` (b04, b10, b15: KEPT)**: springs, and once 10+ Spitters have been seen lately the Aviary at once, the Ticking Owl
  research at once, and Swifts kept coming to morph, one Owl for every 4 Spitters seen (up to 10, fewer once the Brood shows
  its flyer-killers: Venom Challengers, the Dilophosaurus, Pterodactyls, Hatchlings, Storm Challengers); a morph's Tension
  is kept from the Springers while Owls are wanted. See the table above.
- **`sire` (b05, b07, b16: not kept; a Brood change)**: traced with tools/wkb_trace.gd on Hollowfen (block 1): the Venom
  Sire hatched at 7:09 and never rooted (rooted false, 5-7 tiles from the Mother, order idle) to 20:00; 110 of the 120
  places on his rings round her were "Blocked: a building or a rooted creature is in the way" (the supply Mound Turtles
  rooted round her), and the computer's own search (AIBroodNew._nb_father_spot) found none. A Sire with no nest fertilises
  no eggs, so AIBroodVCw laid Raptors only: 88 Raptors, 0 Spitters, 1,000-2,700 food banked from 9:00. Now a Sire with no
  nest for 12 s makes a supply Mound Turtle near his best ring get up and walk 9 tiles out (left alone 25 s, then rooted
  again where there is room) and he nests where it stood. It fired in 3-5 games a block and the Spitters came (the
  Brood's Spitters killed 623 of the Clockwork in b05 against 379-513); the results: b05 -0.38 for the Clockwork, b07
  +0.29, b16 -0.18: nothing beyond the noise.
- **`table` (b06, not kept)**: the Clockwork's reckoning of the Brood's army has a floor from AICwArmy.TABLES "brood"
  (12:00 2,700); in these games the Brood had 3,805 at 12:00 (median), so pushes "pressed on to finish" on half the truth
  (Dune Sea r0: reckoned 1,795, the Brood had 3,870). The floor became the median of blocks 1-3. No effect (+0.03).
- **`brace` (b08 alone, b14 and b17 on the owls)**: most of the Clockwork's fighters died in the middle of the map
  (9:00-15:00), its push meeting the Brood's Spitter wave in the open (Frostfang r1, block 2: the Brood attacked at 10:44,
  the push went at 10:46 and came back with half). From 8:00 to 16:00 the push goes only as a counter (AICwArmy._counter_ok:
  a Brood wave just broken on its gears) or at the supply cap. Alone (b08) it turned decided games into small leads at the
  bell (won 2, led 6, lost 2; mean g as the baseline). On the owls: b14 +1.09, b17 +0.82; pooled +0.24 over the owls (t 0.6), 4 games better and 6 worse, g 14:00 +0.19
  (t 1.5), won or led 8 of 10 in both blocks (the owls 6.3), lost 1 and 2 (the owls 2). Under the bar: OFF.
- **`stuck` (b09, not kept)**: a written build that does no step for 60 s with 1,000 cogs banked hands over to the shared
  rules (AIClockwork._stuck_hand_over); against the Brood that fired 17 times in blocks 1-6, 15 of them in the Owl raids
  build at 5:00-7:15 with 1,000-2,500 cogs banked (Greenhold r0 b06: 1,317 cogs at 6:27, then the Brood's 37 Raptors at
  6:49 killed 32 Winders). Now after 20 s with 450. No effect (-0.12).
- **`pends` (b11, not kept)**: the Pendulums killed the most of the Brood's creatures (~3,100 Raptors and Challengers in
  blocks 1-5); one for every 3 others up to 12 (was 5 and 8). As the owls (+0.04).
- **`works` (b12, not kept)**: one Light Works until 5:10-8:33 in most games (none more until 10:32 in Ashford r1, b09).
  The second from 4:00, the third from 6:30, the Winders and soldiers waiting the few seconds for its cogs. Worse (-0.74).
- **`owlsmore` (b13, not kept)**: the kept Owls sooner and more (from 6 Spitters seen, one for every 3, up to 14). Worse
  (-0.55); the Owls were not more numerous (0-6): the Tension, not the rule, limits them.

## Proposals (not done: numbers or other matchups)

1. **`sire` for every matchup**: a Brood Sire that finds no nest beside the Mother stands idle forever and lays nothing of
   his line. The fix is a bug fix; the numbers here say it neither helps nor hurts the Brood against the Clockwork, but a
   creature standing idle all game is wrong to watch. Better still: keep his nest free when the supply turtles root
   (AIBroodNew's turtle spots should leave the father ring open).
2. **The Clockwork's Mainsprings for every matchup**: 1 Mainspring per Clocktower is the rule (owner 2026-11-15), and the
   computer used half of them. Measure `springs` against the Crown and in the mirror.
3. **Balance, after the coaching**: with `owls` the Clockwork wins this pairing about half the time and loses one in
   five. If that holds in the other jobs' data, the Spitter (165 reach, acid) against Springers (170) and the Owl (no
   Spitter can touch it) is where to look; no number was changed here.
4. **`brace` on the owls, measured more**: holding the push for the counter scored the two best blocks of the job on top
   of the owls (+1.09, +0.82; won or led 8 of 10 both times) but paired game by game it was 4 better and 6 worse, under the
   bar. Two or three more blocks would settle it; if the owner likes how it plays (the Clockwork meets the Brood's wave on
   its gears, then counter-attacks), `-- wkbbrace:on` turns it on, and adding "brace" to KEPT makes it the default.

## What is still wrong

- **The noise**: one block of 10 cannot see a change smaller than about 0.5 in mean g. Most of the changes tried here
  (springs alone, table, stuck, pends, sire) may be small gains or losses this design cannot tell apart.
- **The Owl raids build against the Brood**: the computer sometimes picks it (OPTIMAL's NORMAL read: Pendulums 3, Balanced
  2, Owl raids 2) and in it loses 20-44 Winders before 10:00 on Frostfang and Greenhold (r0): its build gets stuck with
  1,000-2,500 cogs banked while the Brood's Raptors come. It still won or led about as often as the other builds.
- **The Clockwork's early game against the Brood's 6:00-7:00 timing**: one Light Works for minutes, an army of 200-900,
  Winders lost. The changes tried (`stuck`, `works`) did not help.
- **The Brood's Raptors into the Pendulums**: 100-300 a game.
- **AI tests**: see below.

## How it was measured

- **The 10 games**: the 6 parity maps of ai-opponent-review (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen,
  Cinder Steps), then the first 4 again; the start spots alternate and flip on the second pass, so the Clockwork starts
  5 games on each spot. Seeds 11300 + 37 i. Hard OPTIMAL against Hard OPTIMAL, to 20:00. The same 10 every block:
  `python3 tools/study/wr1000_clockwork_brood.py run <block> --extra <switches>` (tags `wkb_<map>_r<round>`).
- **A game's result, from the Clockwork's side**: W won, w led (its score 10% or more ahead at 20:00), = even, l behind,
  L lost.
- **A game's score**: g = ln((income earned + 2 x army) of the Clockwork / of the Brood) at 20:00 or at the defeat, the
  beaten side's score counted a quarter (the crown-1000 rule). A won game is about +2.2, a lost one about -2.0, a game
  that runs to the bell sits between -1.5 and +1. A block's score is the mean g of its 10 games.
- **g 14:00**: the same ratio at 14:00 (the last minute of a side beaten sooner), before most of the decisive fights.
- **The noise**: block 2 reran block 1's code unchanged: mean g +0.23 and +0.13, but 4 of the 10 games changed their
  result (Dune Sea r0 lost then won, Frostfang r1 won then lost): the match is not deterministic, the same seed is
  another game. One block of 10 moves the mean g by about 0.6 on its own. So a change is weighed against the POOLED
  blocks of the code it was added to (each game's numbers the mean of its runs), and kept when its mean g is up by 0.4
  or more with more games better than worse; a change that looks good is run a second time before it is kept.
- **Switches**: every change is `-- wkb<name>:on`; the kept one is on by default (AIWr1000ClockworkBrood.KEPT, the file
  scripts/ai_wr1000_clockwork_brood.gd); `-- wkb:off` plays as before this job; `-- wkb<name>:off` turns one off.
  Every change acts only when a Clockwork computer faces a Brood (or, for `sire`, a Brood computer faces a Clockwork).
- **Each block's code** was a frozen copy of the branch (tools/study/freeze_copy.sh), so editing the next change never
  touched a block under way.
- Data: `docs/wr1000_clockwork_brood/data/<block>/<tag>/` (result.json, story.txt, cwlog.txt: the Clockwork's own match
  log lines; extra.txt = the block's switches); `docs/wr1000_clockwork_brood/blocks.csv` one row a block. The full
  match logs were kept outside the repo (too big).
- `tools/wkb_trace.gd` (new, a measuring tool): qa_match with a line every 10 s for each side: the Brood's Sires (rooted?
  how far from the Mother? near enough? researching?), its food and spoils and its creatures by kind, and when a Sire
  stands unrooted, why no nest round her is free (the place_problem answers counted) and what the computer's own
  search says; the Clockwork's Tension and army by kind.

## AI tests (tools/study/run_ai_tests.sh)

Before (main 0.38.124, docs/wr1000_clockwork_brood/ai_tests_before.txt) and after (this branch, `owls` on,
ai_tests_after.txt), 23 tests:

- Fail both times: test_ai_rush_followup, test_ai_wall_vs_rush (as in ai-opponent-review).
- test_ai_rush failed before and passed after (Crown v Brood, flaky).
- test_ai_expand [clockwork] (a Clockwork against an idle Brood) failed after; run alone it PASSED with the job's code and
  FAILED with `-- wkb:off`: flaky (as CLAUDE.md notes), not this job.
- test_ai_scout_sentry (Clockwork v Crown) failed after, 3 runs of 3, also with `-- wkb:off`; main passed 3 of 3; main with
  only this job's script preloaded passed. None of this job's rules acts against the Crown, so the change is in the
  match's timing (the test sits close to its line: alive 144-147 s on the branch, 168-176 s on main); CLAUDE.md already
  lists it as flaky. Worth a look by the next AI job.

