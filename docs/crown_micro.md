# Crown micro: training the Crown computer to fight the Brood

Job crown-micro, branch `crown-micro`. The owner, 2026-11-25: "Until we have a good fighting Crown AI we can't change the
Brood economy. Until we know the Crown is doing all it really can... a gigantic round of battles, micro training the AI."

No unit or balance number was changed. Only how the Crown computer fights once a fight is on.
The macro (when to attack, where the wave goes, the kill decisions of the crown-finish job) is not touched.

## The short answer

**Yes: the Crown already wins fair fights against the Brood, and now wins them by more.** At equal value, with the armies
the computers really field and with late research, the Crown computer won 22 of 24 set-piece battles before this job and
24 of 24 after, killing 3.5 times what it lost (was 2.4). It even beats one and a half times its value of Brood in most
fights. The only fight it loses is the Brutes-and-Spitters mix at 1.5 times its value.

Four coaching parts are kept (on by default, against the Brood only, `-- cmic:off` turns them off):

| part | what the Crown's men now do |
|---|---|
| riders | Horsemen standing out of a fight ride in for the creatures at our guns and men |
| brace | a marching army halts and sets its guns when a Brood force comes at it |
| kite | a reloading Musketeer steps back from a Brute |
| gunpick | the Field Cannons aim at armoured creatures, the Mortars at the thickest clump |

In 30 real games (15 with the parts, 15 without) the Crown stood better at 14:00 (10 of 15 games, t 2.3) and was beaten
later, but by 20:00 the difference is inside the noise (won or led 5 of 15 against 3 of 15).

**So the remaining gap is not the fighting.** The Crown loses the real games because it fights the Brood's fights on
the Brood's terms: a Brood army bigger than its own (the Brood out-earns it from about 10:00: the far-Rootmaw bonus),
Musketeers with empty muskets (11 to 13 of them dry in the late games: the powder supply), and pushes into the Brood's base
without the guns set (the macro: the press and the siege push). The first is the economy number the owner holds back
(crown-brood-fix measured x2.0 and x1.8); the other two are macro work (crown-finish, the Mill crew), not micro.

One caveat: the bench's Brood is its creatures on an attack-move, not the Brood computer (Claude's choice 1); its real fight code is about the wave, so this is close.

