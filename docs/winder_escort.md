# Winders escort the army (0.38.18, job winder-escort)

The owner's report (2026-11-15 20:11, playing the Clockwork): "if I select all my army and a few Winders and attack-move,
the Winders will not follow the army. Maybe we need another command, WIND UP, in the command card."
The owner decided (20:15): BOTH, an automatic escort and a WIND UP command.

## Why it happened

`Game.group_move` gave every unit its own spot of the bunch. A Winder is a worker that can hit (damage 7), so
`fights_on_command()` is true and he got an attack-move like a soldier, with `war = true`:

- he is faster than the army (Winder 74 v Clock Soldier 68, Springer 70, Netter 54, Pendulum 46, Spring Ballista 34),
  so he ran ahead and reached the enemy first;
- he stopped at his own spot, not with the army;
- in the fight he fought (and died) instead of winding and mending: the REPAIR autocast is skipped at war, and
  WinderWalk (docs/winder_walk.md) only winds constructs that are WALKING within 6 tiles, below 80% charge.

## What changed

### 1. The automatic escort (`scripts/winder_escort.gd`, order `escort`)

A group order that holds Winders AND Clockwork fighting units (ours, on the ground, not workers, not horses, not rooted)
gives the Winders the new order `escort` (`Unit.cmd_escort(group, goal)`) instead of their own spot:

- `Game.group_move` (move and attack-move, Shift-queued too), `Game.line_orders` (the drag-a-line: the Winders take no
  place on the line), and `Game.smart_command`'s right-click on an enemy (the soldiers attack it, the Winders escort).
  All go through `WinderEscort.split_off`.
- **Where he walks.** Nobody needing him, he stands `BEHIND` (40 px) behind the group's rearmost man, on the side away
  from its front, the escorting Winders side by side (`SIDE` 26 px). The front is, in order: where its men fight (their
  targets), where it walks (its mean velocity, while far from its goal), the way it was sent (goal minus where it stood),
  the nearest enemy, the last front seen. If its men are sent somewhere new without him (only the soldiers selected),
  he reads the new goal from their orders, so he follows and stays behind.
