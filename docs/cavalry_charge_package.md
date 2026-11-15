# cavalry-charge-package: the Charge replaces Keen Sabres, and the Officer's price (2026-11-15)

The owner's decisions (2026-11-15 21:34), after docs/keen_sabres_test.md:

- **A.** Keen Sabres is replaced by "the Charge" package (the study's arm f2): Keen Sabres removed; the Cavalry Charge's
  charged blow x2.2 on light units; the computer's riders don't gallop round for the next charge against a fast melee
  swarm; the Cavalry Charge moves from the Armoury to the Horse Breeder.
- **B.** The Officer's price "correct as it should be in math": Officer + horse == Horseman (+ his horse), gold and powder,
  both ways round, and the armoured pair the same. Never raise the Horseman.
- **C.** The Mainspring stays local, 1 per Clocktower (a CLAUDE.md note).

Branch `cavalry-charge-package`, version 0.38.31 (measured on 0.38.22, the same changes before main was merged in). Design: docs/design_principles.md 1 (fair: one clear rule instead of
two overlapping ones; soft counters: a charge must be earned by a gallop, the Raptors can still swarm riders that stand)
and 4 (several ways to win: riders that out-micro a swarm).

## What changed

**Keen Sabres is gone.** `Defs.RESEARCH["keen_sabres"]`, its Horse Breeder button (the card builds its buttons from
`RESEARCH`, so the button went with it), the "+6 v light" blow in `Unit._strike`, its texts (tools/i18n/
71_balance_raptor_horseman.txt deleted; the Horseman's, the Horse Breeder's and the Armoury's "about" and tooltip, the
Help page's two paragraphs, rewritten in en/pt/es in tools/i18n/74_cavalry_charge.txt; the stale entries taken out of the
older files), its stand-in icon (assets/icons/research_keen_sabres.png and its line in docs/art_style_inconsistency.md),
tools/test_keen_sabres.gd (replaced by tools/test_charge_package.gd) and the study switch `keensabres:off`
(Game.KEEN_OFF). An old save's `keen_sabres` flag is dropped on load (SaveGame); one queued at a Horse Breeder is dropped
like any unknown research.

**The Cavalry Charge** (`Defs.RESEARCH["charge"]`):
- researched at the **Horse Breeder** (`"at": "horse_breeder"`, was the Armoury). Same price and time (60 gold, 25 s):
  the keen-sabres-test doc gave no other number. Old saves keep the flag (it is per side, not per building); one queued
  at an Armoury in an old save still finishes there.
- a charged sabre blow hits **x2.2 on a light unit** (`Defs.CHARGE["light"]`; was the study switch `chargelight:2.2`,
  `Unit.STUDY_CHARGE_LIGHT`, now gone): 18 x 2.2 = 39.6, so one charge kills a 38-hp Raptor. Anything not light (a Brute,
  a Clock Soldier in armour, Guardsmen, machines) still takes x2 (`Defs.CHARGE["mult"]`).
- the Armoury's drawn "charge" experiment (BuildingLife.ARMOURY_ART) is left in place but no longer plays (nothing
  drills the charge there); the Horse Breeder plays nothing while drilling, as with Keen Sabres before.

**The computer's riders** (scripts/ai_cav_micro.gd, AICavMicro): **the swarm rule** (`_swarm`). With
`SWARM_N` 4 or more enemy biters within `SWARM_R` 420 px that are light, strike with no reach (under 60) and run at
least `SWARM_SPEED` 0.75 of the rider's pace (Raptors 92 or 114 against a Horseman's 112; not Brutes, not Spitters, not
grubs), the micro does not play the charge: no galloping round the fight until the next blow will be a charge, no
holding back a blow to wait for one. It takes each blow as it comes (hit, ride out OUT_T, back in), and a charge still
lands when the run happens to be full. Against anything else (2-3 Raptors, a Brood army of Brutes and Spitters, the
Clockwork, the Crown) the charge play is unchanged. Measuring switch: `-- cavswarm:off` (AICavMicro.swarm_rule).

