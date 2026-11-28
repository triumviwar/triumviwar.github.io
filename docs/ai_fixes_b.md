# AI fixes B: the Crown's hall below its high ground, and stuck guns and wagons (job ai-fixes-b)

The owner said yes on 2026-11-28 to two proposals of the AI opponent review (docs/ai_opponent_review.md): the Hard Crown
should defend its own hall below its high ground instead of watching it from above, and the Crown's guns and wagons
should stop getting stuck. No balance number changed. Each fix has its own switch.

## What you will notice

- **Field Cannons, Mortars and Powder Wagons no longer stand stuck for good** at a gate in a diagonal palisade, in a
  one-cell lane between buildings, or by a staircase cliff edge. When one is stuck there, its horse team draws in toward
  the gun so it can turn, and lets out again once there is room. For a moment the horses may overlap a wall or a
  building corner while folded; then the team is long again.
- **A gun or wagon walled out by its own palisade** (a natural whose ring is closed, or whose gate is shut) goes to the
  nearest place it can reach and stops, instead of pressing against the wall for the rest of the game.
- **The Crown computer goes down to its own Town Hall below its main** when its army at home is worth as much as the
  force attacking the hall. Before, it waited for a clear edge (1.3 times the force, 2 times against the Brood) and could
  watch the hall burn. It gathers first, out of the enemy's reach, and goes in together, not man by man down the ramp.

## 1. The stuck guns and wagons

### How it was counted

A new measure in `tools/qa_match.gd` (`tools/afb_watch.gd`, result.json "afb"): every Field Cannon, Mortar and Powder
Wagon, every second it has somewhere to go (a move or attack-move order more than 48 px from its point, or a target
out of reach; not waiting for its path, not packing or deploying). A **stuck second** is one where it moved less than
6 px in the last 2 s, as `tools/test_pathing_match.gd` counts it. Runs of 10 s or more are kept with the ground round
the gun (21 x 21 cells) and, from the second version of the watch on, the gun's heading, its next waypoint, whether its
body and its team are clear where it stands and toward the waypoint, and the units pressing on it.

### What was wrong

