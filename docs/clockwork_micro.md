# Clockwork micro: training the Clockwork computer to fight

Job clockwork-micro, branch `clockwork-micro`. The owner, 2026-11-25: "a gigantic round of battles, micro training the AI...
until we know it is doing all it really can", and "it's only fair to make this testing to all matchups, not only Crown vs
Brood." This is the Clockwork's turn: against the Crown, against the Brood, and in the mirror.

No unit or balance number was changed. Only how the Clockwork computer fights once a fight is on was looked at.
The macro (when to attack, what to build, where the push goes) is not touched.
The method is the crown-micro job's (branch `crown-micro`, docs/crown_micro.md there).

## The short answer

@@VERDICT@@

## What was built

1. **A battle bench**, `tools/bench_clockwork_micro.gd`. Two armies of the same value meet. There is no economy.
   The Clockwork is played by its own computer: its push (the march, the screen, the fight, the retreat), the one army's
   home defence, the escort Winders, the Springers' jump in, the Netters' and Pendulums' aims, the shields.
   The enemy goes in the way its own computer goes in:
   - the Crown: the Crown computer's wave, with its line, its guns, its rider screen and its riders' hit and run;
   - the Brood: an attack-move at the Clockwork, the way its waves go in (the Brood computer is taken off, it builds nothing);
   - the mirror: the other Clockwork computer's own push.
2. **The Clockwork's fight micro**, `scripts/ai_cw_micro.gd` (AICwMicro). Eight parts were tried, each behind a switch.
   `-- cwmic<name>:on` turns one on. `-- cwmic:off` turns them all off. `-- cwmicteam:0` coaches only team 0 (for the mirror).
   @@KEPTLINE@@
3. **The study**, `tools/study/clockwork_micro.py`: the bench runs, the paired comparisons, and the real games (Hard
   OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps, 10 games a block). Bench data in
   `docs/clockwork_micro/bench/`, games in `docs/clockwork_micro/data/`.

Hooks in other files are one line each: AIClockwork ticks the micro every frame (`_cav_tick`), the push leaves a machine
alone while the micro has it (`CwPush._order`), and `tools/qa_match.gd` writes the micro's counters into result.json.

## The bench

Each fight is named `<where>-<size>-<enemy>`.

| where | what happens |
|---|---|
| open | the Clockwork push marches across the middle toward the enemy's side. The enemy comes on head-on. |
| home | the Clockwork army stands in front of its Clocktower. The enemy walks at the hall. |
| side | the push marches. The enemy comes in from its flank. |

| size | Clockwork army (the enemy brings the same value) |
|---|---|
| s | 8 Clock Soldiers, 2 Springers, 1 Netter, 2 Winders (about 1,000) |
| m | 18 Clock Soldiers, 2 Pendulums, 3 Springers, 1 Netter, 1 Spring Ballista, 3 Winders (about 2,400) |
| l | 30 Clock Soldiers, 3 Pendulums, 5 Springers, 2 Netters, 2 Ballistas, a Great Winder, 5 Winders (about 4,200) |
| M | 28 Clock Soldiers, 2 Pendulums, 3 Springers, 1 Netter, 1 Ballista, 4 Winders: the push the computer really sends at 10:00 |
| L | 56 Clock Soldiers, 4 Pendulums, 7 Springers, a Netter, 3 Ballistas, a Great Winder, 7 Winders: its push at 15:00 to 20:00 |

The real pushes were read from the Clockwork computer's own match logs ("push goes out: ... units"): they are 85 to 90 in
100 Clock Soldiers, a few Pendulums, Springers and Ballistas, one Great Winder.

| enemy | what it brings |
|---|---|
| crown | Musketeers, Field Cannons, Cuirassiers, a Mortar (with a band of three in the L fights) |
| cw | the same Clockwork army as ours, under its own computer |
| raptor | Raptors only |
| mixed | 2 Raptors to 1 Spitter to 1 Tyrant Challenger |
| late | mixed, with more Spitters and Brutes |
| spit | 2 Spitters to 1 Raptor |
| real | what the Brood computer really fields late: mostly Raptors, some Challengers, Spitters, Brutes, Mist Toads |

Four sets of fights:

- **crown**: 6 fights, **brood**: 8 fights, **mirror**: 4 fights. Each 3 times: 54 fights in all.
- **real**: 8 fights with the real armies (M and L), every side with its late research (the Clockwork's SHIELD WALL, HIGH
  LEAP, LONG CHAIN; the Crown's Cavalry Charge, Prepared Charges, Gunner's Quadrant; the Brood's Pack Hunt, Battering
  Horns, Slither, Long Spit), and 3 in 10 of the Clockwork's machines part run down (a push far from its gears). 24 fights.

