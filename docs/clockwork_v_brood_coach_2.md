# Clockwork v Brood, coached again (job clockwork-v-brood-coach-2)

Short sentences, to be read aloud.

The owner (2026-11-15 22:20 and 2026-11-16 07:07): coach the Clockwork computer against the Brood, in depth. Watch films,
find the real mistakes, fix them, measure. The finding that started it (docs/winrate_2026_11_15.md, "Brood v Clockwork" and
proposal K1): on 0.38.14 the Brood computer beat the Clockwork computer 26-6-6 (won or led 29 of 38).

Only the CLOCKWORK computer's decisions changed. No unit, price or rule number changed. Every change is in
scripts/ai_cw_brood.gd (AICwBrood) with a one-line hook where it acts, acts only for a Clockwork computer whose enemy is
the Brood, and has its own switch; `-- cvb2:off` turns them all off.

<!-- SUMMARY -->

## How it was watched

- `tools/cw_trace.gd` (new, a measuring tool): tools/qa_match.gd's match plus a line every 5 s for each Clockwork
  computer: cogs, what its written build puts by, Winders and their goal, the build's next step, the rush reaction, the
  swarm count, the army's kinds, the Clocktowers' and Works' queues, the push's phase; and a line for every Winder that
  dies: where (how far from its nearest building and its nearest armed unit) and what it was doing.
- `tools/film_coach.gd shots:1` under xvfb-run: the camera pictures (armies, bases, fights) and a map every 15 s.
- `scripts/game.gd` death log (measuring tools only): each death now also keeps the cell and the unit's order.
- `tools/study/cvb2.py`: the 38 Brood v Clockwork games of the win-rate studies (tools/study/qa_matches.py base(), the
  same tags, seeds and seats), to 12:00, and the report from the Clockwork's side.
- Pictures: `docs/shots/clockwork_v_brood_coach_2/` (jpg, 640 wide; before_ = main at 0.38.35, after_ = this branch).

## What was wrong (films and traces on main, 0.38.35)

The first film (Greenhold, seed 1102, the Brood P1, the Clockwork P2; `before_g1102_*`) went like the study's games: the
Clockwork lost every building by 10:13. Its trace and the 38 games of the study said the same things.

### 1. The read: the Brood's first turtle is no greed (K1)

Every Brood plan roots a Mound Turtle on new ground at 0:00. The Clockwork's scout saw it at ~2:00 and read "a second
base and little army" (GREEDY) in 38 of 38 games, and picked the Clock Soldier rush. The trace (headless, the same seed):
at 2:05 the rush plan cut the Winders' goal from 15 to 11-12 and laid a second Light Works; the Winders stood at 14 for a
minute and 400-570 cogs lay unspent at 2:45-3:00 while one Works trained one soldier at a time. The Brood's own rush (its
Raptors at ~2:50, 250 against 0-70) came first, and at ~3:20 the Clockwork read AGGRESSIVE and switched to Balanced (35
of 38). The rush it picked did nothing but cost it its Winders' minute.

Picture: `before_g1102_0400_raptor_rush_at_the_main_ramp.jpg` (the Raptors at its main's ramp at 4:00, the press by it
"WINDERS 0/5").

### 2. The rush reaction starved the Winders

The written opening's RUSH REACTION (BuildsEco.urgent: a Light Works and up to 8 Clock Soldiers, "first, then the
economy goes on") runs before the Winders on every think for as long as the written build runs, and it REPLACES every
soldier that dies. Against the Brood the soldiers kept dying (Raptors), so the economy never went on: in the film the
Winders fell from 14 to 9 in the rush (4:15) and stayed at 9 until 7:00 with the cogs at 0-60 all the time, every cog going
to Clock Soldiers; the Brood had 34 grubs at 6:00. Income: 600 cogs a minute at 3:00, 250 at 5:00-7:00.

