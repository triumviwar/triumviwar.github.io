# Crown micro 2: the Crown computer's fighting against the Clockwork and in the mirror

Job crown-micro-2, branch `crown-micro-2`, based on main after the crown-micro job merged (0.38.210).
The owner, 2026-11-25: "micro training the AI... it's only fair to make this testing to all matchups, not only Crown vs Brood."

No unit or balance number was changed. Only how the Crown computer's men fight once a fight is on. No macro.

## The short answer

**Against the Clockwork the Crown's edge is its fighting. In the mirror the side that fights better wins, and the
parts make the Crown fight better.** Against the Brood (crown-micro) the gap is the economy.

- **Against the Clockwork** the Crown computer already wins almost every fair fight (71 of 72 at equal value, killing 2.8
  times what it loses; two in three against 1.5 times its value), and in real games it already won or led 9 of 10 at
  20:00 while earning a little less than the Clockwork. Five parts are now on against the Clockwork:

  | part | what the Crown's men now do |
  |---|---|
  | gunpick | the Field Cannons aim at the armoured machines (Springers, Pendulums, Ballistas, Netters) |
  | kite | a reloading Musketeer steps back from a slow machine (a Pendulum, a run-down Clock Soldier) |
  | hurt | a badly hurt Musketeer steps back behind his friends |
  | winders (new) | Musketeers shoot a Winder first when one is in reach (the Winders wind and mend the army) |
  | fieldline (new) | a marching wave forms its line before the Clockwork army it sees and steps on with its guns set (the line on the march only; its home lines stay cut) |

  On the bench they win the close fights much better (with the Clockwork at 1.5 times the value: +0.31, t 5.9). In real
  games the Crown now sometimes wins outright (2 or 3 of 10, none before) and trades its fights better.

- **In the mirror** two parts are on: **brace** (a marching wave halts and sets its guns when the enemy wave comes at
  it) and **gunpick** (the guns aim at the thickest clump and the armoured men). On the bench +0.09 (t 1.5); in 10 real
  games against the old Crown it won or led 7 and lost 1 (the old against the old: 4 and 3).

No unit or balance number changed.

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

Hooks in other files, one line each: `AICrownLine.field()` and its use in `AICrownLine.march` and `AICrown._cohesion` (the
line runs on the march where the cleanup cut it, when the micro's fieldline is on). The bench's `killed` and `lost` against
the Clockwork and the Crown are the two armies' own value gone, hit points counted (the enemy computer's base and the Winders'
mending are no part of the fight); against the Brood they are as in crown-micro.

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

| part | fights | score | change | t | k/l | won |
|---|---|---|---|---|---|---|
| riders | 36 | +0.58 | -0.007 | -0.16 | 2.71 | 35 |
| brace | 36 | +0.59 | -0.005 | -0.12 | 2.84 | 35 |
| kite | 72 | +0.45 | +0.041 | +1.03 | 2.61 | 64 |
| gunpick | 72 | +0.45 | +0.043 | +1.01 | 2.62 | 62 |
| hurt | 72 | +0.45 | +0.043 | +1.02 | 2.64 | 64 |
| winders (new) | 72 | +0.43 | +0.023 | +0.55 | 2.53 | 62 |
| canister | 36 | +0.58 | -0.010 | -0.24 | 2.71 | 35 |
| focus | 36 | +0.58 | -0.008 | -0.18 | 2.84 | 35 |
| backline (new) | 36 | +0.58 | -0.008 | -0.16 | 2.80 | 34 |
| counter (new) | 36 | +0.58 | -0.007 | -0.15 | 2.81 | 35 |
| shields (new) | 36 | +0.57 | -0.016 | -0.36 | 2.69 | 35 |
| fieldline (new) | 108 | +0.66 | +0.185 | +6.52 | 4.02 | 107 |

What each means:

- **gunpick, kite, hurt** help a little each, at equal value and more in the close fights (1.5 times): the round shot goes
  for the armoured machines (Springers, Pendulums, Ballistas, Netters), Musketeers step back from the slow Pendulum and
  from run-down Clock Soldiers, a hurt Musketeer steps back behind his friends. (Against the Brood "hurt" did not help: a
  Raptor follows. A Clock Soldier is slower when its wind is low, and the Pendulum is slow.)
- **winders** (new) helps a little: Musketeers shoot the Winders first when one is in reach, so the army behind the front
  stops being mended and wound.