My recommendation: in a fight the Crown computer is now doing most of what it can; what is left is small next to the economy. If the owner wants the matchup closer, the
Rootmaw bonus (`Defs.FOOD_BONUS`, crown-brood-fix's x2.0) is the lever, together with the powder supply.

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

On the core set (72 fights, two runs) the Crown computer already won 67 of 72 fights at equal value, killing 2.4
times what it lost. On the real set (24 fights) it won 22 of 24, killing 2.4 times what it lost, even with late research
on the Brood side and 3 Musketeers in 10 dry. The crown-brood-fix job had found the same with its own fight test (70 of
72 won).

| fight | fights | Crown won | score | k/l | score after | k/l after |
|---|---|---|---|---|---|---|
| open-m-raptor | 6 | 6 | +0.73 | 5.23 | +0.62 | 3.22 |
| open-m-mixed | 6 | 6 | +0.49 | 2.59 | +0.53 | 3.30 |
| open-m-late | 6 | 4 | +0.18 | 1.23 | +0.24 | 1.41 |
| home-m-raptor | 6 | 6 | +0.62 | 2.93 | +0.66 | 3.16 |
| home-m-mixed | 6 | 6 | +0.55 | 2.41 | +0.53 | 2.33 |
| ramp-m-mixed | 6 | 6 | +0.56 | 2.53 | +0.42 | 1.99 |
| side-m-mixed | 6 | 5 | +0.12 | 1.27 | +0.13 | 1.19 |
| open-s-mixed | 6 | 6 | +0.55 | 3.55 | +0.72 | 7.09 |
| open-l-mixed | 6 | 6 | +0.65 | 3.73 | +0.70 | 4.40 |
| open-l-late | 6 | 6 | +0.49 | 2.30 | +0.57 | 2.80 |
| open-m-spit | 6 | 4 | +0.16 | 1.29 | +0.42 | 1.97 |
| home-l-late | 6 | 6 | +0.72 | 4.05 | +0.75 | 4.19 |
| all (core) | 72 | 67 | +0.48 | 2.36 | +0.52 | 2.55 |

("after": the kept parts on, 72 fights.)

The real set:

| fight | fights | Crown won | score | k/l | score after | k/l after |
|---|---|---|---|---|---|---|
| open-M-real | 3 | 3 | +0.61 | 3.41 | +0.55 | 2.92 |
| home-M-real | 3 | 3 | +0.70 | 3.90 | +0.63 | 3.13 |
| side-M-real | 3 | 3 | +0.68 | 4.01 | +0.75 | 5.97 |
| ramp-M-real | 3 | 3 | +0.52 | 2.49 | +0.66 | 3.91 |
| open-L-real | 3 | 3 | +0.53 | 2.45 | +0.64 | 3.67 |
| home-L-real | 3 | 3 | +0.61 | 3.07 | +0.68 | 3.56 |
| open-L-late | 3 | 1 | +0.15 | 1.18 | +0.57 | 3.09 |
| side-L-real | 3 | 3 | +0.57 | 2.68 | +0.62 | 3.20 |
| all (real) | 24 | 22 | +0.55 | 2.41 | +0.64 | 3.47 |

The weak spots were the Brood's late mix (Brutes and Spitters), the Spitter army, and the attack from the side at the guns.

**How far does the Crown's edge go?** The same real fights, the Brood bringing 1.5 times the Crown's value (16 fights
each): before, the Crown still won 11 of 16 (score +0.15, k/l 1.70); with the kept parts 9 of 16 (score +0.17, k/l
1.79: the same, within the noise). So in a fair fight the Crown beats about one and a half times its value of Brood.
Only the Brood's Brute-and-Spitter mix beats it at 1.5 times (score -0.31 before, -0.20 after).

## The films: the mistakes found

I filmed bench fights (`shots:`) and one whole real game (tools/shot_ai_match.gd, Greenhold, seed 4103, Crown OPTIMAL
against Brood OPTIMAL, fights from 8:00 to 12:30). Pictures in `docs/shots/crown_micro/`. What the films showed:

1. **The riders stand out of the fight.** When the Brood comes in from the side and reaches the guns, the Horsemen of the
   rider screen sit on their flank posts 300 px away and do nothing. The guns are eaten. (The screen sends its riders to
   the line's flanks only once the line itself is fighting; a fight at the guns is not "the line's fight".)
2. **The wave walks into the Brood in a column.** In the open, the Brood comes on fast. The line has no time to form.
   The Musketeers arrive in clumps of 4 to 12, the guns still limbered behind them.
3. **Against Spitters the Musketeers walk into them.** The musket reaches 190, a Spitter 165. Standing still and firing
   wins. Walking on (the wave's attack-move) closes the gap for nothing.
4. **The Field Cannons never load canister.** The computer had no code for it. But canister is a cone that hits our own men
   too, and our guns stand behind our own line: in the bench, the moments when canister is safe and useful were rare
   (about one a fight).
5. **Musketeers stand still while a Brute walks up and hits them.** A Brute (56) is slower than a Musketeer (62).
6. **In the real game, most late fights are fought with empty muskets.** The red NO AMMO mark is over most Musketeers in
   the fights after 10:00 (in the crown-brood-late games 11 to 13 of 17 to 27 Musketeers were dry at 20:00 in two of
   three games). Dry, a Musketeer is a 70-health man with a bayonet. This is powder supply (macro), not micro.
7. **In the real game the late fights are in the Brood's base**, on its swamp, against Tyrant Challengers, with no guns
   along. These pushes are the macro's decision (the press, crown-finish's job).

What the films did NOT show: the Musketeers' choice of target is good already. They shoot the nearest creature, and
the computer's old rule moves them onto the most hurt one in reach. Shooting the Spitters first was tried and is worse.

## Each part, measured

Each part alone, on the core set (36 fights), against the Crown before the coaching (72 fights: two runs of the core
set). "t" says how far the change is beyond the noise: under 1 it is noise, about 2 is a real change.

| part | what it does | score (before +0.49) | change | t | k/l (before 2.36) | kept? |
|---|---|---|---|---|---|---|
| riders | a Horseman out of the fight rides in at the creatures at our guns or men | +0.54 | +0.06 | 1.35 | 2.65 | yes |
| brace | a Brood force coming at the marching wave: the men halt, the guns set | +0.53 | +0.05 | 1.11 | 2.56 | yes |
| kite | a reloading Musketeer steps back from a slower creature (the Brute) | +0.52 | +0.03 | 0.66 | 2.55 | yes |
| gunpick | the round shot goes for the armoured creatures, the Mortar's shell for the thickest clump | +0.51 | +0.02 | 0.42 | 2.48 | yes |
| canister | a set cannon loads canister when creatures are on it and none of our men are in its cone | +0.48 | -0.01 | -0.11 | 2.37 | no |
| hurt | a badly hurt Musketeer with a creature on him steps back behind his friends | +0.44 | -0.04 | -0.75 | 2.13 | no |
| focus (Spitters first) | the volleys shared out, no overkill, the Spitters first | +0.38 | -0.11 | -1.76 | 1.91 | no |
| focus, no Spitter bonus | the volleys shared out, no overkill, the most hurt first | +0.48 | -0.01 | -0.18 | 2.25 | no |
| focus, nearest first | the volleys shared out, no overkill, the nearest first | +0.48 | -0.01 | -0.13 | 2.22 | no |

The riders on the real set (24 fights, real armies, late research, 3 in 10 Musketeers dry): +0.55 -> +0.61 (t 1.5),
k/l 2.41 -> 3.15.

What each result means:

- **riders**: the biggest single gain, and on both sets. In the flank attack (side-m-mixed) the score went from +0.12 to
  +0.37: the riders now come back for the guns. It cost a little against pure Raptor swarms in the open (a Horseman riding
  into 60 Raptors dies); a version that sends riders only for the guns and the Spitters (`cmicridewho:1`) measured the
  same overall (+0.06), so the simpler one is kept.
- **brace**: halting the wave when the Brood comes at it lets the rear catch up and the guns set. It helps most against
  Spitters (+0.13) and Brutes (+0.32 in open-m-late).
- **kite**: it only acts against Brutes (55 steps back in 36 fights), and there it helps (open-m-late +0.45). Elsewhere it
  does nothing. Kept because it never hurts.
- **gunpick**: alone about nothing. Kept because together with the others the real set gained most where Brutes and
  Challengers are (open-L-late +0.42). Choice 3 below.
- **canister**: it fired about once a fight. Our guns stand behind our own line, so the cone is almost never clear. Not
  kept. (The cannon's canister stays the player's tool.)
- **hurt**: stepping back with a Raptor on him does not save a Musketeer: the Raptor is faster and follows. Not kept.
- **focus**: the surprise. "Shoot the Spitters first" is WORSE (-0.11): the Raptors and Challengers in front are what
  kill the line, and they must die first. Sharing the volleys out (no two balls into a creature that one kills) changed
  nothing: the computer already moves its Musketeers onto the most hurt creature in reach, and with 85% of balls hitting,
  "overkill" is rare. Not kept.

## What was kept

Four parts are on by default, against the Brood only (Normal and up): **riders, brace, kite, gunpick**.
`AICrownMicro.KEPT` lists them. Together, against the Crown before:

| set | fights | score before | score after | change (t) | k/l before | k/l after | Crown won before / after |
|---|---|---|---|---|---|---|---|
| core | 72 / 72 | +0.48 | +0.52 | +0.04 (0.95) | 2.36 | 2.55 | 67 / 68 |
| real | 24 / 24 | +0.55 | +0.64 | +0.09 (2.0) | 2.41 | 3.47 | 22 / 24 |

On the real set the Crown now keeps 64% of its army in an equal fight where it kept 55%, and kills three and a half times
what it loses. The biggest gain is against the Brutes and Spitters (open-L-late +0.15 -> +0.57), the Crown's old weak spot.

How often they act: in 72 core fights the riders went in 67 times (60 of them taken off the screen), the brace halted the
wave 45 times, a Musketeer stepped back from a Brute 133 times, and the guns changed target 996 times.

Three parts are written but off (`-- cmic<name>:on`): canister, hurt, focus (with its knobs `cmicspit:`, `cmicnear:`,
`cmiclow:`, `cmickill:`, `cmicdmg:` for anyone who wants to try again).

## Real games

The same 10 games as the crown-brood-fix and crown-brood-late jobs (Hard OPTIMAL against Hard OPTIMAL, to 20:00, the
six parity maps, the same seeds and start spots). Each block played on a frozen copy of this branch. "off" is
`-- cmic:off` (the Crown as before), "on" is the kept parts. Two blocks of each: the full 10 games once (off1, on1), then
the first 5 games again (off2, on2). 30 games in all, 15 a side, paired game by game.

| block | games | won | led | even | behind | lost | Crown won or led | mean g | g at 14:00 | defeats (minute) |
|---|---|---|---|---|---|---|---|---|---|---|
| off1 | 10 | 1 | 2 | 1 | 3 | 3 | 3 | -0.45 | +0.03 | 14.4, 18.1, 18.9 |
| on1 | 10 | 0 | 4 | 1 | 1 | 4 | 4 | -0.72 | +0.16 | 17.7, 18.2, 19.3, 19.9 |
| off2 | 5 | 0 | 0 | 0 | 0 | 5 | 0 | -2.22 | -0.45 | 14.6, 16.7, 17.2, 18.3, 18.4 |
| on2 | 5 | 0 | 1 | 0 | 2 | 2 | 1 | -1.03 | +0.01 | 18.2, 19.6 |
| **off, all** | 15 | 1 | 2 | 1 | 3 | 8 | 3 | -1.04 | -0.13 | median 17.65 |
| **on, all** | 15 | 0 | 5 | 1 | 3 | 6 | 5 | -0.82 | +0.11 | median 18.75 |

(g is the Crown's score against the Brood's as a log, as in the earlier jobs: 0 even, +0.7 the Crown twice the Brood,
-0.7 the Brood twice the Crown. The score is income plus twice the army, a beaten side counted a quarter.)

Paired game by game (15 pairs):

| measure | on minus off | t | games better / worse |
|---|---|---|---|
| g at 20:00 | +0.22 | 0.5 | 9 / 6 |
| g at 14:00 | +0.25 | 2.3 | 10 / 5 |

The fights in those games (the crown-guns-coach count: every fight worth 60 or more):

| block | fights | Crown killed | Crown lost | killed for each lost |
|---|---|---|---|---|
| off (all) | 77 | 146,910 | 136,875 | 1.07 |
| on (all) | 80 | 144,105 | 159,065 | 0.91 |

In plain words:

1. **The micro works in the games**: the riders went in about 50 times a game, the guns changed target about 100 times,
   Musketeers stepped back from Brutes about 10 times. The brace never fired in a real game: the waves meet the Brood
   on the line's own terms or at a base, not on the march.
2. **The middle game is better**: at 14:00 the Crown stood better in 10 of 15 games (t 2.3), and it was beaten later
   (median 18:45 against 17:40), 6 times against 8.
3. **By 20:00 it is within the noise**: the Crown won or led 5 of 15 against 3 of 15. The two "off" blocks alone show
   how wide the noise is: the same 5 games gave 0 won or led and 5 beaten the second time, 3 won or led the first time.
4. **The fights in the games did not trade better** (0.91 against 1.07). The count is driven by a few huge fights each
   game, and it swung just as much between the two "off" blocks (1.36 and 0.62). I looked at the worst ones: they are the
   siege push going out to the Brood's base against an army it reckoned bigger than itself ("goes out: 3,427 against the
   4,190 of Brood it estimates"), guns not set at contact, half the Musketeers dry. The micro cannot fix a fight that should
   not have been taken.
5. The AI tests: 21 of 23 tools/test_ai_*.gd pass; the 2 that fail (rush_followup, wall_vs_rush) are the known failures
   of the earlier jobs. The Crown fight tests (cav_micro, crown_defence, crown_line, crown_rider_screen, crown_v_brood,
   crown_siege, crown_hold) all pass.

## The Brood's own micro

The bench's Brood fights the way its waves go in: every creature on an attack-move at the Crown, each picking its own
target. I looked for anything broken that would make the bench meaningless. I found nothing broken:

- The Raptors run in and bite, the Challengers and Brutes walk in behind them, the Spitters stop at their reach and spit.
- The Brood computer's own fight code is mostly about the wave (gather, meet the army, do not chase riders), not about
  each creature in a fight. So the attack-move is close to how its waves really fight.
- What the bench leaves out, and what favours the Brood in real games: its waves are often bigger than the Crown army
  (the economy), they fight on their own swamp beside the Brood Mother and the Tyrant Sire, and they meet Crown pushes
  far from home with dry muskets and the guns left behind. None of that is "the Brood fighting better".

One thing for the owner to know: no Brood creature kites. A Spitter does not step back from a Musketeer, a Raptor
does not dance out of a volley. If the Brood computer is ever coached the same way, that is where it would gain.

## Claude's choices

1. **The bench's Brood is not the Brood computer.** The Brood computer is taken off for the bench (it would build and
   send its own waves) and its creatures attack-move. Its real fight code is about the wave, not the creature, so this is
   close; but it means the bench measures the Crown's fighting, not the Brood's.
2. **Kept all four positive parts together**, though alone only the riders are near the edge of the noise. Together they
   gained +0.09 on the real set (t 2.0) and +0.04 on the core set (t 0.95). Each part is cheap and none measured harmful.
3. **gunpick kept** though alone it measured about nothing (+0.02): it is the part that should matter most against Brutes
   and Challengers, and the real set's Brute fight (open-L-late) is where the whole package gained most (+0.42).
4. **The riders go in at any creature at our guns or men**, not only at the guns and the Spitters. The narrower version
   measured the same.
5. **The micro acts against the Brood only.** It was measured only there. It is cheap to open it to the other matchups
   later, after a measure there (the crown-rule-cleanup job found Crown coaching that helps against one enemy can hurt
   against another).
6. **The score** of a fight is the share of the Crown army left minus the share of the Brood army left, with hit points
   counted. It rewards winning with fewer losses, not only winning.
7. **Dry muskets in the real set**: 3 Musketeers in 10 start with no powder, which is about what the real late games show
   at the moment of a fight (often worse).
8. **No change to the line, the guns' march or the press.** Those are the macro side and the crown-finish job's.

## How to run it

```
godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:core runs:3 out:/abs/a.json
godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:real runs:3 tech:1 dry:0.3
godot ... -- only:side-m-mixed runs:1 cmic:off            (the Crown as before)
godot ... -- only:open-L-real ratio:1.5                   (the Brood brings 1.5 times the value)
xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 ... -- only:side-m-mixed runs:1 shots:/abs/dir
python3 tools/study/crown_micro.py run BLOCK [--extra cmic:off] [--jobs 2] [--root /frozen/copy]
python3 tools/study/crown_micro.py results BLOCK ...
python3 tools/study/crown_micro_bench_cmp.py base1+base2 rid1 combo1     (the bench arms, docs/crown_micro/bench/README.md)
```

Data: the bench arms in `docs/crown_micro/bench/`, the real games in `docs/crown_micro/data/` (off1, on1, off2, on2), the AI
tests' lines in `docs/crown_micro/ai_tests.txt`, pictures in `docs/shots/crown_micro/`.
