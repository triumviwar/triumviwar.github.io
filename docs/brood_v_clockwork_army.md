# The Brood computer against the Clockwork: its army (job brood-v-clockwork-army)

Short sentences, to be read aloud.

The owner (2026-11-19 07:26), on the Brood computer losing to the Clockwork computer with every plan (1 of 72 won or led
in docs/plan_matrix_brood.md): "Why does it lose to clockwork this easily? Is it making enough spitters?"

## The short answer

No, it was not making enough Spitters. Against the Clockwork it laid Raptors, almost only Raptors, and threw them at the
Clockwork's base in small waves. The Pendulums ate them.

- By 12:00 a Balanced Brood lost **220 Raptors a game and 6 Spitters**; **133 of those Raptors died to Pendulums**. At
  8:00 it had a median of 26 Raptors and **1 Spitter**; at 12:00 45 Raptors and 0 Spitters. (16 games on 0.38.81, below.)
- The units are not the problem. At equal cost, in a controlled fight, the Brood beats the Clockwork's army with almost
  anything early, and with Spitters, Venom Challengers or Brutes late. Raptors are the one thing that loses late: against
  the Clockwork's army from about 9:00 (Pendulums and SHIELD WALL) they kill a third of what they lose.
- Three things in the Brood computer made it lose:
  1. **The mix.** Its rule laid one Spitter for every two Raptors at most, and only while the Venom Sire stood rooted by
     the Mother and was not researching.
  2. **No spoils for Spitters.** A Spitter egg costs 5 spoils. Against the Clockwork the computer kept its spoils for
     her growth and never offered Raptors up for Spitters (it did that only against a wall). So it could not lay them.
  3. **The waves.** Against the Clockwork it had a special rule: small waves (14 supply) from 5:00, sent with only 0.3
     of the biggest Clockwork army it had seen. A median wave left with 0.75 of the Clockwork's army and came back with
     57-70% lost, into a base where Winders mend and units come out at a few seconds' notice.

After the fix (scripts/ai_brood_v_cw.gd, only against the Clockwork, no unit number changed):

| Brood v Clockwork OPTIMAL, 16 games to 20:00 (4 maps x both spots) | before (0.38.81) | after |
|---|---|---|
| OPTIMAL: won or led (W-D-L) | 0 (0-2-6) | **4 (4-1-3)** |
| Balanced: won or led (W-D-L) | 0 (0-2-6) | **2 (2-1-5)** |
| both: better / worse, game by game (same map, seed and spot) | | **11 / 5** (sign test p 0.21) |
| Raptors lost by 12:00 a game (OPTIMAL / Balanced) | 128 / 220 | **50 / 110** |
| Raptors killed by Pendulums by 12:00 (OPTIMAL / Balanced) | 41 / 133 | **8 / 42** |
| Spitters standing at 12:00, median (OPTIMAL) | 6 | **72** |
| army ratio Brood / Clockwork at 10:00 / 12:00 (OPTIMAL) | 0.46 / 0.34 | **0.78 / 0.90** |
| income ratio at 12:00 (OPTIMAL / Balanced) | 0.74 / 0.79 | 0.79 / 0.81 |

The Brood now wins some games against the Clockwork computer (6 of 16, none before) and is better in 11 of 16 paired
games. It is not even yet: it still loses 8 of 16. CROWN_MIRROR_LINE

## 1. The question, with numbers

### The army mix over time (before, 0.38.81)

Median count of each kind standing at each minute, 8 games each (tools/qa_match.gd now writes the army's kinds every
minute: `kinds` in result.json). From `tools/study/brood_v_cw_army_report.py`:

| Balanced | 6:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Raptors | 11 | 26.5 | 17 | 45 |
| Spitters | 0 | 1 | 3.5 | 0 |
| Challengers, Brutes, Toads | 0 | 0 | 0 | 0 |
| army, Brood / Clockwork | 0.75 | 0.57 | 0.44 | 0.44 |

| OPTIMAL (opens a Raptor rush on a GREEDY read, then Timing) | 6:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Raptors | 24.5 | 23 | 25.5 | 31.5 |
| Spitters | 0 | 3 | 4 | 6 |
| army, Brood / Clockwork | 0.89 | 0.46 | 0.46 | 0.34 |

The written Spitter timing plan (in the plan matrix) made Spitters, about 23 lost a game, and still lost: its waves went
with 0.57 of the Clockwork's army (it sends its timing at 6:30 whatever the Clockwork has).

### What kills what (deaths by 12:00, a game, before)

