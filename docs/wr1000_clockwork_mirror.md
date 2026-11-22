# WR1000, the Clockwork mirror (wr1000-clockwork-mirror)

The owner, 2026-11-22 01:29: a fresh win-rate study done as "1000 over 10s": 1000 games across six parallel jobs, in
blocks of 10 games, changing ONE thing in the computer's play each block. This job is the Clockwork against the Clockwork
(the mirror), Hard OPTIMAL against Hard OPTIMAL, to 20:00. It copies crown-1000-brood's method (docs/crown_1000_brood.md).
Every change runs only when a Clockwork computer faces a Clockwork (scripts/ai_wr1000_clockwork_mirror.gd, class WkM), so
the sister jobs merge beside it. No balance number was changed.

## Summary

**180 games in 18 blocks of 10** (one game timed out), on main 0.38.124, plus the 10 matching games of ai-opponent-review
(0.38.107) as block 0. Two games at a time on the 2-core machine, about 45 minutes a block.

### The fresh baseline (main as it is)

P1 is always spot A (the top-left start), P2 spot B. "Led" = 10% ahead on income earned + 2 x army at 20:00.

| blocks | games | P1 won / led / even / behind / lost | decided by 20:00 | median defeat (range) | mean g (P1) | g at 14:00 (P1) | P1 income 8:00 / 12:00 of P2's | P1 army 8:00 / 12:00 of P2's | halls at 12:00 P1 / P2 |
|---|---|---|---|---|---|---|---|---|---|
| ai-opponent-review, 0.38.107 (block 0) | 10 | 2 / 0 / 4 / 0 / 4 | 6 of 10 | 13:59 (11:17-17:16) | -0.53 | -0.20 | 0.96 / 0.99 | 0.87 / 1.75 | 3.3 / 3.3 |
| **baseline, main 0.38.124 (blocks 1 + 4)** | **20** | **9 / 2 / 3 / 1 / 5** | **14 of 20** | **13:26 (11:27-16:13)** | **+0.49** | **+0.19** | **1.02 / 1.12** | **0.97 / 3.80** | **3.3 / 2.7** |
| the final defaults: nospr + noeco (blocks 6 + 18) | 20 | 8 / 0 / 5 / 1 / 6 | 14 of 20 | 15:39 (13:22-19:19) | +0.27 | +0.18 | 1.01 / 1.08 | 1.32 / 1.16 | 3.5 / 3.1 |
| with nofeed too (blocks 7, 9, 14, 16; off at the end) | 40 | 9 / 0 / 2 / 2 / 27 | 36 of 40 | 15:15 (12:12-19:48) | -1.07 | -0.39 | 1.02 / 0.92 | 0.90 / 0.29 | 2.9 / 3.6 |

(g = ln of P1's score over P2's; army ratios are geometric means, swung by games where one army is near 0.)

**In one breath**: the fresh mirror is fair between the two starts and finishes 7 games in 10 by 20:00, but a third of
its losses came from a dice throw at 3:00 (the Springer timing or the Economy race against Balanced). The job keeps one
fix: in the mirror OPTIMAL's normal pick is Balanced. With it the games are no more often decided (14 of 20, the same as
the baseline) but they are decided by play: no game is lost to the opening pick, the defeats come later (median 15:39
against 13:26) and the starts stay even (8-6). The one change that made the mirror end almost every game (`nofeed`, 36 of
40) also made spot B win 27 of 36, so it is off.