- **riders, brace** do nothing here: against the Clockwork the rider screen is cut, so the riders are rarely out of the
  fight (7 rides in 36 fights), and the Clockwork army walks in slowly, so the brace seldom has time to fire (12 times).
- **canister, focus, backline, counter, shields** (the last three new) do nothing or a little harm. The riders sent at the
  back line (95 rides) die to the Clock Soldiers round it; the guns' duel with the Ballistas wastes shots the Clock
  Soldiers in front should get; Musketeers leaving a shielded Clock Soldier for another one lose time.
- **fieldline** (new) is the big one: see the next table.

### The rules the cleanup cut against the Clockwork

The crown-rule-cleanup job cut the Crown's whole fight group against the Clockwork (the line, the guns' coaching, the rider
screen, the cavalry micro, the defence), because in real games it measured as harm. On the bench, in the fights, they are
the biggest gains of all:

| rule | fights | score | change | t | k/l | won |
|---|---|---|---|---|---|---|
| the line (crcline:on) | 72 | +0.59 | +0.182 | +5.46 | 3.60 | 71 |
| the cavalry micro (crccavmicro:on) | 72 | +0.53 | +0.125 | +3.33 | 3.20 | 67 |
| the guns' coaching (crcgunscoach:on) | 36 | +0.59 | -0.004 | -0.08 | 2.80 | 35 |
| the line and the screen | 36 | +0.80 | +0.209 | +6.72 | 5.32 | 36 |
| fieldline (the line on the march only) | 108 | +0.66 | +0.185 | +6.52 | 4.02 | 107 |

So the line and the riders' hit and run make the Crown fight much better against the Clockwork. The cleanup's reading
was that they cost in the whole game (the army held at home in formations, posts and musters) though they win the fights.
To test that, I wrote one more part, **fieldline**: the line only on the march (it forms before a seen enemy, steps on
with its guns, falls back in order: `AICrownLine.march`), not the defence's lines and posts at home, not the screen.
On the bench it gains almost all the line's gain (above). The real games tell whether it costs in the whole game.

### In the mirror

| part | fights | score | change | t | k/l | won |
|---|---|---|---|---|---|---|
| riders | 18 | +0.14 | -0.067 | -0.82 | 1.28 | 12 |
| brace | 36 | +0.23 | +0.029 | +0.45 | 1.41 | 26 |
| kite | 18 | +0.11 | -0.093 | -1.07 | 1.17 | 10 |
| gunpick | 36 | +0.21 | +0.011 | +0.17 | 1.37 | 27 |
| canister | 18 | +0.10 | -0.102 | -1.13 | 1.13 | 14 |
| hurt | 18 | +0.08 | -0.126 | -1.76 | 1.09 | 11 |
| focus | 18 | +0.12 | -0.083 | -1.13 | 1.24 | 11 |
| backline (new) | 18 | +0.17 | -0.033 | -0.53 | 1.34 | 13 |
| winders (new) | 18 | +0.14 | -0.064 | -0.71 | 1.29 | 14 |
| counter (new) | 18 | +0.09 | -0.115 | -1.40 | 1.08 | 11 |
| brace and gunpick together | 72 | +0.29 | +0.086 | +1.54 | 1.68 | 57 |

The mirror is noisy (the same code on both sides, and few fights). Alone, only brace and gunpick lean the right way;
together they gain +0.09 (t 1.5), the two working together: the brace halts our wave when their wave comes at it, so our
guns set, and gunpick turns the guns onto the thickest clump and the armoured men. Everything else leans to harm in the
mirror: the riders and the backline riders ride into the enemy's line and guns; the counter-battery leaves the enemy's
Musketeers alone; kite and hurt step men out of a fire fight where every musket counts.

## What was kept

`AICrownMicro.KEPT_BY` now lists the parts by the enemy (Normal and up). The Brood's four are unchanged.

| enemy | parts on by default |
|---|---|
| the Brood | riders, brace, kite, gunpick (the crown-micro job) |
| the Clockwork | gunpick, kite, hurt, winders |
| the Crown (the mirror) | brace, gunpick |

Together, on the bench:

| set | fights | score | change | t | k/l | won |
|---|---|---|---|---|---|---|
| the four kept, equal value | 72 | +0.63 | +0.042 | +1.22 | 3.25 | 71 |
| the four kept, 1.5 times | 36 | +0.29 | +0.057 | +0.79 | 2.37 | 26 |
| the four kept, both | 108 | +0.52 | +0.047 | +1.41 | 2.82 | 97 |
| the four kept, real armies | 24 | +0.57 | +0.077 | +1.49 | 2.55 | 24 |
| the four kept and fieldline, equal value | 36 | +0.73 | +0.141 | +3.84 | 4.83 | 36 |
| the four kept and fieldline, 1.5 times | 36 | +0.54 | +0.307 | +5.92 | 3.66 | 35 |
| fieldline alone, real armies | 24 | +0.68 | +0.190 | +4.08 | 3.77 | 24 |

Plus, in the mirror, brace and gunpick together: +0.09 (t 1.5) over 72 fights (the table above), and on the mirror's
real armies +0.10 (36 fights, t 1.4: +0.25 against +0.15).

The parts not kept stay written and switchable (`-- cmic<name>:on`). **fieldline is kept against the Clockwork** (on by default there since the field1 real games showed it
does not cost in the whole game, see below). The line's own switch (`crcline`) stays cut against the Clockwork: fieldline is
only its march.

## Real games

The same 10 games as the earlier Crown studies (Hard OPTIMAL against Hard OPTIMAL, to 20:00, the six parity maps, the
same seeds and start spots), played on this branch. g is the Crown's score against the enemy's as a log (income plus twice
the army; a beaten side counted a quarter): 0 even, +0.7 the Crown twice the enemy. "fights" are the fights inside the games
(the crown-guns-coach count, every fight worth 60 or more): the value our Crown killed for each value it lost.

### Against the Clockwork