- Balanced: the Brood lost 220 Raptors, 21 grubs, 6 Spitters, 4 Mound Turtles, 3 Rootmaws. The Clockwork lost 42 Clock
  Soldiers, 9 Winders, 4 Springers, 2 Pendulums. The Raptors were killed by Pendulums 133, Clock Soldiers 51, Springers 25,
  the Ballista 6.
- By value that is about 5,500 lost for about 4,500 killed: not a rout fight by fight, but the Clockwork earns more (0.8
  income ratio), mends its units and sweeps its wrecks for cogs, so the gap grows every minute.
- From 9:00 most Raptors died at the Brood's own home, about 100 tiles from the Clockwork's start: the Clockwork's
  Pendulum-led pushes came and the Raptors were swept (in one game 60 Brood to 17 Clockwork in half a minute, then 39 to 4,
  49 to 2).

### The bench: equal cost (tools/bench_brood_v_cw_army.gd)

A controlled fight at equal cost (cogs + Tension against food + spoils, 1:1), 2 seeds each, the Brood attack-moving in,
the Clockwork standing with its Winders escorting and mending. Two Clockwork armies:
- **early** (what it has at 5:00-8:00): 55% Clock Soldiers, 20% Springers, 15% Pendulums, 10% Winders, no research;
- **late** (what it has from ~9:00): 40% Clock Soldiers with SHIELD WALL, 15% Springers, 35% Pendulums, 10% Winders, and the
  Brood with PACK HUNT, LONG SPIT and SLITHER.

"Killed per lost" is the value the Brood killed for each 1 it lost ("nothing lost" = it lost no unit). All tables:
`docs/brood_v_clockwork_army/bench/tables.md`; every fight: `bench/*.jsonl`.

| Brood mix (by cost) | early, 2,000, open ground | early, 2,000, up its ramp | late, 4,000, open ground | late, 4,000, up its ramp | late, attacking at 0.7 | late, attacking at 0.5 |
|---|---|---|---|---|---|---|
| Raptors only | won, 3.7 | won, 4.6 | **lost, 0.35** | **lost, 0.42** | lost, 0.10 | lost, 0.07 |
| 3 Raptors : 1 Spitter | won, 5.1 | won, 4.7 | lost, 0.44 | lost, 0.58 | | |
| 1 : 1 | won, 3.0 | won, 2.7 | lost, 0.66 | lost, 0.70 | lost, 0.42 | lost, 0.42 |
| 1 : 3 | won, 3.1 | won, 2.7 | 1-1, 1.0 | won, 1.6 | | |
| Spitters only | won, 18.6 | won, 14.9 | **won, 5.7** | **won, 10.9** | won, 5.7 | lost, 1.1 |
| Spitters + Brutes (70 : 30) | won, 10.4 | won, 10.4 | won, 6.1 | won, 10.6 | 1-1, 1.5 | lost, 0.7 |
| Tyrant Challengers | won, 2.9 | won, 2.5 | lost, 0.66 | 1-1, 1.0 | | |
| Venom Challengers | won, nothing lost | won, nothing lost | won, nothing lost | won, 21.8 | | |
| Venom Challengers + Spitters | won, nothing lost | won, nothing lost | won, 10.9 | won, 43.5 | won, 43.2 | lost, 1.5 |
| Brutes | won, nothing lost | won, 10.9 | won, 14.3 | won, 5.6 | | |

In plain words:
- At equal cost the Brood's units beat the Clockwork's. The Clockwork wins its games by out-earning the Brood and by being
  attacked at bad odds, not by better units.
