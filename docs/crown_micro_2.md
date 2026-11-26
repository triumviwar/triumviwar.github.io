# Crown micro 2: the Crown computer's fighting against the Clockwork and in the mirror

Job crown-micro-2, branch `crown-micro-2`, based on main after the crown-micro job merged (0.38.210).
The owner, 2026-11-25: "micro training the AI... it's only fair to make this testing to all matchups, not only Crown vs Brood."

No unit or balance number was changed. Only how the Crown computer's men fight once a fight is on. No macro.

## The short answer

@@SHORT@@

## What was built

1. **The battle bench, for every matchup.** `tools/bench_crown_micro.gd` (the crown-micro job's bench) now also fights the
   Clockwork and the Crown itself. Two armies of the same value meet, with no economy.
   - **Against the Clockwork** the enemy is its army on an attack-move, the way its waves go in, with a Winder for every 8
     machines (they escort the army and wind and mend it, as the Clockwork computer's own Winders do), its Springers' own
     jumps out of a melee, the Clock Soldiers' SHIELD FORWARD by the Clockwork computer's own rule (`ShieldWall.think`), and
     each machine's wind drawn between 60% and full (they run down further during the fight, off the gear ground).
     With `tech:1` the Clockwork has SHIELD WALL, HIGH LEAP and LONG CHAIN.
   - **In the mirror** the enemy is the Crown computer too, marching its own wave at ours, with all of its fight code
     (its line, its guns, its riders), but with the new micro parts off. So the bench measures the parts against the old
     Crown.
2. **The micro by matchup**, `scripts/ai_crown_micro.gd` (AICrownMicro). The parts kept are now listed by the enemy's
   faction (`KEPT_BY`). Five new parts were written (below). Every part still has its switch: `-- cmic:off` all of them,
   `-- cmic<name>:off` one, `-- cmic<name>:on` one that is not kept for that matchup. `-- cmicoff:<team>` holds one Crown
   computer to the old fighting (for the mirror's real games).
3. **The real-game study**, `tools/study/crown_micro_2.py` (the crown-micro study with `--opp clockwork` and `--opp crown`),
   the same 10 games (map, seed, start spot) as the earlier Crown studies, Hard OPTIMAL against Hard OPTIMAL, to 20:00, on
   the six parity maps. In the mirror our Crown always plays with the block's switches and the other Crown without the
   parts (`cmicoff`). Data in `docs/crown_micro_2/data/`.

Other tools: `tools/study/crown_micro_2_arms.sh` runs bench arms two at a time, `tools/study/crown_micro_2_table.py`
makes the tables below, the study's `fights` command counts the fights inside the real games.

## The bench

The fights are named `<where>-<size>-<mix>`, as in the crown-micro doc (where: open, home, ramp, side; size: s, m, l, and
M, L for the armies the computer really fields).

The Clockwork's mixes (taken from what the Clockwork computer fields in about 2,000 minute snapshots of earlier study games: at 10:00 about
19 Clock Soldiers, 3 or 4 Springers, a Pendulum, a Ballista, a Netter; at 15:00 to 20:00 33 to 36 Clock Soldiers, 4
Springers, 1 or 2 Pendulums and Ballistas):

| mix | the Clockwork army (and a Winder for every 8) |
|---|---|
| cwline | Clock Soldiers only |
| cwmixed | 3 Clock Soldiers to 1 Springer |
| cwlate | Clock Soldiers with Springers, a Pendulum, a Netter, a Ballista |
| cwpend | 3 Clock Soldiers to 1 Pendulum |
| cwspring | 2 Springers to 1 Clock Soldier |
| cwreal | what the computer fields late: mostly Clock Soldiers, Springers, a Pendulum, a Ballista, a Netter |

The sets:

- **cwcore**: 12 fights against the Clockwork, each 3 times = 36 fights a run. Two runs of the base (72 fights).
- **cwcore at 1.5**: the same, with the Clockwork bringing one and a half times the Crown's value (`ratio:1.5`), to see
  the parts in close fights.
- **cwreal**: 8 fights with the real armies, both sides' late research, 3 in 10 Musketeers with no powder.
- **crcore**: 6 mirror fights (open, home, side; sizes s, m, l), each 3 times = 18 fights a run, four runs of the base.
- **crreal**: 6 mirror fights with the real armies, late research, 3 in 10 Musketeers dry on both sides.

The score of a fight is the share of the Crown army left minus the share of the enemy army left (hit points counted):
plus 1 a clean Crown win, minus 1 a clean loss. "k/l" is the value killed for each value lost.

## How the Crown fights now (the parts off)

| set | fights | score | k/l | Crown won |
|---|---|---|---|---|
| against the Clockwork, equal value (cwcore) | 72 | +0.59 | 2.84 | 71 |
| against the Clockwork, 1.5 times our value | 72 | +0.23 | 2.14 | 53 |
| against the Clockwork, real armies (cwreal) | 24 | +0.49 | 2.13 | 24 |
| the mirror (crcore) | 72 | +0.20 | 1.35 | 52 |
| the mirror, real armies (crreal) | 18 | +0.17 | 1.31 | 12 |

**Against the Clockwork the Crown already wins almost every fair fight, and two of three fights against one and a half
times its value.** It kills more than twice what it loses. The real games say the same (below: in the fights of the 10
"off" games it killed 2.3 for each 1 it lost).

**In the mirror** the two sides fight the same code, so about even is what we want. The +0.20 is the bench's own lean:
our wave marches while theirs comes at us (the side that is met while marching is a little ahead). Only the difference
the parts make counts there.

## The films: the mistakes found

I filmed bench fights (`shots:`); pictures in `docs/shots/crown_micro_2/`.

Against the Clockwork:

1. **The guns are left behind.** The Field Cannons come up limbered, far behind the Musketeers, and set late or never.
   Against the Clockwork the guns' coaching is cut (the crown-rule-cleanup job, see below), so nothing holds the men for
   the guns.
2. **The wave splits round an obstacle** (the plateau in Greenhold's middle) and each half fights alone.
3. **No line forms.** The Musketeers meet the Clock Soldiers in clumps of 4 to 10. Against the Clockwork the line is cut
   too.
4. **The riders ride into the Pendulums.** A Pendulum's sweep cuts every rider in its arc.
5. **The Musketeers stand while a slow machine walks up** (a Pendulum, or a run-down Clock Soldier).
6. **The Winders mend the army behind its line** and nobody shoots at them first.
7. **Raised shields**: Musketeers keep shooting into the front of a Clock Soldier's SHIELD FORWARD.

In the mirror:

8. **The two lines walk onto the high ground in the middle** in a column up the ramp, and fight there out of their guns'
   reach (our guns set far back).
9. **Both sides' guns duel nobody**: they shoot the nearest man, not the guns that shell their line.

What was not a mistake: against Swifts the Crown's riders have nothing to do (Swifts only fight flyers), and against the
Netter's net there is nothing for the men to do but fight on.

## Each part, measured

### Against the Clockwork

Each part alone against the base. "t" says how far the change is beyond the noise: under 1 it is noise, about 2 is a real
change. Rows with 72 fights pool the equal-value set and the 1.5 set.

@@CWTABLE@@

### The rules the cleanup cut against the Clockwork

The crown-rule-cleanup job cut the Crown's whole fight group against the Clockwork (the line, the guns' coaching, the rider
screen, the cavalry micro, the defence), because in real games it measured as harm. On the bench, in the fights, they are
the biggest gains of all:

@@CUTTABLE@@

So the line and the riders' hit and run make the Crown fight much better against the Clockwork. The cleanup's reading
was that they cost in the whole game (the army held at home in formations, posts and musters) though they win the fights.
To test that, I wrote one more part, **fieldline**: the line only on the march (it forms before a seen enemy, steps on
with its guns, falls back in order: `AICrownLine.march`), not the defence's lines and posts at home, not the screen.
On the bench it gains almost all the line's gain (above). The real games tell whether it costs in the whole game.

### In the mirror

@@CRTABLE@@

## What was kept

@@KEPT@@

## Real games

@@REAL@@

## The verdict, matchup by matchup

@@VERDICT@@

## Claude's choices

@@CHOICES@@

## How to run it

```
godot --headless --fixed-fps 30 --path . --script res://tools/bench_crown_micro.gd -- set:cwcore runs:3 out:/abs/a.json cmic:off
godot ... -- set:cwcore runs:3 ratio:1.5 cmicgunpick:on          (one part, the Clockwork bringing 1.5 times the value)
godot ... -- set:cwreal runs:3 tech:1 dry:0.3 wind:0.6             (real armies; wind: the lowest wind drawn)
godot ... -- set:crcore runs:3 seed:50                            (the mirror)
tools/study/crown_micro_2_arms.sh queue.txt 2                     (arms from a queue file: NAME SET RUNS switches...)
python3 tools/study/crown_micro_2_table.py "kite=cwbase1+cwbase2:cwkite;cw15base1+cw15base2:cw15kite"
python3 tools/study/crown_micro_2.py run BLOCK --opp clockwork|crown [--extra a,b] [--jobs 2]
python3 tools/study/crown_micro_2.py results|report|fights BLOCK ... --opp clockwork|crown
```

Data: the bench arms in `docs/crown_micro_2/bench/` (README there), the real games in `docs/crown_micro_2/data/<opp>/`.
