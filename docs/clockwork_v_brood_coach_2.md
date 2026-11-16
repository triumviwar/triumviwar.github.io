# Clockwork v Brood, coached again (job clockwork-v-brood-coach-2)

Short sentences, to be read aloud.

The owner (2026-11-15 22:20 and 2026-11-16 07:07): coach the Clockwork computer against the Brood, in depth. Watch films,
find the real mistakes, fix them, measure. The finding that started it (docs/winrate_2026_11_15.md, "Brood v Clockwork" and
proposal K1): on 0.38.14 the Brood computer beat the Clockwork computer 26-6-6 (won or led 29 of 38).

Only the CLOCKWORK computer's decisions changed. No unit, price or rule number changed. Every change is in
scripts/ai_cw_brood.gd (AICwBrood) with a one-line hook where it acts, acts only for a Clockwork computer whose enemy is
the Brood, and has its own switch; `-- cvb2:off` turns them all off.

## The short version

The 38 Brood v Clockwork games of the win-rate studies (the same maps, seeds and seats), Hard OPTIMAL on both sides, to
12:00, on 0.38.35: main ("before") against this branch ("after"). The Clockwork's view:

| | before (main) | after |
|---|---|---|
| W-D-L | 4-27-7 | **5-32-1** |
| won or led / lost or trailed / even | 14 / 20 / 4 | **33 / 1 / 4** (Fisher p 0.00001) |
| income a minute at 5:00 / 8:00 / 10:00 / 12:00 (median) | 862 / 1,419 / 1,683 / 1,711 | **1,138 / 1,670 / 2,194 / 2,386** |
| earned by 8:00 / 10:00 / 12:00, and of its bench (9,796 / 13,865 at 8:00 / 10:00) | 7,335 (0.75) / 10,576 (0.76) / 13,761 | **8,348 (0.85) / 12,284 (0.89) / 17,122** |
| army at 5:00 / 8:00 / 10:00 / 12:00 | 665 / 1,555 / 1,750 / 1,930 | 280 / **2,048 / 2,578 / 3,602** |
| the Brood's army at 8:00 / 10:00 / 12:00 | 855 / 1,342 / 2,210 | 880 / 1,130 / 1,302 |
| the Brood's income a minute at 10:00 / 12:00 | 1,952 / 1,949 | 1,730 / 1,480 |
| built Clocktowers lost a game | 0.66 | **0.05** |
| Winders lost 6:00-11:00 a game | 12.45 | **4.24** |
| Raptors and others killed by its Pendulums (all 38 games) | 346 (14 Pendulums lost) | **2,167** (48 lost) |
| Heavy Works laid (median) / third Clocktower (median) / first push | 6:23 in 30 / 8:03 in 30 / 4:24 | **5:13 in 38 / 6:06 in 37** / 9:05 |
| the Clock Soldier rush picked | 38 of 38 (1:52) | 0 |

- The Clockwork no longer loses this matchup: it won or led 33 of 38 and lost 1 (Frostmere, the Clockwork P2: the Brood
  won at 10:05; on main that game was a draw the Brood led). Most games are still draws at 12:00 with the Clockwork well
  ahead; the study cut them there (the 0.38.14 study ran to 15:00 and is not the same design: on it main was 6-6-26).
- It earns about a quarter more by 12:00 and its army keeps growing through 7:00-10:00 (the "stall" is gone: 2,048 ->
  2,578 -> 3,602), while the Brood's waves break on it (the Brood's army and income fall from 10:00).
- Both seats: Clockwork P1 won or led 17 of 19 (9 before), P2 16 of 19 (5 before).
- What it gave up: a smaller army at 5:00 (280 against 665: no Clock Soldier rush) and more Winders lost in the Raptor rush
  itself (in the six measured games of the openings, 26 Winders lost before 5:00 against 11 on main); it earns them back by
  6:00.