- Raptors are good early and bad late: once the Clockwork has Pendulums (a sweep that cuts every light unit in its arc for
  x1.5) and shields, a pure Raptor army kills a third of what it loses. Spitters (reach 165, 190 with LONG SPIT, acid), Venom
  Challengers (armoured: the Pendulum's light bonus misses them) and Brutes win at equal cost, early and late.
- Attacking up its ramp at 0.7 of its army, Spitters and Venom Challengers still win; at 0.5 everything loses. That is the
  rule "never into a defended Clockwork base at 1:2".

## 2. What changed (scripts/ai_brood_v_cw.gd, AIBroodVCw)

Every rule acts only for a Brood computer whose enemy is the Clockwork, and not for the Rush plans (their Raptors are the
plan) nor for the written Spitter timing and Brute siege builds (their own mix and timing). `-- bvc:off` turns them all off;
each has its own switch. No unit, price or research number changed.

| switch | the rule |
|---|---|
| bvcmix | Once the Venom Sire stands by the Mother: two Spitters for every Raptor; Raptors held at 24 (16 once a Pendulum or SHIELD WALL is seen); a Brute for every 8 Spitters at her stage 3 (up to 8). The Venom Sire away or researching: the food waits for him once the Raptors are at the cap (unless 400 food or more pile up). With no spoils for a Spitter egg it lays a Raptor, and the spare Raptors at home are offered up for spoils. The plan's mix is "venom" and it matures young when an attack gathers. |
| bvcspoils | Spoils wanted: 40 (60 at her stage 3) once the Venom Sire stands; the spoils kept for her stage 3 do not hold the Spitter eggs back (5 an egg). |
| bvcsire | The Venom Sire's lure from 3:30 (Balanced's was 6:00). In the games he came at about 5:30-6:00: his 25 spoils and the alarm hold him. |
| bvcgrubs | The plan's own grubs again (Balanced 54): the cap of 44 against the Clockwork was there for the small early waves. |
| bvcwave | No small early waves: the first wave from 6:30 with 24 supply or more, and only with 1.15x what it reckons the Clockwork has. THE RECKONING: the Clockwork's army sits at home on its gears, out of sight, so the Brood takes the most it has seen lately or what a Clockwork computer has by that minute (the median of the 72 plan-matrix games: 790 at 6:00, 2,430 at 8:00, 3,380 at 10:00, 4,750 at 12:00), less what it killed in the last 90 s when that is 400 or more (a beaten push is the chance to counter). At the game's own supply cap (186) the army goes anyway. Once a Pendulum or SHIELD WALL is seen, Raptors stay home when 8 shooters or tanks go. |
| bvcraid | THE RAPTOR RAID: with Raptors held home, 8-16 of them (4 kept as a guard) go after the Winders at the Cog Press or Clocktower farthest from where the Clockwork's army was last seen, at most every 75 s, never with the army on the way (14 tiles), an alarm, enemies near the Mother or a wave out. They bite Winders not guarded (under 140 of armed enemies within 6 tiles), walk past buildings, and come home when outmatched (0.8), half dead or after 70 s. |

Also: tools/qa_match.gd writes each side's army by kind every minute (`kinds`), and the Brood's wave line in the match log
says what it reckoned ("attacks with 69 supply (...) (worth 3105; it reckons the Clockwork's army 2650)").

## 3. Measured

Brood OPTIMAL and Balanced (Hard) against the Clockwork's Hard OPTIMAL, 20:00, the plan matrix's 4 maps (Greenhold,
Ashford Crossing, Mirewood, Frostfang), each map twice with the spots swapped: 16 games before (main at 0.38.81) and the
same 16 after (`tools/study/plan_matrix_brood.py`; the data in `docs/brood_v_clockwork_army/data_before/` and
`data_after/`; the tables by `tools/study/brood_v_cw_army_report.py BEFORE AFTER`, in
`docs/brood_v_clockwork_army/report.md`). Scored as the plan matrix: W / L before the bell; at the bell led (w) or
trailed (l) by income + 2 x army, 10%.

RESULTS_TABLE

The army after (median counts standing, 8 games each):

| OPTIMAL after | 6:00 | 8:00 | 10:00 | 12:00 | 16:00 |
|---|---|---|---|---|---|
| Raptors | 22 | 24 | 22 | 25 | 26.5 |
| Spitters | 0 | 2 | 22.5 | 72 | 76 |
| army, Brood / Clockwork | 0.89 | 0.42 | 0.78 | 0.90 | (4 games left; the Brood far ahead in them) |

| Balanced after | 6:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|
| Raptors | 22 | 27 | 38.5 | 7 |
| Spitters | 0 | 1 | 9.5 | 0 |
| Tyrant Challengers | 0 | 0.5 | 3.5 | 2 |
| army, Brood / Clockwork | 0.76 | 0.57 | 0.70 | 0.55 |

- OPTIMAL is the real gain: its Spitters come from ~9:00 and by 12:00 it stands level. Balanced gains less: its Spitters
  come later and fewer (its Venom Sire is held back by the alarm and his spoils, and its Clockwork pushes come at ~8:00 into
  a Raptor army), and the medians at 12:00 count games that are being lost.
- The income gap is a little smaller (0.74 -> 0.79 at 12:00 for OPTIMAL) but still there.

### Against the Crown and in the mirror (8 games each, OPTIMAL, the same 4 maps)

CROWN_MIRROR_TABLE

### The films (tools/film_coach.gd, Greenhold seed 1102, Brood Balanced on spot A; `docs/brood_v_clockwork_army/films/`)

- **before**: two small Raptor waves (5:00, 16 supply: 250 of 400 came back; 6:41, 20 supply: 150 of 540 came back), a
  Clockwork push at 7:44, then at 12:01 a Clockwork push of 56 units meets the Brood's 43-supply wave. The Brood had 5
  Spitters at 10:00 and 8 at 12:00 against 49 Clock Soldiers and 4 Pendulums. Beaten at 13:40 (`map_1000.png`,
  `map_1200.png`, `map_1330.png`).
