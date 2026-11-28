# crown-mirror-20: the Crown mirror measured to 20:00, and crown-mirror-coach's P1-P4

The owner said yes on 2026-11-28 to measuring the Crown v Crown mirror to 20:00, since crown-mirror-coach's games to 15:00
were too short to judge its proposals P1-P4 (docs/crown_mirror_coach.md, "Proposals"). This job measured the mirror on
main as it is (0.38.229, commit 8e7b2d1a), built P2-P4 behind their own switches (all **off** by default), and measured each
one against the same seeds. **No balance number changed by default. No proposal was kept on.**

## How it was measured

- Hard OPTIMAL Crown v Hard OPTIMAL Crown, every game to 20:00 (a defeat ends it sooner), on the six parity maps, with the
  same seeds as winrate-2026-11-26 (1126001 + i). Tool: `tools/study/crown_mirror_20.py` (modelled on
  `tools/study/winrate_1126_no_brood.py`). Two games at a time on a 2-core machine, about 6-8 minutes a game.
- **The spot split is 15/15.** In a mirror both players are the same computer, so the old rule (P1 always on spot A) could
  not tell a start spot's edge from player order. Here game i puts P1 on spot B when `(i + i // 6) % 2` is 1, with the
  measuring switch `spotswap` (brood-spot-study's): 15 games each way out of 30, 10 each way out of 20, every map 2-3 each way.
- Arms (each the same seeds, games 0-19): `p2`, `p3`, `p4` as below, and **`base2`: the same play again** (this branch with
  every switch off, which plays exactly like main) to show how much two runs of the very same code differ.
- "Won" = the other side beaten by 20:00; "led" = 10% ahead at the bell on income earned + 2 x army (the winrate-2026-11-26
  rule). Data: `docs/crown_mirror_20/data/<arm>/<game>/` (result.json, story.txt, and mirror.txt: the match log's press,
  shelling, finisher and hunt lines; games 0-2 of `base` were run before the finisher's lines were kept).

## The results

| arm | games | decided (median min) | P1 won-led-even-led-won P2 | spot A won or led / spot B (mean g for A, t) | leader at 12:00: finished / kept / turned (of) | halls lost a game | mean abs g |
|---|---|---|---|---|---|---|---|
| main as it is | 30 | 12 (18.5) | 10-4-3-11-2 | 7 / 20 (-0.49, -1.9) | 9 / 13 / 2 (15) | 2.5 | 1.20 |
| main as it is (first 20) | 20 | 7 (18.4) | 6-2-3-8-1 | 6 / 11 (-0.24, -0.8) | 6 / 10 / 2 (12) | 2.4 | 1.08 |
| the same play again (switches off) | 20 | 9 (18.2) | 6-7-2-2-3 | 7 / 11 (-0.25, -0.7) | 5 / 12 / 2 (15) | 2.8 | 1.30 |
| P2 guns' screen (`cm20guns:on`) | 20 | 9 (18.3) | 4-5-0-6-5 | 9 / 11 (-0.37, -1.0) | 7 / 12 / 0 (12) | 2.6 | 1.28 |
| P3 past the gates (`cm20gates:on`) | 20 | 8 (18.1) | 4-8-1-3-4 | 9 / 10 (-0.28, -0.9) | 6 / 12 / 2 (14) | 2.6 | 1.19 |
| P4 fading defence (`cm20fade:on`) | 20 | 5 (18.5) | 2-4-3-8-3 | 9 / 8 (+0.22, 0.8) | 5 / 10 / 1 (12) | 2.4 | 0.90 |

"Leader at 12:00": games where one side was 10% ahead at 12:00; "finished" = that side beat the other by 20:00, "kept" = it
won or still led at the bell, "turned" = the other side won or led.

| arm | presses a game | pressed waves held (log lines) | bombardments (rule 7) | waves past the gates (P3) | income 12:00 (both) | army 12:00 (both) |
|---|---|---|---|---|---|---|
| main as it is | 1.9 | 1.5 | 0.1 | 0.0 | 30.6k | 3.5k |
| the same play again | 1.9 | 1.2 | 0.1 | 0.0 | 30.3k | 3.4k |
| P2 | 1.7 | 1.1 | 0.0 | 0.0 | 30.5k | 3.6k |
| P3 | 1.1 | 1.0 | 0.1 | 0.1 | 30.2k | 3.6k |
| P4 | 1.4 | 0.9 | 0.0 | 0.0 | 30.2k | 3.6k |

Game by game against main's first 20 (the same seeds):

| arm | decided only with the arm | decided only on main | same | sign test p | winning side flipped |
|---|---|---|---|---|---|
| the same play again | 8 | 6 | 6 | 0.79 | 5 |
| P2 | 4 | 2 | 14 | 0.69 | 9 |
| P3 | 6 | 5 | 9 | 1.0 | 8 |
| P4 | 1 | 3 | 16 | 0.62 | 5 |

The finisher (crown-finish, AICrownFinish) fired in 22 of main's 30 games, its first start at a median 16:24; it stopped
8 times because the army it took was lost, 3 times for no target left (the hunt took over), twice for a force at home.
In 3 of main's 30 games the loser had no hall left at 20:00 and was still not beaten (its last buildings and men).

## What it says, in plain words

1. **P1 (measure to 20:00): the mirror does end now, about 40% of the time.** On main 12 of 30 games were decided by
   20:00 (median 18:30), against 2 of 38 at 15:00 in crown-mirror-coach (0.38.38) and 11 of 30 in winrate-2026-11-26. Half
   the games have a clear leader at 12:00, and that leader nearly never loses it (2 of 15 turned); it finished 9 of those 15.
   The games are decided late: main's decided games ended between 16:54 and 19:36, so the undecided ones are mostly
   leaders still knocking down the last halls when the bell rings, plus about one game in five that is truly even.
2. **The noise is large.** The very same code on the same seeds (main against "the same play again") gave the same
   decided/undecided answer in only 6 of 20 games and the other side won or led in 5. Over 20 games, 7 against 9 decided is
   no difference at all. Nothing below is beyond this noise.
3. **P2 (the guns' screen) changed nothing measurable.** Rule 7's bombardment fires about once in ten games (0.1 a game):
   the wave is usually not pulled back under a main's cliff at all; the finisher (built after crown-mirror-coach) now takes
   the army to the halls. With P2 the guns may also take a spot under fire whenever our own men stand around it; 9 decided
   of 20 against main's 7 and the same play's 9.
4. **P3 has nothing left to do.** crown-mirror-coach's P3 (a new hall's guards) is gone in today's code: the Crown's
   doctrine clears the guards (AICrown._guard_new_hall). What was built instead lets a pressed wave past the shared rule's
   other gates; it fired twice in 20 games. The "held" lines in the log come mostly while the finisher already has the
   army. 8 decided of 20.
5. **P4 (the defence fades) did not help: fewer games were decided (5 of 20)** and the finisher fired in fewer games (10
   of 20, against 13 and 16 in the P3 and P2 arms). Palisades and gates that break faster from 12:00 help both sides: the loser's raids
   break the winner's walls too. It is a balance change in any case and stays off.
6. **A spot edge: spot B.** On main, the side on spot B won or led 20 games and the side on spot A 7 (p 0.02); with every
   arm, 60 against 41 (p 0.07); with winrate-2026-11-26's 30 mirror games (P1 always on A: 11 v 17), 77 against 52 (p
   0.03). Player order is not it (P1 54, P2 47). The cause shows in the halls: over all 110 games the side on spot B lays its
   4th hall at a median 10:00 against 13:00 on spot A, its 5th at 15:00 against 21:00 (after 20:00), on 5 of the 6 maps
   (Greenhold 13/10, Dune Sea 13/9, Frostfang 13/11, Ashford Crossing 12/10, Cinder Steps 21/14; Hollowfen 9/10). The
   incomes are even to 12:00 and part from there (16:00: 20.9k against 22.7k earned). The Crown's own hall spot rule
   (AICrown._safe_hall_spot / CrownSites.pick, "the 4th as close as it may be to its other halls") most likely picks
   differently on the two mirrored spots, as the Brood's did before brood-spot-study's fix. Not fixed here (no AI change was
   asked for beyond P1-P4): see choice 4.

## The switches (all off; scripts/ai_crown_mirror_20.gd, AICm20)

| switch | what it does | where |
|---|---|---|
| `cm20guns:on` | P2: with no gun spot out of reach, the wave's line stands 120 px before its guns toward the hall and the guns shell the hall from behind it; and a gun's spot under fire is taken whenever 4+ of our armed men stand within 230 px of it | `AICrownMirror.bombard`, `_spot_for`; `AICm20.screen_spots`, `screened` |
| `cm20gates:on` | P3: while the press finds the side ahead (the last 12 s) and the bar is met, the wave goes past the shared rule's other gates (regroup, timing, kit, round 5, the wave's worth, the defence, the screen riders); not with a force at our buildings, not for the Siege push | `AI._press_go` (base: false), `AICrown._press_go`, `AICrownMirror.press_go` |
| `cm20fade:on` | P4 (BALANCE, every side): from 12:00 to 16:00 the damage palisades and gates take rises to 1.75 times | `Entity.take_damage`, `AICm20.wall_k` |

