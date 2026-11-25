# Crown micro: training the Crown computer to fight the Brood

Job crown-micro, branch `crown-micro`. The owner, 2026-11-25: "Until we have a good fighting Crown AI we can't change the
Brood economy. Until we know the Crown is doing all it really can... a gigantic round of battles, micro training the AI."

No unit or balance number was changed. Only how the Crown computer fights once a fight is on.
The macro (when to attack, where the wave goes, the kill decisions of the crown-finish job) is not touched.

## The short answer

@@VERDICT@@

## What was built

1. **A battle bench**, `tools/bench_crown_micro.gd`. Two armies of the same value meet. There is no economy.
   The Crown is played by its own computer: its wave, its line, its guns, its rider screen, its riders' hit and run,
   its defence. The Brood fights the way its waves go in: an attack-move at the Crown. The Brood computer is taken off,
   so it builds nothing during the test.
2. **The Crown's fight micro**, `scripts/ai_crown_micro.gd` (AICrownMicro). Seven parts were tried. Four are kept.
   Every part has a switch. `-- cmic:off` turns all of them off. `-- cmic<name>:off` turns one off.
   A part that was not kept can be tried with `-- cmic<name>:on`.
3. **The real-game study**, `tools/study/crown_micro.py`, the same 10 games as the crown-brood-fix and crown-brood-late
   jobs (Hard OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps). Data in `docs/crown_micro/data/`.

Hooks in other files are one line each: AICrown ticks the micro next to the riders' hit and run, and `AI._micro` leaves a
Musketeer's target alone when the micro is picking it (`_mic_focus`). `tools/qa_match.gd` writes the micro's counters
into result.json.

## The bench

Each fight is named `<where>-<size>-<mix>`.

| where | what happens |
|---|---|
| open | the Crown wave marches across the open middle. The Brood comes on head-on. |
| home | the Crown army stands in front of its Town Hall. The Brood walks at the hall. |
| ramp | the Crown wave goes up the Brood's main ramp. The Brood waits at the top. |
| side | the Crown wave marches. The Brood comes in from its flank, at the guns. |

| size | Crown army (the Brood brings the same value) |
|---|---|
| s | 8 Musketeers, 1 Field Cannon, 2 Horsemen (about 700) |
| m | 14 Musketeers, 3 Field Cannons, 3 Horsemen, 1 Mortar (about 1,700) |
| l | 26 Musketeers, 5 Field Cannons, 4 Horsemen, 2 Mortars (about 2,900) |
| M | 14 Musketeers, 3 Field Cannons, 6 Horsemen, 1 Mortar (the army the computer really fields at 10:00) |
| L | 24 Musketeers, 5 Field Cannons, 12 Horsemen, 2 Mortars, a band of three (the army at 15:00 to 20:00) |

| mix | the Brood army |
|---|---|
| raptor | Raptors only |
| mixed | 2 Raptors to 1 Spitter to 1 Tyrant Challenger |
| late | mixed, with more Spitters and Brutes |
| spit | 2 Spitters to 1 Raptor |
| real | what the Brood computer really fields late: mostly Raptors, some Challengers, Spitters, Brutes, Mist Toads |

Two sets of fights:

- **core**: 12 fights (open, home, ramp and side; all sizes s, m, l; all mixes), each 3 times = 36 fights.
- **real**: 8 fights with the real armies (sizes M and L), both sides with their late research (the Brood's Pack Hunt,
  Battering Horns, Slither, Long Spit; the Crown's Cavalry Charge, Prepared Charges, Gunner's Quadrant), and 3 in 10
  Musketeers with no powder left, as in the real late games. Each 3 times = 24 fights.

The score of a fight is the share of the Crown army left minus the share of the Brood army left (hit points counted).
Plus 1 is a clean Crown win, minus 1 a clean loss, 0 even. "k/l" is the value the Crown killed for each value it lost.

## The Crown before the coaching

@@BASE@@

## The films: the mistakes found

@@FILMS@@

## Each part, measured

@@PARTS@@

## What was kept

@@KEPT@@

## Real games

@@GAMES@@

## The Brood's own micro

@@BROOD@@

## Claude's choices

@@CHOICES@@

## How to run it

```
godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:core runs:3 out:/abs/a.json
godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:real runs:3 tech:1 dry:0.3
godot ... -- only:side-m-mixed runs:1 cmic:off            (the Crown as before)
godot ... -- only:open-L-real ratio:1.5                   (the Brood brings 1.5 times the value)
xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 ... -- only:side-m-mixed runs:1 shots:/abs/dir
python3 tools/study/crown_micro.py run BLOCK [--extra cmic:off] [--jobs 2] [--root /frozen/copy]
python3 tools/study/crown_micro.py results BLOCK ...
```
