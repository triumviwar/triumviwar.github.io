# Brood micro: training the Brood computer to fight

Job brood-micro, branch `brood-micro`. The owner, 2026-11-25: "a gigantic round of battles, micro training the AI...
until we know it is doing all it really can", and "it's only fair to make this testing to all matchups, not only Crown
vs Brood".

No unit or balance number was changed. Only how the Brood computer's creatures fight once a fight is on.
The macro is not touched: when a wave goes, where it goes, what is laid, the economy.

This is the same method as the crown-micro job (branch `crown-micro`, docs/crown_micro.md there), the other way round.

## The short answer

**Against the Crown: it is the economy, not the fighting.** In a straight fight at equal value the Crown's computer
beats the Brood's badly. The Brood kills about a quarter of what it loses (k/l 0.26), and it needs about 1.6 times the
Crown's value just to come out even. The new micro makes that a bit better (k/l 0.33) but changes nothing in real games
(the same 10 games: mean score +1.14 before, +1.12 after; won or led 8 of 10 both times). So the Brood does not beat the
Crown by fighting better. In the real games its standing army is smaller than the Crown's until about 15:00 (a half at
8:00, three quarters at 12:00). It wins late: from about 13:00 it earns more than the Crown (0.77 of the Crown's income at
8:00, 1.04 at 15:00), it remakes its army fast, and the Crown's own late economy fails (powder runs dry, labourers are
killed on the road; crown-brood-late found the same). **Changing the far-Rootmaw food bonus is the right lever for this
matchup.** Better Brood fighting would not hide anything there.

**Against the Clockwork: the Brood fights better per value, but it was losing; part of that was its fighting.** At equal
value the Brood wins clearly (k/l 2.7); it needs only about two thirds of the Clockwork's value to come out even. Yet in
the real games, before the coaching, it was beaten 7 times in 10, earning only three quarters of the Clockwork's income.
With the new micro (the most hurt enemy first, Spitters stepping back from slower biters) it was beaten 3 times in 10 and
won or led 7 of 10 (mean score -1.25 before, +0.19 after; t 2.3; at 14:00 t 3.1). So here the fighting did matter, and
the micro closed most of the gap. What is left is economy: it still earns about 0.8 of the Clockwork's.

**The mirror: about even, before and after.** The micro does not change a mirror game measurably (10 games, noise).

**Two parts were kept: the focus and the kite.** The pack was better on the bench
but worse in real games, so it is off.

## What was built

1. **A battle bench**, `tools/bench_brood_micro.gd`. Two armies of the same value meet. There is no economy: both
   sides' food and gold are taken away, so nothing is built during a fight.
   The Brood is played by its own Hard computer: its wave, its close-ranks, its gathering, its defence at home, its Toads'
   spells, and the new micro. The enemy is played by its own Hard computer too: the Crown's wave, line, guns, rider screen
   and riders' hit and run; the Clockwork's push with its Winders; and in the mirror another Brood computer without the
   new micro.