Shared code touched (for the merge): `scripts/ai.gd` (the wave's go line: `... or _press_go(ready)`, false unless P3 is on),
`scripts/entity.gd` (`take_damage`: one line, only with `cm20fade:on`), `scripts/ai_crown.gd` (`_press_go`),
`scripts/ai_crown_mirror.gd` (`bombard`, `_spot_for`, `press`, `press_go`; `_held_by` now also names the kit, the swarm and
the wave's worth: a log line only). With every switch off the play is main's.

## Tests

`tools/test_crown*.gd` on this branch, 23 tests: 22 pass (ammo, balloon, balloon_coach, build_order, build_stack,
defence, farms, finish, gate, ghosts, hold, line, lost_hall, mill_crew, mirror, owner_eco, powder, rider_screen, siege,
stall, v_brood, v_clock); test_crown_dragoon_raid fails its "[plan] ... a group out by 690 s (formed true, rode false)"
check, the same on main (8e7b2d1a), known since crown-mirror-coach.

## Claude's choices (for the owner to confirm)

1. **Nothing kept on.** P2, P3 and P4 are left off: none raised the decided games beyond what the same code does on a second
   run, and none removed the spot edge. They stay as measuring switches; tell me to delete them instead.
2. **P1 needs no switch**: it was the measure itself. Its answer: the mirror ends in about 40% of the games by 20:00 and a
   leader at 12:00 almost always stays ahead; the rest are late finishes and a few truly even games. 20:00 is a fair length
   for this mirror; 25:00 would tell whether the undecided leaders would finish.
3. **P3 was rebuilt** because its target (the new hall's guards) no longer exists in the Crown's code; "the pressed wave
   goes past the other gates" is the nearest thing in today's code. It hardly ever fires: the finisher made it moot.
4. **The spot edge is the thing to work on next**: a job like brood-spot-study for the Crown (trace the 3rd/4th hall picks
   on both spots of each map, look for a pick that scores mirrored spots differently, fix it behind a switch, measure).
   I recommend it before any other mirror change; it is an AI fault, not balance.
5. **The spot split by `spotswap`** (15/15) instead of P1 always on spot A: it is what tells the spot from player order;
   the seeds are winrate-2026-11-26's, so the two can be set beside each other.
6. **P4's numbers** (12:00 to 16:00, up to 1.75x, palisades and gates only, every side) were my pick for a first look;
   it made the games closer, not shorter. If the owner wants the defender's advantage to fade, I would look at the gate's
   hit points or the repair rate in a balance job of its own rather than this.
7. **"The same play again" was run instead of P2 + P3 together**: P2 and P3 each fired too seldom for a combined arm to say
   anything, and the noise of the same code on the same seeds was the number needed to read the others.