The score of a fight is the share of the Clockwork army left minus the share of the enemy army left (hit points counted).
Plus 1 is a clean Clockwork win, minus 1 a clean loss, 0 even. "k/l" is the value the Clockwork killed for each value it lost.

**The bench is not exactly repeatable.** Two runs of the same fight with the same seed and the same code do not always end
the same (the game's path finding and timing are not deterministic). So I ran the whole bench twice with no change at all,
to see how big a change has to be before it means something. @@NOISE@@

## The Clockwork before the coaching

@@BASE@@

## The films: what the Clockwork does in a fight

I filmed bench fights (`shots:`) and followed every fight in numbers (`trace:1`: every 2 seconds, what each machine is
doing, how many are in reach of an enemy, run down, hurt, shielded). Pictures in `docs/shots/clockwork_micro/`.

What it does well already (the earlier coaching jobs built most of this):

- The push keeps together. It marches at the pace of its slowest machine, and in a fight the front holds a SCREEN in front
  of the Ballistas and meets what comes within reach, instead of running after every enemy.
- The Clock Soldiers raise their SHIELD WALL when they walk into ranged fire (21 to 27 of 28 shields up in the fights against
  the Crown with the research), and lower them to chase or fall back.
- The escort Winders follow the push and wind and mend it; in the bench fights almost no machine ran down.
- Netters net the most dangerous enemy in reach, Pendulums swing into the thickest knot, Springers jump in as the front
  meets the enemy, hurt Clock Soldiers step back to a Winder.

What the films showed going wrong:

1. **The enemy's back line is never reached.** Against the late Brood mix, the Clockwork killed the Raptors and Challengers
   in front and then died: 0 of 13 Spitters and 1 of 6 Brutes were killed. Against the Crown, 0 of 4 Field Cannons and 0 of 1
   Mortar; 13 of 23 Musketeers. The Clock Soldiers fight what is in front of them while the shooters behind shoot them.
2. **Against Spitters behind a Raptor screen, the Clock Soldiers stand still.** Nine of 18 stood with the order "idle",
   each on a Raptor, while 42 Spitters shot them from beyond the screen.
3. **Against the Crown the front melts in 6 to 8 seconds.** 18 Clock Soldiers became 3 between the first contact and the
   eighth second, with at most 12 of them in reach of an enemy at any moment. Musketeers in a line and Field Cannons behind
   them shoot a melee army walking in.
4. **The push pulls back late.** It turns home when it has lost about two thirds; the rest is often shot down on the way.

## Each part, measured

Each part alone on the 54 fights, against the Clockwork before the coaching (paired fight by fight). "t" says how far the
change is beyond the noise: under 1 it is noise, about 2 is a real change (but see the noise check above: on this bench a
group's t moves by up to about @@NOISET@@ with no change at all).

@@PARTS@@

What each result means:

@@MEANING@@

## What was kept

@@KEPT@@

## Other armies at the same value

Not the micro, but it answers the owner's question ("is the gap its fighting or its decisions?"): the same bench with
armies the computer does NOT build, of about the same value.

@@MIXES@@

## How much more does the Clockwork need against the Crown?

@@RATIO@@

## Real games

@@GAMES@@

## The verdict, matchup by matchup

@@VERDICT2@@

## Claude's choices

@@CHOICES@@

## How to run it

```
godot --headless --fixed-fps 30 --path . --script res://tools/bench_clockwork_micro.gd -- set:crown runs:3 out:/abs/a.json
godot ... -- set:real runs:3 tech:1 down:0.3                       (the real armies, late research, 3 in 10 run down)
godot ... -- only:open-m-late runs:1 trace:1                       (what every machine does, every 2 seconds)
godot ... -- only:open-m-crown runs:1 cwmicpick:on cwmicteam:0      (one part on, for team 0 only)
godot ... -- only:open-m-crown ratio:0.7                           (the enemy brings 0.7 times the value)
xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 ... -- only:open-m-crown runs:1 shots:/abs/dir
python3 tools/study/clockwork_micro.py bench NAME [--sets crown,brood,mirror] [--extra cwmicpick:on]
python3 tools/study/clockwork_micro.py compare base NAME [NAME ...] [--sc]
python3 tools/study/clockwork_micro.py run BLOCK --opp crown|brood|clockwork [--extra cwmic:off]
python3 tools/study/clockwork_micro.py report BLOCK ...
python3 tools/study/clockwork_micro.py paired BLOCK_OFF BLOCK_ON
```
