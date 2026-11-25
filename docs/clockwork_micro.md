# Clockwork micro: training the Clockwork computer to fight

Job clockwork-micro, branch `clockwork-micro`. The owner, 2026-11-25: "a gigantic round of battles, micro training the AI...
until we know it is doing all it really can", and "it's only fair to make this testing to all matchups, not only Crown vs
Brood." This is the Clockwork's turn: against the Crown, against the Brood, and in the mirror.

No unit or balance number was changed. Only how the Clockwork computer fights once a fight is on was looked at.
The macro (when to attack, what to build, where the push goes) is not touched.
The method is the crown-micro job's (branch `crown-micro`, docs/crown_micro.md there).

## The short answer

**The Clockwork computer already fights about as well as simple rules can make it fight. Its gap against the Crown is the
army it builds and the units' matchup, not its fighting. Against the Brood it has an edge, and the mirror is even.**

- Ten ways of fighting were tried on hundreds of equal-value battles (Clock Soldiers going for the shooters, a flank
  group, the whole push charging, Springers jumping at the guns, hurt machines stepping back, early retreats, Winders
  kept out of the shooters' reach...). **None helped beyond the noise. The ones that pull machines out of the block made it
  clearly worse.** Nothing was kept; the game is unchanged. The parts stay in the code, off.
- **Against the Crown**, at equal value, the Clockwork loses every fight (it kills a quarter of what it loses) and needs about
  twice the Crown's value to come out even. In real games it earns as much as the Crown and has the bigger army at 12:00,
  and still wins none of 10 games, because its army trades at 0.48. **But the same computer, fighting the same way, with
  five Spring Ballistas instead of ten Clock Soldiers, closes most of the gap** (-0.62 to -0.23 in the open, even at home).
  So: not the fighting, the army it builds (macro), and behind that a hard matchup for a melee army against muskets and guns.
- **Against the Brood** the Clockwork wins (5 of 10 games, trade 1.47): its economy is bigger and the Brood's real army,
  mostly Raptors, is what the Clock Soldiers beat. Its one weak spot (Spitters behind a Raptor screen) is again fixed by
  Ballistas, not by fighting differently.
- **In the mirror** it is even, as a mirror should be; on the bench the Springers-heavy army beats the computer's own.

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
   None of them is kept: none helped beyond the noise (the chapters below). They stay in the code, all off, for the next
   coach to try again (`-- cwmic<name>:on`).
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
to see how big a change has to be before it means something. The whole bench run a second time with nothing changed (`base2`): the mean score of all 54 fights moved by 0.02, one
fight's mean by as much as 0.47 (open-m-cw), and the groups' t by up to 0.9 (the mirror). So in this doc a part is
measured against the mean of the two plain runs, and a t under about 1.5 is called noise.

## The Clockwork before the coaching

Every fight, the two plain runs together (6 fights each):

| fight | score | Clockwork left | enemy left | k/l |
|---|---|---|---|---|
| open-m-crown | -0.62 | 0.05 | 0.67 | 0.25 |
| home-m-crown | -0.33 | 0.03 | 0.36 | 0.58 |
| side-m-crown | -0.63 | 0.23 | 0.86 | 0.12 |
| open-s-crown | -0.67 | 0.05 | 0.72 | 0.25 |
| open-l-crown | -0.68 | 0.01 | 0.69 | 0.26 |
| home-l-crown | -0.62 | 0.02 | 0.65 | 0.30 |
| open-m-raptor | +0.25 | 0.27 | 0.03 | 1.31 |
| open-m-mixed | -0.07 | 0.16 | 0.23 | 0.78 |
| open-m-late | -0.27 | 0.09 | 0.36 | 0.57 |
| home-m-mixed | +0.04 | 0.18 | 0.13 | 1.03 |
| side-m-mixed | +0.57 | 0.62 | 0.05 | 2.25 |
| open-m-spit | -0.42 | 0.06 | 0.49 | 0.46 |
| open-l-late | +0.32 | 0.45 | 0.13 | 1.62 |
| home-l-raptor | +0.11 | 0.14 | 0.03 | 1.16 |
| open-s-cw | +0.04 | 0.82 | 0.78 | 0.76 |
| open-m-cw | -0.36 | 0.20 | 0.56 | 0.46 |
| home-m-cw | +0.29 | 0.53 | 0.23 | 1.60 |
| open-l-cw | -0.35 | 0.16 | 0.52 | 0.54 |

The real armies (M and L, late research, 3 in 10 machines part run down; 3 fights each):

| fight | score | k/l |
|---|---|---|
| open-M-crown | -0.70 | 0.25 |
| home-M-crown | -0.47 | 0.44 |
| open-L-crown | -0.74 | 0.22 |
| open-M-real | +0.24 | 1.36 |
| home-M-real | +0.54 | 2.32 |
| open-L-real | +0.46 | 2.03 |
| open-M-cw | -0.04 | 1.03 |
| open-L-cw | +0.08 | 1.11 |

What it says:

- **Against the Crown the Clockwork loses every kind of fight at the same value**, and badly: it kills a quarter of what it
  loses (k/l 0.25), in the open, at home, from the side, small or big, with or without the late research. At home, where
  the Crown walks into it, it does least badly (-0.33).
- **Against the Brood it depends on the mix.** It wins against Raptor swarms (+0.25) and against the real late Brood army,
  which is mostly Raptors (+0.24 to +0.54). It loses against Spitters (-0.42) and the Spitter and Brute mix (-0.27).
- **In the mirror it is even**, as it should be; the side that waits at home on its gears wins (+0.29), the side that walks
  into the other's push loses (-0.36).

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
group's t moves by up to about 0.9 with no change at all).

| part | what it does | v Crown | v Brood | mirror | all 54 | kept? |
|---|---|---|---|---|---|---|
| close | a Clock Soldier or Pendulum in the enemy's fire with nothing of its own in reach goes for the nearest shooter | -0.046 (-1.4) | -0.139 (-2.1) | -0.154 (-1.8) | -0.111 (-3.1) | no |
| pick, wide (dive) | a Clock Soldier on a melee foe goes for a shooter within 220 px when 3 or more are there | -0.121 (-3.8) | -0.115 (-2.0) | +0.037 (0.3) | -0.083 (-2.1) | no |
| pick | a Clock Soldier on a melee foe goes for a shooter right beside it (90 px) | +0.010 (0.2) | -0.031 (-1.1) | +0.215 (2.5) | +0.037 (1.3) | no |
| flank | a third of the Clock Soldiers and the Springers walk round the side onto the enemy's back line | -0.056 (-1.1) | -0.128 (-2.7) | +0.001 (0.0) | -0.075 (-2.0) | no |
| charge | enemy shooters standing off: the whole push front goes at them together | -0.008 (-0.2) | +0.013 (0.3) | -0.087 (-0.9) | -0.016 (-0.5) | no |
| springpick | a ready Springer jumps at the guns or the Spitters, not the nearest foe | -0.018 (-0.7) | -0.068 (-1.6) | +0.141 (1.6) | -0.005 (-0.2) | no |
| mend | a hurt Pendulum, Netter, Springer or Ballista steps back to a Winder | -0.046 (-1.1) | +0.004 (0.1) | +0.022 (0.2) | -0.009 (-0.2) | no |
| bail | the push pulls back early from a fight it is clearly losing (lost 35%, killed under 0.45 of it) | +0.025 (0.5) | -0.011 (-0.2) | +0.163 (1.6) | +0.039 (1.0) | no |
| bail, sooner | the same, sooner (lost 20%, killed under 0.6 of it) | -0.068 (-2.5) | -0.010 (-0.2) | +0.102 (0.7) | -0.005 (-0.1) | no |
| safe | the escort Winders keep out of the enemy shooters' reach | +0.002 (0.1) | -0.059 (-1.4) | +0.076 (0.7) | -0.009 (-0.3) | no |

Each cell: the change in the mean score, and its t in brackets.

What each result means:

- **Everything that breaks the army up made it worse.** `close` (each machine goes for the nearest shooter), `dive` (the
  Clock Soldiers leave their melee foe for the shooters 220 px away) and `flank` (a third of the army walks round the side
  onto the back line) all lost, by a lot and beyond the noise (t -2 to -3.8). The machines that leave the block are
  caught alone: by the Raptors and Brutes they turned their backs on, by the Musketeers' volleys on the way, by the
  Cuirassiers. The push's own rule (hold the screen in front of the machines, meet what comes into reach) is better.
  The films' first two mistakes are real, but walking at the back line is not the answer with this army.
- **`charge`** (the whole block at the shooters, together) almost never had the chance to act (12 times in 54 fights):
  the enemy's shooters come into the screen by themselves.
- **`pick`** (a Clock Soldier fighting a melee foe takes the shooter right beside it instead) did nothing against the Crown
  (the Musketeers are the front line: it is already on a shooter) and nothing against the Brood, but helped in the mirror
  (+0.22, t 2.5): there the shooters beside the Clock Soldiers are the enemy's Springers and Netters. I ran it again on 12 new mirror fights (seeds 3 to 5) against a fresh plain run of the same fights: **-0.19 (t -1.2)**.
So the first +0.22 was the noise, and `pick` is not kept.
- **`springpick`, `bail`**: a little better in the mirror, a little worse against the Brood, all inside the noise.
- **`bail`, sooner**: worse against the Crown (t -2.5). Pulling back from the Crown's line does not save the machines: the
  Cuirassiers and the volleys follow a push walking home at the pace of its slowest machine.
- **`mend`**: nothing. The Pendulums and Ballistas are rarely the ones hurt and alive.
- **`safe`** (the escort Winders out of the shooters' reach): nothing on the bench, where a fight lasts 90 seconds. Its
  target is the long game: in the real games against the Crown the Clockwork lost about 80 Winders a game, half of them
  to Musketeers, a fifth while winding or mending. So it was tried in real games too (below).

## What was kept

**Nothing.** Ten parts (eight ideas, two with a second setting) were tried; none made the Clockwork fight better beyond the
noise, and the three that pull machines out of the block (close, dive, flank) made it clearly worse. Every part stays in
`scripts/ai_cw_micro.gd`, off, behind its switch. The game plays exactly as before this job.

This is a result, not a failure: the Clockwork computer's fighting is not where its games are lost. The earlier coaching
jobs (clockwork-army, cinder-clockwork-ai, clockwork-v-brood-coach-2, the escort, the shields) already made its push fight
as one block, and with this army that is the best of the simple rules I could find.

## Other armies at the same value

Not the micro, but it answers the owner's question ("is the gap its fighting or its decisions?"): the same bench with
armies the computer does NOT build, of about the same value.

Three armies of about the "m" value (2,300 to 2,500) that the computer does not build:

- **bolts**: 8 Clock Soldiers, 2 Pendulums, 3 Springers, 2 Netters, 5 Spring Ballistas, 4 Winders;
- **Pendulums**: 8 Clock Soldiers, 7 Pendulums, 2 Springers, a Netter, 3 Winders;
- **Springers**: 6 Clock Soldiers, 15 Springers, 2 Netters, 3 Winders.

The same computer fights them, with the same rules. 3 fights each. In the mirror the enemy keeps the computer's own army.

| fight | the other army | score | the computer's own army in the same fight |
|---|---|---|---|
| open, v Crown | bolts | -0.23 | -0.62 |
| home, v Crown | bolts | -0.01 | -0.33 |
| open, v Crown | Pendulums | -0.59 | -0.62 |
| open, v Crown | Springers | -0.65 | -0.62 |
| home, v Crown | Springers | -0.65 | -0.33 |
| open, v the late Brood | bolts | +0.10 | -0.27 |
| open, v the late Brood | Pendulums | +0.18 | -0.27 |
| open, v Spitters | bolts | **+0.50** | -0.42 |
| open, v Spitters | Springers | -0.51 | -0.42 |
| open, mirror | bolts | +0.37 | -0.36 |
| open, mirror | Pendulums | +0.05 | -0.36 |
| open, mirror | Springers | **+0.56** | -0.36 |

This is the biggest number in the whole study, and it is not about fighting. **The same computer, fighting the same way,
does far better with more Spring Ballistas** against the Crown (-0.62 to -0.23 in the open, even at home), against the
Spitters (-0.42 to +0.50) and in the mirror (+0.37); and with more Springers in the mirror (+0.56). The Ballista reaches
300 px: farther than a Spitter (165), a Musketeer (190) or a Springer (170). Behind the push's screen it shoots the back
line that the Clock Soldiers never reach. The computer's real pushes are 85 to 90 in 100 Clock Soldiers with 1 to 3
Ballistas. (3 fights a cell: these are big differences, but they are a first look, not a finished measure.)

## How much more does the Clockwork need against the Crown?

The crown fights again with the Crown bringing LESS value (`ratio:0.7`, `ratio:0.5`; 3 fights each):

| fight | the Crown at the same value | at 0.7 of it | at half of it |
|---|---|---|---|
| open-m | -0.62 | -0.24 | +0.19 |
| home-m | -0.33 | +0.17 | +0.33 |
| side-m | -0.63 | -0.01 | +0.06 |
| open-s | -0.67 | -0.15 | -0.11 |
| open-l | -0.68 | -0.53 | +0.07 |
| home-l | -0.62 | -0.20 | +0.01 |

With the army it builds, the Clockwork needs about **twice the Crown's value** to come out even in a field fight.

## Real games

Hard OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps (round 0 on all six, round 1 with the starts swapped on
the first four), 10 games a block, the same 10 pairings in every block of a matchup. "Won" and "lost" are games that ended;
"led", "even", "behind" are the score at the bell (income earned + 2 x army, 10% either way is even). g is the log of the
score ratio, ours over theirs (+0.69 = twice theirs).

**No part was kept, so "with the micro" can only mean a part on trial.** I ran the one part whose target the bench cannot
see, `safe` (the Winders out of the shooters' reach), as the "with" block.

| block | switches | games | won | led | even | behind | lost | mean g | g at 14:00 | army 12:00 | defeats (min) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| g_crown_off | opp:crown cwmic:off | 10 | 0 | 1 | 2 | 4 | 3 | -1.01 | -0.14 | 1.11 | 16.4, 18.8, 19.0 |
| g_crown_safe | opp:crown cwmicsafe:on | 10 | 0 | 0 | 2 | 6 | 2 | -0.82 | -0.22 | 0.89 | 16.0, 16.4 |
| g_brood_off | opp:brood cwmic:off | 10 | 5 | 0 | 1 | 1 | 3 | +0.55 | +0.25 | 2.19 | 15.8, 16.6, 18.9 |
| g_mirror_off | opp:clockwork cwmic:off cwmicteam:0 | 9 | 3 | 1 | 1 | 1 | 3 | +0.07 | +0.04 | 2.84 | 13.7, 14.2, 18.0 |

With `safe` against without, game by game:

```
g_crown_safe v g_crown_off: n 10  d g +0.20 (t 0.62, better 5 worse 5)  d g14 -0.08 (t -0.65)
g_mirror_safe v g_mirror_off: n 0  d g +0.00 (t 0.00, better 0 worse 0)  d g14 +0.00 (t 0.00)
```

The trade (armies only, by value, what the Clockwork killed for what it lost) and the economy (income earned, ours over
theirs):

| block | games | army killed / lost (value) | k/l | workers killed / lost | income ours / theirs at 12:00 | at 20:00 |
|---|---|---|---|---|---|---|
| g_crown_off | 10 | 61290 / 128420 | 0.48 | 2250 / 48060 | 1.05 | 0.72 |
| g_crown_safe | 10 | 67105 / 143175 | 0.47 | 2150 / 35460 | 0.99 | 0.72 |
| g_brood_off | 10 | 91995 / 62695 | 1.47 | 5650 / 23160 | 1.27 | 0.78 |
| g_mirror_off | 9 | 76695 / 70790 | 1.08 | 20040 / 17460 | 1.07 | 1.09 |
| g_mirror_safe | 0 | 0 / 0 | 0.00 | 0 / 0 | - | - |

What the games say:

- **Against the Crown the Clockwork earns as much (1.05 at 12:00) and has the bigger army at 12:00 (1.11), but it trades
  badly: 0.48 of value killed for each value lost, and it loses about 80 Winders a game besides (4,800 in value).**
  It won none of 10, lost 3, was behind in 4. The bench says the same thing: at equal value it loses every kind of fight.
- `safe` cut the Winders lost by a quarter (48,060 to 35,460 in value over 10 games) but changed nothing else: the trade
  stayed 0.47, the result d g +0.20 (t 0.6, 5 games better, 5 worse). Not kept.
- **Against the Brood the Clockwork wins** (5 won, 3 lost, g +0.55): it out-earns the Brood (1.27 at 12:00) and trades 1.47.
  The bench agrees: the Brood computer's real army is mostly Raptors, and the Clockwork beats Raptors.
- **The mirror is even** (g +0.07, trade 1.08), as it should be.

## The verdict, matchup by matchup

| matchup | real games (10) | trade (k/l) | income at 12:00 | bench at equal value | the gap is... |
|---|---|---|---|---|---|
| v the Crown | 0 won, 1 led, 2 even, 4 behind, 3 lost | 0.48 | 1.05 | -0.62 (needs ~2x the value) | the army it builds and the units' matchup: not the fighting |
| v the Brood | 5 won, 1 even, 1 behind, 3 lost | 1.47 | 1.27 | +0.07 (wins v Raptors, loses v Spitters) | an edge, from its economy and the Brood's Raptor-heavy army |
| mirror | 3 won, 1 led, 1 even, 1 behind, 3 lost (9 games) | 1.08 | 1.07 | even | no gap |

**What I would do next (proposals, not built):**

1. A coached BUILD job for the Clockwork: more Spring Ballistas in every push (against the Crown and against Spitters),
   more Springers in the mirror. The bench says this is worth far more than any fighting rule. It must be measured in real
   games: Ballistas are slow (34) and the push marches at its slowest machine's pace.
2. Against the Crown, the balance question for the owner: a melee army needs about twice the value to beat a Musketeer
   line with guns in a set fight. The Clockwork makes up for it today with its economy and its repairs; whether that is the
   wanted shape of the matchup is the owner's call (docs/design_principles.md, "fairness before perfect balance").
3. The Winders lost against the Crown (about 80 a game) are worth a look in the macro: `safe` saved a quarter of them in
   real games but did not change results.

## Claude's choices

1. **The enemies in the bench**: the Crown under its own computer's wave (its line, guns, screen, riders); the Brood as an
   attack-move with its computer taken off (as in the crown-micro bench: its waves go in that way and it would otherwise
   build); the mirror's enemy under its own push. In the mirror only our side is coached (`cwmicteam:0`).
2. **The Winders count** in the Clockwork army's value: they cost, and they come with the push.
3. **The same map and places as crown-micro** (Greenhold; its "open" middle has a hill with two ramps): real fights have
   terrain too. The other side's start and the hall decide where "home" and "side" are.
4. **The noise rule**: a part is measured against the mean of two plain runs of the bench, and a t under about 1.5 is noise
   (two plain runs moved a group's t by up to 0.9). A part is kept only beyond that, and never if it hurts a matchup.
5. **Nothing kept**, so the game is unchanged. The parts stay in the code, off, with their switches.
6. **`safe` was tried in real games** although the bench saw nothing: its target (Winders lost over a whole game, about
   80 a game against the Crown) does not show in a 90-second fight. It stays off unless the real games say otherwise.
7. **The other armies (bolts, Pendulums, Springers) were measured but not built into the computer**: what to build is the
   macro, outside this job. They answer the owner's question about where the gap is. 3 fights a cell only.
8. **The real games use a seed set of their own** (not crown-micro's), the same 10 map and start pairings in every block,
   so blocks compare game by game.

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