- **Who he winds and mends.** Every 0.5 s: the man of the group, or a neighbour within 3 tiles of it (WIND UP's "and the
  units round them"), with the lowest of charge or health share (a run-down one first), that he can repair (Clockwork),
  that needs it (charge under 95%, done at 98%; or hurt), not with an armed enemy within 40 px of it, and that no other
  Winder near has (two on one only when nobody else needs it). He keeps his man unless another needs it 0.25 more.
  A walking man is wound walking behind it (`WinderWalk.tick`, the walk-wind strip); a standing one standing, the same
  rates and price as REPAIR (0.15 charge a second; health paid in cogs). Out of cogs he just follows (he does not stop).
- **Out of melee.** An armed enemy on the ground within 64 px of him (edge to edge): he steps back, away from it and
  toward his place behind the group, never chases. Only if an enemy is on him and he has not got away for 0.8 s does he
  hit it where he stands.
- **His own spring.** He cranks it walking (as on the march), so he does not stop for 3 s in the middle of it.
- **When the order ends** (the attack-move done, the army idle) he stays with it, winding and mending, until given
  another order. The group gone (all dead): his next Shift-queued order, else he stops.
- **A group of only Winders** keeps today's plain orders (move, attack-move with its fight).
- **Card.** "ESCORTING: winds and mends the army" on his card's line (en/pt/es). Being a non-idle order, the box
  select keeps him with the army as before.

### 2. WIND UP (W) on the Winder's card

- With fighting units in the selection too: the selected Winders escort them at once (`Game.wind_up_order`), until
  another order. Shift held: queued.
- With only Winders selected: the mode `windup`; tap one of your units and the Winders escort it (and the units round
  it, 3 tiles). Shift keeps the mode on and queues.
- A right-click on a walking construct keeps today's REPAIR on the march (docs/winder_walk.md).
- Icon: a copy of the Great Winder's MEND key (`assets/icons/clockwork/ab_wind_up.png`), logged in
  docs/art_style_inconsistency.md for a painted one. Hotkey W (free on every Winder card; RELEASE's W is only on horse
  cards).
- Online: `wind_up_order` is a funnel command (NetCommands.GAME, both lists must be the guest's); `give` with the order
  dict `{"o": "escort", "g": [units], "p": goal}` travels as before. Saves: orders are not saved (as before), so after a
  load an escorting Winder stands; mixed replays record the commands.

### Texts

Tip, toasts, card line, the Clockwork help page's new paragraph WINDERS WITH THE ARMY, a line at the end of the Clockwork
tutorial lesson, patch notes: en/pt/es (tools/i18n/74_winder_escort.txt, tools/i18n/campaign/tutorial.txt).

## The computer

The computers' escort Winders do not use group orders: the Clockwork AI moves its escort with `cmd_move` / `cmd_repair`
(`AI._follow_with_escort`, `_escort_wind`, `_rewinders`, the rush/raid winders), so nothing changed for them. Measured:
the Clockwork and AI tests below, run before and after.

## Tests

`tools/test_winder_escort.gd` (ALL PASS): 8 run-down, hurt Clock Soldiers and 2 Winders starting IN FRONT of them,
attack-moved at 4 Crown Musketeers:

- the Winders escort, the soldiers attack-move as before;
- on the march the Winders are never ahead of the army's front (0 of ~230 samples; at worst 8 px behind it);
- in the fight they wind and mend (40-60 samples), never fight, and the nearest an enemy came was ~60 px; the army's
  charge 0.39 -> 0.73-0.81;
- they stay escorting after the attack-move; with everybody wound they stand behind the army, side by side;
- the army sent on alone (only the soldiers selected): they follow and end behind it;
- WIND UP on one soldier: he winds it walking and stays with it; on a group: three Winders, three different men, all
  wound to 90%+;
- Shift: the escort waits behind his move, then starts; a group of only Winders keeps its plain attack-move and move;
  a right-click on an enemy: the soldiers attack, the Winder escorts; STOP ends it.

Pictures (FILM=1, xvfb): docs/shots/winder_escort/ (amove_*.png: the attack-move with the Winders behind, amove_end.png).

Other tests: see "Test results" below.

## Choices for the owner (Claude's)

1. **Which units count as "the army"**: ground units that are not workers (a mixed selection of Labourers is not an
   army). Flyers are not followed (a Winder cannot follow them over cliffs) but are wound/mended if they stand within the
   group's reach. WIND UP on a tapped flyer does follow it.
2. **Rally points** are not escort orders: units come out one at a time, so a Winder rallied with them does what he did.
3. **Right-click on a hurt friendly unit** with a mixed selection is still REPAIR for the Winders (the old rule).
4. **Out of cogs**: he keeps following and only follows (REPAIR would stop him).
5. **Distances**: 40 px behind the rearmost man, 26 px between Winders, enemy within 64 px = step back, 40 px = his man
   is left until clear, 0.8 s pinned = hit back, neighbours within 3 tiles.
6. **Priority**: the lower of charge and health share; a run-down unit (charge 0) first of all.
7. **Hotkey W** and the copied MEND icon.
8. Orders are not saved, so a loaded game's escorting Winder stands (as every other order does today).

## Test results

Run on this branch (Godot 4.7 headless, `--fixed-fps 30`), failures compared with main (0.38.17) in a second checkout:

- PASS: test_winder_escort, test_winder_walk, test_clockwork_army, _builds_a, _builds_b, _eco, _home, _sounds,
  _springer_timing, test_cw_ai, _air, _air_ai, _army, _builders_share, _carrier, _couple, _crate_build, _lab, _plate,
  _raid_leash, _rifleman, _scout_workers, _scrapper, _siding, _storm, _tesla, _tier2, _tier3_ai, _work_car, _gun_rush
  (its own report; Godot aborts at quit, as on main), test_brass_serpent, test_tutorial (0 failures), test_i18n.
- Fail on main too (pre-existing, the same checks): test_cw_heavy ("it will not set up too far from the Line"),
  test_cw_militia ("not sent at a target far from the Line"), test_cw_tier3 (3 online guest checks).
- Flaky (known in CLAUDE.md): test_clockwork_owls (failed once "first Owl sortie by 8:00", passed on rerun here and on
  main), test_ai_cw_horse_raid (failed once on the branch, passed on main: a different check each run before this job
  too; the computers give their Winders no group orders, so this job's code does not run in it).