Read aloud: the mirror finishes most games (14 of 20 by 20:00, most between 12:30 and 14:30); the side ahead at 12:00
went on to win or lead in 17 of the 18 games where one side was ahead: nobody comes back. No spot edge overall: over
blocks 1-13, P1 won 43 and P2 46 (p 0.83), but some maps lean (Cinder Steps r0: spot B won
10 of 13, most of them games where P1's dice picked the Springer timing; Hollowfen r0: spot A won 5 of 8). Two blocks of
the same code differ by about 2 in games decided (block 1: 6, block 4: 8), so a change must beat that.

### What the baseline does wrong (from the logs)

1. **A pick decided by dice loses the game.** OPTIMAL's "normal" pick in the mirror is Balanced 3 / Economy 2 / Springer
   timing 1. The Springer timing, switched to at 3:00, buys HIGH LEAP, a Clock Aviary and a Swift before an army: 240 worth
   at 5:00, 365 at 8:00 against 2,015; it lost all 4 games it was picked in (beaten 11:17-13:31). The Economy race lost all
   7 games it was picked in against Balanced's waves (Hollowfen r0 P2 four times).
2. **The draws are stalls.** After a push that pulled back, the next goes only 1.25 times bigger; under the 200 cap that
   bar can't be met (Greenhold r0, block 1: a push of 7,315 that killed 4,590 for 4,415 asks 9,143; the side sits at the cap
   with 6,000 cogs to 20:00). Every draw had 5-9 such holds per side after 12:00.
3. **Feeding.** An enemy push far stronger than the army at home, standing AT its gathering point, was met by whatever was
   there: 1, 2, 5 units at a time (Greenhold r0, block 4: 62 lost for 13, out at 12:26).
4. **Pushes on a stale reckoning** ("goes out worth 7,040 against the 1,580 it reckons, a report 31 s old") meet the whole
   enemy army on its gears and pull back having lost about 60%.
5. **The end is slow**: the winner takes one Clocktower about every 40 s as one block, 8,500 against 100-275, and the
   loser's last Winders live 2-5 minutes more.

### Every block

The kept set grows: blocks 3-5 have `nospr` on, blocks 6-16 `nospr` + `noeco`, blocks 7, 9, 10-16 `nofeed` too (turned off
again at the end, see below). "Decided" is out of 10.

| block | the change (switch) | on top of | decided | median end | P1 W-L | leader at 12:00 won | mean abs g | kept? |
|---|---|---|---|---|---|---|---|---|
| 0 | ai-opponent-review's games (0.38.107) | | 6 | 13:59 | 2-4 | 6 of 8 | 1.57 | |
| 1 | **baseline** (main 0.38.124) | | 6 | 13:32 | 4-2 | 9 of 9 | 1.62 | |
| 2 | `cap`: the after-a-failed-push bar waived for a full army (180 supply), a full bank (1,500) or 150 s later | base | 8 | 13:43 | 4-4 | 9 of 9 | 2.15 | no (fired in 1 game) |
| 3 | `nospr`: no Springer timing in the mirror's normal pick | base | 7 | 14:15 | 5-2 | 10 of 10 | 1.98 | **yes** (Claude's choice 1) |
| 4 | **baseline again** (the noise) | | 8 | 13:25 | 5-3 | 8 of 9 | 2.07 | |
| 5 | `raze`: a push clearly ahead splits into parties, one at each enemy Clocktower | nospr | 4 | 14:16 | 1-3 | 5 of 6 | 1.06 | no |
| 6 | `noeco`: no Economy race in the mirror's normal pick (Balanced always) | nospr | 7 | 15:41 | 4-3 | 6 of 8 | 1.69 | **yes** (choice 1) |
| 7 | `nofeed`: far weaker than a push at its door, the army gathers at its farthest Clocktower and goes back in together | nospr+noeco | 9 | 14:40 | 6-3 | 9 of 9 | 2.24 | on, then off (below) |
| 8 | `cap` again | nospr+noeco | 4 | 15:40 | 2-2 | 5 of 6 | 1.14 | no |
| 9 | `nofeed` again | nospr+noeco | 9 | 16:57 | 1-8 | 9 of 10 | 2.05 | |
| 10 | `counter`: the counter-push after a held defence (the Brood rule) in the mirror too | +nofeed | 7 | 14:27 | 4-3 | 7 of 7 | 1.82 | no |
| 11 | `mreck`: the enemy reckoned as our own army + its kills - ours | +nofeed | 7 | 14:02 | 4-3 | 7 of 7 | 1.76 | no |
| 12 | `raze2`: `raze` only after a building at the push's goal fell | +nofeed | 8 | 14:41 | 2-6 | 10 of 10 | 1.96 | no |
| 13 | `cap` a third time | +nofeed | 5 of 9 | 15:58 | 1-4 | 7 of 7 | 1.43 | no (and one game hung to the 50-minute timeout) |
| 14 | the kept set again | +nofeed | 10 | 15:12 | 1-9 | 10 of 10 | 2.40 | |
| 15 | `fairfail`: a push that killed 80% of what it lost sets no bar | +nofeed | 8 | 15:40 | 2-6 | 9 of 9 | 1.97 | no |
| 16 | `nofeed` made symmetric (its spot away from the push, not "below" the Clocktower) and sticky (it no longer flips back to defending when the push steps 600 px on) | nospr+noeco | 8 of 9 | 14:43 | 1-7 | 9 of 9 | 2.03 | |
| 17 | `nofeed` with `spotswap` (player 1 on spot B): is it the spot or the player? | nospr+noeco | 7 | 14:21 | 3-4 (player 1 on spot B) | 6 of 7 | 1.82 | diagnostic |
| 18 | **the final defaults** (nospr + noeco) | | 7 | 15:37 | 4-3 | 7 of 8 | 1.75 | (block 6 again: 7, 15:41, 4-3) |