- **after**: no wave before 12:00. The Brood holds its ground and the Clockwork's push of 53 units at 9:44 breaks on 58
  Spitters and 3 Brutes (`map_0945.png`, `map_1000.png`); 106 Spitters at 12:00 against 35 Clock Soldiers; its wave of 115
  supply at 12:09 lost three quarters at the Clockwork's base (1,300 of 5,220 came back: `map_1200.png`, `map_1400.png`),
  but the Clockwork never recovered: 20:00 a draw the Brood leads by far (army 5,395 against 70; `map_1800.png`,
  `map_1945.png`).

## 4. What is left

- It still loses half the games. The Clockwork out-earns it (about 0.8 of the Clockwork's income at 8:00-12:00, before and
  after): a Brood that holds can still be out-grown.
- **No Venom Challengers.** The bench's best unit; the computer matured none (0 at every minute in 16 games): its maturing
  rule waits for 200-300 food banked while a push gathers, and with Spitters taking the food the bank never fills.
- Its big counter-waves into the Clockwork's base still lose most of themselves (the film's 12:09 wave). The counter goes
  after a held push (the kills come off the reckoning), but the base's turrets, Springers and Netters are not reckoned.
- Balanced's Spitters still come late (its first Spitters at ~9:00); the Clockwork's first Pendulum push at ~8:00 meets
  Raptors.
- The raid rarely does much: in the traces it went out 1-2 times a game and killed a Winder or two; once it lost half its
  pack in 5 s to soldiers guarding the Winder it chased (fixed: guarded Winders are not chased).

## 5. Balance options (proposed, NOT applied; the owner's call)

The play fix closes part of the gap: 0 -> 6 of 16 won or led. If the owner wants the matchup even between the computers:
1. **Raptor v Pendulum**: the Pendulum's x1.5 on light units (Defs.PENDULUM_SWING "vs_light") is what turns the late
   Raptor army into food (133 Raptors a game before). x1.25 would leave it the Raptor answer it is meant to be with less
   of a wipe. (A Clockwork balance change; the Crown's light units would feel it too.)
2. **Spitter eggs without spoils** (cost2 5 -> 0): the spoils were the Brood computer's bottleneck; a human player feels
   it less, but the cost is small and the rule is a trap.
3. **The Brood's income against the Clockwork** (0.8): better first a Brood economy coach job against the Clockwork's
   pressure (grubs lost to its pushes: 13-21 a game by 12:00).
My lean: none yet. Coach the Venom Challengers in (above) and measure again first (design_principles 1: fairness by
counterplay; the counterplay exists, the computer was not using it).

## 6. The Brood AI tests

All run on this branch (`tools/test_ai_brood*.gd`, `tools/test_brood_*.gd`, `tools/test_rootmaw_spots.gd`): all pass but
two, and both fail the same way on main 0.38.81:
- test_brood_new: "the VENOM SIRE costs 200 food + 25 spoils: his lure's price on the BUILD card ()": the card's price is
  empty headless (fails on main too).
- test_brood_new_defence: the rooted-muskets case (the Mother dies to 5 Musketeers): known, fails on main (CLAUDE.md).
These tests play the Brood against the Crown or itself (the Clockwork rules don't act in them); test_brood_ai_defend,
test_brood_builds, test_brood_fixes and test_brood_regen_calm also have Clockwork cases and pass.

## 7. Claude's choices (for the owner to confirm)

1. Every rule only against the Clockwork, and not in the Rush plans or the written Spitter / Brute builds (their own mix
   and timing are the point of those plans).
2. The reckoning from a TABLE (the median Clockwork computer's army by minute in the plan matrix), as the Crown computer
   reckons the Brood (BROOD_TABLE). It is a computer's knowledge of a typical game, not cheating: it sees nothing more.
3. EDGE 1.15: a wave goes with 1.15x the reckoning (the bench: Spitters win at 0.7 up a ramp, but the Brood's waves are
   mixed and the Clockwork's turrets and Netters are not in the bench).
4. Raptors capped at 16 once Pendulums or SHIELD WALL are seen, and kept home from the waves (a guard, the raid, spoils).
5. The plan's own grubs back (54 for Balanced).
6. The raid as a small extra; it could be dropped (`bvcraid:off`) if the owner finds it does too little.
7. The early OPTIMAL Raptor rush on a GREEDY read is left as it was (the plan matrix found it as good as Balanced; its
   Raptors set the Clockwork's Winders back).
8. Venom Challengers left to the old maturing rule (see what is left): the next step.