**The computer's research**: the generic research loop (AI._research) now finds the Charge at the Horse Breeder (it
looks the building up from `RESEARCH["at"]`). It drills it once it has 2 riders (as before), or with its **first rider,
out or still in a Barracks queue, when its plan is a rider plan** (`AI._rider_plan`: the Horse Breeder opening, i.e.
the Horseman rush and OPTIMAL's breeder punish). Before, the Armoury came late in most Crown plans, and in the 16
keen-sabres-test games the Charge was never drilled before 15:00.

**The Officer costs 100 gold** (was 75). See the arithmetic below.

**Tools**: tools/study_keen_sabres.gd (arms d and e gone; c is now the package; c2 = no charge play at all; cr = the
package without the swarm rule), tools/study/keen_sabres_report.py (knows cr), tools/study/keen_sabres_games.py (`--arms`:
"package", "swarmoff"), tools/test_raptor_rider_fight.gd (`charge:1` instead of `keen:1`), tools/test_unit_duel.gd's
usage line, tools/test_pistol.gd (the Officer's price).

## The price arithmetic (decision B)

The numbers in Defs (0.38.21):

| | gold | powder (his pistol) | horse |
|---|---|---|---|
| Horseman (`cuirassier`) | 100 | 5 (1 loaded shot + 4 charges, 1 each) | **a horse more**: one of ours at the Barracks or a free one at a breeder, else the breeder trains one and 40 gold more is paid at once (Game.train) |
| Officer (`dismounted`) | 75 | 5 | none (he walks); MOUNT takes any horse of ours |
| Horse | 40 | 0 | |
| Armour fee | Horseman 30, Officer 30 | 0 | |

So the Horseman's 100 never included his horse: **a Horseman costs 100 + 40 = 140**, and **an Officer + a horse cost
75 + 40 = 115**: training an Officer and mounting him was the cheaper Horseman by 25 gold. (The Defs comment said the
Officer was "the Horseman's price less the horse's": that held when the Horseman was 115 and was read as including the
horse, but the training code always charged the horse apart.)

The owner proposed "Officer 75 -> 60?" (balance-raptor-horseman's proposal 2: 100 - 40). **That makes it worse**: an
Officer + a horse would be 60 + 40 = 100 against the Horseman's 140. Since the horse is paid apart on both paths, the
only number that makes the two paths equal is **Officer = Horseman = 100**:

    Officer + a horse      = 100 + 40 = 140
    Horseman (+ his horse) = 100 + 40 = 140
    Horseman, DISMOUNT     = an Officer (100) + a loose horse of ours (40): 140, nothing gained or lost
    powder                 = 5 = 5 (Defs.POWDER "cuirassier" 4 / "dismounted" 4 charges + the loaded shot, 1 each)
    Armoured Officer + a horse = 100 + 30 + 40 = 170 = Cuirassier (100 + 30) + his horse 40
    the armoured pair's powder = 5 = 5 (the Armour fee has no powder for either)

This is the rule every other rider pair already follows: Labourer 50 = Messenger 50, Musketeer 60 = Dragoon 60, the
horse 40 apart. The Horseman is not raised (the owner just set it). **Claude's choice 1**: the Officer goes UP (75 ->
100), the opposite direction from the owner's guess, because the guess rested on the wrong reading of the Horseman's
price; the alternative that keeps "Officer 60" would be a Horseman of 60 + horse (an all-in 100), a 30% cheaper rider,
which undoes the 0.38.10 balance the owner just set. If the owner prefers that, it is two numbers in Defs.

Nothing can make money across the saddle: MOUNT and DISMOUNT move no gold (the horse is a unit of its own, never sold);
cancelling a Horseman in a queue gives back his 100 and frees his reserved horse (the breeder's horse is kept, as a
spare, as before); an Officer cancelled gives back 100. The army tallies (`Game.unit_value`, the match log's army
value, AICrownDefence's and AIBroodNew's `_value_of`, the rider counts) use `Defs.UNITS[kind]["cost"]`, so a Horseman
and an Officer are now worth the same 100 (before, a dismount "lost" 25 of army value and a mount gained it).
`AICrown.foe_reckon` reckons from a table of the enemy's army by the clock and the value killed, not from prices: no
change. The computer never trains Officers on purpose (it gets them from dismounted riders).

**Side effect**: an Officer on foot (80 health, a pistol shot and a sabre) is 33% dearer. balance-raptor-horseman saw 3
Officers (225 gold) beat 2 Horsemen (280) 5 of 6; at 100 each 3 Officers cost 300. The Officer was never meant as a
cheap foot soldier (a Musketeer is 60); his card now says what he is: a Horseman without his horse.

## The numbers (decision A)

### The fight study, rerun

`tools/study_keen_sabres.gd -- sizes:2,8 arms:b,c,cr seeds:4` (Hollowfen's open ground; open and in the riders' base;
Pack Hunt off and on; 4 seeds a cell; equal cost: a rider with his horse 140, a Raptor 25). b = hit and run, no research;
c = **the package** (the Charge x2.2 on light, the swarm rule); cr = the package without the swarm rule (the old charge
loop with x2.2: the old arm f). "Before" = docs/keen_sabres_test.md's rows on 0.38.12 (arm c = the old Charge, x2 with
its charge loop; d = Keen Sabres; f2 = the alternative this package was built from).

Trade (Brood value killed / rider value lost), riders lost in brackets, open and base summed (8 fights a cell):

| arm | Pack Hunt | 2 v 11 | 8 v 45 |
|---|---|---|---|
| before: c (old Charge) | no | 0.41 (100%) | 0.35 (97%) |
| before: c (old Charge) | yes | 0.27 (100%) | 0.23 (100%) |
| before: d (Keen Sabres) | no | 3.04 (6%) | 0.50 (48%) |
| before: d (Keen Sabres) | yes | 2.82 (31%) | 0.78 (66%) |
| before: f2 | no | no loss (0%) | 0.88 (28%) |
| before: f2 | yes | 1.15 (56%) | 0.72 (73%) |
| **now: c (the package)** | no | **3.57 (6%)** | **1.04 (33%)** |
| **now: c (the package)** | yes | **0.89 (56%)** | **0.62 (80%)** |
| now: cr (no swarm rule) | no | 0.69 (88%) | 0.35 (100%) |
| now: cr (no swarm rule) | yes | 0.56 (88%) | 0.23 (100%) |
| now: b (no research) | no | 0.42 (19%) | 0.45 (33%) |
| now: b (no research) | yes | 0.85 (56%) | 0.38 (81%) |

All four cells summed by ground (16 fights a cell):

| arm | ground | Pack Hunt | riders W-D-L | trade | riders lost | Raptors killed |
|---|---|---|---|---|---|---|
| c (package) | open | no | 0-8-0 | 1.15 | 30% | 34% |
| c (package) | base | no | 0-8-0 | 1.16 | 25% | 29% |
| c (package) | open | yes | 2-4-2 | 0.68 | 82% | 56% |
| c (package) | base | yes | 0-8-0 | 0.65 | 68% | 44% |
| cr | open | no | 2-0-6 | 0.40 | 95% | 38% |
| cr | base | no | 0-0-8 | 0.42 | 100% | 42% |
| cr | open | yes | 2-0-6 | 0.33 | 95% | 31% |
| cr | base | yes | 0-0-8 | 0.26 | 100% | 26% |
| b | open | no | 0-8-0 | 0.54 | 45% | 24% |
| b | base | no | 0-8-0 | 0.18 | 15% | 3% |
| b | open | yes | 0-3-5 | 0.33 | 90% | 29% |
| b | base | yes | 0-6-2 | 0.63 | 62% | 39% |

Raids (4 riders, the package): 10 grubs + 6 Spitters 4-0-0 (all 10 grubs, no rider lost; before c and e 4-0-0 too);
with 12 Raptors on guard 0-2-2, trade 0.54, 3.5 of 4 riders lost (before: old c 0-0-4, 4.0 lost; e 0-1-3, 3.8 lost).

What it says:
- **The package measures as the study's f2 said it would**: without Pack Hunt it trades 1.15 (Keen Sabres 0.5-3.0 by
  size: as good in small fights, twice as good at 8 v 45); with Pack Hunt about 0.6-0.9, a little under Keen Sabres
  (0.8-2.8) and f2. It does not win big equal-cost fights (none of the arms ever did).
