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

@@KEPT@@

## Real games

@@GAMES@@

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
```