Pictures: `before_g1102_0600_main_winders_short.jpg` (its main at 6:00: "WINDERS 0/5" and "2/5" at its presses),
`before_g1102_0630_eight_soldiers_one_press.jpg` (the second Clocktower at 6:30: one press, eight Clock Soldiers),
`before_g1102_0645_the_wave_comes.jpg` (the Brood's wave of 25 Raptors at 6:45; at 7:00 the army was 0).

### 3. The Brass Serpent before the Pendulums

Its swarm answer said "a Heavy Works, Pendulums and another turret" (38 of 38 games), but the Heavy Works' first unit was a
Brass Serpent (30 of 38 games, about 50 s after the yard stood): OPTIMAL's Serpent rule (BrassSerpent.ai_produce) runs
before the shared production, and its gears keep the yard's queue busy. In the 38 games the Clockwork's Pendulums killed 510
Raptors for 9 Pendulums lost (its Clock Soldiers 902 for 823, its Springers 673 for 219, the Serpents 47 for 25): the
Pendulum is by far its best answer to the Raptors, and it had 0-2 of them. A traced game (the same seed, headless) had its
Heavy Works laid at 7:36 and a Serpent at 8:34 and no Pendulum at all; its push of 1,890 at 9:08 (15 Clock Soldiers, 3
Springers, 3 Netters, the Serpent) lost 1,300 for 17 Raptors.

### 4. Tension spent before the Pendulums came

A Pendulum costs 75 Tension. A small Mainspring winds 2 a second (120 a minute) and stores 200. The pool stood full (200)
from 5:00 to 7:30 with nothing to spend it on, then the Springers and Netters took it as fast as it came (8-60 in the pool
from 7:00), and the shared rule kept Tension for the yard only once the Heavy Works stood: its first Pendulum waited.

### 5. Two Clocktowers all game

The Clockwork wants a fresh hall for every 13 Winders (AI._hall_first), and its Winders are kept to its posts (two halls:
26). So with two halls it never wanted a third: the trace shows 26 Winders from 7:05 to 9:30 and the third Clocktower
only at 9:44, when "it puts its expansion off: it must answer the swarm first" (the swarm rule held it again). In the 38
games of the study the third came at a median of 8:13 in 26, never in 12; the Brood rooted new ground every minute or two.

### 6. The Escapement late, the yard later

Its written opening laid the Escapement after a second Light Works and two Regulators. With the rush reaction eating
the cogs, a traced game (with fixes 1-4 already in) laid it at 6:05 (the Heavy Works stood at 8:02, the first Pendulum came at 9:00); meanwhile the
swarm rule held the expansion "for the Heavy Works" from 6:00.

### 7. Pushes into the Brood's ground

"goes out: worth 2,590 against the 1,835 it reckons" (a traced game with fixes 1-6 in, Dune Sea 1108, 8:32): 12 Clock Soldiers, 6 Springers,
a Netter and 3 Pendulums walked onto the Brood's swamp where 47 Raptors and 11 Spitters stood (3,870 with the rooted
creatures); 30 s later it "pulls back (it has lost 1,555 of the 2,590 ...), killed 50". The Brood's eggs hatch at home and
its scout reckoning does not see them. At home, on its gears, with Pendulums and Winders mending, the same armies traded
evenly or better (Greenhold, 10:40-11:20: 2,650 lost for 3,050 killed).

### 8. Soldiers dying on plain walks

A trace with fixes 1-7 in (Frostfang 1111) showed its Clock Soldiers dying 3 to 10 every half minute from 8:00 to 10:30 with the order
"move", killing next to nothing: the army's walks to its rest spots and gathering point, defenders called back and a
push's units walking to their places are PLAIN moves (a unit on a plain move does not hit back), and the Raptors roam the
Clockwork's ground between its halls. It lost every building by 11:40.

### What was not wrong

- Its home defence against the waves (the earlier coaching's C2-C8) works: the fights on its gears trade evenly or
  better, and the counter after a held wave wins when it goes.
- Its Winders mostly die to Raptor raids on presses away from the army (5 at once at 8:51 in a trace, 64-101 px from
  their press, 221-595 px from the nearest soldier): a Winder (74) cannot outrun a Raptor (92, 124 with Pack Hunt). Fewer
  died once the army was bigger and at home (below); not changed further.