- **The swarm rule is the half that matters**: the same x2.2 with the old charge loop (cr) trades 0.23-0.69 and loses
  88-100% of the riders, barely better than the old Charge.
- Without any research (b) the riders keep alive and draw without Pack Hunt; with it they are run down.

### Computer games (Crown OPTIMAL v Brood OPTIMAL, Hard, 15:00)

`python3 tools/study/keen_sabres_games.py run docs/cavalry_charge_package/games --seeds 4 --arms package` (tools/qa_match.gd;
greenhold, mirewood, hollowfen, dune_sea; 4 seeds a map, odd seeds with the sides swapped; seeds s0 and s1 are the
same games as keen-sabres-test's). Tables: `python3 tools/study/keen_sabres_games.py report docs/cavalry_charge_package/games`.

| build | games | Crown W-D-L | won or led Crown/Brood/even | riders made | riders lost | kills by riders | of them Raptors | grubs | Raptors killed per rider lost |
|---|---|---|---|---|---|---|---|---|---|
| before: Keen Sabres on (0.38.12) | 8 | 0-2-6 | 0/7/1 | 45 | 35 | 116 | 44 | 58 | 1.26 |
| before: Keen Sabres off (0.38.12) | 8 | 0-5-3 | 1/7/0 | 74 | 45 | 110 | 33 | 62 | 0.73 |
| **the package, the same 8 games (s0, s1)** | 8 | 0-4-4 | 0/8/0 | 57 | 38 | 110 | 52 | 34 | **1.37** |
| **the package, all 16** | 16 | 0-6-10 | 0/16/0 | 101 | 69 | 221 | 113 | 69 | **1.64** |

- **The Crown computer still loses this matchup** (0 wins in 16; the win-rate study had it 0-11-27). On the same 8 games
  the package went 0-4-4, between the two old arms (0-2-6 with Keen Sabres, 0-5-3 without); a won-or-led count of 8
  moves +-3 between runs of the same games, so the games don't separate the builds. The new seeds s2 and s3 lost more
  (2 draws in 8): Hollowfen and Mirewood lost all 4 each.
- **The riders do their job better against Raptors**: 1.6 Raptors killed per rider lost over 16 games (1.26 with Keen
  Sabres, 0.73 with neither). They killed fewer grubs on the old seeds (34 v 58-62).
- **The Charge is drilled now**: at 5:50-7:00 in 15 of 16 games (10:40 in one), where Keen Sabres came at 5:55-7:40; the
  old Armoury Charge came in none of the 16 keen-sabres-test games by 15:00.

Per game:

| arm | game | Crown result | leader (draw) | length | riders made | riders lost | kills by riders | Raptors | grubs | Keen Sabres at | Charge at |
|---|---|---|---|---|---|---|---|---|---|---|---|
| package | dune_sea_s0 | D | brood | 15:00 | 13 | 4 | 19 | 7 | 7 |  | 6:40 |
| package | dune_sea_s1 | D | brood | 15:00 | 7 | 2 | 17 | 6 | 3 |  | 6:00 |
| package | dune_sea_s2 | L |  | 12:32 | 5 | 4 | 16 | 11 | 3 |  | 5:50 |
| package | dune_sea_s3 | D | brood | 15:00 | 6 | 6 | 16 | 10 | 6 |  | 6:05 |
| package | greenhold_s0 | D | brood | 15:00 | 6 | 6 | 13 | 4 | 8 |  | 6:25 |
| package | greenhold_s1 | D | brood | 15:00 | 9 | 5 | 18 | 8 | 5 |  | 6:00 |
| package | greenhold_s2 | L |  | 11:24 | 5 | 4 | 13 | 9 | 2 |  | 5:50 |
| package | greenhold_s3 | D | brood | 15:00 | 9 | 4 | 16 | 7 | 5 |  | 6:00 |
| package | hollowfen_s0 | L |  | 12:29 | 5 | 4 | 9 | 5 | 3 |  | 6:40 |
| package | hollowfen_s1 | L |  | 14:55 | 6 | 6 | 17 | 12 | 3 |  | 6:25 |
| package | hollowfen_s2 | L |  | 10:49 | 5 | 3 | 7 | 2 | 3 |  | 7:00 |
| package | hollowfen_s3 | L |  | 11:38 | 4 | 3 | 8 | 3 | 4 |  | 6:25 |
| package | mirewood_s0 | L |  | 12:02 | 4 | 4 | 8 | 3 | 4 |  | 5:55 |
| package | mirewood_s1 | L |  | 14:53 | 7 | 7 | 9 | 7 | 1 |  | 10:40 |
| package | mirewood_s2 | L |  | 13:00 | 5 | 4 | 11 | 2 | 7 |  | 6:35 |
| package | mirewood_s3 | L |  | 13:49 | 5 | 3 | 24 | 17 | 5 |  | 5:55 |

| arm | games | Crown W-D-L | won or led Crown/Brood/even | riders made | riders lost | kills by riders | of them Raptors | grubs |
|---|---|---|---|---|---|---|---|---|
| package | 16 | 0-6-10 | 0/16/0 | 101 | 69 | 221 | 113 | 69 |

## Tests

Pass on the branch: **test_charge_package (new: 27 checks)**, test_raptor_rider_fight (an information test: 2 riders v 10
Raptors, standup / stand / kite; with `charge:1` the riders won 2 of 6 standing up and left 3.0 Raptors, without it 1 of
6 and 5.3; with Pack Hunt and the Charge 3 of 6 and 1 of 6 kiting), test_cav_micro, test_pistol (its Officer check now
reads the new price), test_i18n, test_unit_stats, test_content_all (0 FAIL, 16 WARN), test_horses, test_ride_by,
test_ride_by_raid, test_dragoon_remount, test_crown_ammo, test_crown_v_brood, test_crown_rider_screen, test_crown_line,
test_crown_hold, test_crown_build_order, test_crown_defence, test_crown_mirror, test_ai_optimal, test_cav_gate,
test_brood_rush_riders, test_loose_horses, test_haulers, test_horse_care, test_crown_gate, test_crown_siege,
test_crown_farms, test_crown_lost_hall, test_crown_balloon, test_ai_crown_bank, test_crown_owner_eco, test_mount_select,
test_lead_no_mount.

Fail the same way on main (0.38.21, checked in a worktree): test_card_text (the Town Hall's pt/es card lines over 80
characters, from econ-limit-local), test_ai_rush ("workers before the Brood Mother"), test_ai_rush_followup (15 checks,
known stale), test_crown_stall ([foundry] at 344 s), test_crown_dragoon_raid ([plan], known). Flaky: test_cinder_crown
failed [hall] once (348 s) and passed it on a rerun (failing [labs] instead, 22 of 23), as CLAUDE.md lists. Every test
here ends with Godot's exit-time abort (rc 134) after printing its result, on main too.

## Claude's choices (the owner to confirm)

1. **The Officer goes up to 100** (not down to 60): see the arithmetic. The other way to make the paths equal (a
   Horseman of 60 + his horse) would make riders 30% cheaper.
2. **The swarm rule's numbers**: 4 or more fast, light, no-reach biters within 420 px (about the micro's own pick
   radius), at least 0.75 of the rider's pace. 2-3 Raptors still get the charge loop (one charge kills one of them).
   Only the computer is affected; a player's riders do whatever he tells them.
3. **The Charge keeps its price and time** (60 gold, 25 s) at the Horse Breeder; Keen Sabres was 75 gold, 30 s. With
   the Charge now the riders' only research and its blow stronger, 75 / 30 would also be defensible.
4. **x2.2 on every light unit**, not only Raptors: a charged blow now kills a Musketeer (70) or a Labourer (46) no
   faster in blows (39.6 v 36), a Clock Soldier unarmoured a little faster. Armoured units keep x2.
5. **The computer's rider plan** = the Horse Breeder opening (`opening == "breeder"`): the Charge comes with the first
   rider there; every other plan waits for 2 riders, as the Charge did at the Armoury.
6. The Armoury's charge experiment animation is kept (unused) in case the research goes back.
