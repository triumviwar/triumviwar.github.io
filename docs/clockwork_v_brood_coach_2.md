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

A Pendulum costs 75 Tension. A small Mainspring winds 2 a second (120 a minute) and stores 200. In the trace on main the pool
stood full (200) from 6:00 to 7:35 with nothing to spend it on, then the Netters and Springers took it as fast as it came
(13-50 in the pool from 8:30), and the shared rule kept Tension for the yard only once the Heavy Works stood: its first Pendulum waited.

### 5. Two Clocktowers all game

The Clockwork wants a fresh hall for every 13 Winders (AI._hall_first), and its Winders are kept to its posts (two halls:
26). So with two halls it never wanted a third: the trace shows 26 Winders from 7:05 to 9:30, two Clocktowers to the end (10:00), and at 9:44 "it puts its expansion
off: it must answer the swarm first" (the swarm rule held it as well). In the 38
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

## The measuring batch

`python3 tools/study/cvb2.py run OUT --data DATA [--root DIR]` for each set, `... report before after`: 38 games, the tags,
seeds and seats of tools/study/qa_matches.py base() rounds 0 and 1 (Brood v Clockwork), Hard OPTIMAL on both sides, to
12:00, on 0.38.35. "before" ran in a worktree of main (f6ac0540), "after" in a worktree of this branch (218d0c26). Won or
led: won, or led a draw (income earned + 2 x army value 10% ahead, the studies' rule). Data:
`docs/clockwork_v_brood_coach_2/before/` and `after/` (result.json with every death, its cell and order; the AI STORY),
`tables.md` (the report), `pergame.md`.

| game (map, the Clockwork's seat) | before (main) | after |
|---|---|---|
| amberfall_vale, CW P2 | BR won 10:46 | draw, CW led |
| amberfall_vale, CW P1 | draw, even | draw, CW led |
| ashfall, CW P1 | **CW won 8:25** | **CW won 10:48** |
| ashfall, CW P2 | draw, even | draw, CW led |
| ashford_crossing, CW P1 | draw, BR led | draw, CW led |
| ashford_crossing, CW P2 | BR won 9:45 | draw, CW led |
| border_march, CW P1 | draw, BR led | draw, even |
| border_march, CW P2 | draw, BR led | draw, even |
| cinder_steps, CW P2 | **CW won 11:25** | draw, CW led |
| cinder_steps, CW P1 | draw, BR led | draw, CW led |
| dune_sea, CW P2 | draw, CW led | **CW won 11:52** |
| dune_sea, CW P1 | draw, CW led | draw, CW led |
| frostfang, CW P1 | BR won 11:27 | draw, CW led |
| frostfang, CW P2 | draw, BR led | draw, CW led |
| frostmere, CW P1 | BR won 9:33 | draw, CW led |
| frostmere, CW P2 | draw, BR led | BR won 10:05 |
| glimmerdeep, CW P2 | BR won 7:32 | draw, CW led |
| glimmerdeep, CW P1 | draw, CW led | draw, even |
| greenhold, CW P2 | draw, CW led | draw, even |
| greenhold, CW P1 | **CW won 9:52** | **CW won 11:44** |
| highmoor, CW P1 | **CW won 8:17** | draw, CW led |
| highmoor, CW P2 | BR won 8:44 | draw, CW led |
| hollowfen, CW P1 | draw, CW led | **CW won 10:37** |
| hollowfen, CW P2 | draw, even | draw, CW led |
| kestrel_rise, CW P2 | draw, CW led | draw, CW led |
| kestrel_rise, CW P1 | draw, CW led | draw, CW led |
| mirewood, CW P2 | draw, BR led | draw, CW led |
| mirewood, CW P1 | draw, BR led | draw, CW led |
| red_coast, CW P2 | draw, CW led | draw, CW led |
| red_coast, CW P1 | draw, even | draw, CW led |
| redrock_canyon, CW P2 | BR won 9:52 | draw, CW led |
| redrock_canyon, CW P1 | draw, BR led | draw, CW led |
| saltmarsh_isles, CW P1 | draw, CW led | draw, CW led |
| saltmarsh_isles, CW P2 | draw, BR led | draw, CW led |
| thornwood_maze, CW P1 | draw, BR led | draw, CW led |
| thornwood_maze, CW P2 | draw, BR led | **CW won 10:56** |
| twin_fords, CW P2 | draw, BR led | draw, CW led |
| twin_fords, CW P1 | draw, CW led | draw, CW led |

## The openings measured (point 1 of the owner's list)

Which opening holds the Brood's Raptor rush (~2:50, 250 against 0-70) and earns best? Each candidate was forced on the
greedy read with `-- cvbgreedy:<plan>` and played on Greenhold, Dune Sea and Hollowfen, both seats (6 games each, to
12:00). "final" = this branch's last version (218d0c26, the after batch's own six games for Balanced); "v2" = an earlier
version of the branch (f8173c0f: rules 1-5 and the hand-over, not yet rules 6's Escapement step, 7 and 8).

| on the greedy read | games | W-D-L | won or led / lost or trailed | its units lost before 5:00 (Winders) / the Brood's | earned by 5:00 / 8:00 / 12:00 | army 8:00 / 12:00 |
|---|---|---|---|---|---|---|
| main (the Clock Soldier rush, before) | 6 | 1-5-0 | 5 / 0 | 41 (11) / 59 | 3,545 / 7,250 / 15,271 | 1,735 / 3,305 |
| **Balanced kept (rule 1), final** | 6 | **3-3-0** | **5 / 0** | 42 (26) / 42 | **3,960 / 8,598** / 16,259 | **2,442** / 3,030 |
| Economy, final | 6 | 1-5-0 | 5 / 1 | **34 (26) / 53** | 3,818 / 8,306 / **17,303** | 2,275 / **3,670** |
| Pendulums (the cw-builds-b plan), final | 6 | 0-6-0 | 4 / 2 | 45 (25) / 51 | 3,462 / 7,114 / 15,667 | 1,648 / 2,628 |
| the Clock Soldier rush, v2 | 6 | 2-4-0 | 2 / 1 | 67 (16) / 73 | 3,580 / 8,005 / 15,264 | 1,462 / 2,518 |
| Balanced kept, v2 | 6 | 1-5-0 | 3 / 2 | 54 (37) / 51 | 3,790 / 8,378 / 16,821 | 1,605 / 1,455 |

- These three maps were among the Clockwork's better ones already on main (won or led 5 of 6 there): the six games tell
  the openings apart by their losses and economy more than by results.
- The two economy openings hold the rush as well as the rush itself does (34-42 units lost before 5:00 against 41-67) and
  earn the most; the Clock Soldier rush loses the most units early (it meets the Raptors in the open) and earns least; the
  Pendulum plan is slowest of all (its written build waits for the Heavy Works).
- Balanced and Economy are close: Balanced led more games (3 wins), Economy held the rush with fewer losses and earned a
  little more by 12:00. Balanced is kept (Claude's choice 2): it is the common opening's own plan (no switch at 2:00), and
  its Light Works stands before the Raptors come.
- The punish stays for a TRUE greed (3 grounds or 5 Rootmaws seen): it was not seen in any of the 38 games (no Brood plan
  takes a third ground by 2:00).

## Claude's choices (for the owner to confirm or change)

1. **The true-greed line** (rule 1): 3 grounds or 5 Rootmaws seen, the Crown's own numbers (AIOptimal.TRUE_GREED_*).
   It never fired in the 38 games; the rush on a real greed is kept for a Brood that skips its army.
2. **Balanced, not Economy, on its usual opening** (rule 1): measured close (see the openings); Balanced kept because it
   is the common opening's own plan and its Light Works stands before the Raptors. `-- cvbgreedy:economy` plays the other.
3. **One Clocktower's Winders under a rush** (rule 2a), not all of them: the others' cogs still go to the soldiers first.
   26 Winders were lost before 5:00 in six games against 11 on main (the rush now meets fewer soldiers); they are back by
   6:00 and the economy is ahead from 5:00.
4. **The rush is over after 40 s calm** (rule 2b).
5. **6:00 and 20 Winders for the third Clocktower** (rule 4). The swarm rule may still hold it (2 games of 38).
6. **A Pendulum for every 5 soldiers, at least 2, up to 8** (rule 5) and **one Pendulum's Tension kept** (rule 5b). The
   Pendulums killed 2,167 for 48 lost in the 38 games: more of them may pay; the cap of 8 is a guess.
7. **The written opening ends once the presses and the Escapement are laid** (rule 6): what it had left (a second Light
   Works, Regulators, six soldiers) is what the shared rules do anyway.
8. **The push at 2 times the reckoning with 2 Pendulums** (rule 7); at the supply cap (within 12) it goes anyway. The
   counter after a held wave (C2, the earlier coaching) is unchanged: it is how most pushes go now.
9. **Attack-moves within 360 px of an armed enemy** (rule 8): the push's own leash (a unit led off after a rider walks
   back on a plain move, to stop chasing) is left as it was.

## What is still wrong (written up, not changed)

1. **The counter into the Brood's swamp** still loses now and then: Frostfang 1111 at 7:20 lost 990 for 25, Greenhold
   1102 at 9:09 1,550 killed for 2,065 lost. Its fights at home win; the counter's floor (C2) might want Pendulums too, or
   a goal at the Brood's outer turtles rather than its Rootmaws by the Mother.
2. **The one lost game** (Frostmere, the Clockwork P2): its army stayed at 0-270 from 3:00 to 9:00 and its Winders fell
   from 22 to 15; a replay of the seed (traced, `traces/` beside this doc is t0-t5; this one was not kept) was a draw the
   Clockwork led a little, its army small until 8:30 with one Light Works for long: a cramped main may want a look.
3. **The Brass Serpent** still comes in 35 of 38 games (median 7:50, after the Pendulums): its trades against the Raptors
   stay poor (30 kills for 9 lost); OPTIMAL's Serpent rule could skip the Brood (brass-serpent's own choices).
4. **Most games are draws at 12:00** with the Clockwork far ahead: it rarely finishes the Brood by then (5 wins). A
   15:00 batch would tell how many of the 32 draws it wins.
5. **The Winders under the rush** (choice 3): more die before 5:00 than on main.

## Tests

On this branch (a worktree at 218d0c26) every Clockwork and AI test in the job's list was run: test_ai_cw_horse_raid,
test_ai_optimal, test_clockwork_army, _builds_a, _builds_b, _eco, _home, _owls, _sounds, _springer_timing, test_cw_ai,
_air, _air_ai, _army, _builders_share, _carrier, _couple, _crate_build, _gun_rush, _heavy, _lab, _militia, _plate,
_raid_leash, _rifleman, _scout_workers, _scrapper, _siding, _storm, _tesla, _tier2, _tier3, _tier3_ai, _work_car. All pass
but these, each failing the same way on main (0.38.35, run there too) and none with a Brood in it (no rule here acts):
- test_cw_heavy ("it will not set up too far from the Line") and test_cw_militia ("it will not be sent at a target far
  from the Line"): the old Clockwork's units, the same on main (CLAUDE.md lists them as failing before).
- test_cw_tier3: 3 online checks (the guest's copy of a morph, a net, a catch), the same on main.
- test_clockwork_sounds: "the Great Winder swept a wreck" fails now and then on both (main: passed once, failed once;
  here failed twice); flaky, as CLAUDE.md says. Its match is the Clockwork against the Crown.
- test_cw_gun_rush prints a measurement (no pass/fail beyond its two set-up checks, which pass): the same on both.
(Every test ends with "Aborted" after its result: the engine's exit, the same on main.)

## Shared functions changed (for the merges)

Every rule is in the new scripts/ai_cw_brood.gd; the shared functions got one-line hooks:

| file | function | the hook |
|---|---|---|
| scripts/ai_optimal.gd | `_punish` (the Clockwork's branch) | `if f == "brood": CwBrood.greedy_pick(self, early)` before the Clock Soldier rush |
| scripts/ai_cw_eco.gd | `urgent` | `CwBrood.rush_winders(ai)` and `if CwBrood.rush_over(self): return` before the Light Works and soldiers |
| scripts/ai_clockwork.gd | `_make_plan` | `steps = CwBrood.tech_steps(self, steps)` |
| scripts/ai_clockwork.gd | `_build_up` | `if bo_on and CwBrood.hand_over(self): return` |
| scripts/ai_clockwork.gd | `_produce` | `BrassSerpent.ai_produce(self)` only `if not CwBrood.serpent_waits(self)` |
| scripts/ai.gd | `_hall_first` | `need = AICwBrood.halls_need(self, need)` in the Clockwork's branch |
| scripts/ai.gd | `_produce` (gear mode) | `swarm_p` / `pend_cap` from `AICwBrood.pend_more` / `pend_target`; `keep0 += AICwBrood.pend_keep(...)` |
| scripts/ai_cw_army.gd | `may_launch` | `if CwBrood.push_waits(ai, self, mine, rk): return false` after the counter |
| scripts/ai_cw_army.gd, ai_cw_push.gd | `_order` | `if not amove and CwBrood.amove_near(ai, u): amove = true` |
| scripts/game.gd | `on_unit_died` | the measuring tools' death log keeps the cell and the order too (null in a normal game) |

New tools: tools/cw_trace.gd, tools/study/cvb2.py. Data beside this doc: `before/`, `after/` (the 38 games each),
`openings/` (the six-game candidates), `others/` (Clockwork v Crown and the mirror, main and after), `films/` (the three
films' AI STORY, coach lines and result), `traces/` (t0 main; t1 rules 1-4; t2 + rules 5 and the hand-over; t3 + the
Escapement step; t4 + rule 7 and the Tension from the Escapement; t5 the final version), `tables.md`, `pergame.md`.
Measured on 0.38.35; main has 0.38.36 since (brood-spot-study: fair Brood starts and one think phase from the seed), merged
into this branch before its last commit.