**Kept, on by default** (in the mirror only): `nospr` and `noeco`, together: OPTIMAL's normal pick in the mirror is
Balanced. **Measured and not kept**, off behind their switches: `cap`, `raze`, `raze2`, `counter`, `mreck`, `fairfail`,
and **`nofeed`** (see below). `-- wkm:off` plays the mirror as before this job; `-- wkm<name>:on` turns one on.

### `nofeed`: the most decisive change, and why it is OFF

With `nofeed` on, 36 of 40 games ended by 20:00 (the baseline 14 of 20), every time the side ahead at 12:00 won, and the
games ran later (median 15:15). It looked like the change to keep. But in its four blocks spot B won 27 of 36 decided games
(blocks 9, 14, 16: 3-24), where without it the spots were even (43-46). The side that falls back concedes its gathering
point and the buildings round it, and spot A fell back about four times as often as spot B (block 14: 54 times to 14).
The gathering points are roughly but not exactly mirrored (Greenhold: P1 rests at (34, 30) at 6:47, P2 at (77, 48), whose
mirror would be about (71, 46)), so the rule seems to magnify a small edge in where the two armies wait. Block 17 checks
whether it is the spot or the player order. Until the cause is found it stays off: a mirror that one start wins 3 times in
4 is worse to watch than a draw.

Block 17 played `nofeed` with the starts swapped (player 1 on spot B): player 1 won 3, player 2 (now on spot A) won 4, 7
decided. So it is neither simply the spot nor simply the player order: spot B with player 2 won 24 of 27 decided games in
blocks 9, 14 and 16, and block 7 (the same code) had gone 6-3 the other way. Ten games can't settle it; the proposals say
where to look.

## Claude's choices for the owner

