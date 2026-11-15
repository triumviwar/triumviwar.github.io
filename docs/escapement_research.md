# The Escapement's three researches (escapement-research, 0.38.19)

The owner, 2026-11-15 20:34: "Put the Clock Soldier SHIELD upgrade in the Escapement instead of in the Works; also make
an upgrade for the Net thrower (Netter). Reduce its current range, and the upgrade increases it to something longer than
the current range but less than the Crown cannon; the cannon is still the longest-ranged unit. So the Escapement would
have 3 upgrades."

## What changed

| | before (0.38.18) | now (0.38.19) |
|---|---|---|
| SHIELD WALL (Clock Soldiers: SHIELD FORWARD, +10 health) | Light Works (`movement_works`), 100 cogs + 50 Tension, 45 s | **Escapement**, same price and time |
| HIGH LEAP (Springers jump up) | Escapement | Escapement (unchanged) |
| LONG CHAIN (new) | - | **Escapement**, 100 cogs + 50 Tension, 40 s: every Netter +90 reach |
| Netter reach | 180 | **150**; 240 with LONG CHAIN |
| Longest reach of any unit | Field Cannon 430 (462 with the Gunner's Quadrant) | unchanged; next is the Mortar 352, then the Ballista 300; the Netter 240 |

- `Defs.RESEARCH`: `shield_wall` "at": "escapement"; new `long_chain` (a drill, "kinds": ["netter"], "range": 90,
  icon `research_long_chain`). The Light Works researches nothing now.
- `Game.apply_drills`: a Netter's `d["range"]` is base + LONG CHAIN on its own copy of `d` (Defs untouched), on every new
  Netter and on every Netter in the field the moment the research ends (the drill pass in `research_done`). A save keeps
  `players[t]["tech"]`, and loaded units are made through `_add_unit`, so they come back with 240.
- The Netter's own targeting (`Netter.pick`), the computer's Netter aim (`AI._netter_aim`), the push's chasers and the
  unit's attack all read `u._range()` = `d["range"]`, so they follow the research. Its sight (9 tiles = 288 px) still
  covers 240. The range chip on the unit card shows 4.7 tiles (150 px) or 7.5 tiles (240 px) with the line
  "Long Chain: +2.8 tiles." (`UnitStats`), the same way the Gunner's Quadrant shows on the guns.
- The Escapement's card: GEAR VIEW=G, HIGH LEAP=E, SHIELD WALL=S, LONG CHAIN=C, DEMOLISH=Z
  (`tools/test_card_keys.gd`: 278 cards, ALL PASS, the letters stay put while researching and with all research done).
- A stand-in icon drawn in code (`CwArt._ability_glyph "research_long_chain"`: a chain net with brass weights over a long
  arrow), listed in `docs/art_style_inconsistency.md` with a ChatGPT prompt idea; a painted
  `assets/icons/clockwork/research_long_chain.png` drops in with no code.
- Texts en/pt/es (`tools/i18n/74_escapement_research.txt`): the research's name, label and about; the Netter's about
  ("Its net reaches about as far as a Spitter spits; LONG CHAIN, researched at the Escapement, makes it reach further than
  a Musketeer shoots"); the Escapement's about (its three researches); the Light Works' about (no research line); the
  Clock Soldier's about and the SHIELD FORWARD refusal ("Research SHIELD WALL at an Escapement first.") and the stats
  tooltip ("Needs SHIELD WALL at the Escapement."); the Escapement's working line on its card; the AI story line for
  LONG CHAIN. Patch notes 0.38.19 in three languages.

## The Tension rule at the Escapement

SHIELD WALL costs Tension, so before it was made only at a Light Works whose gear network had a Mainspring. The Escapement
is a Tension user itself (`Defs.TENSION_USERS`): it works only while a Mainspring is in its gear network, and it
researches only while it works (`Game.research_problem` asks `gear_net.speed_mult` for every Tension user, then
`GearEcon.spend_problem`). So the rule is the same one as before, now on the Escapement, and the same as HIGH LEAP's:
nothing new to learn. What does change: SHIELD WALL now needs the Escapement standing (150 cogs, 40 s, after a Light
Works and a Mainspring). Every Clockwork plan builds the Escapement before it meets a ranged army anyway (see the
computer's timing below), so in practice it is not later.

Two side effects:
- The research no longer queues behind Clock Soldiers in the Light Works: it gets its own queue. In the matches below it
  took 41 s from queue to done at the Escapement against 60-61 s at a busy Light Works.
- It now shares the Escapement's queue with HIGH LEAP and LONG CHAIN (one at a time). A second Escapement researches in
  parallel, as before with two Light Works.

## Old saves (Claude's choice)

- **Done stays done**: `players[t]["tech"]["shield_wall"]` is a flag; it is not tied to a building.
- **Queued at a Light Works**: paid back in full on load (100 cogs + 50 Tension, like a CANCEL), and taken out of that
  queue (`SaveGame.restore`: a research queued at a building that no longer makes it is refunded; its head-of-queue clock
  does not carry over to the next unit). The player queues it again at the Escapement. Moving it would have needed an
  Escapement that may not exist yet.
- A mixed-replay keyframe goes through the same restore, so it behaves the same.

## The computer

- `AI._shield_research`: the same trigger as before (3+ enemy shooters seen in the last 90 s and 4+ Clock Soldiers), now at
  a working Escapement (`game.has_working(team, "escapement")`) instead of a Light Works meshing with a Mainspring.
  No Clockwork plan named SHIELD WALL in its written steps (only `research high_leap` in the Springer timing and
  `research owl_morph` in the Owl raids), so only this function had to change.
- `AI._chain_research` (new, Normal and Hard): LONG CHAIN at a working Escapement once it has 2 Netters (no build names
  Netters in its mix: the shared `_produce` makes them, the first from an army of 8, up to 3). SHIELD WALL first when that
  is wanted, like HIGH LEAP. Its Tension and cogs are held back the same way (`_research_keep`, `_research_cogs`). Story
  line: "researches Long Chain: its N Netters throw their nets from further back."

### Timing (Hard Clockwork OPTIMAL, 12:00, main v this branch, same map and seed)

| map, seed, enemy | Escapement done (main / branch) | SHIELD WALL queued -> done, main (Light Works) | SHIELD WALL queued -> done, branch (Escapement) | LONG CHAIN (branch) |
|---|---|---|---|---|
| Greenhold 1, Crown | 4:47 / 4:50 | 5:38 -> 6:39 | 6:09 -> 6:50 | 7:41 -> 8:17 (2 Netters) |
| Hollowfen 2, Crown | 3:44 / 3:45 | 6:08 -> 7:09 | 7:36 -> 8:17 | - (1 Netter) |
| Ashford Crossing 3, Crown | 3:44 / 3:43 | 8:10 -> 9:11 | 7:24 -> 8:05 | - (1 Netter) |
| Greenhold 4, Brood | 4:53 / 4:20 | - | - | 7:44 -> 8:20 |
| Hollowfen 5, Brood | 6:27 / 5:33 | 8:12 -> 9:29 | - (never 4 Clock Soldiers at home when it met shooters) | 10:10 -> 10:47 |

SHIELD WALL done: +11 s, +68 s, -66 s against the Crown: no systematic slip (the games part ways after a few minutes;
what decides the moment is the same trigger, meeting 3 shooters with 4 Clock Soldiers at hand, and in every game the
Escapement already stood long before it: 3:43-4:53 against the Crown). What the move does save: 41 s from queue to done
at the Escapement, 61-77 s at the Light Works, where it waited behind Clock Soldiers. In the 5th game the branch never
bought it (its army was out or down to 2-6 Clock Soldiers whenever it met Spitters), which is the trigger's choice, not
the Escapement's. All 10 games were undecided at 12:00 but one (the branch's Greenhold v Brood, a Clockwork win).

## The bench: 6 Netters + 10 Clock Soldiers v 12 Musketeers + 2 Field Cannons

`tools/bench_netter_range.gd -- range:<r> seed:<0-7> [shield]`: the Clockwork attack-moves from 560 px onto a holding
Musketeer line with the two guns 90 px behind it, open ground by the hall, no computers; the Netters' reach forced to
180 (before), 150 (now) or 240 (LONG CHAIN). 8 runs each (the lines shifted a little per seed), 120 s.

| Clock Soldiers' shields | Netter reach | Clockwork wins | Netters alive (of 6) | Clockwork value lost | Crown value lost | Crown units left (of 14) | catches |
|---|---|---|---|---|---|---|---|
| off | 180 (before) | 0/8 | 1.5 | 1,262 | 38 | 13.4 | 4.9 |
| off | 150 (now) | 0/8 | 2.8 | 1,106 | 82 | 12.6 | 4.9 |
| off | 240 (LONG CHAIN) | 0/8 | 3.9 | 966 | 45 | 13.2 | 6.2 |
| SHIELD WALL | 180 | 0/8 | 3.9 | 966 | 218 | 10.4 | 4.9 |
| SHIELD WALL | 150 | 2/8 | 3.8 | 902 | 459 | 7.5 | 6.2 |
| SHIELD WALL | 240 | 0/8 | 5.0 | 825 | 188 | 10.9 | 8.5 |

(The Clockwork's army is worth 1,450, the Crown's 1,060.)

What it shows:
- This fight is lost by the Clockwork whatever the Netter's reach: ten 75-hp Clock Soldiers walking into twelve muskets
  and two guns' canister die in about ten seconds. The reach changes how much the Netters do and how many come home.
- **150 v 180** (the cut alone): about the same number of catches; the shorter-reaching Netters walk closer behind the
  soldiers, so a few more of them die with no shield, and with SHIELD WALL they fight inside the shielded line (2 of the
  8 runs won outright, the only wins in the whole bench; the Crown lost twice as much). Noisy at 8 runs.
- **240** (LONG CHAIN): the most catches (6.2 without shields, 8.5 with: the Netters stand outside the muskets' 190 and
  net from there) and the most Netters alive (3.9 and 5.0 of 6). It does not turn a lost fight into a won one: a net
  holds one man for 4 s and the musket line keeps firing. It makes the Netter a safer support unit, which is what the
  research is for; the Field Cannon (430) still outranges it by far.

## Tests

- `tools/test_escapement_research.gd` (new, 36 checks, ALL PASS): SHIELD WALL only at the Escapement (a Light Works refuses
  it), its price and time, the 3 researches, LONG CHAIN 150 -> 240 on a Netter in the field and a new one, Defs left at
  150, the range chip, the cannon still the longest reach (next the Mortar 352), the Netter's sight covers 240, the
  Tension rule (an Escapement without a Mainspring refuses), a save keeps LONG CHAIN and pays back a SHIELD WALL queued at
  a Light Works, the computer buys LONG CHAIN at 2 Netters (not 1) and SHIELD WALL at the Escapement when it meets shooters.
- `tools/test_clock_soldier_shield.gd`: its research section now at the Escapement. Its one failure ("online: the guest has
  the soldier") fails on main too.
- `tools/test_cw_tier3_ai.gd`: the Cuirassier the Netter should net was put 155 px away (inside 180, outside 150); moved to
  ~115. ALL PASS.
- `tools/test_content_all.gd -- only=clockwork`: 0 FAIL, 0 WARN (it measures LONG CHAIN's range on a Netter before and
  after, and SHIELD WALL's health wherever it is researched).
- `tools/test_card_keys.gd`: ALL PASS (278 cards).
- `tools/test_i18n.gd`: PASS (0 untranslated data texts).
- `tools/test_cw_tier3.gd`: 3 online failures (the guest's copy of the morph bar, the net in flight, the catch), the same 3
  on main.
- The Clockwork computer's tests: `test_clockwork_springer_timing` (HIGH LEAP at 4:19, as before), `test_clockwork_builds_b`,
  `test_clockwork_eco`, `test_ai_optimal`: ALL PASS. (Every Godot run here ends with an engine abort at quit, exit 134,
  on main too.)

## Claude's choices for the owner

1. **Netter 150** (the job's proposal): a Spitter's reach; a Musketeer's 190 still outreaches it, so before LONG CHAIN
   the Netter has to come into the muskets' reach to throw.
2. **LONG CHAIN +90 -> 240** (the job's proposal): longer than the old 180 and than a Musketeer (190) and a Springer, far
   under the Field Cannon (430) and the Mortar (352), under the Ballista (300).
3. **LONG CHAIN's price 100 cogs + 50 Tension, 40 s**: SHIELD WALL's price, a little quicker. Tune freely.
4. **A drill**: every Netter has it at once (like the Gunner's Quadrant and the Brood's Long Spit), no refit walk.
5. **SHIELD WALL queued at a Light Works in an old save is paid back** (not moved: the Escapement may not stand yet).
6. **The computer buys LONG CHAIN at 2 Netters** (Normal and Hard; not on Easy, like HIGH LEAP), SHIELD WALL first when
   it is wanted.
7. **The icon**: a stand-in drawn in code until a painted one.
8. The Netter's own pick still nets "the most dangerous enemy in reach"; with 240 it simply has more to choose from. No
   kiting rule was added: the Netter already stands at the back of the computer's push (`AICwPush` rows) and its
   attack-move stops at its reach, so a longer reach keeps it further back by itself.
