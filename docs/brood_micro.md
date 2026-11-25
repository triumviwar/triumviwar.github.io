# Brood micro: training the Brood computer to fight

Job brood-micro, branch `brood-micro`. The owner, 2026-11-25: "a gigantic round of battles, micro training the AI...
until we know it is doing all it really can", and "it's only fair to make this testing to all matchups, not only Crown
vs Brood".

No unit or balance number was changed. Only how the Brood computer's creatures fight once a fight is on.
The macro is not touched: when a wave goes, where it goes, what is laid, the economy.

This is the same method as the crown-micro job (branch `crown-micro`, docs/crown_micro.md there), the other way round.

## The short answer

@@VERDICT@@

## What was built

1. **A battle bench**, `tools/bench_brood_micro.gd`. Two armies of the same value meet. There is no economy: both
   sides' food and gold are taken away, so nothing is built during a fight.
   The Brood is played by its own Hard computer: its wave, its close-ranks, its gathering, its defence at home, its Toads'
   spells, and the new micro. The enemy is played by its own Hard computer too: the Crown's wave, line, guns, rider screen
   and riders' hit and run; the Clockwork's push with its Winders; and in the mirror another Brood computer without the
   new micro.
2. **The Brood's fight micro**, `scripts/ai_brood_micro.gd` (AIBroodMicro). Six parts were tried. Three are kept.
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

@@BASE@@

## The films: the mistakes found

I filmed bench fights (`shots:`). Pictures in `docs/shots/brood_micro/`. What the films and the counters showed:

1. **The wave reaches the enemy as a stream.** Raptors (92 speed) run ahead. Spitters (68), Challengers (84) and Brutes
   (56) come later. A hill or a wood splits the wave. Against the Crown the first Raptors meet a full musket line and
   the guns alone, and are shot down before the rest arrive (`crown_open_contact.jpg`). The Brood computer has a
   close-ranks rule, but only against the Clockwork; and a gathering rule, but only against another Brood.
2. **Every creature bites the first enemy it finds and keeps at it.** Two hundred Raptors pile onto the nearest
   Musketeers. A creature with a nearly dead enemy beside it goes on biting a fresh one.
3. **Spitters stand still while a Clock Soldier walks up and hits them.** A Spitter (68) is as fast as a Clock Soldier (68)
   and faster than a Brute (56) or a Pendulum (46), but it never steps back.
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

@@PARTS@@

## What was kept

@@KEPT@@

## How much bigger must the army be?

The kept micro on the bench, the Brood bringing more or less value than the enemy (`ratio:`, 16 fights each):

@@RATIO@@

## Real games

@@GAMES@@

## Claude's choices

@@CHOICES@@

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
