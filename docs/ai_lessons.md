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
| 4d. Clockwork v Brood army | `ailkbcomp` | Pendulums and Ballistas, fewer Springers and Netters, no Serpent | 10 games | KBCOMP |
| 4e. Brood v Crown army | `ailbcomp` | a Spitter for each Raptor (Venom Challengers when grown) | 10 games | off (leaned worse) |
| 4f. Brood v Clockwork army | `ailbkcomp` | the same, v the Clockwork | 10 games | BKCOMP |
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

TABLE_MIX

### The games

TABLE_GAMES

Notes:

NOTES_GAMES

## Lesson 5: the open test failures

| test | what failed | why | done |
|---|---|---|---|
| test_brood_new | "swamp round the rooted Mother" (the job's note); here "the VENOM SIRE costs 200 food + 25 spoils" | the swamp check passed in all 4 runs here; the Venom Sire check opened the BUILD page before the card was built for the new pick (a new pick resets the page): the card showed the main page. Fails on main too | the test builds the card first. Passes |
| test_crown_stall | "[foundry] a Foundry stands by 330 s" | the Foundry stands at ~345 s with nothing stalled (stalls none, bank 0): the coach's FARM FIRST and LABOURERS FIRST (0.38.31+) put it a little later. Not the stall the test is about | the bar 330 -> 360 s |
| test_cav_micro | StubAI has no `_foe` (AICrownRules.cut asks for it) | a stale test stub | `_foe()` added (no enemy: no rule cut). ALL PASS |

## The AI tests

All of `tools/test_ai_*.gd`, `test_crown*.gd`, `test_brood_new*.gd`, `test_cw_ai*.gd`, one at a time, on the branch
(before the defaults changed). Exit 134 at quit is Godot's exit crash; judged by the FAIL lines.

TESTS

## Claude's choices (for the owner)

CHOICES

## Files

- scripts/ai_lessons.gd (AILessons): the switches and the army mix rules.
- Hooks: AI._army (the Dragoon count), AI._produce (the Crown's riders, Officers, Mortars; the Clockwork's Ballistas,
  Pendulums, Springers, Netters), AI._mount_men, AI._wants_horse, Unit.cmd_hold, AICrownScreen._screen /
  _muskets_fight, BrassSerpent.ai_produce, AIBroodNew._nb_warrior, AICrownBroodLate.KEPT.
- tools/test_dragoon_wave.gd (new), tools/test_crown_rider_screen.gd, tools/test_brood_new.gd, tools/test_crown_stall.gd,
  tools/test_cav_micro.gd.
- tools/study/ai_lessons.py; data docs/ai_lessons/data/ (one folder a block, its switches in extra.txt).