2. **The Brood's fight micro**, `scripts/ai_brood_micro.gd` (AIBroodMicro). Six parts were tried. Two are kept.
   Every part has a switch. `-- bmic:off` turns all of them off. `-- bmic<name>:off` turns one off.
   A part that was not kept can be tried with `-- bmic<name>:on`. `-- bmicteam:0` gives the micro to one team only
   (the mirror's real games).
3. **The real-game study**, `tools/study/brood_micro.py` (the crown-micro study script with the Brood as "our" side):
   Hard OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps, 10 games a block, against each faction.
   Data in `docs/brood_micro/data/`. Bench data in `docs/brood_micro/bench/`, read with
   `tools/study/brood_micro_bench.py`.

Hooks in other files are one line each: `AIBroodNew._tick_ai` ticks the micro, `AIBroodNew.bmic_off` turns it off for
one computer, and `tools/qa_match.gd` writes the micro's counters into result.json (`brood_micro`).

## Before: the Brood computer had no micro at all

The other computers run `AI._micro` on Hard: a unit moves its shot onto the most hurt enemy in reach, a hurt unit goes
home, a shooter steps back from a biter. The Brood computer has its own think (`AIBroodNew._tick_ai`) and never ran it.
Every creature bit or spat at the first enemy it found (the nearest) and kept at it until it died.

## The bench

Each fight is named `<foe>:<where>-<size>-<mix>`.

| where | what happens |
|---|---|
| open | both waves march across the open middle and meet |
| home | the Brood army stands at home by its Mother. The enemy wave walks in. The Brood defends. |
| base | the enemy army stands in front of its own hall. The Brood wave walks in. The Brood attacks. |

| size | the enemy army (the Brood brings the same value) |
|---|---|
| m | Crown: 14 Musketeers, 3 Field Cannons, 3 Cuirassiers, a Mortar (about 1,700). Clockwork: 14 Clock Soldiers, 2 Springers, a Pendulum, a Netter, 3 Winders. Brood: 20 Raptors, 6 Spitters, 2 Tyrant Challengers. |
| l | about 3,000: the same kinds, more of them, a Ballista for the Clockwork, a Brute for the Brood |
| R | the armies the computers really field at 10:00 to 15:00 (from the wr1000 games), with the late research of both sides |

| mix | the Brood army |
|---|---|
| raptor | Raptors only |
| mixed | 2 Raptors to 1 Spitter to 1 Tyrant Challenger |
| spit | 2 Spitters to 1 Raptor |
| real | what the Brood computer really fields against that enemy at 10:00 to 15:00: against the Crown mostly Raptors with a few Spitters, Challengers, a Brute and a Toad; against the Clockwork half Spitters, half Raptors; in the mirror mostly Raptors |

The core set is 24 fights: 8 against each faction (open, home and base; sizes m and l; all mixes).

The score of a fight is the share of the Brood army left minus the share of the enemy army left (hit points counted).
Plus 1 is a clean Brood win, minus 1 a clean loss, 0 even. "k/l" is the value the Brood killed for each value it lost.

**The bench is noisy.** The same fight with the same seed does not always end the same (the Crown's fights least of
all). Two runs of the same code, 72 fights each, differed by -0.02 overall and by -0.05 against the Crown (t -1.9).
So the base is the mean of three runs of the old code (base, base2, base3), and a part counts only with a t of about 2.

## The Brood before the coaching

The base: three runs of the old code (bmic:off), 120 fights.

| against | score | k/l (Brood killed per value lost) | what it means |
|---|---|---|---|
| the Crown | -0.62 | 0.26 | the Crown wins nearly every fight at equal value, in the open, at its own base and at the Brood's home |
| the Clockwork | +0.44 | 2.68 | the Brood wins nearly every fight at equal value, most of all at home (k/l 4.6 to 6.5) |
| the Brood (the mirror) | +0.13 | 1.22 | about even; the defender at home wins (+0.26 to +0.37) |

Every fight against the Crown was lost: open -0.51 to -0.67, the Crown's base -0.53 to -0.59, the Brood's home -0.70 to -0.72.
The real armies with their late research (`set:real tech:1`, 24 fights) said the same: against the Crown -0.61 (k/l 0.30),
against the Clockwork +0.37 (k/l 2.21), the mirror +0.38.

## The films: the mistakes found

I filmed bench fights (`shots:`). Pictures in `docs/shots/brood_micro/`. What the films and the counters showed:

1. **The wave reaches the enemy as a stream.** Raptors (92 speed) run ahead. Spitters (68), Challengers (84) and Brutes
   (56) come later. A hill or a wood splits the wave. Against the Crown the first Raptors meet a full musket line and
   the guns alone, and are shot down before the rest arrive (`crown_open_contact.jpg`). The Brood computer has a
   close-ranks rule, but only against the Clockwork; and a gathering rule, but only against another Brood.
2. **Every creature bites the first enemy it finds and keeps at it.** Two hundred Raptors pile onto the nearest
   Musketeers. A creature with a nearly dead enemy beside it goes on biting a fresh one.
3. **Spitters stand still while a slower biter walks up and hits them.** A Spitter (68) is faster than a Brute (56), a
   Pendulum (46), and a Clock Soldier with its shield forward or its spring running down, but it never steps back.
4. **The Spitters are out-ranged by the Musketeers** (165 against 190). Arriving late and alone, they walk into the
   volleys. (The pack, below, brings them in with the Raptors.)
5. **Big creatures fight to the death at the front.** A Challenger at a quarter of its health stays in.
   (Pulling them back was tried: it does not help. See "hurt".)
6. **The Raptors never go for the guns.** The guns stand behind the line; the Raptors bite the line.
   (Sending them at the guns was tried: it does not help. See "guns".)
7. **Against the Clockwork the bench showed few mistakes.** The Clockwork's push meets the Brood in clumps, and the
   Brood wins those fights at equal value by a lot.

## Each part, measured

Each part alone, on the core set (72 fights: 3 runs of 24), against the base (the mean of the old code's runs).
"t" says how far the change is beyond the noise: under 1 it is noise, about 2 is a real change.

| part | what it does | change | t | against the Crown | against the Clockwork | the mirror | kept? |
|---|---|---|---|---|---|---|---|
| focus | a creature with several enemies in reach bites or spits at the most hurt one, a fighter before a worker | +0.05 | 2.3 | +0.08 (t 2.1), k/l 0.26 -> 0.36 | -0.02 | +0.10 (t 2.0) | yes |
| kite | a Spitter that has just spat steps back from a biter on it that is slower right now (a Brute, a Pendulum, a slowed Clock Soldier) | +0.02 | 1.0 | +0.04 | +0.02 (t 1.6) | 0.00 | yes |
| pack | a wave on the road keeps together: creatures ahead of its bulk wait for it | +0.02 | 0.8 | +0.07 (t 1.8) | -0.02 | +0.01 | no (see below) |
| spread | a biter that can't reach its target (others in the way) bites an enemy at its side | -0.02 | -0.7 | +0.03 | -0.04 | -0.03 | no |
| guns | a biter near an enemy gun goes for the gun (the Crown only) | +0.01 | 0.4 | +0.01 | | | no |
| hurt | a badly hurt Challenger or Brute steps back behind its friends | -0.01 | -0.7 | +0.05 | -0.02 | -0.06 (t -2.3) | no |

What each result means:

- **focus**: the biggest gain. The Brood computer's creatures used to bite the first enemy they found and keep at it.
  Now, with a nearly dead enemy in reach, they finish it first. Fewer enemies stay alive to shoot or bite back.
  It helps most in the mirror and against the Crown.
- **kite**: it acts only against biters slower than the Spitter at that moment: slowed Clock Soldiers, Brutes, Pendulums (hundreds of steps a fight
  against the Clockwork, almost none against the Crown). It helps a little there, and never hurts.
- **pack**: on the bench it helped against the Crown (the wave arrives together, not as a stream). But in the real games it
  made the Brood worse against the Crown (the same 10 games: -0.63, t -1.1, 8 games worse, 2 better) and in the mirror
  (-0.64, t -1.4). Turning only the pack off gave the old results back (-0.02 against the Crown). In real games a wave's
  bulk includes fresh creatures still walking up from home, far behind, so the front waited a long time (up to 2,216
  waits in a game) while the enemy got ready. Not kept. Against the Clockwork it was always off: the Brood computer's
  own close-ranks does this job there, and the bench found the pack worse on top of it.
- **spread**: in theory, biters stuck behind their friends should bite someone else. In the fights it did not help:
  the next enemy over is often the one the Musketeers or Clock Soldiers protect. Not kept.
- **guns**: Raptors sent at the guns behind the line die on the line on the way. Not kept.
- **hurt**: a hurt Challenger stepping back does not live: it is followed and the front is thinner. Not kept.

## What was kept

Two parts are on by default: **focus** and **kite**. Together on the bench (the core set, 5 runs, 120 fights, against the
mean of three runs of the old code):

| against | before | after | change | t | k/l before -> after |
|---|---|---|---|---|---|
| all | -0.02 | +0.05 | +0.07 | 3.9 | 1.01 -> 1.13 |
| the Crown | -0.62 | -0.57 | +0.05 | 1.8 | 0.26 -> 0.33 |
| the Clockwork | +0.44 | +0.50 | +0.06 | 2.5 | 2.68 -> 3.05 |
| the mirror | +0.13 | +0.22 | +0.09 | 2.5 | 1.22 -> 1.45 |

The three together with the pack (the first combination, the same set): +0.09 (t 3.8), against the Crown +0.10.
The real armies with late research (24 fights, with the pack): +0.02 (t 0.4), against the Clockwork +0.10, against the
Crown +0.06, the mirror -0.16 (6 fights).

Switches: `-- bmic:off` all off (the Brood as before), `-- bmicfocus:off`, `-- bmickite:off`; the parts not kept:
`-- bmicpack:on`, `-- bmicspread:on`, `-- bmicguns:on`, `-- bmichurt:on`, `-- bmicpackcw:on` (the pack against the
Clockwork too).

## How much bigger must the army be?

The kept micro on the bench, the Brood bringing more or less value than the enemy (`ratio:`, 16 fights each):

| against | the Brood brings | score | k/l |
|---|---|---|---|
| the Crown | 1 times the value | -0.57 | 0.33 |
| the Crown | 1.5 times | -0.05 | 0.65 |
| the Crown | 2 times | +0.31 | 0.87 |
| the Crown | 2.5 times | +0.51 | 1.14 |
| the Clockwork | 1 times | +0.50 | 3.05 |
| the Clockwork | two thirds | +0.05 | 1.89 |
| the Clockwork | a half | -0.34 | 1.20 |

So against the Crown the Brood needs about 1.6 times the value to come out even in a set fight; against the Clockwork
about two thirds. (These ran with the pack on, as the first combination.)

## Real games

Hard OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps, the same 10 games (maps, seeds, start spots) in every
block, as the wr1000 and crown-micro studies. "g" is the log of the score ratio (income + 2 x army; a beaten side's score
counted a quarter): above 0 the Brood was ahead. Won = the enemy beaten; led = ahead by 10% at 20:00.

| matchup | block | won | led | even | behind | beaten | mean g | g at 14:00 | change (t) |
|---|---|---|---|---|---|---|---|---|---|
| v the Crown | before (bmic:off) | 4 | 4 | 1 | 1 | 0 | +1.14 | +0.10 | |
| v the Crown | focus + kite + pack | 4 | 3 | 0 | 2 | 1 | +0.51 | -0.19 | -0.63 (-1.1) |
| v the Crown | **focus + kite (kept)** | 6 | 2 | 0 | 1 | 1 | +1.12 | +0.05 | -0.02 (0.0) |
| v the Clockwork | before (bmic:off) | 2 | 0 | 0 | 1 | 7 | -1.25 | -0.36 | |
| v the Clockwork | **focus + kite (kept; the pack is never on here)** | 3 | 4 | 0 | 0 | 3 | +0.19 | +0.15 | **+1.44 (2.3)**, at 14:00 +0.51 (3.1) |
| the mirror | before (both bmic:off) | 5 | 1 | 0 | 0 | 4 | +0.24 | +0.03 | |
| the mirror | one side focus + kite + pack | 2 | 2 | 1 | 0 | 5 | -0.40 | 0.00 | -0.64 (-1.4) |
| the mirror | **one side focus + kite (kept)** | 3 | 2 | 1 | 0 | 4 | -0.03 | +0.11 | -0.28 (-0.5), at 14:00 +0.07 (1.1) |

The economy in the same games (medians of the Brood's number over the enemy's; "army" is the standing army's value):

| matchup | income 8:00 | income 12:00 | income 15:00 | army 8:00 | army 12:00 | army 15:00 |
|---|---|---|---|---|---|---|
| v the Crown (before) | 0.77 | 0.93 | 1.04 | 0.47 | 0.74 | 1.06 |
| v the Clockwork (before) | 0.74 | 0.74 | 0.69 | 0.54 | 0.77 | 0.40 |
| v the Clockwork (kept micro) | 0.74 | 0.87 | 0.87 | 0.56 | 1.37 | much bigger (the Clockwork's army broken) |
| the mirror (before) | 1.01 | 1.01 | 1.11 | 1.10 | 0.86 | 1.10 |

Ten games a cell is few. The games swing a lot (one map's g goes from +2.2 to -3.0 between blocks). Only the Clockwork's
change is clearly beyond the noise.

## Claude's choices

1. **Focus and kite kept, the pack off.** The pack was the best part against the Crown on the bench, but worse in real
   games. I trusted the real games. A pack that only counts the creatures near the front of the wave (not the fresh ones
   walking up from home) might work; it was not built.
2. **The micro only on Hard and up**, like the other computers' `AI._micro`. Easy and Normal Broods fight as before.
3. **The bench's "equal value"** is Game.unit_value (a Raptor is worth 25: two hatch from a 50-food egg). The Brood's eggs,
   Rootmaws, Sires and Mother are not in the bench's armies, and nothing is laid during a fight.
4. **The bench's Clockwork** is its push (`CwPush._launch`) with 3-4 Winders along; there are no gear floors in the middle
   of the map, as in a real push. Its result there (the Brood wins at equal value) matches the real games' turnaround with
   the micro: the Brood had the better units all along.
5. **The mirror's real games** give the micro to one side only (`bmicteam:0`), so they measure the coached Brood against
   the old one.
6. **The pack was tried against the Crown in real games with the Crown's own crown-micro coaching NOT merged** (main has
   none of it). If crown-micro is merged, the Crown fights still better, and the Crown v Brood bench gap grows.
7. **The real games ran on a frozen copy** of this branch (`--root`), so that work on the code during the games could not
   change them.
8. **The verdict on the Crown v Brood gap** rests on three things: the bench (the Crown wins every equal fight), the real
   games' economy (the Brood earns less and stands smaller until ~13-15:00, then out-earns the Crown), and the micro
   changing nothing there. Together: the Brood's edge is not its fighting. "Fighting" here means how creatures fight once
   a fight is on. Where and when the Brood fights (its raids on labourers, its home on the swamp) is macro, and was not
   touched.

## How to run it

```
godot --headless --fixed-fps 30 --path . --script res://tools/bench_brood_micro.gd -- set:core runs:3 out:/abs/a.json
godot ... -- set:crown runs:3 bmic:off               (the Brood as before, against the Crown only)
godot ... -- set:core runs:3 bmiconly:focus          (one part alone)
godot ... -- set:real runs:2 tech:1                  (the real armies with their late research)
godot ... -- set:crown runs:2 ratio:1.5              (the Brood brings 1.5 times the value)
xvfb-run -a godot --rendering-driver opengl3 --resolution 1280x720 ... -- only:crown:open-l-real runs:1 shots:/abs/dir
python3 tools/study/brood_micro_bench.py BASE.json [BASE2.json ...] -- ARM.json
python3 tools/study/brood_micro.py run crown_on --opp crown [--extra bmic:off] [--jobs 2] [--root /frozen/copy]
python3 tools/study/brood_micro.py run brood_on --opp brood --extra bmicteam:0      (the mirror: only slot 0 coached)
python3 tools/study/brood_micro.py results crown_off crown_on --opp crown
```