Before anything was changed, the 270 win-rate games of 0.38.221 (docs/winrate_2026_11_26) had 123 guns and wagons
stuck 30 s or more on a move order (54 Field Cannons, 48 Powder Wagons, 21 Mortars). By the ground round them:
**61 at a palisade or its gate**, **59 between buildings** (the one-cell lanes of the Crown's base layout), 3 by a cliff.

`tools/test_wheels_replay.gd` lays each of those 123 spots again on open ground (the buildings, walls, gates, cliffs
and fields as they were, the other units left out) and sends the same gun or wagon to the same goal, facing 4 ways,
with one horse and with three. **31 of the 123 spots got a trial stuck for good** (89 of 984 trials) with the old
code. The traces showed three causes:

1. **The team cannot turn.** A limbered gun is the barrel; its horses stand ahead of it along its heading, and the whole
   line (up to about 80 px with a team of three) must be clear of walls, cliffs and buildings for any step or turn
   (`Unit._tow_clear`). Round a tight bend no heading was clear, so it kept its heading and its step was refused, for
   good. The bends: a gate in a diagonal palisade (the wall a staircase of pieces, the gate two cells deep), the turn
   out of a one-cell lane between two buildings, the steps of a diagonal cliff edge (Dune Sea's main, filmed and traced:
   a Crown game there had its guns stuck 796 of 2,297 moving seconds round the cells 90,61 to 93,59). Teams of three
   horses were stuck far more often than single horses.
2. **No slip round a corner.** A man's step that hits a corner tries the step turned 35 and 63 degrees
   (`Game._resolve_terrain`, the pathfinding job); a limbered gun only slid along x or y, then stopped.
3. **Walled out by its own palisade.** A soldier who cannot walk to his goal is given a path up to the wall in the way,
   to break it (`Game.find_path`'s siege fallback). Guns and wagons were given it too. A gun outside its own walled
   natural, its ring closed or its gate shut, was sent into its own palisade and pressed at it for good (Ashford
   Crossing, 13 runs of a gun or wagon stuck 10-40 s at the same diagonal wall in one game).

Crowds also stuck the light Powder Wagon (mass 1: 24 of its own men pushed it about, 288 of push) and squeezed the
guns, but crowds come and go: none of those runs could be replayed without them.

### What changed (switch `afbwheels:off` for all three)

1. **THE TEAM FOLDS IN** (`Unit._tow_fold_tick`, `tow_fold` 0..1): stuck while trying to move, the line of horses
   checked ahead of the barrel shrinks over `TOW_FOLD_T` 1.2 s to the shaft horse (and narrower), so the gun can turn
   and go; moving again, it lets out as far as the ground allows (it lets out only where the longer team is clear, so it
   never pops back into a wall).
2. **ROUND A CORNER**: `Unit._tow_resolve` tries the same turned steps as a man (`Game.CORNER_SLIP`) before it stops.
3. **NO SIEGE PATH FOR A LIMBERED GUN OR WAGON**: walled out, it walks to the nearest place it can reach and stops
   (`Unit.compute_path`: siege only for units that are not workers and not limbered guns or wagons).

### The numbers

| test | old code | new code |
|---|---|---|
| the 123 stuck spots of the study games replayed, 8 trials each (tools/test_wheels_replay.gd) | 31 spots, 89 of 984 trials stuck | 0 spots, 0 trials |
| 12 spots of this job's own first games, 16 trials each | 10 spots, 28 of 192 stuck | 0 |
| test bed: four of the spots, a gun or wagon with three horses, four headings (tools/test_pathing.gd `wheels_*`) | 11 of 16 fail | 16 pass |
| test bed: walled out by its own palisade (`wheels_walled_out/guns`) | pressed 16.8 s of 20, order still on | stops, 0 s |

In real games: **Hard OPTIMAL v Hard OPTIMAL to 20:00, the Crown against the Brood and against the Clockwork, 20 games a
matchup and arm, the same games each arm** (seed 2811001 + i, the six parity maps, the Crown on spot A then B;
`tools/study/ai_fixes_b.py`, data docs/ai_fixes_b/data/off and on). "off" is both fixes off, "on" both on.

| the Crown's guns and wagons | v Brood off | v Brood on | v Clockwork off | v Clockwork on |
|---|---|---|---|---|
| guns and wagons that took the field | 217 | 214 | 244 | 225 |
| seconds with somewhere to go | 26,417 | 31,164 | 32,440 | 32,693 |
| stuck seconds (share of those) | 2,389 (9.0%) | 1,800 (5.8%) | 6,639 (20.5%) | 1,795 (5.5%) |
| stuck seconds a gun | 11.0 | 8.4 | 27.2 | 8.0 |
| stuck 10 s or more (runs) | 53 | 34 | 184 | 10 |
| stuck 30 s or more | 21 | 3 | 76 | 2 |

In plain words: against the Clockwork a Crown gun used to stand stuck a fifth of the time it was meant to be moving;
now about one twentieth, and long stops (30 s or more) went from 76 to 2 in 20 games. Against the Brood the share fell
from 9% to 6% and long stops from 21 to 3. Most of the stuck seconds left are short shoves in crowds (the Powder
Wagon among its own men) and one spot at Ashford Crossing's walled natural (three runs of 35-52 s).

The first "on" arm (data/on_v1, 15 games, before the walled-out fix) is kept: it had 8.0-8.6% stuck and 15 runs of 30 s
or more against the Brood; the walled-out fix took most of those.

## 2. The Crown's hall below its high ground

### What was wrong

The Crown computer on Normal and up holds its main (the owner's doctrine, `scripts/ai_crown_hold.gd`): its army at home
stands at the top of its ramp (the ramp post) or at its walled natural's gate (the gate post), and goes down to a force
below only when it is worth `BEAT` times the force (1.3; against the Brood `AICrown.HOLD_BEAT_BROOD` 2.0, because in the
open a value count flatters a musket line against a swarm). That is right for a force walking about below. It is wrong
for a force razing one of the Crown's own Town Halls below the main: the review saw the Hard Crown watch 1,520 of the
novice's army take a hall below from the top of its ramp with 1,863 of its own ("goes down only at 1,978"). In the 270
win-rate games of 0.38.221 the Crown held the top or the gate while BIGGER than the force below in 79 of 228 such lines
(a hall lost within two minutes after 26 of them). In this job's 20 Crown v Brood games with the old code: 91 holds, 31
of them while bigger than the force; 68 fights at a hall below, 38 halls below lost.

And when it did go down, `AI._defend` sent detachments sized to 1.5 times the force, nearest first, each walking from
where he stood: with an army of 1.2 to 1.5 times the force everyone went, one after another, down the ramp (a trickle).
`AICrownDefence.muster` (gather out of reach, then go in as one) only took over below 1.2 times the force.

Against the Clockwork the hold doctrine and the muster are both cut (`AICrownRules.CUT`, crown-rule-cleanup: measured
as harm there), so this case does not arise in that matchup: the Crown meets a force at its halls straight away with
`AI._defend`. With the old code it won 91 of its 107 fights at halls below there and lost 13 halls in 20 games.

The match logs show it plainly: the gate post holding while the natural's hall or a hall outside the wall was hit
("holds the gate of its walled natural: against the force outside (1034) its army (1828) goes out only at 2069",
Greenhold 12:31, seed 2811001; that hall fell 2:30 later). The two films made of that game (`tools/shot_ai_match.gd`,
fights and coach mode) did not play the same: a match is not the same twice (docs/pathfinding_audit.md), and in the
films the army was out on its siege push when the halls were hit. The cause was found from the logs and the watch's
fight records instead (and the guns' from the watch's traces and the replays).

### What changed (switch `afbhome:off`)

- **ITS OWN HALL BELOW** (`AICrownHold.low_hall`, `_beat(spots)`): a threat within `HALL_R` 12 tiles of one of the
  Crown's own built Town Halls below the main's level lowers the bar to go down to `HALL_BEAT` 1.0 (an even fight), at
  the ramp post and at the gate post. The cliff edge post still shoots from above where it covers the hall. The log
  says "goes down to its hall below as one body".
- **AS ONE BODY** (`AICrownDefence.muster`): against a force at such a hall the muster takes the army up to
  `HALL_BODY` 1.6 times the force (just over `AI.DEF_MARGIN` 1.5): it gathers out of the enemy's reach and goes in
  together (its log line: "gathers to go down to its hall below as one body").

### The numbers (the same 20 + 20 games)

| the Crown's halls below its main | v Brood off | v Brood on | v Clockwork off | v Clockwork on |
|---|---|---|---|---|
| held the top or the gate while bigger than the force (story lines) | 31 of 91 | 21 of 112 | - | - |
| went down to a hall below it would have watched ("goes down" lines) | - | 39 | - | - |
| fights at a hall below (200+ of enemy army near it) | 68 | 86 | 107 | 108 |
| of them won (hall standing, the enemy lost more) | 26 | 35 | 91 | 94 |
| halls below lost in them | 38 | 46 | 13 | 12 |
| all halls lost, before 15:00 / in all | 14 / 47 | 13 / 62 | - / 13 | - / 13 |
| halls held at 16:00 (average) | 4.07 | 4.44 | 6.44 | 6.20 |
| army at 16:00 (average) | 1,459 | 2,075 | 3,025 | 3,316 |
| result: won / led / even / behind / lost | 5 / 5 / 0 / 3 / 7 | 4 / 4 / 0 / 7 / 5 | 8 / 7 / 3 / 2 / 0 | 9 / 6 / 3 / 1 / 1 |
| score (income + 2 x army), the same game paired | | +0.00 (t 0.0), 9 better / 8 worse | | +0.00 (t 0.0), 8 better / 6 worse |

In plain words: against the Brood the Crown now goes down where it used to watch (39 times in 20 games); in the fights
where it did, it killed 2.4 times what it lost (54,780 of Brood for 22,660) and kept the hall in 19 of 33. It held more
halls at 16:00 and had a bigger army then. It also lost more halls in all (62 against 47), nearly all after 15:00, when
it had more of them to lose; before 15:00 the same (13 against 14). The results did not move: the same game paired,
the Crown's score is as before in both matchups, well within the noise. Against the Clockwork nothing of the home fix
acts (the doctrine is cut there); its column moves with the wheels fix only.

## Switches

- `-- afbwheels:off` the three wheels fixes off (a gun's team stays full length, no corner slip, the siege path).
- `-- afbhome:off` the hall-below rule off (the old bar, the old muster).
- Measuring: `-- afbdbg:1` prints everything about a gun stuck 10 s (tools/afb_watch.gd).

## Tools

- `tools/afb_watch.gd` (called by `tools/qa_match.gd`, result.json "afb"): the wheels' stuck seconds and runs, the
  Crown's fights at its halls below.
- `tools/study/ai_fixes_b.py run ARM [--jobs N] [--root FROZEN] [--reverse]`, `report [ARM ...]`.
- `tools/test_wheels_replay.gd [-- file=... only=... facings=8 teams=1,3 crowd=1 trace=1]`: the stuck spots of
  docs/ai_fixes_b/wheel_spots.json laid again and driven.
- `tools/test_pathing.gd`: new cases `<map>/wheels_lane`, `wheels_lane_bend`, `wheels_palisade_gate`, `wheels_cliff_base`
  (four headings each) and `wheels_walled_out/guns`.

## Tests run

- tools/test_pathing.gd, all five maps: every new wheels case passes (160 lines); with `afbwheels:off` 11 of 16
  wheels cases and the walled-out case fail. `rim_click_from_low/brood` failed on Greenhold and Kestrel Rise in the full
  run (10 of 11 Raptors arrived) and passed when run alone with the new code too: an order-dependent flake of a Brood case
  that no wheels or hall code touches.
- Gun, horse, gate and defence tests: test_limber_gate, test_gun_mass, test_horse_gate, test_cliff_horse,
  test_stuck_gap, test_wall_stuck, test_haulers, test_cav_gate, test_crown_gate, test_gun_crew_fetch,
  test_crown_hold, test_crown_defence: all pass.
- The AI tests (tools/test_ai_*.gd, 23) on the new code: 21 pass; the 2 known failures fail as on main (test_ai_rush_followup's
  rider checks; test_ai_wall_vs_rush: "Barracks and Powder Mill by 75 s", 100 s), both listed as known in CLAUDE.md.

## Claude's choices

1. **The fold over the art.** While folded the horses are still drawn at full length along the heading, so for a second
   or two they may overlap a wall, a building corner or a cliff edge. The alternative, horses following the path like a
   train, is a larger rework of the towing and its art; the fold gets the gun out now.
2. **TOW_FOLD_T 1.2 s**, and the folded team keeps the shaft horse (radius + 4 px ahead, horse box 9 instead of 13).
   Shorter would make guns squeeze through places a human player expects them to go round.
3. **A walled-out gun stops at the nearest place it can reach** (it does not wait at the gate or look for one): the
   computer's next order takes it on, and a human sees it stop instead of push.
4. **Only limbered guns and wagons lost the siege path.** Soldiers walled out by their OWN palisade have the same
   fallback (they walk up to the wall, and cannot break their own); out of this job's scope, noted below.
5. **HALL_BEAT 1.0** (an even fight) as the review proposed, for every enemy, the Brood too, where the old bar was 2.0:
   at its own hall the walls and buildings are the defender's advantage the value count leaves out.
6. **HALL_R 12 tiles** from the hall's edge: the natural's Farms and Mill round it count as the hall.
7. **HALL_BODY 1.6**: the muster now covers the range where AI._defend would have sent every man from where he stood.
8. **The hall-below rule stays ON** though the Crown lost more halls in all against the Brood (62 against 47 in 20
   games, after 15:00, with more halls held at 16:00 and the results unchanged): the owner asked for the behaviour, and
   the fights it chose it won 2.4 to 1. `afbhome:off` takes it back.
9. **Not against the Clockwork's cuts.** The hold doctrine and the muster stay cut against the Clockwork
   (crown-rule-cleanup measured them as harm there); the hall-below rule lives inside them, so it does not reach that
   matchup, where the Crown already won 85% of its fights at halls below.
10. **20 games a matchup and arm, both fixes in one "on" arm**: the two fixes touch different things (the wheels' stuck
    seconds, the home fights), so they were measured together to save time; the switches let them be split.

## Left open

- The light Powder Wagon is pushed about by its own crowd (mass 1, a gun's is 12); a heavier wagon would hold its line.
- One spot at Ashford Crossing's walled natural still stopped a gun 35-52 s three times in one game (the team clear,
  the step refused); not reproduced without its crowd.
- Soldiers walled out by their own palisade walk up to it to "break" it (choice 4).
- The Crown's late halls against the Brood: more held at 16:00 and more lost after 15:00 with the hall-below rule;
  worth a look at its fourth and fifth halls' guards (the economy gap the Brood micro and battle-matrix jobs found is the
  bigger story).
