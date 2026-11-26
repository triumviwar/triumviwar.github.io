# The lessons of the battle tests in the main computers

Job ai-lessons, branch `ai-lessons`, from main at 0.38.216. No version bump; patch note under 0.38.999.

The owner, 2026-11-26: "After implementation of the new combat and battle rules and what was learned by the battle tests
into the main AI, I want you to run win rate tests." This job puts the lessons in and checks each one. The win-rate runs
are separate jobs, after this one merges.

No unit or balance number changed (prices, health, damage, the food bonus stay).

## The short answer

| lesson | switch | what it does | measured | kept |
|---|---|---|---|---|
| 1. Dragoon waves | `aildragoonwave` | a Dragoon getting off to fire stays in the wave's count; HOLD does not start his dismount over | test | **on** (a fix) |
| 2. riders in front of the muskets | `ailriderpull` | the screen's riders pull back whenever the wave's muskets fight | test | **on** (a fix) |
| 3. guns set at contact, v the Brood | `cblguns` (crown-brood-late's) | the press and the push wait for their guns and set them before the Brood | 10 games | **on** |
| 4a. Crown v Brood army | `ailcbcomp` | Musketeers and Horsemen 70 / 30, one field Mortar, no spare-horse Dragoons | 10 games | **on** |
| 4b. Crown v Clockwork army | `ailckcomp` | Musketeers with Officers, no Mortars, no spare-horse Dragoons | 10 games | **on** |
| 4c. Clockwork v Crown army | `ailkccomp` | Spring Ballistas for Clock Soldiers, more Pendulums, fewer Springers and Netters, no Serpent | 10 games | **on** |
| 4d. Clockwork v Brood army | `ailkbcomp` | Pendulums and Ballistas, fewer Springers and Netters, no Serpent | 10 games | off (no help, did not build its Ballistas) |
| 4e. Brood v Crown army | `ailbcomp` | a Spitter for each Raptor (Venom Challengers when grown) | 10 games | off (leaned worse) |
| 4f. Brood v Clockwork army | `ailbkcomp` | the same, v the Clockwork | 10 games | off (did the opposite: fewer Spitters) |
| 5. open test failures | | test_brood_new, test_crown_stall, test_cav_micro | tests | fixed (stale tests) |

Switches: `-- ail:off` turns all of this job's own lessons off; `-- ail<name>:off` one; `-- ail<name>:on` one that is off.
`-- cblguns:off` (or `cbl:off`) turns lesson 3 off.

## How it was measured

Ten games a block, Hard OPTIMAL against Hard OPTIMAL, to 20:00, on the six parity maps (the same ten map, seed and start
spot pairs as every Crown study since wr1000). One switch is on in a block; the block is compared game by game with its
base block. `tools/study/ai_lessons.py` (crown_micro_2.py with its own data folder `docs/ai_lessons/data/<enemy>/<block>`,
`--me` for the side we look from).

The game score is (income earned + 2 x army) ours over theirs at the bell or the defeat; g is its logarithm (plus is good
for "our" side). "d (t)" is the mean change of g against the base, and its t: under 2 either way is the noise.

The study games ran from frozen copies of the branch (`tools/study/freeze_copy.sh`), so later edits never reached a game
already queued.

## Lesson 1: Dragoon waves go home

battle-matrix-all found that a Dragoon army never fought: the wave counted only the men "ready", a Dragoon getting off
his horse to fire dropped out of that, the wave fell under 6 supply and was sent home.

Looking closer there were two faults:

1. **The count.** A Dragoon getting on or off is out of `ready` (`AI._horse_coming`). Now any man of the wave who is a
   Dragoon (mounted, or on foot by his own horse, or getting on or off) stays in the wave (`AI._army`,
   `AILessons.dragoon`).
2. **HOLD started his dismount over.** A Dragoon on HOLD gets off to fight on foot. The Crown's line puts its men on HOLD
   every think, and each HOLD started the Dragoon's dismount again: in the test, 7 of 10 Dragoons stood "getting off" for
   25 seconds and never got off. Now HOLD on a Dragoon already getting off only keeps HOLD for after (`Unit.cmd_hold`).
   This one changes the game for players too: pressing HOLD twice no longer restarts the dismount.

The test `tools/test_dragoon_wave.gd`: a Crown wave of 10 Dragoons, a Brood force coming at it.

| | the wave ended | Brood health taken |
|---|---|---|
| before (`ail:off`) | 4 s after the first Dragoon got off | all |
| after | never (still out 25 s on) | all |

(The Brood force dies either way in the test: the Dragoons that stay mounted still fire. In a real wave the ending sent
everyone home.)

Note: the Crown computer mounts idle Musketeers on spare horses as Dragoons, up to a quarter of the line
(`AI._mount_men`). So Dragoons were in many of its waves, not only in the Dragoon raids plan.

## Lesson 2: a rider left in front of the muskets

`tools/test_crown_rider_screen.gd` failed after crown-micro-2: "no rider stands in front of the muskets (1)".

What was found:

- The screen pulled its riders back only while the line's state said "fight". When the brace halted the line, or the
  line lost its state, the riders rode on ahead, in front of the muskets.
- The test's own check looked at one moment, 7 seconds after contact. By then the enemy force was dead in almost every
  run, and the screen was riding ahead again, as it should.

Fixes:

- `ailriderpull`: the riders pull back whenever an armed enemy is within 260 px of one of the wave's muskets
  (`AICrownScreen._muskets_fight`), whatever the line's state.
- The test now looks from 2.5 s after contact (time to ride out of the way) to 7 s, while the enemy force is still there,
  and counts the worst moment. It passes. (The test is not the same twice: its other check, the picket's warning, failed
  in 1 run of 4 here, on main too.)

## Lesson 3: guns set at contact

The lab: the Crown's guns were set at contact in 0 of 3,627 open-field fights. Since then three parts exist:

- `brace` (crown-micro, on v the Brood and in the mirror): the marching wave halts and sets its guns when the enemy comes.
- `fieldline` (crown-micro-2, on v the Clockwork): the marching wave forms its line and sets its guns before the army
  it sees.
- `cblguns` (crown-brood-late, was off): the press waits for its guns, a rider rides ahead as its eyes, the push goes
  by bounds with the guns set.

What they give now in real games (fights worth 60+ in the ten games; "guns set" = at least one Crown gun near the fight
standing unlimbered at contact):

| matchup, block | fights | with guns near: a gun set at contact | away from home | killed for each lost |
|---|---|---|---|---|
| v Brood, base (brace on) | 51 | 9 of 31 | 3 of 14 | 1.27 |
| v Brood, cblguns on | 59 | **25 of 44** | **14 of 25** | 1.18 |
| v Brood, all kept together (cblguns + cbcomp) | 48 | 16 of 31 | 8 of 17 | 1.00 |
| v Clockwork, base (fieldline on) | 64 | 10 of 49 | 3 of 27 | 3.11 |

The result with cblguns: d +0.53 (t 0.7), 6 games better, 4 worse, survived 7 of 10 (base 5). Not worse; the guns are set
before the fight far more often. **Kept on** (`AICrownBroodLate.KEPT = ["guns"]`). Its other two parts (the Mill crew
`cap`, the home guard `home`) stay off as crown-brood-late measured.

Against the Clockwork the guns are set in only 1 in 5 fights with guns near, but the Crown already wins there 10 of 10 and
kills 3 for each 1 it loses. No block was spent on it.

## Lesson 4: the army mixes

From the tables (docs/battle_matrix.md, docs/battle_matrix_all.md): at equal cost

- the Crown's best army v the Brood is Musketeers and Horsemen 70 / 30; Mortars and Dragoon armies trade badly;
- the Crown's best v the Clockwork is Musketeers with Officers (MO);
- the Clockwork's real fighters are Pendulums and Owls, and Spring Ballistas with Clock Soldiers (KB) late; Springers,
  Netters and the Brass Serpent lose to nearly everything; 5 Ballistas instead of 10 Clock Soldiers closed most of the
  gap v the Crown (clockwork-micro);
- the Brood's strongest value v both is Venom Challengers.

Each plan keeps its own build and timings (the owner trains against each plan): only the share of each soldier in the
army moves. The Siege push keeps its Mortars (its siege kit) and the Dragoon raids plan keeps its Dragoons. OPTIMAL never
picks the Dragoon raids against the Brood already.

What changed in the army (average a game at 12:00, our side):

| block | side | its army at 12:00 (a game) |
|---|---|---|
| Crown v Brood, base | Crown | Musketeers 14.9, Horsemen 4.8, Field Cannons 3.8, Mortars 1.5 |
| cbcomp | Crown | Musketeers 18.9, Horsemen 4.4, Field Cannons 3.9, Mortars 1.0 |
| all kept, together | Crown | Musketeers 19.9, Horsemen 4.5, Field Cannons 2.9, Mortars 0.8 |
| Crown v Clockwork, base | Crown | Musketeers 25.8, Field Cannons 3.0, Horsemen 2.9, Mortars 1.7, Officers 0.7, the band |
| ckcomp | Crown | Musketeers 16.4, **Officers 7.6**, Field Cannons 3.8, Horsemen 3.6, Mortars 0.5 |
| Clockwork v Crown, base | Clockwork | Clock Soldiers 26.8, Springers 5.0, Brass Serpent 1.1, Ballistas 1.0, Netters 0.5 |
| kccomp | Clockwork | Clock Soldiers 25.6, **Ballistas 4.3**, Springers 3.1, no Serpent, no Netter |
| Clockwork v Brood, base | Clockwork | Clock Soldiers 15.5, Springers 4.3, Pendulums 2.7, Owls 1.3, Netters 0.8, Ballistas 0.4 |
| kbcomp | Clockwork | Clock Soldiers 8.5, Springers 2.8, Pendulums 2.5, Owls 0.9, no Ballista |
| Brood v Crown, base | Brood | Raptors 45.2, Spitters 8.2, Tyrant Challengers 2.1 |
| bcomp | Brood | Raptors 41.3, Spitters 6.6, Tyrant Challengers 2.3 |
| Brood v Clockwork, base | Brood | Spitters 55.9, Raptors 26.9 |
| bkcomp | Brood | Raptors 40.4, Spitters 30.6, Tyrant Challengers 4.2 |

(The Mortars and the guns left in the Crown's army are the Siege push plan's kit and the first Field Cannons.)

### The games

Won / led / even / behind / lost at 20:00, for the side named first (10 games a block). d (t) is against its base block;
for the lines marked "the other side changed" a plus d means the changed side did worse.

| matchup | block | switch | won | led | even | behind | lost | mean g | d (t) | at 14:00 d (t) | kept |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | base | | 1 | 2 | 0 | 2 | 5 | -0.84 | | | |
| Crown v Brood | cb_cbcomp | ailcbcomp:on | 3 | 0 | 1 | 4 | 2 | +0.15 | +0.99 (1.5) | +0.30 (1.5) | on |
| Crown v Brood | cb_cblguns | cblguns:on | 2 | 1 | 0 | 4 | 3 | -0.31 | +0.53 (0.7) | +0.06 (0.3) | on |
| Crown v Brood | cb_bcomp (the other side changed) | ailbcomp:on | 3 | 0 | 1 | 2 | 4 | -0.13 | +0.71 (1.0) | +0.22 (1.2) | off |
| Crown v Brood | cb_lessons: all kept, together | (the defaults) | 1 | 3 | 0 | 0 | 6 | -0.75 | +0.09 (0.2) | +0.15 (0.9) | |
| Crown v Clockwork | ck_base | | 7 | 3 | 0 | 0 | 0 | +1.53 | | | |
| Crown v Clockwork | ck_ckcomp | ailckcomp:on | 6 | 3 | 1 | 0 | 0 | +1.38 | -0.15 (-0.4) | +0.16 (1.9) | on |
| Crown v Clockwork | ck_kccomp (the other side changed) | ailkccomp:on | 5 | 5 | 0 | 0 | 0 | +1.14 | -0.39 (-0.9) | -0.17 (-2.3) | on |
| Brood v Clockwork | kb_base | (brood-micro's block) | 3 | 4 | 0 | 0 | 3 | +0.19 | | | |
| Brood v Clockwork | kb_kbcomp (the other side changed) | ailkbcomp:on | 4 | 2 | 1 | 0 | 3 | +0.30 | +0.11 (0.1) | -0.04 (-0.2) | off |
| Brood v Clockwork | kb_bcomp | ailbcomp:on (bkcomp now) | 5 | 0 | 2 | 0 | 3 | +0.33 | +0.15 (0.2) | -0.22 (-1.3) | off |

Notes:

- **The noise is large.** cb_bcomp barely changed the Brood's army, yet the Crown scored +0.71 against the base: that is
  about the size of chance in 10 games. So cbcomp's +0.99 and cblguns' +0.53 are not proof of help, only "not worse".
  With all the kept lessons together (cb_lessons) the Crown v the Brood is where it was (+0.09). This agrees with the
  crown-micro and brood-micro jobs: against the Brood the Crown's gap is the economy, not the fighting or the mix.
- **cbcomp** did not raise the Horsemen (the Crown already fields about a rider for every 3 Musketeers, mostly from its
  rush); what it changed is fewer Mortars and the gold going on Musketeers. The rule is kept, it costs nothing.
- **ckcomp** gave the line its Officers as planned (7.6 a game). The Crown already wins this matchup 10 of 10 (won or
  led); it still does. Kept: within the noise, and 14:00 leans better (t 1.9).
- **kccomp** is the one clear sign: the Clockwork built its Ballistas (4.3 a game, was 1) and dropped its Serpent and
  Netters, and did better against the Crown: d -0.39 for the Crown at 20:00 (t 0.9), -0.17 at 14:00 (t 2.3, beyond the
  noise). The Crown still won or led all 10, but by less. Kept.
- **kbcomp** did not build the Ballistas it was meant to (its Heavy Works went on Pendulums and the Great Winder first),
  its army at 12:00 was smaller, and the score did not move. Off. (Its base block is brood-micro's, run on 0.38.209
  with the same seeds and the same Clockwork and Brood code: Claude's choice 4.)
- **bcomp / bkcomp** did not do what was meant. "A Spitter for each Raptor" is a CAP on Spitters in the Brood's egg
  choice, not a floor: against the Crown it changed almost nothing, against the Clockwork (where the Brood lays twice as
  many Spitters as Raptors by its own rules) it cut the Spitters by half. Both off. The right lever would be the Brood
  plans' own mix and its MATURE order (the Venom Challengers grow from Spitters): left for later.
- The Dragoon fix and the rider fix are on in every block above.

## Lesson 5: the open test failures

| test | what failed | why | done |
|---|---|---|---|
| test_brood_new | "swamp round the rooted Mother" (the job's note); here "the VENOM SIRE costs 200 food + 25 spoils" | the swamp check passed in all 4 runs here; the Venom Sire check opened the BUILD page before the card was built for the new pick (a new pick resets the page): the card showed the main page. Fails on main too | the test builds the card first. Passes |
| test_crown_stall | "[foundry] a Foundry stands by 330 s" | the Foundry stands at ~345 s with nothing stalled (stalls none, bank 0): the coach's FARM FIRST and LABOURERS FIRST (0.38.31+) put it a little later. Not the stall the test is about | the bar 330 -> 360 s |
| test_cav_micro | StubAI has no `_foe` (AICrownRules.cut asks for it) | a stale test stub | `_foe()` added (no enemy: no rule cut). ALL PASS |

## The AI tests

All of `tools/test_ai_*.gd`, `test_crown*.gd`, `test_brood_new*.gd`, `test_cw_ai*.gd`, one at a time, on the branch
(before the defaults changed). Exit 134 at quit is Godot's exit crash; judged by the FAIL lines.

On the branch with this job's two fixes (the mixes still off), then again with the new defaults on for the tests the
mixes and the guns can touch (test_crown_v_brood, test_crown_v_clock, test_cw_ai, test_cw_air_ai, test_crown_siege,
test_crown_line, test_ai_optimal, test_crown_finish, test_crown_rider_screen, test_dragoon_wave, test_crown_build_order,
test_ai_brood, test_crown_hold, test_crown_defence, test_ai_round6): all pass.

Failing, all known or failing on main too:

| test | its failing check | known |
|---|---|---|
| test_ai_rush_followup | many | known |
| test_ai_wall_vs_rush | Barracks and Powder Mill laid by 75 s (58 s, 100 s) | known |
| test_ai_cw_horse_raid | round 5 loses fewer Winders or kills more riders | known (a different check each run) |
| test_ai_worker_safety | two Brutes do not kill the workers off (10 -> 4) | known (fails with its job off too, 0.36.1) |
| test_brood_new_defence | muskets [rooted] the Mother dies | known |
| test_crown_dragoon_raid | [plan] a group out by 690 s (formed, rode false) | known; the same on main |
| test_cw_air | a save keeps a morph under way | not in the job's list; fails the same on main (the save/load of a Swift's morph, not the computer) |

Now passing: test_ai_rush, test_ai_brood (its 900-food bank), test_cav_micro (the stub), test_brood_new,
test_crown_stall, test_crown_rider_screen.

## Claude's choices (for the owner)

1. **Kept means "not worse beyond the noise"**, as the job asked, so cbcomp, ckcomp and the guns are on although their
   gains are within the noise. Where a rule did not do what it was written to do (kbcomp, bcomp, bkcomp) it was left off
   even inside the noise.
2. **The HOLD fix is in the unit, not only the computer** (Unit.cmd_hold): a Dragoon already getting off keeps getting
   off. Players who press HOLD twice get the same. It sits behind the same switch (`aildragoonwave:off`).
3. **The rider test now looks while the fight is on.** Its old single look at +7 s came after the enemy was dead in most
   runs; a screen riding ahead then is right.
4. **The Clockwork v Brood base block is borrowed** from brood-micro (clockwork_on, 0.38.209, the same ten seeds): the
   Clockwork and Brood code paths are the same as on main now (only switched-off parts were added since). It saved two
   hours. A fresh base would be better if the owner wants that matchup checked again.
5. **No block for the guns against the Clockwork.** fieldline is on there already and the Crown wins every game.
6. **The Siege push keeps its Mortars and the Dragoon raids its Dragoons**: the plans stay what they are; the mixes
   only touch the shared army.
7. **The Crown v Brood mix aims at 30 Horsemen in 100 of the army** (by count, near enough by value). It did not raise
   the riders in practice; it is the Mortars it cut.
8. **The Officers stay on foot** against the Clockwork (AI._wants_horse): the computer used to put every Officer on a
   spare horse, making him a Horseman, so the MO line could never form.
9. **The Clockwork v Crown Ballistas: one for every 3 Clock Soldiers and Springers, up to 6**, Pendulums up to 2 + one
   for every 3 (8 at most), Springers one for every 3 Clock Soldiers (was 2 for 3), one Netter at most, no Serpent.
   In the games the Ballistas came, the Pendulums did not (the Heavy Works was busy with the Ballistas).
10. **Not done: the Brood's counter circle by what it scouts** (Storm Challengers v ground armies, Venom v flyers, the
    Sire with the wave). The egg rule touched was the wrong lever (note above). The mirror was not measured either: a
    mirror switch changes both sides.

## Files

- scripts/ai_lessons.gd (AILessons): the switches and the army mix rules.
- Hooks: AI._army (the Dragoon count), AI._produce (the Crown's riders, Officers, Mortars; the Clockwork's Ballistas,
  Pendulums, Springers, Netters), AI._mount_men, AI._wants_horse, Unit.cmd_hold, AICrownScreen._screen /
  _muskets_fight, BrassSerpent.ai_produce, AIBroodNew._nb_warrior, AICrownBroodLate.KEPT.
- tools/test_dragoon_wave.gd (new), tools/test_crown_rider_screen.gd, tools/test_brood_new.gd, tools/test_crown_stall.gd,
  tools/test_cav_micro.gd.
- tools/study/ai_lessons.py; data docs/ai_lessons/data/ (one folder a block, its switches in extra.txt).