1. **`nospr` and `noeco` were kept without beating the noise on games decided** (7 and 7 against the baseline's 6 and 8).
   They were kept on the pick record instead: the Springer timing lost 4 of 4 and the Economy race 7 of 7 games against
   Balanced in the mirror, both decided by a dice throw at 3:00, not by play. With them the mirror's normal pick is always
   Balanced (a GREEDY read already picked Balanced). The cost: every Clockwork mirror the computer plays now opens the same
   way. The plan matrix of 2026-11-19 put Balanced 3, Economy 2, Springer 1 in the mirror; this data says Economy and the
   Springer timing (as switched to at 3:00) lose there.
2. **`nofeed` turned off at the end** after being on for blocks 7-16, for the spot B edge above, though it decided the
   most games. Its code is kept (with the two fixes of block 16) behind `wkmnofeed:on`.
3. **The measure for a mirror**: "better" was read as more games decided by 20:00 and the side ahead closing it out, with no
   spot edge; not who wins. A block needed to beat the baseline's 6-8 decided by 2 or more, twice.
4. **The Ballista fix** (scripts/ballista.gd): a Spring Ballista's line shot skips a target that is already gone (a SCRIPT
   ERROR "has_tag in base Nil" in 2 of the games, on main too). Not AI, but a one-line guard.
5. 180 games instead of the ~170 asked: the two extra blocks are the spot check and the final defaults.

## Proposals (not built)

1. **Find the spot edge under `nofeed`**: compare the two sides' gathering points (AICwArmy._gather_home) on every parity map
   and make them exact mirrors (as brood-spot-study did with BroodRoot.sym_feet for the Brood); then `nofeed` again.
2. **The Springer timing from the economy opening**: as the mirror switches to it at 3:00 it builds HIGH LEAP, the Clock
   Aviary and a Swift before an army; it should hold its army first, or not be a pick after the economy opening.
3. **A finishing rule that works**: `raze` and `raze2` split too soon or into strength. A push that has broken two
   Clocktowers in a row with nothing seen in a minute could send a party to the farthest one.
4. **The 200 cap and the bank**: in the stalls both sides sit at 180-200 supply with 4,000-14,000 cogs (Ashford r1 block 2:
   14,180). The owner decided no cog sink (2026-11-13); noted only as what the long mirrors look like.

## What is still wrong

- Nobody comes back: in every block the side ahead at 12:00 won or led nearly every game. The defender's gears win every
  even fight at home, so the side that loses the first big fight at its door loses the game.
- Pushes still go out on a stale reckoning and pull back at first sight of the enemy army ("pulls back, killed 70").
- Ashford Crossing r0 and r1 end in a draw or late more than other maps.
- `test_ai_cw_horse_raid` is flaky (failed once on the branch, passed on the rerun and on main).

## The tests

Every tools/test_ai_*.gd (23) on the branch (blocks 10-11's code: the kept set then, nospr + noeco + nofeed; no AI test
plays a Clockwork mirror, so none of the changes act in them): 20 pass; `test_ai_rush_followup` and `test_ai_wall_vs_rush`
fail on main too (as in ai-opponent-review); `test_ai_cw_horse_raid` failed once and passed on the rerun (on main it
passed). The list: docs/wr1000_clockwork_mirror/ai_tests_branch.txt.

## How it is measured

- **The 10 games**: the ai-opponent-review parity games of the Clockwork mirror, the tags and seeds of qa_matches' base
  rounds: Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps round 0 and the first four round 1 (6
  maps; round 1 has another seed). The same 10 every block:
  `python3 tools/study/wr1000_clockwork_mirror.py run <block> --extra <switches> --root <frozen copy>`.
- **A game's score** (P1's view): g = ln((income earned + 2 x army) of P1 / of P2) at 20:00 or at the defeat, the beaten
  side's score counted a quarter. A block: games decided by 20:00, the median minute of the defeats, P1's record, whether
  the side ahead at 12:00 (10% or more) won, the mean of |g| (how clear the results are), P1's g.
- **Report**: `python3 tools/study/wr1000_clockwork_mirror.py report b01 b04 ... [--games]`; one row a block in
  docs/wr1000_clockwork_mirror/blocks.csv (`csv`).
- Data: docs/wr1000_clockwork_mirror/data/<block>/<tag>/ (result.json, story.txt, cwlog.txt = the Clockwork computers' own
  log lines); a block's switches in extra.txt (the kept ones are on by default and not listed there).