- Its other matchups (every rule acts only against the Brood): Clockwork v Crown and the mirror, 4 games each way, the
  same side led in 3 of 4 (the fourth, a mirror on Greenhold, is a mirror's coin: P1 led on main, P2 here).

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

## What changed (scripts/ai_cw_brood.gd; every rule only for a Clockwork computer against the Brood)

| # | the rule | switch | hook |
|---|---|---|---|
| 1 | THE READ: a GREEDY read of the Brood is checked first (as the Crown's own check): 3 grounds or more, or 5 Rootmaws or more, is a true greed and the Clock Soldier rush still punishes it (before 2:30); its usual opening (the Mother and one far turtle) keeps the economy opening (Balanced: its Light Works right after the second Clocktower, two soldiers), "its first ground is its usual opening". `-- cvbgreedy:<plan>` forces a plan on that read (the study switch the openings were measured with). | `cvbread:off` | AIOptimal._punish |
| 2a | THE WINDERS UNDER A RUSH: before the rush reaction's soldiers, one Clocktower keeps a Winder in its queue while the Winders are short of the build's goal (the other Clocktowers' cogs go to the soldiers first, as before). | `cvbwind:off` | BuildsEco.urgent |
| 2b | THE RUSH IS OVER: 40 s after the rush came with no enemy at its buildings for 40 s, the reaction's soldiers are no longer replaced ahead of the build (the army's own rules make soldiers from there). | `cvbrushend:off` | BuildsEco.urgent |
| 3 | THE PENDULUMS BEFORE THE SERPENT: OPTIMAL's Brass Serpent (and its gears) waits while the Pendulums are short (rule 5's number). | `cvbserp:off` | AIClockwork._produce |
| 4 | A THIRD CLOCKTOWER ON TIME: from 6:00, with two Clocktowers standing and 20 Winders or more, it wants a third fresh hall (the rule on main wanted one for every 13 Winders, and its Winders are kept to two halls' posts). The swarm rule may still hold it while the army is clearly outmatched and has no Pendulums. | `cvbhall:off` | AI._hall_first |
| 5 | MORE PENDULUMS: a Pendulum for every 5 Clock Soldiers and Springers, at least 2, up to 8 (on main: one for every 6, up to 4, two against the Brood), made first at the Heavy Works. | `cvbpend:off` | AI._produce |
| 5b | THEIR TENSION: from the Escapement on, while Pendulums are short, one Pendulum's Tension (75) stays in the pool: the Springers and Netters take only what is above it. | `cvbtension:off` | AI._produce |
| 6 | THE YARD ON TIME: its written opening's Escapement right after the second Clocktower's two presses (before the second Light Works and the Regulator), and once the presses and the Escapement are laid the written opening hands over to the shared rules, which lay the Heavy Works by a Mainspring at once. | `cvbyard:off` | AIClockwork._make_plan, _build_up |
| 7 | THE PUSH ONLY WHEN IT WINS: a push that is not the counter after a held wave (the earlier coaching's C2, unchanged) goes only worth 2 times the enemy army it reckons, with 2 Pendulums in it; within 12 supply of its cap it goes anyway. | `cvbpush:off` | CwArmy.may_launch |
| 8 | NO PLAIN WALK PAST THE RAPTORS: an army or push order that would be a plain move is an attack-move while an armed enemy (not rooted) is within 360 px of the unit (the push's leash back from a chase stays a plain move). | `cvbamove:off` | CwArmy._order, CwPush._order |

`-- cvb2:off` turns all of them off.

## Two filmed games after, with the coach's notes

### Greenhold, seed 1102 (the Brood P1, the Clockwork P2): the first film's seed again

On main this seed was lost at 10:13 (the film above). On this branch: a draw at 12:00 with the Clockwork well ahead
(earned 17,380 against 14,462; army 3,765 against 2,600; Winders 48 against the Brood's 44 grubs).

- 2:00 "keeps Balanced: its first ground is its usual opening" (rule 1). The Brood's rush came at 2:50 as always; the
  Clockwork lost 6 Winders and 3 Clock Soldiers to it and killed 10 Raptors, then kept its Winders coming (rule 2): 23 at
  5:00 (the film on main: 9).
- 4:29 the Escapement with the new presses and the opening handed over (rule 6); the Heavy Works was laid at 5:14, the
  first Pendulum came at 7:09 (on main: none at all in its trace of this seed).
- 6:03 the third Clocktower (rule 4), 24 tiles out; at 6:00 both halls' presses were manned (`after_g1102_0600_*`).
- 5:52-8:54 it held at its gathering point five times ("against the Brood it goes out only clearly ahead", rule 7) while
  its army grew 545 -> 3,315; the Brood's waves at 8:00 and 9:00 broke on its gears (35 and 73 Raptors killed).
- 9:09 the counter after the held wave (C2) went out with 35 units: it killed 1,550 for 2,065 in the Brood's ground
  (`after_g1102_0931_counter_at_the_brood_ground.jpg`) and pulled back; the next wave (10:00) broke at home again (2,625
  killed for 1,040). Coach's note: the counter into the Brood's swamp is still its worst trade; the fights it wins are on
  its own gears.

### Frostfang, seed 1111 (the Clockwork P1, the Brood P2)

On main this seed was lost at 11:27 (the 38 games' "before"), and a trace with fixes 1-7 lost every building by 11:40
(finding 8). On this branch: a draw at 12:00 with the Clockwork far ahead (earned 17,156 against 11,440; army 4,475 against
880), its push "clearly ahead (worth 2,700 against 473): it presses on to the enemy's halls to finish the game" at 11:44.

- 3:22 the rush read, 4:04 the Escapement and the hand-over, 4:53 the Heavy Works, 6:16 the first Pendulum.
- 6:59 a Raptor wave at the natural's presses was met there by the whole army while the third Clocktower went up beside
  it (`after_f1111_0659_*`; the Winders had stepped off the presses: "WINDERS 0/5", "1/5").
- 7:20 a counter (its defence had killed 650) went into the Brood's ground with 2 Pendulums and lost 990 for 25: the
  same weak spot as above. 9:34 the next counter (its defence had killed 1,025, 3 Pendulums) broke the Brood's army
  (`after_f1111_1013_*`, Pendulums in a Mound Turtle's ring) and the push stayed out to the end (`after_f1111_1130_*`).