| block | switches | games | won | led | even | behind | lost | mean g | g at 14:00 | income 8:00 / 12:00 | fights: killed for each lost |
|---|---|---|---|---|---|---|---|---|---|---|---|
| off1 | `cmic:off` (the Crown as before) | 10 | 0 | 9 | 0 | 1 | 0 | +0.39 | +0.01 | 0.94 / 0.96 | 2.28 (81 fights) |
| on1 | gunpick, kite, hurt, winders | 10 | 3 | 3 | 3 | 1 | 0 | +0.77 | +0.14 | 0.91 / 0.96 | 2.68 (83 fights) |
| field1 | the same and fieldline (today's default) | 10 | 2 | 7 | 1 | 0 | 0 | +0.71 | +0.18 | 0.94 / 1.00 | 2.50 (75 fights) |
Paired game by game against off1: on1 +0.37 (t 1.2), 4 better / 4 worse; field1 +0.31 (t 1.3), 6 better / 4 worse, and at
14:00 +0.17 (t 1.5).

In plain words:

1. **The Crown already beats the Clockwork computer.** Without any of this it won or led 9 of 10 games at 20:00, though it
   earned a little less (0.94 of the Clockwork's income at 8:00). It wins the fights: 2.3 killed for each 1 lost.
2. **With the parts it wins outright now and then** (3 and 2 games won, none before) and trades better in the fights
   (2.7 and 2.5). The mean is better by about a third of a point; with 10 games a block that is not beyond the noise.
3. **fieldline did not cost in the whole game.** The crown-rule-cleanup had found the full line stack (with the home lines,
   the musters, the screen) harmful against the Clockwork. The line on the march alone formed 16 times in the 10 games, and
   the block is as good as on1 (9 of 10 won or led, none behind).

### The mirror

Our Crown with the block's switches, the other Crown held to the old fighting (`cmicoff`).

| block | switches | games | won | led | even | behind | lost | mean g | g at 14:00 | income 8:00 / 12:00 | fights: killed for each lost |
|---|---|---|---|---|---|---|---|---|---|---|---|
| off1 | `cmic:off` on both sides | 10 | 4 | 0 | 1 | 2 | 3 | +0.20 | +0.10 | 1.02 / 1.05 | 0.90 (72 fights) |
| on1 | brace, gunpick (ours only) | 10 | 3 | 4 | 1 | 1 | 1 | +0.70 | +0.21 | 1.01 / 1.12 | 1.24 (91 fights) |
Paired against off1: +0.50 (t 0.7), 7 better / 2 worse; at 14:00 +0.11 (t 1.0).

In plain words: with the same economy (income 1.01 of the other side's at 8:00), the Crown with brace and gunpick won or
led 7 of 10 games and lost 1, against 4 of 10 and 3 lost when both fought the old way. It traded its fights at 1.24 where
it had 0.90. One block is not proof (the mirror's games swing hard: g of +2.4 or -2.2 when one side is beaten), but every
measure leans the same way.

AI tests run on this branch: `test_crown_line` ALL PASS, `test_crown_defence` ALL PASS, `test_cav_micro` ALL PASS (its
"_foe in StubAI" script errors come from the cleanup's `AICrownRules.cut` in its stub, not from this job).

## The verdict, matchup by matchup

- **Crown against the Clockwork: the edge is the FIGHTING.** The Crown earns a little less than the Clockwork (0.94 of
  its income at 8:00, 0.96 at 12:00 in the games before this job) and still leads by 20:00 in 9 games of 10, because it
  wins its fights by more than 2 to 1. On the bench it beats one and a half times its value of Clockwork two times in
  three. Its economy is behind; its fighting more than makes up for it. If the matchup is ever to be closer, it is the
  Crown's fighting (or the Clockwork's) that moves it, not the economy. The fight rules the cleanup cut (the line, the
  riders' hit and run) would make the Crown fight even better: their cost in the whole game, when it showed, was the
  army held at home, not the fighting.
- **The mirror: the FIGHTING decides.** Both sides have the same economy by construction (1.01 at 8:00), so whoever fights
  better wins: the parts alone turned 4 won-or-led of 10 into 7 of 10. The mirror is the matchup where micro matters most.
- **Crown against the Brood (crown-micro, for the full picture): the gap is the ECONOMY.** The Crown wins fair fights
  against the Brood too (22 of 24 before, 24 of 24 after crown-micro), but the Brood out-earns it from about 10:00 and
  fields the bigger army.

So: the Crown computer's fighting is good in all three matchups. Where it loses (the Brood) it loses on the economy;
where it wins (the Clockwork) it wins on the fighting.

## Claude's choices

1. **The bench's Clockwork is not the Clockwork computer.** Its army attack-moves, as the Brood's did in crown-micro. I
   kept the pieces of the Clockwork computer that act inside a fight: the Springers' jump out of a melee (it needs a
   computer on its side: the bench keeps the Clockwork computer in the list but stops it), SHIELD FORWARD by its own rule
   (`ShieldWall.think`), the Winders escorting the army (the player's own escort order, as the computer's Winders follow
   its army). Its retreat when outnumbered and its mending trips home are left out.
2. **The machines' wind is drawn between 60% and full** at the start of a bench fight, and runs down from there. In real
   games the army is often wound by its Winders on the march; 60% is a guess at the worst a computer army brings.
3. **Winders count in the Clockwork's value** (one for every 8 machines). They are part of what it brings to a fight.
4. **In the mirror the enemy is the Crown computer with all its old fight code**, only the new micro parts off
   (`AICrownMicro.off_team`). So the mirror bench and the mirror games measure the parts against the Crown as it was.
5. **Pooled over two sizes of fight.** Against the Clockwork the Crown wins almost every equal fight, so the parts were
   also measured with the Clockwork bringing 1.5 times the value, where fights are close and a part can show. A part kept
   had to lean the right way in both.
6. **Kept four small parts against the Clockwork** (gunpick, kite, hurt, winders) though alone each is only about t 1
   pooled; together +0.05 (t 1.4) on the core fights and +0.08 (t 1.5) on the real armies, and none measured harmful.
7. **fieldline kept on against the Clockwork** though the cleanup cut the whole line there. On the bench it is the
   biggest gain of all (about +0.19, t 6.5); in the real games it did not cost (field1: 9 of 10 won or led, 2 won, none
   behind, against 9 of 10 and none won for the Crown as before). Its home lines and the rider screen stay cut. If the
   owner prefers the cleanup's stack exactly, `-- cmicfieldline:off`.
8. **Only brace and gunpick in the mirror**: alone each is noise; together +0.09 (t 1.5) and +0.10 on the real armies.
   Everything else leaned to harm there.
9. **The riders' hit and run (`cavmicro`) stays cut against the Clockwork** although on the bench it gains +0.13 (t 3.3):
   it is not one of the micro's parts, it is the cleanup's rule, and I had no real games left to measure it alone. It is
   the next thing to try (`-- crccavmicro:on`).
10. **The cut rules were measured on the bench with `cmic:off`**, against the same base, to see their fighting worth only.

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
